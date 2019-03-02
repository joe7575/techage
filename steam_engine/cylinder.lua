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
local TP = function(pos) return minetest.registered_nodes[minetest.get_node(pos).name].techage end
local TN = function(node) return minetest.registered_nodes[node.name].techage end

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

local function turn_on(pos, dir, on)
	--local mem = tubelib2.get_mem(pos)
	--print("turn_on", mem.power_dir, dir, on)
	--if mem.power_dir == dir then
		local npos = techage.next_pos(pos, "R")
		print("turn_on", S(pos), S(npos))
		local this = TP(npos)
		if this and this.try_to_start then
			on = this.try_to_start(npos, on)
		end
		if on then
			swap_node(pos, "techage:cylinder_on")
		else
			swap_node(pos, "techage:cylinder")
		end
	--end
end	

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local inv = M(pos):get_inventory()
	local fuellist = inv:get_list("fuel")
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
		turn_on = turn_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.SteamPipe,
		power_consume = POWER_CONSUME,
		power_side = 'L',
	},
	
	after_place_node = techage.consumer_after_place_node,
	after_tube_update = techage.consumer_after_tube_update,
	on_destruct = techage.consumer_on_destruct,
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
		turn_on = turn_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.SteamPipe,
		power_consume = POWER_CONSUME,
		power_side = 'L',
	},
	
	after_place_node = techage.consumer_after_place_node,
	after_tube_update = techage.consumer_after_tube_update,
	on_destruct = techage.consumer_on_destruct,
	after_dig_node = techage.consumer_after_dig_node,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

