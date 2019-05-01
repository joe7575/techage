--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Basalt as result from the lava/water generator
	
]]--


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
	description = "Basalt Stone",
	tiles = {"default_stone.png^[brighten"},
	groups = {cracky = 3, stone = 1},
	drop = "default:silver_sand",
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("techage:basalt_stone_brick", {
	description = "Basalt Stone Brick",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"default_stone_brick.png^[brighten"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:basalt_stone_block", {
	description = "Basalt Stone Block",
	tiles = {"default_stone_block.png^[brighten"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:basalt_gravel", {
	description = "Basalt Gravel",
	tiles = {"default_gravel.png^[brighten"},
	groups = {crumbly = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_node("techage:sieved_basalt_gravel", {
	description = "Sieved Basalt Gravel",
	tiles = {"default_gravel.png^[brighten"},
	groups = {crumbly = 2, falling_node = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_gravel_defaults(),
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

techage.add_grinder_recipe({input="techage:basalt_stone", output="techage:basalt_gravel"})
techage.add_grinder_recipe({input="techage:basalt_gravel", output="default:clay"})
techage.add_grinder_recipe({input="techage:sieved_basalt_gravel", output="default:clay"})