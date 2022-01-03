--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Cement as ingredient and alternative recipe for basic_materials:wet_cement
	Cement is cooked and grinded clay

]]--

local S = techage.S


if not  minetest.get_modpath("bakedclay") then
	minetest.register_node("techage:cement_block", {
		description = S("Cement Block"),
		tiles = {"default_clay.png^[colorize:#FFFFFF:160"},
		is_ground_content = false,
		groups = {cracky = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
	})

	minetest.register_craft({
		type = "cooking",
		output = "techage:cement_block",
		recipe = "default:clay",
	})

	techage.add_grinder_recipe({input="techage:cement_block", output="techage:cement_powder"})
else
	-- The block should not exist when the mod baked clay is loaded.
	-- But this block was active due to an error and can therefore no longer be deleted.
	minetest.register_node("techage:cement_block", {
		description = S("Cement Block"),
		tiles = {"default_clay.png^[colorize:#FFFFFF:160"},
		is_ground_content = false,
		groups = {cracky = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
	})

	techage.add_grinder_recipe({input="techage:cement_block", output="techage:cement_powder"})
	techage.add_grinder_recipe({input="bakedclay:white", output="techage:cement_powder"})
end

minetest.register_craftitem("techage:cement_powder", {
	description = S("Cement Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#FFFFFF:240",
	groups = {powder = 1},
})

minetest.register_craft({
	output = "basic_materials:wet_cement 3",
	recipe = {
		{"bucket:bucket_water", "techage:cement_powder"},
		{"group:sand", "default:gravel"},
	},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
})
