--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Steam pipes for the Steam Engine

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 12,
	show_infotext = false,
	force_to_use_tubes = true,
	tube_type = "pipe1",
	primary_node_names = {"techage:steam_pipeS", "techage:steam_pipeA"},
	secondary_node_names = {"techage:cylinder", "techage:cylinder_on", "techage:boiler2"},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		minetest.swap_node(pos, {name = "techage:steam_pipe"..tube_type, param2 = param2})
	end,
})

minetest.register_node("techage:steam_pipeS", {
	description = S("TA2 Steam Pipe"),
	tiles = {
		"techage_steam_pipe.png^[transformR90",
		"techage_steam_pipe.png^[transformR90",
		"techage_steam_pipe.png",
		"techage_steam_pipe.png",
		"techage_steam_hole.png",
		"techage_steam_hole.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -1/8, -4/8,  1/8, 1/8, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=3, cracky=3, snappy=3},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:steam_pipeA", {
	description = S("TA2 Steam Pipe"),
	tiles = {
		"techage_steam_knee2.png",
		"techage_steam_hole2.png^[transformR180",
		"techage_steam_knee.png^[transformR270",
		"techage_steam_knee.png",
		"techage_steam_knee2.png",
		"techage_steam_hole2.png",
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -4/8, -1/8, 1/8, 1/8, 1/8},
			{-1/8, -1/8, -4/8, 1/8, 1/8, -1/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly=3, cracky=3, snappy=3, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:steam_pipeS",
})

minetest.register_craft({
	output = "techage:steam_pipeS 3",
	recipe = {
		{'', '', "default:bronze_ingot"},
		{'', 'techage:iron_ingot', ''},
		{"default:bronze_ingot", '', ''},
	},
})

techage.SteamPipe = Pipe
