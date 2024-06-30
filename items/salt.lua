--[[

	TechAge
	=======

	Copyright (C) 2024 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Salt

]]--


--Detects if the salt node is registered.
minetest.register_on_mods_loaded(function()
    if minetest.registered_nodes["farming:salt"] then
		--Adds salt to powder group to ensure reactor and silo will accept it
		local def = minetest.registered_nodes["farming:salt"]
		local groups = table.copy(def.groups)
		groups.powder = 1
		minetest.override_item("farming:salt", { groups=groups })

		--Add the water -> salt & river water recipe.
		techage.recipes.add("ta4_doser", {
			output = "farming:salt 1",
			waste = "techage:river_water 1",
			input = {
				"techage:water 1",
				}
		})

		-- Add salt recipe as replacement for the minetest.register_craft("farming:salt") recipe
		techage.furnace.register_recipe({
			output = "farming:salt",
			recipe = {"bucket:bucket_water"},
			waste = "bucket:bucket_empty",
			time = 8,
		})
	else
		-- Creates a water -> River Water recipe in absense of the farming:salt node.
		techage.recipes.add("ta4_doser", {
		output = "techage:river_water 1",
		input = {
			"techage:water 1",
			}
		})
	end
end)
