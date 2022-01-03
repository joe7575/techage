--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Meltingpot to produce metal and alloy ingots

]]--

local S = techage.S

local SMELTING_TIME = 2

local Tabs = S("Menu,Recipes")

local Recipes = {}     -- registered recipes
local KeyList = {}     -- index to Recipes key translation
local NumRecipes = 0
local Cache = {}       -- store melting pot inventory data

-- formspec images
local function draw(images)
	local tbl = {}
	for y=0,4 do
		for x=0,4 do
			local idx = 1 + x + y * 5
			local img = images[idx]
			if img ~= false then
				tbl[#tbl+1] = "image["..(x*0.8)..","..(y*0.8)..";0.8,0.8;"..img..".png]"
			end
		end
	end
	return table.concat(tbl)
end

local formspec1 =
	"size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"tabheader[0,0;tab;"..Tabs..";1;;true]"..
	"label[1,0.2;"..S("Menu").."]"..

	"container[1,1]"..
	"list[current_name;src;0,0;2,2;]"..
	"item_image[2.6,0;0.8,0.8;techage:meltingpot]"..
	"image[2.3,0.6;1.6,1;gui_furnace_arrow_bg.png^[transformR270]"..
	"list[current_name;dst;4,0;2,2;]"..
	"container_end[]"..

	"list[current_player;main;0,4;8,4;]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"

local function formspec2(idx)
	idx = math.min(idx, #KeyList)
	local key = KeyList[idx]
	local input1 = Recipes[key].input[1] or ""
	local input2 = Recipes[key].input[2] or ""
	local input3 = Recipes[key].input[3] or ""
	local input4 = Recipes[key].input[4] or ""
	local num = Recipes[key].number
	local heat = Recipes[key].heat
	local time = Recipes[key].time
	local output = Recipes[key].output
	if num > 1 then
		output = output.." "..num
	end
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"tabheader[0,0;tab;"..Tabs..";2;;true]"..
	"label[1,0.2;"..S("Melting Guide").."]"..

	"container[1,1]"..
	"item_image_button[0,0;1,1;"..input1..";b1;]"..
	"item_image_button[1,0;1,1;"..input2..";b2;]"..
	"item_image_button[0,1;1,1;"..input3..";b3;]"..
	"item_image_button[1,1;1,1;"..input4..";b4;]"..
	"item_image[2.6,0;0.8,0.8;techage:meltingpot]"..
	"image[2.3,0.6;1.6,1;gui_furnace_arrow_bg.png^[transformR270]"..
	"item_image_button[4,0.5;1,1;"..output..";b5;]"..
	"label[2,2.2;"..S("Heat")..": "..heat.."  /  "..S("Time")..": "..time.." s]"..
	"label[2,4;Recipe "..idx.." of "..NumRecipes.."]"..
	"button[2,5.5;1,1;priv;<<]"..
	"button[3,5.5;1,1;next;>>]"..
	"container_end[]"
end

local function on_receive_fields(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	local recipe_idx = meta:get_int("recipe_idx")
	if recipe_idx == 0 then recipe_idx = 1 end
	if fields.tab == "1" then
		meta:set_string("formspec", formspec1)
	elseif fields.tab == "2" then
		meta:set_string("formspec", formspec2(recipe_idx))
	elseif fields.next == ">>" then
		recipe_idx = math.min(recipe_idx + 1, NumRecipes)
		meta:set_int("recipe_idx", recipe_idx)
		meta:set_string("formspec", formspec2(recipe_idx))
	elseif fields.priv == "<<" then
		recipe_idx = math.max(recipe_idx - 1, 1)
		meta:set_int("recipe_idx", recipe_idx)
		meta:set_string("formspec", formspec2(recipe_idx))
	end
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

-- generate an unique key based on the unsorted and
-- variable number of inventory items
local function recipe_key(items)
	local tbl = {}
	-- remove items which exist more than once
	for _,item in ipairs(items) do
		tbl[item] = true
	end
	local names = {}
	for key,_ in pairs(tbl) do
		names[#names + 1] = key
	end
	-- bring in a sorted order
	table.sort(names)
	return table.concat(names, "-")
end

-- determine recipe based on inventory items
local function get_recipe(inv)
	-- collect items
	local stacks = {}
	local names = {}
	for _,stack in ipairs(inv:get_list("src")) do
		if not stack:is_empty() then
			table.insert(names, stack:get_name())
			table.insert(stacks, stack)
		else
			table.insert(stacks, ItemStack(""))
		end
	end
	local key = recipe_key(names)
	local recipe = Recipes[key]

	if recipe then
		return {
			input = recipe.input,
			stacks = stacks,
			output = ItemStack(recipe.output.." "..recipe.number),
			heat = recipe.heat,
			time = recipe.time,
		}
	end
	return nil
end

-- prepare recipe and store in cache table for faster access
local function store_recipe_in_cache(pos)
	local hash = minetest.hash_node_position(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local recipe = get_recipe(inv)
	Cache[hash] = recipe
	return recipe
end

-- read value from the node below
local function get_heat(pos)
	local heat = 0
	pos.y = pos.y - 1
	local node = techage.get_node_lvm(pos)
	local meta = minetest.get_meta(pos)
	if minetest.get_item_group(node.name, "techage_flame") == 0 then
		pos.y = pos.y + 1
		return 0
	end

	pos.y = pos.y - 1
	node = techage.get_node_lvm(pos)
	pos.y = pos.y + 2
	if minetest.get_item_group(node.name, "techage_flame") == 0 and
			node.name ~= "techage:charcoal_burn" then
		return 0
	end

	return meta:get_int("heat")
end

-- Start melting if heat is ok AND source items available
function techage.switch_to_active(pos)
	local meta = minetest.get_meta(pos)
	local heat = get_heat(pos)
	local recipe = store_recipe_in_cache(pos)

	if recipe and heat >= recipe.heat then
		minetest.swap_node(pos, {name = "techage:meltingpot_active"})
		minetest.registered_nodes["techage:meltingpot_active"].on_construct(pos)
		meta:set_string("infotext", S("Melting Pot active (heat=")..heat..")")
		minetest.get_node_timer(pos):start(2)
		return true
	end
	meta:set_string("infotext", S("Melting Pot inactive (heat=")..heat..")")
	return false
end

function techage.update_heat(pos)
	local meta = minetest.get_meta(pos)
	local heat = get_heat(pos)
	meta:set_string("infotext", S("Melting Pot inactive (heat=")..heat..")")
end

local function set_inactive(meta, pos, heat)
	minetest.get_node_timer(pos):stop()
	minetest.swap_node(pos, {name = "techage:meltingpot"})
	minetest.registered_nodes["techage:meltingpot"].on_construct(pos)
	meta:set_string("infotext", S("Melting Pot inactive (heat=")..heat..")")
end

-- Stop melting if heat to low OR no source items available
local function switch_to_inactive(pos)
	local meta = minetest.get_meta(pos)
	local heat = get_heat(pos)
	local hash = minetest.hash_node_position(pos)
	local recipe = Cache[hash] or store_recipe_in_cache(pos)

	if not recipe or heat < recipe.heat then
		set_inactive(meta, pos, heat)
		return true
	end
	meta:set_string("infotext", S("Melting Pot active (heat=")..heat..")")
	return false
end


local function index(list, x)
	for idx, v in pairs(list) do
		if v == x then return idx end
	end
	return nil
end

-- move recipe src items to output inventory
local function process(inv, recipe, heat)
	if heat < recipe.heat then
		return false
	end
	local res = false
	if inv:room_for_item("dst", recipe.output) then
		for _,item in ipairs(recipe.input) do
			res = false
			for _, stack in ipairs(recipe.stacks) do
				if stack:get_count() > 0 and stack:get_name() == item then
					stack:take_item(1)
					res = true
					break
				end
			end
			if res == false then
				return false
			end
		end
		inv:add_item("dst", recipe.output)
		inv:set_list("src", recipe.stacks)
		return true
	end
	return false
end

local function smelting(pos, recipe, heat, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	elapsed = elapsed + meta:get_int("leftover")

	while elapsed >= recipe.time do
		if process(inv, recipe, heat) == false then
			meta:set_int("leftover", 0)
			set_inactive(meta, pos, heat)
			return false
		end
		elapsed = elapsed - recipe.time
	end
	meta:set_int("leftover", elapsed)
	return true
end

local function pot_node_timer(pos, elapsed)
	if switch_to_inactive(pos) == false then
		local hash = minetest.hash_node_position(pos)
		local heat = get_heat(pos)
		local recipe = Cache[hash] or store_recipe_in_cache(pos)
		if recipe then
			return smelting(pos, recipe, heat, elapsed)
		end
	end
	return false
end

minetest.register_node("techage:meltingpot_active", {
	description = S("TA1 Melting Pot"),
	tiles = {
		{
			image = "techage_meltingpot_top_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1,
			},
		},
		"default_cobble.png^techage_meltingpot.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-10/16, -8/16, -10/16,  10/16, 9/16,  -6/16},
			{-10/16, -8/16,   6/16,  10/16, 9/16,  10/16},
			{-10/16, -8/16, -10/16,  -6/16, 9/16,  10/16},
			{  6/16, -8/16, -10/16,  10/16, 9/16,  10/16},
			{ -6/16, -8/16,  -6/16,   6/16, 5/16,   6/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-10/16, -8/16, -10/16,  10/16, 9/16,  10/16},
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec1)
		local inv = meta:get_inventory()
		inv:set_size('src', 4)
		inv:set_size('dst', 4)
	end,

	on_timer = function(pos, elapsed)
		return pot_node_timer(pos, elapsed)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_fields(pos, formname, fields, sender)
	end,

	on_metadata_inventory_move = function(pos)
		store_recipe_in_cache(pos)
		switch_to_inactive(pos)
	end,

	on_metadata_inventory_put = function(pos)
		store_recipe_in_cache(pos)
		switch_to_inactive(pos)
	end,

	on_metadata_inventory_take = function(pos)
		store_recipe_in_cache(pos)
		switch_to_inactive(pos)
	end,

	can_dig = can_dig,

	drop = "techage:meltingpot",
	is_ground_content = false,
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

minetest.register_node("techage:meltingpot", {
	description = S("TA1 Melting Pot"),
	tiles = {
		"default_cobble.png",
		"default_cobble.png^techage_meltingpot.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-10/16, -8/16, -10/16, 10/16,  9/16, -6/16},
			{-10/16, -8/16,   6/16, 10/16,  9/16, 10/16},
			{-10/16, -8/16, -10/16, -6/16,  9/16, 10/16},
			{  6/16, -8/16, -10/16, 10/16,  9/16, 10/16},
			{ -6/16, -8/16,  -6/16,  6/16, -4/16,  6/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-10/16, -8/16, -10/16, 10/16, 9/16, 10/16},
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec1)
		meta:set_string("infotext", S("Melting Pot inactive (heat=0)"))
		local inv = meta:get_inventory()
		inv:set_size('src', 4)
		inv:set_size('dst', 4)
	end,

	on_metadata_inventory_move = function(pos)
		store_recipe_in_cache(pos)
		techage.switch_to_active(pos)
	end,

	on_metadata_inventory_put = function(pos)
		store_recipe_in_cache(pos)
		techage.switch_to_active(pos)
	end,

	on_metadata_inventory_take = function(pos)
		store_recipe_in_cache(pos)
		techage.switch_to_active(pos)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_fields(pos, formname, fields, sender)
	end,

	can_dig = can_dig,

	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_metal_defaults(),

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

minetest.register_craft({
	output = "techage:meltingpot",
	recipe = {
		{"default:cobble", "default:copper_ingot", "default:cobble"},
		{"default:cobble", "",                     "default:cobble"},
		{"default:cobble", "default:cobble",       "default:cobble"},
	},
})

techage.recipes.register_craft_type("melting", {
	description = S("TA1 Melting"),
	icon = "default_cobble.png^techage_meltingpot.png",
	width = 2,
	height = 2,
})
techage.recipes.register_craft_type("burning", {
	description = S("TA1 Burning"),
	icon = "techage_smoke.png",
	width = 1,
	height = 1,
})
techage.recipes.register_craft({
	output = "techage:charcoal",
	items = {"group:wood"},
	type = "burning",
})

function techage.ironage_register_recipe(recipe)
	local key = recipe_key(recipe.recipe)
	local output = string.split(recipe.output, " ")
	local number = tonumber(output[2] or 1)
	table.insert(KeyList, key)
	Recipes[key] = {
		input = recipe.recipe,
		output = output[1],
		number = number,
		heat = math.max(recipe.heat or 3, 2),
		time = math.max(recipe.time or 2, 2*number),
	}
	NumRecipes = NumRecipes + 1

	recipe.items = recipe.recipe
	recipe.type = "melting"
	techage.recipes.register_craft(recipe)
end
