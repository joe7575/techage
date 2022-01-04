--[[

	TechAge
	=======

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA1 mill boards

]]--

local M = minetest.get_meta
local S = techage.S

local function register_board1(output, description, tiles, input)
	minetest.register_node(output, {
		description = description,
		tiles = tiles,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-1/2, -4/8, -1/2, 1/2, -3/8, 1/2},
			},
		},
		paramtype2 = "wallmounted",
		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = output .. " 3",
		recipe = {
			{"", "", input},
			{"", "", input},
			{"", "", input},
		},
	})
end

local function register_board2(output, description, tiles, input1, input2)
	minetest.register_node(output, {
		description = description,
		tiles = tiles,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-1/2,  3/8,  -1/2,   1/2,  4/8, 1/2},
				{-1/2,  3/16, -2/16,  1/2,  6/16, 2/16},
				{-1/2, -5/16, -1/16,  1/2, -3/16, 1/16},
			},
		},

		paramtype2 = "facedir",
		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, fence = 1},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = output,
		recipe = {
			{"", input1, ""},
			{"", input2, ""},
			{"", "", ""},
		},
	})
end

register_board1("techage:ta1_board1_apple",  S("TA1 Apple Wood Board"),  {"default_wood.png"},        "stairs:slab_wood")
register_board1("techage:ta1_board1_jungle", S("TA1 Jungle Wood Board"), {"default_junglewood.png"},  "stairs:slab_junglewood")
register_board1("techage:ta1_board1_pine",   S("TA1 Pine Wood Board"),   {"default_pine_wood.png"},   "stairs:slab_pine_wood")
register_board1("techage:ta1_board1_acacia", S("TA1 Acacia Wood Board"), {"default_acacia_wood.png"}, "stairs:slab_acacia_wood")
register_board1("techage:ta1_board1_aspen",  S("TA1 Aspen Wood Board"),  {"default_aspen_wood.png"},  "stairs:slab_aspen_wood")

register_board2("techage:ta1_board2_apple",  S("TA1 Apple Millrace Board"),  {"default_wood.png"},        "techage:ta1_board1_apple", "default:fence_rail_wood")
register_board2("techage:ta1_board2_jungle", S("TA1 Jungle Millrace Board"), {"default_junglewood.png"},  "techage:ta1_board1_jungle", "default:fence_rail_junglewood")
register_board2("techage:ta1_board2_pine",   S("TA1 Pine Millrace Board"),   {"default_pine_wood.png"},   "techage:ta1_board1_pine", "default:fence_rail_pine_wood")
register_board2("techage:ta1_board2_acacia", S("TA1 Acacia Millrace Board"), {"default_acacia_wood.png"}, "techage:ta1_board1_acacia", "default:fence_rail_acacia_wood")
register_board2("techage:ta1_board2_aspen",  S("TA1 Aspen Millrace Board"),  {"default_aspen_wood.png"},  "techage:ta1_board1_aspen", "default:fence_rail_aspen_wood")
