--
-- Script to check recipe overlaps
--
local Recipes = {}

local function recipe_key(items)
	local tbl = {}
	for idx = 1,9 do
		tbl[#tbl + 1] = items[idx] or "#"
	end
	return table.concat(tbl, "-")
end

minetest.after(1, function()
	for name,_ in pairs(minetest.registered_items) do
		local mod = string.split(name, ":")[1]
		if mod == "techage" or mod == "signs_bot" or mod == "vm16" or mod == "beduino" then
			local recipes = minetest.get_all_craft_recipes(name)
			if recipes then
				for _,recipe in ipairs(recipes) do
					if recipe and recipe.items then
						--print(dump(recipe.items))
						local key = recipe_key(recipe.items)
						if Recipes[key] then
							if not string.find(name, "slab") and not string.find(name, "stair") then
								local text = Recipes[key].." and "..name.." have the same incredients"
								minetest.log("error", text)
							end
						end
						Recipes[key] = name
					end
				end
			end
		end
	end
end)
