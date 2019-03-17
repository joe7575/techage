--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Steam Engine Flywheel

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
local POWER_CAPACITY = 8

local Axle = techage.Axle
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

local function start_cylinder(pos, on)
	local pos2 = techage.get_pos(pos, 'L')
	local trd = TRD(pos2)
	if trd and trd.start_cylinder then
		return trd.start_cylinder(pos2, on)
	end
	return false
end

local function can_start(pos, mem, state)
	return start_cylinder(pos, true)
end

local function start_node(pos, mem, state)
	generator.turn_power_on(pos, POWER_CAPACITY)
end

local function stop_node(pos, mem, state)
	start_cylinder(pos, false)
	generator.turn_power_on(pos, 0)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:flywheel",
	node_name_active = "techage:flywheel_on",
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
		start_cylinder(pos, false)
		generator.turn_power_on(pos, 0)
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	print("flywheel node_timer")
	local pos2 = techage.get_pos(pos, 'L')
	if minetest.get_node(pos2).name == "techage:cylinder_on" and tubelib2.get_mem(pos2).running then
		distibuting(pos, mem)
	else
		State:fault(pos, mem)	
		start_cylinder(pos, false)
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
		start_cylinder(pos, false)
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

minetest.register_node("techage:flywheel", {
	description = I("TA2 Flywheel"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_axle_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png^[transformFX]",
	},
	techage = {
		turn_on = turn_power_on,
		read_power_consumption = generator.read_power_consumption,
		power_network = Axle,
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

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:flywheel_on", {
	description = I("TA2 Flywheel"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		{
			image = "techage_filling4_ta2.png^techage_axle_clutch4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		{
			image = "techage_filling8_ta2.png^techage_frame8_ta2.png^techage_flywheel8.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.2,
			},
		},
		{
			image = "techage_filling8_ta2.png^techage_frame8_ta2.png^techage_flywheel8.png^[transformFX]",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.2,
			},
		},
	},
	techage = {
		turn_on = turn_power_on,
		read_power_consumption = generator.read_power_consumption,
		power_network = Axle,
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
