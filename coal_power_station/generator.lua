--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA3 Power Station Generator

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local PWR_CAPA = 80

local Cable = techage.ElectricCable
local power = techage.power
local networks = techage.networks

local function formspec(self, pos, nvm)
	return "size[4,4]"..
		"box[0,-0.1;3.8,0.5;#c6e8ff]"..
		"label[1,-0.1;"..minetest.colorize( "#000000", S("Generator")).."]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		power.formspec_label_bar(pos, 0, 0.8, S("power"), PWR_CAPA, nvm.provided)..
		"image_button[2.8,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2.8,2;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function transfer_turbine(pos, topic, payload)
	return techage.transfer(pos, "L", topic, payload, nil, 
		{"techage:turbine", "techage:turbine_on"})
end

local function can_start(pos, nvm, state)
	return (nvm.firebox_trigger or 0) > 0 -- by means of firebox
end

local function start_node(pos, nvm, state)
	local outdir = M(pos):get_int("outdir")
	power.generator_start(pos, Cable, CYCLE_TIME, outdir)
	transfer_turbine(pos, "start")
	nvm.running = true
end

local function stop_node(pos, nvm, state)
	local outdir = M(pos):get_int("outdir")
	power.generator_stop(pos, Cable, outdir)
	nvm.provided = 0
	transfer_turbine(pos, "stop")
	nvm.running = false
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:generator",
	node_name_active = "techage:generator_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA3 Generator"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.firebox_trigger = (nvm.firebox_trigger or 0) - 1
	if nvm.firebox_trigger <= 0 then
		State:nopower(pos, nvm)
		stop_node(pos, nvm, State)
		transfer_turbine(pos, "stop")	
	else
		local outdir = M(pos):get_int("outdir")
		nvm.provided = power.generator_alive(pos, Cable, CYCLE_TIME, outdir)
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
	local number = techage.add_node(pos, "techage:generator")
	State:node_init(pos, nvm, number)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec(State, pos, nvm))
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, outdir, tlib2)
end

local net_def = {
	ele1 = {
		sides = {R = 1},
		ntype = "gen1",
		nominal = PWR_CAPA,
	},
}

minetest.register_node("techage:generator", {
	description = S("TA3 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png^[transformFX]",
	},
	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:generator_on", {
	description = S("TA3 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_generator4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_generator4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},
	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,

	drop = "",
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Cable:add_secondary_node_names({"techage:generator", "techage:generator_on"})

-- controlled by the turbine
techage.register_node({"techage:generator", "techage:generator_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "trigger" then
			nvm.firebox_trigger = 3
			if nvm.running then
				return math.max((nvm.provided or PWR_CAPA) / PWR_CAPA, 0.02)
			else
				return 0
			end
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "delivered" then
			return math.floor((nvm.provided or 0) + 0.5)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
})

minetest.register_craft({
	output = "techage:generator",
	recipe = {
		{"basic_materials:steel_bar", "dye:green", "default:wood"},
		{"", "basic_materials:gear_steel", "techage:electric_cableS"},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})
