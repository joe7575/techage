--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Redstone as result from the redmud/sand

]]--

local S = techage.S


minetest.register_node("techage:red_stone", {
	description = S("Red Stone"),
	tiles = {"default_stone.png^[colorize:#ff4538:110"},
	groups = {cracky = 3, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:red_stone_brick", {
	description = S("Red Stone Brick"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_stone_brick.png^[colorize:#ff4538:110"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:red_stone_block", {
	description = S("Red Stone Block"),
	tiles = {"default_stone_block.png^[colorize:#ff4538:110"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "techage:red_stone_brick 4",
	recipe = {
		{"techage:red_stone", "techage:red_stone"},
		{"techage:red_stone", "techage:red_stone"},
	}
})

minetest.register_craft({
	output = "techage:red_stone_block 9",
	recipe = {
		{"techage:red_stone", "techage:red_stone", "techage:red_stone"},
		{"techage:red_stone", "techage:red_stone", "techage:red_stone"},
		{"techage:red_stone", "techage:red_stone", "techage:red_stone"},
	}
})

techage.furnace.register_recipe({
	output = "techage:red_stone",
	recipe = {
		"techage:canister_redmud",
		"default:sand",
	},
	waste = "techage:ta3_canister_empty",
	time = 4,
})
