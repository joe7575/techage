--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Power Station Generator

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 8
local POWER_CAPACITY = 50

local Cable = techage.ElectricCable
local generator = techage.generator

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[6,0.5;1,2;"..generator.formspec_level(mem, mem.power_result)..
		"image_button[5,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"button[2,1.5;2,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function start_turbine(pos, on, mem)
	if not on then
		if mem.handle then
			minetest.sound_stop(mem.handle)
			mem.handle = nil
		end
	end
	local pos2 = techage.get_pos(pos, 'L')
	local trd = TRD(pos2)
	if trd and trd.start_turbine then
		return trd.start_turbine(pos2, on, mem)
	end
	return false
end

local function can_start(pos, mem, state)
	return start_turbine(pos, true, mem)
end

local function play_sound(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.techage_state == techage.RUNNING then
		mem.handle = minetest.sound_play("techage_turbine", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 15})
		minetest.after(2, play_sound, pos)
	end
end

local function start_node(pos, mem, state)
	generator.turn_power_on(pos, POWER_CAPACITY)
	mem.techage_state = techage.RUNNING
	play_sound(pos)
end

local function stop_node(pos, mem, state)
	mem.techage_state = techage.STOPPED
	start_turbine(pos, false, mem)
	generator.turn_power_on(pos, 0)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:generator",
	node_name_active = "techage:generator_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function distibuting(pos, mem)
	if mem.power_result > 0 then
		State:keep_running(pos, mem, COUNTDOWN_TICKS)
	else
		State:fault(pos, mem)	
		start_turbine(pos, false, mem)
		generator.turn_power_on(pos, 0)
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local pos2 = techage.get_pos(pos, 'L')
	if minetest.get_node(pos2).name == "techage:turbine_on" and tubelib2.get_mem(pos2).running then
		distibuting(pos, mem)
	else
		State:fault(pos, mem)	
		start_turbine(pos, false, mem)
		generator.turn_power_on(pos, 0)
	end
	return State:is_active(mem)
end

local function valid_power_dir(pos, power_dir, in_dir)
	return power_dir == in_dir
end

local function turn_power_on(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	-- store result for formspec
	mem.power_result = sum
	if State:is_active(mem) and sum <= 0 then
		State:fault(pos, mem)
		start_turbine(pos, false, mem)
		-- No automatic turn on
		mem.power_capacity = 0
	end
	M(pos):set_string("formspec", formspec(State, pos, mem))
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

minetest.register_node("techage:generator", {
	description = I("TA3 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png^[transformFX]",
	},
	techage = {
		turn_on = turn_power_on,
		read_power_consumption = generator.read_power_consumption,
		power_network = Cable,
		power_side = "R",
		animated_power_network = true,
	},
	
	after_place_node = function(pos, placer)
		local mem = generator.after_place_node(pos)
		State:node_init(pos, mem, "")
		on_rightclick(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		generator.after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = generator.after_tube_update,	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,

	drop = "",
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:generator_on", {
	description = I("TA3 Generator"),
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
			image = "techage_filling4_ta3.png^techage_appl_generator4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},
	techage = {
		turn_on = turn_power_on,
		read_power_consumption = generator.read_power_consumption,
		power_network = Cable,
		power_side = "R",
		animated_power_network = true,
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		generator.after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = generator.after_tube_update,	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:generator",
	recipe = {
		{"basic_materials:steel_bar", "dye:red", "default:wood"},
		{"", "basic_materials:gear_steel", "techage:axle"},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})

minetest.register_lbm({
	label = "[techage] Generator sound",
	name = "techage:power_station",
	nodenames = {"techage:generator_on"},
	run_at_every_load = true,
	action = function(pos, node)
		play_sound(pos)
	end
})

techage.register_help_page(I("TA3 Generator"), 
I([[Part of the Coal Power Station.
Has to be placed side by side
with the TA3 Turbine.
Connect the Generator with your TA3 machines
by means of Electric Cables and Junction Boxes
(see TA3 Coal Power Station)]]), "techage:generator")