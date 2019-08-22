--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Cooking routines for furnace
	
]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local range = techage.range

local Recipes = {}     -- registered recipes
local Ingredients = {}
local KeyList = {}     -- index to Recipes key translation

techage.furnace = {}


local function all_ingredients_available(output, ingr)
	if Recipes[output] then
		for idx,recipe in ipairs(Recipes[output]) do
			local not_in_list = false
			for _,item in ipairs(recipe.input) do
				if not techage.in_list(ingr, item) then
					not_in_list = true
				end
			end
			if not_in_list == false then
				return idx -- list number of the recipe
			end
		end
	end
end			

-- Return a list with all outputs of the given list of ingredients
local function get_recipes(ingr)
	if #ingr > 0 then
		local tbl = {}
		for _,item in ipairs(ingr) do
			if Ingredients[item] then
				for _,output in ipairs(Ingredients[item]) do
					if all_ingredients_available(output, ingr) then
						techage.add_to_set(tbl, output)
					end
				end
			end
		end
		return tbl
	else
		return KeyList
	end
end
	
function techage.furnace.get_ingredients(pos)
	local inv = M(pos):get_inventory()
	local tbl = {}
	for _,stack in ipairs(inv:get_list('src')) do
		if stack:get_name() ~= "" then
			tbl[#tbl+1] = stack:get_name()
		end
	end
	return tbl
end

-- move recipe src items to output inventory
local function process(inv, recipe, output)
	-- check if all ingredients are available
	for _,item in ipairs(recipe.input) do
		if not inv:contains_item("src", item) then
			return false
		end
	end
	-- remove items
	for _,item in ipairs(recipe.input) do
		inv:remove_item("src", item)
	end
	-- add to dst
	local stack = ItemStack(output)
	stack:set_count(recipe.number)
	inv:add_item("dst", stack)
	return true
end		

function techage.furnace.smelting(pos, mem, elapsed)
	local inv = M(pos):get_inventory()
	local state = techage.RUNNING
	if inv and not inv:is_empty("src") then
		if not mem.output or not mem.num_recipe then
			return techage.FAULT
		end
		local recipe = Recipes[mem.output][mem.num_recipe]
		if not recipe then
			return techage.FAULT
		end
		-- check dst inv
		local item = ItemStack(mem.output)
		if not inv:room_for_item("dst", item) then
			return techage.BLOCKED
		end
			
		elapsed = elapsed + (mem.leftover or 0)
		while elapsed >= recipe.time do
			if process(inv, recipe, mem.output) == false then 
				mem.leftover = 0
				return techage.STANDBY
			else
				state = techage.RUNNING
			end
			elapsed = elapsed - recipe.time
		end
		mem.leftover = elapsed
		if recipe.time >= 10 then
			mem.item_percent = math.min(math.floor((mem.leftover * 100.0) / recipe.time), 100)
		else
			mem.item_percent = 100
		end
		return state
	end
	return techage.STANDBY
end

function techage.furnace.get_output(mem, ingr, idx)
	local tbl = get_recipes(ingr)
	idx = range(idx, 1, #tbl)
	mem.output = tbl[idx] or tbl[1]
	mem.num_recipe = all_ingredients_available(mem.output, ingr)
	return mem.output
end

function techage.furnace.get_num_recipes(ingr)
	return #get_recipes(ingr)
end

function techage.furnace.reset_cooking(mem)
	mem.leftover = 0
end


if minetest.global_exists("unified_inventory") then
	unified_inventory.register_craft_type("ta3_melting", {
		description = S("TA3 Melting"),
		icon = "techage_concrete.png^techage_appl_furnace.png^techage_frame_ta3.png",
		width = 2,
		height = 2,
	})
end

function techage.furnace.register_recipe(recipe)
	local words = string.split(recipe.output, " ")
	local output = words[1]
	local number = tonumber(words[2] or 1)
	table.insert(KeyList, output)
	--print(recipe.output, dump(recipe.recipe))
	if not Recipes[output] then
		Recipes[output] = {}
	end
	table.insert(Recipes[output], {
		input = recipe.recipe,
		number = number,
		time = math.max((recipe.time or 3) * number, 2),
	})
	for _,item in ipairs(recipe.recipe) do
		if Ingredients[item] then
			techage.add_to_set(Ingredients[item], output)
		else
			Ingredients[item] = {output}
		end
	end

	if minetest.global_exists("unified_inventory") then
		recipe.items = recipe.recipe
		recipe.type = "ta3_melting"
		unified_inventory.register_craft(recipe)
	end
end