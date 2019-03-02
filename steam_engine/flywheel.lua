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

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local CYCLE_TIME = 10
local POWER = 8

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function formspec(mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[3,0.5;1,2;"..techage.generator_formspec_level(mem)..
		"button[5.5,1.2;1.8,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		"listring[current_name;water]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 3)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	if fields.update then
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("formspec", formspec(mem))
	end
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(mem))
end
	

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	techage.generator_on(pos, POWER, techage.Axle)
	return true
end

local function on_punch(pos, node, puncher, pointed_thing)
	local mem = tubelib2.get_mem(pos)
	if mem.power_produce and mem.power_produce > 0 then
		swap_node(pos, "techage:flywheel")
		techage.generator_off(pos, techage.Axle)
		--techage.generator_off(pos)
		minetest.get_node_timer(pos):stop()
	else
		swap_node(pos, "techage:flywheel_on")
		techage.generator_on(pos, POWER, techage.Axle)
		--techage.generator_on(pos, POWER)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
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
		network = techage.Axle,
		power_consumption = techage.generator_power_consumption,
	},
	
	after_place_node = techage.generator_after_place_node,
	after_tube_update = techage.generator_after_tube_update,	
	on_destruct = techage.generator_on_destruct,
	after_dig_node = techage.generator_after_dig_node,
	
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_punch = on_punch,

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
		network = techage.Axle,
		power_consumption = techage.generator_power_consumption,
	},

	after_place_node = techage.generator_after_place_node,
	after_tube_update = techage.generator_after_tube_update,	
	on_destruct = techage.generator_on_destruct,
	after_dig_node = techage.generator_after_dig_node,
	
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_punch = on_punch,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	--diggable = false,
	--drop = "techage:flywheel",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})
