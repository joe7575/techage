--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Meltingpot recipes
	
]]--

local S = techage.S

--
-- New burner recipes
--
techage.ironage_register_recipe({
	output = "default:obsidian", 
	recipe = {"default:cobble"}, 
	heat = 10,
	time = 8,
})

techage.ironage_register_recipe({
	output = "techage:iron_ingot", 
	recipe = {"default:iron_lump"}, 
	heat = 5,
	time = 3,
})

minetest.register_craftitem("techage:iron_ingot", {
	description = S("TA1 Iron Ingot"),
	inventory_image = "techage_iron_ingot.png",
	use_texture_alpha = true,
})


--
-- Changed default recipes
--
if techage.modified_recipes_enabled then
	minetest.clear_craft({output = "default:bronze_ingot"})
	minetest.clear_craft({output = "default:steel_ingot"})
	minetest.clear_craft({output = "fire:flint_and_steel"})
	minetest.clear_craft({output = "bucket:bucket_empty"})

	techage.ironage_register_recipe({
		output = "default:bronze_ingot 4", 
		recipe = {"default:copper_ingot", "default:copper_ingot", "default:copper_ingot", "default:tin_ingot"}, 
		heat = 4,
		time = 8,
	})

	techage.ironage_register_recipe({
		output = "default:steel_ingot 4", 
		recipe = {"default:coal_lump", "default:iron_lump", "default:iron_lump", "default:iron_lump"}, 
		heat = 7,
		time = 8,
	})

	minetest.register_craft({
	   output = "fire:flint_and_steel",
	   recipe = {
		  {"default:flint", "default:iron_lump"}
	   }
	})

	minetest.override_item("fire:flint_and_steel", {
			description = S("Flint and Iron"),
			inventory_image = "fire_flint_steel.png^[colorize:#c7643d:60",
	})

	minetest.override_item("bucket:bucket_empty", {
			inventory_image = "bucket.png^[colorize:#c7643d:40"
	})
	minetest.override_item("bucket:bucket_lava", {
			inventory_image = "bucket_lava.png^[colorize:#c7643d:30"
	})
	minetest.override_item("bucket:bucket_river_water", {
			inventory_image = "bucket_river_water.png^[colorize:#c7643d:30"
	})
	minetest.override_item("bucket:bucket_water", {
			inventory_image = "bucket_water.png^[colorize:#c7643d:30"
	})
	
	minetest.register_craft({
	output = 'bucket:bucket_empty 2',
	recipe = {
		{'techage:iron_ingot', '', 'techage:iron_ingot'},
		{'', 'techage:iron_ingot', ''},
	}
})
end

