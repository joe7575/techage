--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Recipe Block for the TA4 Autocrafter
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local MAX_RECIPE = 10

local function recipes_formspec(x, y, idx)
	return "container[" .. x .. "," .. y .. "]" ..
		"background[0,0;8,3.2;techage_form_grey.png]" ..
		"list[context;input;0.1,0.1;3,3;]" ..
		"image[3,1.1;1,1;techage_form_arrow.png]" ..
		"list[context;output;3.9,1.1;1,1;]" ..
		"button[5.5,1.1;1,1;priv;<<]" ..
		"button[6.5,1.1;1,1;next;>>]" ..
		"label[5.5,0.5;"..S("Recipe") .. ": " .. idx .. "/" .. MAX_RECIPE .. "]"  ..
		"container_end[]"
end

local function formspec(pos, nvm)
	return "size[8,7.4]"..
		recipes_formspec(0, 0, nvm.recipe_idx or 1) ..
		"list[current_player;main;0,3.6;8,4;]" ..
		"listring[current_player;main]"..
		"listring[context;src]" ..
		"listring[current_player;main]"..
		"listring[context;dst]" ..
		"listring[current_player;main]"
end

local function determine_new_input(pos, inv)
	local output = inv:get_stack("output", 1):get_name()
	if output and output ~= "" then
		local recipe = minetest.get_craft_recipe(output)
		if recipe.items and recipe.type == "normal" then
			for i = 1, 9 do
				local name = recipe.items[i]
				if name then
					if minetest.registered_items[name] then
						inv:set_stack("input", i, name)
					end
				end
			end
			inv:set_stack("output", 1, recipe.output)
		end
	else
		for i = 1, 9 do
			inv:set_stack("input", i, nil)
		end
	end
end

local function determine_new_output(pos, inv)
	local items = {}
	for i = 1, 9 do
		items[i] = inv:get_stack("input", i):get_name()
	end
	local input = {
		method = "normal",
		width = 3,
		items = items,
	}
	local output, _ = minetest.get_craft_result(input)
	inv:set_stack("output", 1, output.item)
end

local function get_recipe(inv)
	local items = {}
	local last_idx = 0
	for i = 1, 9 do
		local name = inv:get_stack("input", i):get_name()
		if name ~= "" then
			last_idx = i
		end
		items[i] = name
	end
	local input = table.concat(items, ",", 1, last_idx)
	local stack = inv:get_stack("output", 1)
	return {
		input = input,
		output = stack:get_name() .. " " .. stack:get_count()
	}
end

local function after_recipe_change(pos, inv, listname)
	if listname == "input" then
		determine_new_output(pos, inv)
	else
		determine_new_input(pos, inv)
	end
	local nvm = techage.get_nvm(pos)
	nvm.recipes = nvm.recipes or {}
	nvm.recipes[nvm.recipe_idx or 1] = get_recipe(inv)
end

local function update_inventor(pos, inv, idx)
	local nvm = techage.get_nvm(pos)
	nvm.recipes = nvm.recipes or {}
	local recipe = nvm.recipes[idx]
	if recipe then
		local items = string.split(recipe.input, ",", true)
		for i = 1, 9 do
			inv:set_stack("input", i, items[i] or "")
		end
		inv:set_stack("output", 1, recipe.output)
	else
		for i = 1, 9 do
			inv:set_stack("input", i, nil)
		end
		inv:set_stack("output", 1, nil)
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	local inv = M(pos):get_inventory()
	local list = inv:get_list(listname)
	stack:set_count(1)
	inv:set_stack(listname, index, stack)
	after_recipe_change(pos, inv, listname)
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	local inv = M(pos):get_inventory()
	inv:set_stack(listname, index, nil)
	after_recipe_change(pos, inv, listname)
	return 0
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	local inv = M(pos):get_inventory()
	if from_list == to_list then
		minetest.after(0.1, after_recipe_change, pos, inv, from_list)
		return 1
	end
	return 0
end

minetest.register_node("techage:ta4_recipeblock", {
	description = S("TA4 Recipe Block"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_recipeblock.png",
	},

	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('input', 9)
		inv:set_size('output', 1)
	end,

	after_place_node = function(pos, placer, itemstack)
		local nvm = techage.get_nvm(pos)
		local number = techage.add_node(pos, "techage:ta4_chest")
		M(pos):set_string("owner", placer:get_player_name())
		M(pos):set_string("node_number", number)
		M(pos):set_string("formspec", formspec(pos, nvm))
		M(pos):set_string("infotext", S("TA4 Recipe Block") .. " " .. number)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local nvm = techage.get_nvm(pos)
		nvm.recipe_idx = nvm.recipe_idx or 1
		if fields.next == ">>" then
			nvm.recipe_idx = techage.in_range(nvm.recipe_idx + 1, 1, MAX_RECIPE)
		elseif fields.priv == "<<" then
			nvm.recipe_idx = techage.in_range(nvm.recipe_idx - 1, 1, MAX_RECIPE)
		end
		local inv = M(pos):get_inventory()
		update_inventor(pos, inv, nvm.recipe_idx or 1)
		M(pos):set_string("formspec", formspec(pos, nvm))
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.register_node({"techage:ta4_recipeblock"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "input" and payload and payload ~= "" then
			nvm.recipes = nvm.recipes or {}
			local recipe = nvm.recipes[tonumber(payload) or 1]
			if recipe then
				return recipe.input
			end
		else
			return "unsupported"
		end
	end,
})

minetest.register_craft({
	output = "techage:ta4_recipeblock",
	recipe = {
		{"techage:ta4_carbon_fiber", "dye:blue", "techage:aluminum"},
		{"", "basic_materials:ic", ""},
		{"default:steel_ingot", "techage:ta4_wlanchip", "default:steel_ingot"},
	},
})
