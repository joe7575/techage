--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Cooking routines for furnace
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local range = techage.range

local Recipes = {}     -- registered recipes
local Ingredients = {}
local KeyList = {}     -- index to Recipes key translation

techage.furnace = {}

-- Return a list with all outputs of the given list of ingredients
local function get_recipes(ingr)
	if #ingr > 0 then
		local tbl = {}
		for _,item in ipairs(ingr) do
			if Ingredients[item] then
				for _,output in ipairs(Ingredients[item]) do
					tbl[#tbl+1] = output
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
local function process(inv, recipe)
	local res
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
	local stack = ItemStack(recipe.output)
	stack:set_count(recipe.number)
	inv:add_item("dst", stack)
	return true
end		

function techage.furnace.smelting(pos, mem, elapsed)
	local inv = M(pos):get_inventory()
	local state = techage.STANDBY
	if inv and not inv:is_empty("src") then
		local key = KeyList[mem.recipe_idx or 1] or KeyList[1]
		local recipe = Recipes[key]
		-- check dst inv
		local item = ItemStack(recipe.output)
		if not inv:room_for_item("dst", item) then
			return techage.BLOCKED
		end
			
		elapsed = elapsed + (mem.leftover or 0)
		while elapsed >= recipe.time do
			if process(inv, recipe) == false then 
				mem.leftover = 0
				return techage.STANDBY
			else
				state = techage.RUNNING
			end
			elapsed = elapsed - recipe.time
		end
		mem.leftover = elapsed
		return state
	end
	return techage.STANDBY
end

function techage.furnace.get_output(ingr, idx)
	local tbl = get_recipes(ingr)
	idx = range(idx, 1, #tbl)
	local key = tbl[idx] or tbl[1]
	if  Recipes[key] then
		return Recipes[key].output
	end
	return Recipes[KeyList[1]].output
end

function techage.furnace.get_num_recipes(ingr)
	return #get_recipes(ingr)
end

function techage.furnace.reset_cooking(mem)
	mem.leftover = 0
end


if minetest.global_exists("unified_inventory") then
	unified_inventory.register_craft_type("ta3_melting", {
		description = I("TA3 Melting"),
		icon = "techage_concrete.png^techage_appl_furnace.png^techage_frame_ta3.png",
		width = 2,
		height = 2,
	})
end

function techage.furnace.register_recipe(recipe)
	local output = string.split(recipe.output, " ")
	local number = tonumber(output[2] or 1)
	table.insert(KeyList, output)
	Recipes[output] = {
		input = recipe.recipe,
		output = output[1],
		number = number,
		time = math.max((recipe.time or 3) * number, 2),
	}
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