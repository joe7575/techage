--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Heat Exchanger

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.BiogasPipe

minetest.register_node("techage:glow_gravel", {
	description = "Techage Gravel",
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

minetest.register_node("techage:ta4_tes_coreelem", {
	description = S("TA4 TES Core Element"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_tes_core_elem_top.png",
		"techage_tes_core_elem_top.png",
		"techage_tes_core_elem.png",
	},
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

