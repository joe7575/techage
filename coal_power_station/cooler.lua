--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Cooler

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.SteamPipe

local function transfer(pos, in_dir, topic, payload)
	return techage.transfer(pos, in_dir, topic, payload, Pipe,
			{"techage:coalboiler_base"})
end

local function after_place_node(pos)
	Pipe:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Pipe:after_dig_node(pos)
	techage.del_mem(pos)
end

minetest.register_node("techage:cooler", {
	description = S("TA3 Cooler"),
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
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

-- legacy node
minetest.register_node("techage:cooler_on", {
	description = S("TA3 Cooler"),
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
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	paramtype2 = "facedir",
	drop = "techage:cooler",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Pipe:add_secondary_node_names({"techage:cooler", "techage:cooler_on"})

-- for logical communication
techage.register_node({"techage:cooler", "techage:cooler_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		return transfer(pos, in_dir, topic, payload)
	end
})

minetest.register_craft({
	output = "techage:cooler",
	recipe = {
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
		{"techage:steam_pipeS", "basic_materials:gear_steel", "techage:steam_pipeS"},
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
	},
})
