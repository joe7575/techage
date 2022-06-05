--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Doser

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid
local recipes = techage.recipes

local Liquids = {}  -- {hash(pos) = {name = outdir},...}

local STANDBY_TICKS = 2
local COUNTDOWN_TICKS = 3
local CYCLE_TIME = 10

local function formspec(self, pos, nvm)
	return "size[6,3.6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;5.8,0.5;#c6e8ff]"..
		"label[2.5,-0.1;"..minetest.colorize( "#000000", S("Doser")).."]"..
		recipes.formspec(0.1, 0.8, "ta4_doser", nvm)..
		"image_button[5,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[5,2;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function get_liquids(pos)
	local hash = minetest.hash_node_position(pos)
	if Liquids[hash] then
		return Liquids[hash]
	end
	-- determine the available input liquids
	local tbl = {}
	for outdir = 1,4 do
		local name, num = liquid.peek(pos, Pipe, outdir)
		if name then
			tbl[name] = outdir
		end
	end
	Liquids[hash] = tbl
	return Liquids[hash]
end

local function del_liquids(pos)
	local hash = minetest.hash_node_position(pos)
	Liquids[hash] = nil
end

-- if liquids are missing, update the cached liquid table
local function reload_liquids(pos)
	local hash = minetest.hash_node_position(pos)
	-- determine the available input liquids
	local tbl = {}
	for outdir = 1,4 do
		local name, num = liquid.peek(pos, Pipe, outdir)
		if name then
			tbl[name] = outdir
		end
	end
	Liquids[hash] = tbl
	return Liquids[hash]
end

local function reactor_cmnd(pos, cmnd, payload)
	return techage.transfer(
		pos,
		6,  -- outdir
		cmnd,  -- topic
		payload,  -- payload
		Pipe,  -- network
		{"techage:ta4_reactor_fillerpipe"})
end


local function can_start(pos, nvm, state)
	-- check reactor
	local res = reactor_cmnd(pos, "check")
	if not res then
		return S("reactor defect")
	end
	res = reactor_cmnd(pos, "can_start")
	if not res then
		return S("reactor defect or no power")
	end
	local recipe = recipes.get(nvm, "ta4_doser")
	if recipe.catalyst then
		res = reactor_cmnd(pos, "catalyst")
		if not res or res == "" then
			return S("catalyst missing")
		end
		if res ~= recipe.catalyst then
			return S("wrong catalyst")
		end
	end
	return true
end

local function start_node(pos, nvm, state)
	reactor_cmnd(pos, "start")
	del_liquids(pos)
	nvm.running = true
end

local function stop_node(pos, nvm, state)
	reactor_cmnd(pos, "stop")
	nvm.running = false
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_doser",
	node_name_active = "techage:ta4_doser_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = "TA4 Doser",
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function untake(pos, taken)
	for _,item in pairs(taken) do
		liquid.untake(pos, Pipe, item.outdir, item.name, item.num)
	end
end

local function dosing(pos, nvm, elapsed)
	-- trigger reactor (power)
	if not reactor_cmnd(pos, "power") then
		if not nvm.techage_countdown or nvm.techage_countdown < 3 then
			reactor_cmnd(pos, "stop")
			State:nopower(pos, nvm, S("reactor has no power"))
			return
		end
		State:idle(pos, nvm)
		return
	end
	-- available liquids
	local liquids = get_liquids(pos)
	local recipe = recipes.get(nvm, "ta4_doser")
	if not liquids or not recipe then return end
	-- check from time to time
	nvm.check_cnt = (nvm.check_cnt or 0) + 1
	if nvm.check_cnt >= 4 then
		nvm.check_cnt = 0
		local res = reactor_cmnd(pos, "check")
		if not res then
			State:fault(pos, nvm, S("reactor defect"))
			reactor_cmnd(pos, "stop")
			return
		end
		if recipe.catalyst then
			res = reactor_cmnd(pos, "catalyst")
			if not res then
				State:fault(pos, nvm, S("catalyst missing"))
				reactor_cmnd(pos, "stop")
				return
			end
			if res ~= recipe.catalyst then
				State:fault(pos, nvm, S("wrong catalyst"))
				reactor_cmnd(pos, "stop")
				return
			end
		end
	end

	-- check leftover
	local leftover
	local mem = techage.get_mem(pos)
	if mem.waste_leftover then
		leftover = reactor_cmnd(pos, "waste", {
				name = mem.waste_leftover.name,
				amount = mem.waste_leftover.num}) or mem.waste_leftover.num
		if leftover > 0 then
			mem.waste_leftover.num = leftover
			State:blocked(pos, nvm)
			return
		end
		mem.waste_leftover = nil
	end
	if mem.output_leftover then
		leftover = reactor_cmnd(pos, "output", {
				name = mem.output_leftover.name,
				amount = mem.output_leftover.num}) or mem.output_leftover.num
		if leftover > 0 then
			mem.output_leftover.num = leftover
			State:blocked(pos, nvm)
			return
		end
		mem.output_leftover = nil
	end

	-- inputs
	local taken = {}
	mem.dbg_cycles = (mem.dbg_cycles or 0) - 1

	for _,item in pairs(recipe.input) do
		if item.name ~= "" then
			local outdir = liquids[item.name] or reload_liquids(pos)[item.name]
			if not outdir then
				State:standby(pos, nvm)
				reactor_cmnd(pos, "stop")
				untake(pos, taken)
				return
			end
			local num = liquid.take(pos, Pipe, outdir, item.name, item.num, mem.dbg_cycles > 0)
			if num < item.num then
				taken[#taken + 1] = {outdir = outdir, name = item.name, num = num}
				State:standby(pos, nvm)
				reactor_cmnd(pos, "stop")
				untake(pos, taken)
				return
			end
			taken[#taken + 1] = {outdir = outdir, name = item.name, num = item.num}
		end
	end
	-- waste
	if recipe.waste.name ~= "" then
		leftover = reactor_cmnd(pos, "waste", {
				name = recipe.waste.name,
				amount = recipe.waste.num}) or recipe.waste.num
		if leftover > 0 then
			mem.waste_leftover = {name = recipe.waste.name, num = leftover}
			mem.output_leftover = {name = recipe.output.name, num = recipe.output.num}
			State:blocked(pos, nvm)
			reactor_cmnd(pos, "stop")
			return
		end
	end
	-- output
	leftover = reactor_cmnd(pos, "output", {
			name = recipe.output.name,
			amount = recipe.output.num}) or recipe.output.num
	if leftover > 0 then
		mem.output_leftover = {name = recipe.output.name, num = leftover}
		State:blocked(pos, nvm)
		reactor_cmnd(pos, "stop")
		return
	end
	State:keep_running(pos, nvm, COUNTDOWN_TICKS)
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	dosing(pos, nvm, elapsed)
	return State:is_active(nvm)
end

local function on_rightclick(pos)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local nvm = techage.get_nvm(pos)
	if not nvm.running then
		recipes.on_receive_fields(pos, formname, fields, player)
	end
	local mem = techage.get_mem(pos)
	mem.dbg_cycles = 5
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

minetest.register_node("techage:ta4_doser", {
	description = S("TA4 Doser"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_pump_up.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local number = techage.add_node(pos, "techage:ta4_doser")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec(State, pos, nvm))
		meta:set_string("infotext", S("TA4 Doser").." "..number)
		State:node_init(pos, nvm, number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos, dir, tlib2, node)
		del_liquids(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		Pipe:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_doser_on", {
	description = S("TA4 Doser"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		{
			image = "techage_filling8_ta4.png^techage_frame8_ta4.png^techage_appl_pump_up8.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},

	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos, dir, tlib2, node)
		del_liquids(pos)
	end,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta4_doser", "techage:ta4_doser_on"}, Pipe, "pump", nil, {})

techage.register_node({"techage:ta4_doser", "techage:ta4_doser_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		return State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return State:on_beduino_request_data(pos, topic, payload)
	end,
})

techage.recipes.register_craft_type("ta4_doser", {
	description = S("TA4 Reactor"),
	icon = 'techage_reactor_filler_plan.png',
	width = 2,
	height = 2,
})

minetest.register_craft({
	output = "techage:ta4_doser",
	recipe = {
		{"", "techage:ta3_pipeS", ""},
		{"techage:ta3_pipeS", "techage:t4_pump", "techage:ta3_pipeS"},
		{"", "techage:ta4_wlanchip", ""},
	},
})
