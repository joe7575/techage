--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Cooking recipes for furnace
	
]]--


techage.furnace.register_recipe({
	output = "techage:iron_ingot", 
	recipe = {"default:iron_lump"}, 
	time = 2,
})

if techage.modified_recipes_enabled then
	techage.ironage_register_recipe({
		output = "default:bronze_ingot 4", 
		recipe = {"default:copper_ingot", "default:copper_ingot", "default:copper_ingot", "default:tin_ingot"}, 
		time = 2,
	})

	techage.furnace.register_recipe({
		output = "default:steel_ingot 4", 
		recipe = {"default:coal_lump", "default:iron_lump", "default:iron_lump", "default:iron_lump"}, 
		time = 4,
	})
end


minetest.after(1, function()
	for key,_ in pairs(minetest.registered_items) do
		if key ~= "" then
			local tbl = minetest.get_all_craft_recipes(key)
			if tbl then
				for _,recipe in ipairs(tbl) do
					if recipe and recipe.method == "cooking" then
						--print(dump(idef), dump(recipe))
						--print(key, recipe.width)
						techage.furnace.register_recipe({
							output = recipe.output, 
							recipe = recipe.items, 
							time = math.floor((recipe.width + 1) / 2),
						})
					end
				end
			end
		end
	end
end)
