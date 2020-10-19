--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA4 Water Pump
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = techage.power
local Pipe = techage.LiquidPipe
local liquid = techage.liquid
local networks = techage.networks

local CYCLE_TIME = 4
local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 3
local PWR_NEEDED = 4

local function formspec(self, pos, nvm)
	return "size[3,2]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;2.8,0.5;#c6e8ff]"..
		"label[0.5,-0.1;"..minetest.colorize( "#000000", S("Water Pump")).."]"..
		"image_button[1,1;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[1,1;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function can_start(pos, nvm, state)
	local outdir = M(pos):get_int("waterdir")
	local pos1 = vector.add(pos, tubelib2.Dir6dToVector[outdir or 0])
	if not techage.is_ocean(pos1) then
		return S("no usable water")
	end
	if not power.power_available(pos, Cable) then
		return S("no power")
	end
	return true
end

local function start_node(pos, nvm, state)
	power.consumer_start(pos, Cable, CYCLE_TIME)
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	power.consumer_stop(pos, Cable)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:t4_waterpump",
	infotext_name = S("TA4 Water Pump"),
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function on_power(pos)
	local nvm = techage.get_nvm(pos)
	State:start(pos, nvm)
	nvm.running = true
end

local function on_nopower(pos)
	local nvm = techage.get_nvm(pos)
	State:nopower(pos, nvm)
	nvm.running = false
end

local function pumping(pos, nvm)
	if techage.needs_power(nvm) then
		power.consumer_alive(pos, Cable, CYCLE_TIME)
	end
	if nvm.running then
		local leftover = liquid.put(pos, 6, "techage:water", 1)
		if leftover and leftover > 0 then
			State:blocked(pos, nvm)
			return
		end
		State:keep_running(pos, nvm, COUNTDOWN_TICKS)
		return
	end
end

-- converts power into hydrogen
local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	pumping(pos, nvm)
	return State:is_active(nvm)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	nvm.running = false
	local number = techage.add_node(pos, "techage:t4_waterpump")
	State:node_init(pos, nvm, number)
	M(pos):set_int("waterdir", networks.side_to_outdir(pos, "R"))
	Pipe:after_place_node(pos)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
	Cable:after_dig_node(pos)
	liquid.after_dig_pump(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	if tlib2.tube_type == "pipe2" then
		liquid.update_network(pos, outdir, tlib2)
	else
		power.update_network(pos, outdir, tlib2)
	end
end

local netw_def = {
	pipe2 = {
		sides = {U = 1}, -- Pipe connection sides
		ntype = "pump",
	},
	ele1 = {
		sides = {L = 1}, -- Cable connection sides
		ntype = "con1",
		on_power = on_power,
		on_nopower = on_nopower,
		nominal = PWR_NEEDED,
	},
}

minetest.register_node("techage:t4_waterpump", {
	description = S("TA4 Water Pump"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_waterpump_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = netw_def,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
})

Cable:add_secondary_node_names({"techage:t4_waterpump"})
Pipe:add_secondary_node_names({"techage:t4_waterpump"})

techage.register_node({"techage:t4_waterpump"}, {
	on_recv_message = function(pos, src, topic, payload)
		return State:on_receive_message(pos, topic, payload)
	end,
})	

minetest.register_craft({
	output = "techage:t4_waterpump",
	recipe = {
		{"", "default:mese_crystal", ""},
		{"", "techage:ta3_liquidsampler_pas", ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})

