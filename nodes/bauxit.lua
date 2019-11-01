--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bauxite
	
]]--

local S = techage.S

minetest.register_node("techage:bauxite_stone", {
	description = S("Bauxite Stone"),
	tiles = {"default_desert_stone.png^techage_bauxit_overlay.png^[colorize:#800000:80"},
	groups = {cracky = 3, stone = 1},
	drop = 'techage:bauxite_cobble',
	sounds = default.node_sound_stone_defaults(),
	--paramtype = "light",
	--light_source = minetest.LIGHT_MAX
})

minetest.register_node("techage:bauxite_cobble", {
	description = S("Bauxite Cobblestone"),
	tiles = {"default_desert_cobble.png^[colorize:#800000:80"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:bauxite_gravel", {
	description = S("Bauxite Gravel"),
	tiles = {"default_gravel.png^[colorize:#9b1f06:180"},
	is_ground_content = false,
	groups = {crumbly = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "techage:bauxite_stone",
	wherein         = {"default:stone"},
	clust_scarcity  = 12 * 12 * 12,
	clust_size      = 5,
	y_max           = -100,
	y_min           = -200,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 8, y = 8, z = 8},
		seed = 1234, --2316,
		octaves = 1,
		persist = 0.0
	},
	biomes = {"underground"}
})
