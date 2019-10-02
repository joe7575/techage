--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	TA4 Solar Power DC/AC Inverter
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

local Power = techage.ElectricCable
local Solar = techage.TA4_Cable
local power = techage.power

local CYCLE_TIME = 2
local PWR_PERF = 120

local function determine_power(pos, mem)
	local time = minetest.get_timeofday() or 0
	if time < 6.00/24.00 or time > 18.00/24.00 then
		mem.ticks = 0
		mem.max_power = 0
		return
	end
	mem.ticks = mem.ticks or 0
	if (mem.ticks % 20) == 0 then -- calculate max_power not to often
		local dir = M(pos):get_int("left_dir")
		-- We have to use get_connected_node_pos, because the inverter has already
		-- a AC power connection. An additional DC power connection is not possibe,
		-- so we have to start the connection_walk on the next node.
		local pos1 = Solar:get_connected_node_pos(pos, dir)
		mem.max_power = math.min(PWR_PERF, power.get_power(pos1))
	else
		mem.max_power = mem.max_power or 0
	end
	mem.ticks = mem.ticks + 1
end

local function determine_power_now(pos, mem)
	local dir = M(pos):get_int("left_dir")
	-- We have to use get_connected_node_pos, because the inverter has already
	-- a AC power connection. An additional DC power connection is not possibe,
	-- so we have to start the connection_walk on the next node.
	local pos1 = Solar:get_connected_node_pos(pos, dir)
	mem.max_power = math.min(PWR_PERF, power.get_power(pos1))
end

local function formspec(self, pos, mem)
	determine_power_now(pos, mem)
	local max_power = mem.max_power or 0
	local delivered = mem.delivered or 0
	local bar_in = techage.power.formspec_power_bar(max_power, max_power)
	local bar_out = techage.power.formspec_power_bar(max_power, delivered)
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"label[0.2,0;DC]"..
		"image[0,0.5;1,2;"..bar_in.."]"..
		"label[0,2.5;"..max_power.." ku]"..
		"button[1.1,1;1.8,1;update;"..S("Update").."]"..
		"image_button[3,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"label[4.2,0;AC]"..
		"image[4,0.5;1,2;"..bar_out.."]"..
		"label[4,2.5;"..delivered.." ku]"
end

local function can_start(pos, mem, state)
	determine_power(pos, mem)
	return mem.max_power > 0 or "no solar power"
end

local function start_node(pos, mem, state)
	mem.running = true
	mem.delivered = 0
	mem.ticks = 0
	power.generator_start(pos, mem, mem.max_power)
end

local function stop_node(pos, mem, state)
	mem.running = false
	mem.delivered = 0
	power.generator_stop(pos, mem)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_solar_inverter",
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	formspec_func = formspec,
	infotext_name = S("TA4 Solar Inverter"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		determine_power(pos, mem)
		if mem.max_power > 0 then
			mem.delivered = power.generator_alive(pos, mem)
		else
			mem.delivered = 0
		end
	end
	return mem.running
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	State:state_button_event(pos, mem, fields)
	
	if fields.update then
		M(pos):set_string("formspec", formspec(State, pos, mem))
	end
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
end

minetest.register_node("techage:ta4_solar_inverter", {
	description = S("TA4 Solar Inverter"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_ta4_cable.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inverter.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inverter.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	after_place_node = function(pos, placer)
		local mem = tubelib2.init_mem(pos)
		local number = techage.add_node(pos, "techage:ta4_solar_inverter")
		mem.running = false
		mem.delivered = 0
		State:node_init(pos, mem, number)
		local meta = M(pos)
		-- Solar/low power cable direction
		meta:set_int("left_dir", techage.power.side_to_outdir(pos, "L"))
		meta:set_string("formspec", formspec(State, pos, mem))
	end,

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
})

techage.power.register_node({"techage:ta4_solar_inverter"}, {
	conn_sides = {"R"},
	power_network  = Power,
})

Solar:add_secondary_node_names({"techage:ta4_solar_inverter"})

techage.register_node({"techage:ta4_solar_inverter"}, {
	on_recv_message = function(pos, src, topic, payload)
		return State:on_receive_message(pos, topic, payload)
	end,
	on_node_load = function(pos)
		State:on_node_load(pos)
	end,
})	

minetest.register_craft({
	output = "techage:ta4_solar_inverter",
	recipe = {
		{'default:steel_ingot', 'dye:green', 'default:steel_ingot'},
		{'techage:ta4_power_cableS', 'techage:ta4_wlanchip', 'techage:electric_cableS'},
		{'default:steel_ingot', "techage:baborium_ingot", 'default:steel_ingot'},
	},
})

