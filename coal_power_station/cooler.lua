--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Cooler

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUMPTION = 1

local Power = techage.SteamPipe
local distributor = techage.distributor

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function turn_on(pos, dir, sum)
	if sum > 0 then
		swap_node(pos, "techage:cooler_on")
	else
		swap_node(pos, "techage:cooler")
	end
end

minetest.register_node("techage:cooler", {
	description = I("TA3 Cooler"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_appl_cooler.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_cooler.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
	},
	techage = {
		turn_on = turn_on,
		read_power_consumption = distributor.read_power_consumption,
		power_network = Power,
		power_consumption = POWER_CONSUMPTION,
		--animated_power_network = true,
	},
	
	after_place_node = distributor.after_place_node,
	after_tube_update = distributor.after_tube_update,
	after_dig_node = distributor.after_dig_node,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:cooler_on", {
	tiles = {
		-- up, down, right, left, back, front
		{
			image = "techage_filling4_ta3.png^techage_appl_cooler4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_cooler4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
	},
	techage = {
		turn_on = turn_on,
		read_power_consumption = distributor.read_power_consumption,
		power_network = Power,
		power_consumption = POWER_CONSUMPTION,
		--animated_power_network = true,
	},
	
	after_tube_update = distributor.after_tube_update,
	after_dig_node = distributor.after_dig_node,
	
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Power:add_secondary_node_names({"techage:cooler", "techage:cooler_on"})
