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
local TP = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end
local TN = function(name) return (minetest.registered_nodes[name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 8
local POWER = 8

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[6,0.5;1,2;"..techage.generator_formspec_level(mem)..
		"image_button[5,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"button[2,1.5;2,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, mem, state)
	local pos2 = techage.get_pos(pos, 'L')
	if minetest.get_node(pos2).name == "techage:cylinder" and tubelib2.get_mem(pos2).power_supply then
		local sum = techage.calc_power_consumption(pos, mem, POWER)
		return sum > 0
	end
	return false
end

local function start_node(pos, mem, state)
	local pos2 = techage.get_pos(pos, 'L')
	local that = TP(pos2)
	if that and that.start_cylinder then
		that.start_cylinder(pos2, true)
		techage.generator_on(pos, mem)
	end
end

local function stop_node(pos, mem, state)
	techage.generator_off(pos, mem)
	local pos2 = techage.get_pos(pos, 'L')
	local that = TP(pos2)
	if that and that.start_cylinder then
		that.start_cylinder(pos2, false)
	end
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
	local sum = techage.calc_power_consumption(pos, mem, 8)
	if sum > 0 then
		State:keep_running(pos, mem, COUNTDOWN_TICKS)
	else
		State:fault(pos, mem)	
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	print("flywheel node_timer")
	local pos2 = techage.get_pos(pos, 'L')
	if minetest.get_node(pos2).name == "techage:cylinder_on" and tubelib2.get_mem(pos2).power_supply then
		distibuting(pos, mem)
	else
		State:fault(pos, mem)	
	end
	return State:is_active(mem)
end

local function valid_power_dir(pos, mem, in_dir)
	return mem.power_dir == in_dir
end

local function turn_power_on(pos, in_dir, on)
	local mem = tubelib2.get_mem(pos)
	if State:is_active(mem) and not on then
		State:fault(pos, mem)
	end
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
		power_network = techage.Axle,
		power_consumption = techage.generator_power_consumption,
		power_consume = 0,
		animated_power_network = true,
		valid_power_dir = valid_power_dir,
		turn_on = turn_power_on,
	},
	
	after_place_node = function(pos, placer)
		local mem = techage.generator_after_place_node(pos)
		State:node_init(pos, mem, "")
		on_rightclick(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		techage.generator_after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = techage.generator_after_tube_update,	
	on_destruct = techage.generator_on_destruct,
	
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,

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
			image = "techage_filling4_ta2.png^techage_frame4_ta2.png^techage_flywheel4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			image = "techage_filling4_ta2.png^techage_frame4_ta2.png^techage_flywheel4.png^[transformFX]",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
	},
	techage = {
		power_network = techage.Axle,
		power_consumption = techage.generator_power_consumption,
		power_consume = 0,
		animated_power_network = true,
		valid_power_dir = valid_power_dir,
		turn_on = turn_power_on,
	},
	
	after_tube_update = techage.generator_after_tube_update,	
	
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})
