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

minetest.register_node("techage:ta5_fr_shell", {
	description = S("TA5 Fusion Reactor Shell"),
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

minetest.register_node("techage:ta5_fr_nucleus", {
	description = S("TA5 Fusion Reactor Nucleus"),
	tiles = {
		"techage_reactor_shell.png^techage_collider_detector_core.png",
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = "blend",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

techage.furnace.register_recipe({
	output = "techage:ta5_fr_shell 3",
	recipe = {'techage:ta4_colliderblock', 'techage:ta4_colliderblock', "techage:graphite_powder"},
	time = 24,
})

minetest.register_craft({
	output = "techage:ta5_fr_nucleus",
	recipe = {
		{"", "techage:ta5_aichip2", ""},
		{"techage:electric_cableS", "techage:cylinder_large_hydrogen", "techage:ta3_valve_open"},
		{"", "techage:ta5_fr_shell", ""},
	},
})

