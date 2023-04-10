--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Cooking recipes for furnace

]]--


techage.furnace.register_recipe({
	output = "techage:iron_ingot",
	recipe = {"default:iron_lump"},
	time = 2,
})

techage.furnace.register_recipe({
	output = "default:obsidian",
	recipe = {"default:cobble"},
	time = 8,
})

if techage.modified_recipes_enabled then
	techage.furnace.register_recipe({
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

if minetest.global_exists("wielded_light") then
	techage.furnace.register_recipe({
		output = "techage:meridium_ingot",
		recipe = {"default:steel_ingot", "default:mese_crystal_fragment"},
		heat = 4,
		time = 3,
	})
end

local function node_group(group)
	local tbl = {}
	for key,_ in pairs(minetest.registered_items) do
		if minetest.get_item_group(key, group) > 0 then
			tbl[#tbl + 1] = key
		end
	end
	return tbl
end

minetest.after(1, function()
	for key,_ in pairs(minetest.registered_items) do
		if key ~= "" then
			local tbl = minetest.get_all_craft_recipes(key)
			if tbl then
				for _,recipe in ipairs(tbl) do
					if recipe and recipe.method == "cooking" then
						if recipe.items[1] and string.split(recipe.items[1], ":")[1] == "group" then
							for _,item in ipairs(node_group(string.split(recipe.items[1], ":")[2])) do
								techage.furnace.register_recipe({
									output = recipe.output,
									recipe = {item},
									time = math.floor((recipe.width + 1) / 2),
								})
							end
						else
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
	end
end)

techage.furnace.register_recipe({
	output = "techage:basalt_glass2",
	recipe = {
		"techage:basalt_gravel",
		"techage:basalt_gravel",
	},
	time = 4,
})

techage.furnace.register_recipe({
	output = "techage:basalt_glass",
	recipe = {
		"techage:sieved_basalt_gravel",
		"techage:sieved_basalt_gravel",
	},
	time = 4,
})

techage.furnace.register_recipe({
	output = "techage:basalt_glass_thin2 2",
	recipe = {
		"techage:basalt_gravel",
	},
	time = 4,
})

techage.furnace.register_recipe({
	output = "techage:basalt_glass_thin 2",
	recipe = {
		"techage:sieved_basalt_gravel",
	},
	time = 4,
})

techage.furnace.register_recipe({
	output = "techage:basalt_glass_thin_xl2",
	recipe = {
		"techage:basalt_gravel",
	},
	time = 4,
})

techage.furnace.register_recipe({
	output = "techage:basalt_glass_thin_xl",
	recipe = {
		"techage:sieved_basalt_gravel",
	},
	time = 4,
})

techage.furnace.register_recipe({
	output = "basic_materials:concrete_block 4",
	recipe = {
		"basic_materials:wet_cement",
		"default:sand",
		"default:gravel",
		"techage:steelmat",
	},
	time = 4,
})

if minetest.global_exists("moreores") then

	if techage.modified_recipes_enabled then
		minetest.clear_craft({output = "moreores:mithril_ingot"})
		minetest.clear_craft({output = "moreores:silver_ingot"})
	end

	techage.furnace.register_recipe({
		output = 'moreores:silver_ingot',
		recipe = {'moreores:silver_lump'},
		time = 2,
	})

	techage.furnace.register_recipe({
		output = 'moreores:mithril_ingot',
		recipe = {'moreores:mithril_lump'},
		time = 5,
	})

end
