--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Nodes

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

minetest.register_node("techage:glow_gravel", {
	description = S("TechAge Gravel"),
	tiles = {{
		name = "techage_gravel4.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 0.2,
		},
	}},
	paramtype = "light",
	light_source = 8,
	groups = {crumbly = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults(),
	drop = "",
})
