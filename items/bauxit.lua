--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Bauxite

]]--

local S = techage.S

minetest.register_node("techage:bauxite_stone", {
	description = S("Bauxite Stone"),
	tiles = {"default_desert_stone.png^techage_bauxit_overlay.png^[colorize:#FB2A00:120"},
	groups = {cracky = 3, stone = 1},
	drop = 'techage:bauxite_cobble',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:bauxite_cobble", {
	description = S("Bauxite Cobblestone"),
	tiles = {"default_desert_cobble.png^[colorize:#FB2A00:80"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:bauxite_gravel", {
	description = S("Bauxite Gravel"),
	tiles = {"default_gravel.png^[colorize:#FB2A00:180"},
	is_ground_content = false,
	groups = {crumbly = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_craftitem("techage:bauxite_powder", {
	description = S("Bauxite Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#FB2A00:120",
	groups = {powder = 1},
})


minetest.register_ore({
	ore_type       = "blob",
	ore            = "techage:bauxite_stone",
	wherein        = {"default:stone", "default:desert_stone"},
	clust_scarcity = 16 * 16 * 16,
	clust_size     = 6,
	y_max          = -50,
	y_min          = -500,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 41524,
			octaves = 1,
			persist = 0.0
		},
})

techage.add_grinder_recipe({input="techage:bauxite_cobble", output="techage:bauxite_gravel"})
techage.add_grinder_recipe({input="techage:bauxite_gravel", output="techage:bauxite_powder"})
