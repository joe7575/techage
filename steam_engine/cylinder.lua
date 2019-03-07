--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Steam Engine Cylinder

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local TP = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end
local TN = function(node) return (minetest.registered_nodes[node.name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUME = 8

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

-- called from pipe network
local function valid_power_dir(pos, mem, in_dir)
	return mem.power_dir == in_dir
end

-- called from pipe network
local function turn_power_on(pos, in_dir, on)
	print("turn_power_on", in_dir, on)
	local mem = tubelib2.get_mem(pos)
	mem.power_supply = on
end	

-- called from flywheel
local function start_cylinder(pos, on)
	local mem = tubelib2.get_mem(pos)
	if on and mem.power_supply then
		mem.power_consume = POWER_CONSUME
		swap_node(pos, "techage:cylinder_on")
		return true
	else
		mem.power_consume = 0
		swap_node(pos, "techage:cylinder")
	end
	return false
end	


minetest.register_node("techage:cylinder", {
	description = I("TA2 Cylinder"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_steam_hole.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
	},
	techage = {
		turn_on = turn_power_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.SteamPipe,
		power_side = 'L',
		valid_power_dir = valid_power_dir,
		start_cylinder = start_cylinder,
	},
	
	after_place_node = function(pos, placer)
		local mem = techage.consumer_after_place_node(pos, placer)
		mem.power_consume = 0  -- needed power to run
		mem.power_supply = false  -- power available?
	end,
	
	after_tube_update = techage.consumer_after_tube_update,
	after_dig_node = techage.consumer_after_dig_node,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:cylinder_on", {
	description = I("TA2 Cylinder"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_steam_hole.png",
		{
			image = "techage_filling4_ta2.png^techage_cylinder4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta2.png^techage_cylinder4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	techage = {
		turn_on = turn_power_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.SteamPipe,
		power_side = 'L',
		valid_power_dir = valid_power_dir,
		start_cylinder = start_cylinder,
	},
	
	after_tube_update = techage.consumer_after_tube_update,
	after_dig_node = techage.consumer_after_dig_node,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

