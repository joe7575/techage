--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Doser

]]--

local S = techage.S
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local Pipe = techage.BiogasPipe
local liquid = techage.liquid
local recipes = techage.recipes

local Liquids = {}  -- {hash(pos) = {name = outdir},...}

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		recipes.formspec(0, 0, "ta4_doser", mem)..
		"image_button[6,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"tooltip[6,1;1,1;"..self:get_state_tooltip(mem).."]"..
		"list[current_player;main;0,3.3;8,4;]" ..
		default.get_hotbar_bg(0, 3.5)
end

local function get_liquids(pos)
	local hash = minetest.hash_node_position(pos)
	if Liquids[hash] then
		return Liquids[hash]
	end
	-- determine the available input liquids
	local tbl = {}
	for outdir = 1,4 do
		local name, num = liquid.peek(pos, outdir)
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
	
local function reactor_cmnd(pos, cmnd, payload)
	return techage.transfer(
		pos, 
		6,  -- outdir
		cmnd,  -- topic
		payload,  -- payload
		Pipe,  -- network
		{"techage:ta4_reactor_fillerpipe"})
end


local function can_start(pos, mem, state)
	-- check reactor
	local res = reactor_cmnd(pos, "check")
	if not res then
		return S("reactor defect")
	end
	res = reactor_cmnd(pos, "can_start")
	if not res then
		return S("reactor defect or no power")
	end
	return true
end

local function start_node(pos, mem, state)
	reactor_cmnd(pos, "start")
	mem.running = true
end

local function stop_node(pos, mem, state)
	reactor_cmnd(pos, "stop")
	mem.running = false
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

local function reset_dosing(mem)
	-- alle 4 ports checken und inputs vorladen
end

local function dosing(pos, mem, elapsed)
	-- trigger reactor (power)
	if not reactor_cmnd(pos, "power") then
		if not mem.techage_countdown or mem.techage_countdown < 2 then
			State:nopower(pos, mem, S("reactor has no power"))
		end
		State:idle(pos, mem)
		return
	end
	-- available liquids
	local liquids = get_liquids(pos)
	local recipe = recipes.get(mem, "ta4_doser")
	if not liquids or not recipe then return end
	-- inputs
	for _,item in pairs(recipe.input) do
		if item.name ~= "" then
			print("dosing", item.name, dump(liquids))
			local outdir = liquids[item.name]
			if not outdir then
				State:fault(pos, mem, S("input missing"))
				return
			end
			if liquid.take(pos, outdir, item.name, item.num) < item.num then
				State:fault(pos, mem, S("input missing"))
				return
			end
		end
	end
	-- output
	local leftover
	leftover = reactor_cmnd(pos, "output", {
			name = recipe.output.name, 
			amount = recipe.output.num})
	if not leftover or leftover > 0 then
		State:fault(pos, mem, S("output blocked"))
		return
	end
	if recipe.waste.name ~= "" then
		leftover = reactor_cmnd(pos, "waste", {
				name = recipe.waste.name, 
				amount = recipe.waste.num})
		if not leftover or leftover > 0 then
			State:fault(pos, mem, S("output blocked"))
			return
		end
	end
	State:keep_running(pos, mem, COUNTDOWN_TICKS)
end	

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	dosing(pos, mem, elapsed)
	return State:is_active(mem)
end	

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	local mem = tubelib2.get_mem(pos)
	if not mem.running then	
		recipes.on_receive_fields(pos, formname, fields, player)
	end
	State:state_button_event(pos, mem, fields)
	M(pos):set_string("formspec", formspec(State, pos, mem))
end


minetest.register_node("techage:ta4_doser", {
	description = S("TA4 Doser"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_pump.png^techage_appl_hole_pipe.png",
	},

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
			image = "techage_filling8_ta4.png^techage_frame8_ta4.png^techage_appl_pump8.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

-- for mechanical pipe connections
techage.power.register_node({"techage:ta4_doser", "techage:ta4_doser_on"}, {
	conn_sides = {"F", "B", "R", "L", "U"},
	power_network  = Pipe,
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		local number = techage.add_node(pos, "techage:ta4_doser")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		local node = minetest.get_node(pos)
		local indir = techage.side_to_indir("R", node.param2)
		meta:set_int("indir", indir) -- from liquid point of view
		meta:set_string("formspec", formspec(State, pos, mem))
		meta:set_string("infotext", S("TA4 Tank").." "..number)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
	end,
})

if minetest.global_exists("unified_inventory") then
	unified_inventory.register_craft_type("ta4_doser", {
		description = S("TA4 Doser"),
		icon = 'techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_pump.png^techage_appl_hole_pipe.png',
		width = 2,
		height = 2,
	})
end
