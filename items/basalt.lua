--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Basalt as result from the lava/water generator

]]--

local S = techage.S

-- Replace default:stone with techage:basalt which is less valuable for ore generation.
default.cool_lava = function(pos, node)
	if node.name == "default:lava_source" then
		minetest.set_node(pos, {name = "default:obsidian"})
	else -- Lava flowing
		minetest.set_node(pos, {name = "techage:basalt_stone"})
	end
	minetest.sound_play("default_cool_lava",
		{pos = pos, max_hear_distance = 16, gain = 0.25})
end

minetest.register_node("techage:basalt_stone", {
	description = S("Basalt Stone"),
	tiles = {"default_stone.png^[brighten"},
	groups = {cracky = 3, stone = 1},
	drop = 'techage:basalt_cobble',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:basalt_cobble", {
	description = S("Basalt Cobble"),
	tiles = {"default_cobble.png^[brighten"},
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:basalt_stone_brick", {
	description = S("Basalt Stone Brick"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_stone_brick.png^[brighten"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:basalt_stone_block", {
	description = S("Basalt Stone Block"),
	tiles = {"default_stone_block.png^[brighten"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:basalt_gravel", {
	description = S("Basalt Gravel"),
	tiles = {"default_gravel.png^[brighten"},
	groups = {crumbly = 2, falling_node = 1, gravel = 1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_node("techage:sieved_basalt_gravel", {
	description = S("Sieved Basalt Gravel"),
	tiles = {"default_gravel.png^[brighten"},
	groups = {crumbly = 2, falling_node = 1, gravel = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_node("techage:basalt_glass", {
	description = S("Basalt Glass"),
	drawtype = "glasslike_framed_optional",
	tiles = {"techage_basalt_glass.png"},
	use_texture_alpha = techage.BLEND,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:basalt_glass2", {
	description = S("Basalt Glass 2"),
	drawtype = "glasslike_framed_optional",
	tiles = {"techage_basalt_glass2.png"},
	use_texture_alpha = techage.BLEND,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:basalt_glass_thin", {
	description = S("Basalt Glass Thin"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -1/16, 8/16,  8/16,  1/16},
		},
	},
	tiles = {"techage_basalt_glass.png"},
	use_texture_alpha = techage.BLEND,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:basalt_glass_thin2", {
	description = S("Basalt Glass Thin 2"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -1/16, 8/16,  8/16,  1/16},
		},
	},
	tiles = {"techage_basalt_glass2.png"},
	use_texture_alpha = techage.BLEND,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:basalt_glass_thin_xl", {
	description = S("Basalt Glass Thin XL"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -1/16, 16/16,  16/16,  1/16},
		},
	},
	tiles = {"techage_basalt_glass.png"},
	use_texture_alpha = techage.BLEND,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:basalt_glass_thin_xl2", {
	description = S("Basalt Glass Thin XL 2"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -1/16, 16/16,  16/16,  1/16},
		},
	},
	tiles = {"techage_basalt_glass2.png"},
	use_texture_alpha = techage.BLEND,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = "techage:basalt_stone_brick 4",
	recipe = {
		{"techage:basalt_stone", "techage:basalt_stone"},
		{"techage:basalt_stone", "techage:basalt_stone"},
	}
})

minetest.register_craft({
	output = "techage:basalt_stone_block 9",
	recipe = {
		{"techage:basalt_stone", "techage:basalt_stone", "techage:basalt_stone"},
		{"techage:basalt_stone", "techage:basalt_stone", "techage:basalt_stone"},
		{"techage:basalt_stone", "techage:basalt_stone", "techage:basalt_stone"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "techage:basalt_stone",
	recipe = "techage:basalt_cobble",
})

techage.add_grinder_recipe({input="techage:basalt_stone", output="techage:basalt_gravel"})
techage.add_grinder_recipe({input="techage:basalt_cobble", output="techage:basalt_gravel"})
techage.add_grinder_recipe({input="techage:basalt_gravel", output="default:clay"})
techage.add_grinder_recipe({input="techage:sieved_basalt_gravel", output="default:clay"})
