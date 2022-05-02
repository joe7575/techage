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

local GROUP_ITEMS = {
	stone = "default:cobble",
	wood = "default:wood",
	book = "default:book",
	sand = "default:sand",
	leaves = "default:leaves",
	stick = "default:stick",
	tree = "default:tree",
	vessel = "vessels:glass_bottle",
	wool = "wool:white",
}


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

local function filter_recipes_based_on_points(recipes, owner)
	local ex_points = 0
	if owner then
		local player = minetest.get_player_by_name(owner)
		ex_points = techage.get_expoints(player) or 0
	end

	local tbl = {}
	for _,item in ipairs(recipes) do
		if ex_points >= (item.ex_points or 0) then
			tbl[#tbl + 1] = item
		end
	end
	return tbl
end


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

function techage.recipes.get(nvm, rtype, owner)
	local recipes = Recipes[rtype] or {}
	if owner then
		recipes = filter_recipes_based_on_points(recipes, owner)
	end
	return recipes[nvm.recipe_idx or 1] or recipes[1]
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
	item.ex_points = recipe.ex_points or 0
	Recipes[rtype][#Recipes[rtype]+1] = item
	output = name

	techage.recipes.register_craft({
		output = recipe.output,
		items = recipe.input,
		type = rtype,
	})
	NormalizedRecipes[output] = {
			output = recipe.output,
			items = recipe.input,
	}
end

function techage.recipes.formspec(x, y, rtype, nvm, owner)
	local recipes = Recipes[rtype] or {}
	recipes = filter_recipes_based_on_points(recipes, owner)
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


function techage.recipes.get_default_group_item_name(item_name)
	if item_name and item_name:sub(1, 6) == "group:" then
		local default_name = GROUP_ITEMS[item_name:sub(7)]
		if default_name then
			return default_name
		end
	end
	return item_name
end

function techage.recipes.add_group_item(group, default_item_name)
	GROUP_ITEMS[group] = default_item_name
end

-------------------------------------------------------------------------------
-- Borrowed from ghaydn
-------------------------------------------------------------------------------
local has_i3 = minetest.get_modpath("i3")
local has_ui = minetest.get_modpath("unified_inventory")
local has_cg = minetest.get_modpath("craftguide")

local function format_i3(input)
	local output = {}
	for _, entry in ipairs(input) do
		local secondput = ""
		if type(entry) == "table" then
			for _, secondtry in ipairs(entry) do
				secondput = secondput..secondtry..","
			end
			table.insert(output, secondput)
		else
			table.insert(output, entry)
		end
	end
	return output
end

techage.recipes.register_craft_type = function(name, def)
	if has_cg then
		local cg_def = {
			description = def.description,
			icon = def.icon,
		}
		craftguide.register_craft_type(name, cg_def)
	end
	if has_i3 then
		local i3_def = {
			description = def.description,
			icon = def.icon,
			width = def.width or 3,
			height = def.height or 3,
			dynamic_display_size = def.dynamic_display_size or nil,
			uses_crafting_grid = def.uses_crafting_grid,
		}
		i3.register_craft_type(name, i3_def)
	end
	if has_ui then
		local ui_def = {
			description = def.description,
			icon = def.icon,
			width = def.width or 3,
			height = def.height or 3,
			dynamic_display_size = def.dynamic_display_size or nil,
			uses_crafting_grid = def.uses_crafting_grid,
		}
		unified_inventory.register_craft_type(name, ui_def)
	end
end

techage.recipes.register_craft = function(def)
	if not def.items then
		if def.input then
			def.items = table.copy(def.input)
		elseif def.recipe then
			def.items = table.copy(def.recipe)
		end
	end
	if not def.result then
		if def.output then def.result = def.output end
	end

	if has_cg then
		local cg_def = {
			result = def.result,
			type = def.type,
			items = def.items,
		}
		craftguide.register_craft(cg_def)
	end
	if has_i3 then

		local i3_def = {
			result = def.result,
			type = def.type,
			items = format_i3(def.items),
			width = def.width or 3,
		}
		i3.register_craft(i3_def)
	end
	if has_ui then
		local ui_def = {
			output = def.result,
			type = def.type,
			items = def.items,
			width = def.width or 3,
			height = def.height or 3,
		}
		unified_inventory.register_craft(ui_def)
	end
end
