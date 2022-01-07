--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fusion Reactor Plasma

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local MAGNETS = {"techage:ta5_magnet1", "techage:ta5_magnet2", "techage:ta5_magnet3"}

minetest.register_node("techage:plasma2", {
	description = "TA5 Plasma",
	tiles = {
		"techage_plasma1.png",
		"techage_plasma1.png",
		"techage_plasma1.png",
		"techage_plasma1.png",
		{
			image = "techage_plasma2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.5,
			},
		},
		"techage_plasma1.png",
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -4/16, -4/16,  8/16, 4/16, 4/16},
		},
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	light_source = 14,
	drop = "",
	use_texture_alpha = "blend",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:plasma1", {
	description = "TA5 Plasma",
	tiles = {
		"techage_plasma1.png",
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	light_source = 0,
	drop = "",
	use_texture_alpha = "blend",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})
