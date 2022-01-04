--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Cooking routines for furnace

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local range = techage.in_range

local Recipes = {}     -- registered recipes {output = {recipe, ...},}
local Ingredients = {} -- {{input = output},
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

local function remove_item_from_list(list, item)
	for _,stack in ipairs(list) do
		if stack:get_name() == item then
			stack:set_count(stack:get_count() - 1)
			return true
		end
	end
	return false
end

-- move recipe src items to output inventory
local function process(inv, recipe, output)
	-- check dst inv
	local stack = ItemStack(output)
	stack:set_count(recipe.number)
	if not inv:room_for_item("dst", stack) then
		return techage.BLOCKED
	end
	-- handle waste
	if recipe.waste then
		if not inv:room_for_item("dst", ItemStack(recipe.waste)) then
			return techage.BLOCKED
		end
	end
	-- remove items
	local list = inv:get_list("src")
	for _,item in ipairs(recipe.input) do
		if not remove_item_from_list(list, item) then
			return techage.STANDBY
		end
	end
	-- store changes on scr
	inv:set_list("src", list)
	-- add output to dst
	inv:add_item("dst", stack)
	-- add waste to dst
	if recipe.waste then
		local leftover = inv:add_item("dst", ItemStack(recipe.waste))
		if leftover:get_count() > 0 then
			inv:add_item("src", leftover)
			return techage.BLOCKED
		end
	end
	return techage.RUNNING
end

function techage.furnace.check_if_worth_to_wakeup(pos, nvm)
	local inv = M(pos):get_inventory()
	if not nvm.output or not nvm.num_recipe then
		return false
	end
	local recipe = Recipes[nvm.output] and Recipes[nvm.output][nvm.num_recipe]
	if not recipe then
		return false
	end
	-- check dst inv
	local stack = ItemStack(nvm.output)
	stack:set_count(recipe.number)
	if not inv:room_for_item("dst", stack) then
		return false
	end
	-- check src inv
	local list = inv:get_list("src")
	for _,item in ipairs(recipe.input) do
		if not remove_item_from_list(list, item) then
			return false
		end
	end
	return true
end

function techage.furnace.smelting(pos, nvm, elapsed)
	local inv = M(pos):get_inventory()
	local state = techage.RUNNING
	if inv and not inv:is_empty("src") then
		if not nvm.output or not nvm.num_recipe then
			return techage.FAULT, "recipe error"
		end
		local recipe = Recipes[nvm.output] and Recipes[nvm.output][nvm.num_recipe]
		if not recipe then
			return techage.FAULT, "recipe error"
		end

		elapsed = elapsed + (nvm.leftover or 0)
		while elapsed >= recipe.time do
			state = process(inv, recipe, nvm.output)
			if state ~= techage.RUNNING then
				return state
			end
			elapsed = elapsed - recipe.time
		end
		nvm.leftover = elapsed
		if recipe.time >= 10 then
			nvm.item_percent = math.min(math.floor((nvm.leftover * 100.0) / recipe.time), 100)
		else
			nvm.item_percent = 100
		end
		return state
	end
	return techage.STANDBY
end

function techage.furnace.get_output(nvm, ingr, idx)
	local tbl = get_recipes(ingr)
	idx = range(idx, 1, #tbl)
	nvm.output = tbl[idx] or tbl[1]
	nvm.num_recipe = all_ingredients_available(nvm.output, ingr)
	return nvm.output
end

function techage.furnace.get_num_recipes(ingr)
	return #get_recipes(ingr)
end

function techage.furnace.reset_cooking(nvm)
	nvm.leftover = 0
	nvm.item_percent = 0
end


techage.recipes.register_craft_type("ta3_melting", {
	description = S("TA3 Melting"),
	icon = "techage_concrete.png^techage_appl_furnace.png^techage_frame_ta3.png",
	width = 2,
	height = 2,
})

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
		waste = recipe.waste,
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

	recipe.items = recipe.recipe
	recipe.type = "ta3_melting"
	techage.recipes.register_craft(recipe)
end
