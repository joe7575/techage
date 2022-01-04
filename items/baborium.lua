--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Baborium

]]--

local S = techage.S

minetest.register_node("techage:stone_with_baborium", {
	description = S("Baborium Ore"),
	tiles = {"default_stone.png^techage_baborium.png"},
	groups = {cracky = 2},
	drop = 'techage:baborium_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craftitem("techage:baborium_lump", {
	description = S("Baborium Lump"),
	inventory_image = "techage_baborium_lump.png",
})

minetest.register_craftitem("techage:baborium_ingot", {
	description = S("Baborium Ingot"),
	inventory_image = "techage_baborium_ingot.png",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "techage:stone_with_baborium",
	wherein        = "default:stone",
	clust_scarcity = 8 * 8 * 8,
	clust_num_ores = 5,
	clust_size     = 3,
	y_min          = -340,
	y_max          = -250,
})

minetest.register_craft({
	type = 'cooking',
	output = 'techage:baborium_ingot',
	recipe = 'techage:baborium_lump',
	cooktime = 5,
})
