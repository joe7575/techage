--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fusion Reactor Shell

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

minetest.register_node("techage:ta5_fr_shell1", {
	description = "TA5 Fusion Reactor Shell 1",
	tiles = {
		"techage_reactor_shell.png",
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = "blend",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta5_fr_shell2", {
	description = "TA5 Fusion Reactor Shell 2",
	tiles = {
		"techage_reactor_shell.png",
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -2/16,  8/16,  8/16},
			{ 2/16, -8/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16, -2/16,  8/16},
			{-8/16,  2/16, -8/16,  8/16,  8/16,  8/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = "blend",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})
