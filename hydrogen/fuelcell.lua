--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Fuel Cell

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power
local Pipe = techage.LiquidPipe
local liquid = networks.liquid
local control = networks.control

local CYCLE_TIME = 2
local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 2
local PWR_PERF = 34
local PWR_UNITS_PER_HYDROGEN_ITEM = 75
local CAPACITY = 100

local function formspec(self, pos, nvm)
	local amount = (nvm.liquid and nvm.liquid.amount) or 0
	local lqd_name = (nvm.liquid and nvm.liquid.name) or "techage:liquid"
	local arrow = "image[2,1.5;1,1;techage_form_arrow_bg.png^[transformR270]"
	if techage.is_running(nvm) then
		arrow = "image[2,1.5;1,1;techage_form_arrow_fg.png^[transformR270]"
	end
	if amount > 0 then
		lqd_name = lqd_name.." "..amount
	end
	return "size[6,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;5.8,0.5;#c6e8ff]"..
		"label[0.2,-0.1;"..minetest.colorize( "#000000", S("Fuel Cell")).."]"..
		techage.item_image(0.5,2, lqd_name)..
		arrow..
		"image_button[2,2.5;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2,2.5;1,1;"..self:get_state_tooltip(nvm).."]"..
		techage.formspec_power_bar(pos, 3.5, 0.8, S("Electricity"), nvm.provided, PWR_PERF)
end

local function has_hydrogen(nvm)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	nvm.num_pwr_units = nvm.num_pwr_units or 0
	return nvm.num_pwr_units > 0 or (nvm.liquid.amount > 0 and nvm.liquid.name == "techage:hydrogen")
end

local function can_start(pos, nvm, state)
	if has_hydrogen(nvm) then
		return true
	end
	return S("no hydrogen")
end


local function consuming(pos, nvm)
	if nvm.num_pwr_units <= 0 then
		nvm.num_pwr_units = nvm.num_pwr_units + PWR_UNITS_PER_HYDROGEN_ITEM
		nvm.liquid.amount = nvm.liquid.amount - 1
	end
	nvm.num_pwr_units = nvm.num_pwr_units - nvm.provided
end

local function start_node(pos, nvm, state)
	local meta = M(pos)
	nvm.provided = 0
	local outdir = meta:get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
	techage.evaluate_charge_termination(nvm, meta)
end

local function stop_node(pos, nvm, state)
	nvm.provided = 0
	nvm.running = nil  -- legacy
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_fuelcell",
	node_name_active = "techage:ta4_fuelcell_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA4 Fuel Cell"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local running = techage.is_running(nvm)
	local hydro = has_hydrogen(nvm)
	if running and not hydro then
		State:standby(pos, nvm, S("no hydrogen"))
		stop_node(pos, nvm, State)
	elseif not running and hydro then
		State:start(pos, nvm)
		-- start_node() is called implicit
	elseif running then
		local meta = M(pos)
		local outdir = meta:get_int("outdir")
		local tp1 = tonumber(meta:get_string("termpoint1"))
		local tp2 = tonumber(meta:get_string("termpoint2"))
		nvm.provided = power.provide_power(pos, Cable, outdir, PWR_PERF, tp1, tp2)
		local val = power.get_storage_load(pos, Cable, outdir, PWR_PERF)
		if val > 0 then
			nvm.load = val
		end
		consuming(pos, nvm)
		State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return State:is_active(nvm)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	nvm.num_pwr_units = 0
	local number = techage.add_node(pos, "techage:ta4_fuelcell")
	State:node_init(pos, nvm, number)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec(State, pos, nvm))
	Pipe:after_place_node(pos)
	Cable:after_place_node(pos)
	local inv = M(pos):get_inventory()
	inv:set_size('src', 4)
	inv:set_stack('src', 2, {name = "techage:gasoline", count = 60})
	inv:set_stack('src', 4, {name = "techage:gasoline", count = 60})
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
	Cable:after_dig_node(pos)
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
end

minetest.register_node("techage:ta4_fuelcell", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png",
	},

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		return liquid.is_empty(pos)
	end,

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_generator_data = get_generator_data,
	on_punch = liquid.on_punch,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	on_rightclick = on_rightclick,
	ta4_formspec = techage.generator_settings("ta4", PWR_PERF),

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
})

minetest.register_node("techage:ta4_fuelcell_on", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png^[transformFX",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
	},

	get_generator_data = get_generator_data,
	on_receive_fields = on_receive_fields,
	on_punch = liquid.on_punch,
	on_timer = node_timer,
	on_rightclick = on_rightclick,
	ta4_formspec = techage.generator_settings("ta4", PWR_PERF),

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	diggable = false,
	paramtype = "light",
	light_source = 6,
})

local liquid_def = {
	capa = CAPACITY,
	peek = function(pos)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local leftover = liquid.srv_put(nvm, name, amount, CAPACITY)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return leftover
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		amount, name = liquid.srv_take(nvm, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return amount, name
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local leftover = liquid.srv_put(nvm, name, amount, CAPACITY)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return leftover
	end,
}

liquid.register_nodes({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on"}, Pipe, "tank", {"L"}, liquid_def)
power.register_nodes({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on"}, Cable, "gen", {"R"})

minetest.register_alias_force("techage:ta4_fuelcell2", "techage:ta4_fuelcell")
minetest.register_alias_force("techage:ta4_fuelcell2_on", "techage:ta4_fuelcell_on")

techage.register_node({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "load" then
			return techage.power.percent(CAPACITY, (nvm.liquid and nvm.liquid.amount) or 0)
		elseif topic == "delivered" then
			return math.floor((nvm.provided or 0) + 0.5)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 134 and payload[1] == 1 then
			return 0, {techage.power.percent(CAPACITY, (nvm.liquid and nvm.liquid.amount) or 0)}
		elseif topic == 135 then
			return 0, {math.floor((nvm.provided or 0) + 0.5)}
		else
			return State:on_beduino_request_data(pos, topic, payload)
		end
	end,
})

control.register_nodes({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				local meta = M(pos)
				return {
					type = S("TA4 Fuel Cell"),
					number = meta:get_string("node_number") or "",
					running = techage.is_running(nvm) or false,
					available = PWR_PERF,
					provided = nvm.provided or 0,
					termpoint = meta:get_string("termpoint"),
				}
			end
			return false
		end,
	}
)

minetest.register_craft({
	output = "techage:ta4_fuelcell",
	recipe = {
		{'default:steel_ingot', 'dye:blue', 'default:steel_ingot'},
		{'techage:ta3_pipeS', 'techage:ta4_fuelcellstack', 'techage:electric_cableS'},
		{'default:steel_ingot', "techage:ta4_wlanchip", 'default:steel_ingot'},
	},
})
