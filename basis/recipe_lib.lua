--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	Recipe lib for formspecs

]]--

local S = techage.S
local M = minetest.get_meta

local Recipes = {}  -- {rtype = {ouput = {....},...}}
local NormalizedRecipes = {}  -- {output = "", items = {...}}

local range = techage.in_range

techage.recipes = {}

local RECIPE = {
     output = {name = "", num = 0},
     waste = {name = "", num = 0},
     input = {                    
         {name = "", num =0},
         {name = "", num =0},
         {name = "", num =0},
         {name = "", num =0},
     },
 }


-- Formspec
local function input_string(recipe)
	local tbl = {}
	for idx, item in ipairs(recipe.input) do
		local x = ((idx-1) % 2)
		local y = math.floor((idx-1) / 2)
		tbl[idx] = techage.item_image(x, y, item.name.." "..item.num)
	end
	return table.concat(tbl, "")
end

function techage.recipes.get(nvm, rtype)
	local recipes = Recipes[rtype] or {}
	return recipes[nvm.recipe_idx or 1]
end
	
-- Add 4 input/output/waste recipe
-- {
--     output = "<item-name> <units>",  -- units = 1..n
--     waste = "<item-name> <units>",   -- units = 1..n
--     input = {                        -- up to 4 items
--         "<item-name> <units>",
--         "<item-name> <units>",
--     },
-- }
function techage.recipes.add(rtype, recipe)
	if not Recipes[rtype] then
		Recipes[rtype] = {}
	end
	
	local name, num, output
	local item = {input = {}}
	for idx = 1,4 do
		local inp = recipe.input[idx] or ""
		name, num = unpack(string.split(inp, " "))
		item.input[idx] = {name = name or "", num = tonumber(num) or 0}
	end
	if recipe.waste then 
		name, num = unpack(string.split(recipe.waste, " "))
	else
		name, num = "", "0"
	end
	item.waste = {name = name or "", num = tonumber(num) or 0}
	name, num = unpack(string.split(recipe.output, " "))
	item.output = {name = name or "", num = tonumber(num) or 0}
	item.catalyst = recipe.catalyst
	Recipes[rtype][#Recipes[rtype]+1] = item
	output = name

	if minetest.global_exists("unified_inventory") then
		unified_inventory.register_craft({
			output = recipe.output, 
			items = recipe.input,
			type = rtype,
		})
	end
	NormalizedRecipes[output] = {
			output = recipe.output, 
			items = recipe.input,
	}
end

function techage.recipes.formspec(x, y, rtype, nvm)
	local recipes = Recipes[rtype] or {}
	nvm.recipe_idx = range(nvm.recipe_idx or 1, 1, #recipes)
	local idx = nvm.recipe_idx
	local recipe = recipes[idx] or RECIPE
	local output = recipe.output.name.." "..recipe.output.num
	local waste = recipe.waste.name.." "..recipe.waste.num
	local catalyst = recipe.catalyst and techage.item_image_small(2.05, 0, recipe.catalyst, S("Catalyst")) or ""
	return "container["..x..","..y.."]"..
		"background[0,0;4,3;techage_form_grey.png]"..
		input_string(recipe)..
		"image[2,0.7;1,1;techage_form_arrow.png]"..
		catalyst..
		techage.item_image(2.95, 0, output)..
		techage.item_image(2.95, 1, waste)..
		"button[0,2;1,1;priv;<<]"..
		"button[1,2;1,1;next;>>]"..
		"label[1.9,2.2;"..S("Recipe")..": "..idx.."/"..#recipes.."]"..
		"container_end[]"
end

function techage.recipes.on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	
	nvm.recipe_idx = nvm.recipe_idx or 1
	if not nvm.running then	
		if fields.next == ">>" then
			nvm.recipe_idx = nvm.recipe_idx + 1
		elseif fields.priv == "<<" then
			nvm.recipe_idx = nvm.recipe_idx - 1
		end
	end
end

function techage.recipes.get_recipe(name)
	return NormalizedRecipes[name]
end
	