--[[

	TechAge
	=======

	Copyright (C) 2017-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end

local InvalidBlocks = {}

local function base_checks(user, pointed_thing, place)
	if pointed_thing.type ~= "node" then
		return false
	end

	if not user then
		return false
	end

	local pos = place and pointed_thing.above or pointed_thing.under
	local player_name = user:get_player_name()

	if minetest.is_protected(pos, player_name) then
		return false
	end

	return true, pos, player_name
end

----------------------------------------------------------------------------
local function add_to_inventory(pos, item, user)
	local inv = user:get_inventory()
	if inv and item and inv:room_for_item("main", item) then
		inv:add_item("main", item)
	else
		minetest.item_drop(item, user, pos)
	end
end

local function take_from_inventory(user)
	local inv = user:get_inventory()
	local stack = inv:get_stack("main", 1)
	local taken = stack:take_item(1)

	if taken:get_count() == 1 then
		local imeta = taken:get_meta()
		if imeta:get_string("node_number") ~= ""  then
			inv:set_stack("main", 1, stack)
			return taken
		end
	end
end

-----------------------------------------------------------------------------
local function remove_node(pos, digger)
	local node = minetest.get_node(pos)
	local number = M(pos):get_string("node_number")
	local item = ItemStack(node.name)
	local imeta = item:get_meta()
	local ndef = minetest.registered_nodes[node.name]
	local oldmetadata = minetest.get_meta(pos):to_table()

	if InvalidBlocks[node.name] then
		return
	end

	if ndef.can_dig and not ndef.can_dig(pos, digger) then
		return
	end

	if ndef and ndef.preserve_nodedata then
		local s = ndef.preserve_nodedata(pos, node)
		imeta:set_string("node_data", s)
		minetest.remove_node(pos)
		if ndef.after_dig_node then
			ndef.after_dig_node(pos, node, oldmetadata, digger)
		end
		if number ~= "" then
			techage.post_remove_node(pos)
			imeta:set_string("node_number", number)
			imeta:set_string("description", ndef.description .. " : " .. number)
		else
			imeta:set_string("description", ndef.description .. " (preserved)")
		end
		return item
	elseif number ~= "" and ndef and ndef.after_dig_node then
		minetest.remove_node(pos)
		ndef.after_dig_node(pos, node, oldmetadata, digger)
		techage.post_remove_node(pos)
		imeta:set_string("node_number", number)
		imeta:set_string("description", ndef.description .. " : " .. number)
		return item
	end 
end

local function place_node(pos, item, placer, pointed_thing)
	local imeta = item:get_meta()
	local number = imeta:get_string("node_number")
	local name = item:get_name()
	local param2 = minetest.dir_to_facedir(placer:get_look_dir())
	local ndef = minetest.registered_nodes[name]

	if ndef and ndef.restore_nodedata then
		if number ~= "" then
			techage.pre_add_node(pos, number)
		end
		minetest.add_node(pos, {name = name, param2 = param2})
		local s = imeta:get_string("node_data")
		ndef.restore_nodedata(pos, s)
		return true
	elseif number ~= "" and ndef and ndef.after_place_node then
		techage.pre_add_node(pos, number)
		minetest.add_node(pos, {name = name, param2 = param2})
		ndef.after_place_node(pos, placer, item, pointed_thing)
		return true
	end
end

----------------------------------------------------------------------------
local function on_place_node(itemstack, pos, user, player_name, pointed_thing)
	local item = take_from_inventory(user)
	if item then
		if place_node(pos, item, user, pointed_thing) then
			itemstack:add_wear(65636/200)
			minetest.sound_play("techage_tool2", {
				pos = pos,
				gain = 1,
				max_hear_distance = 10})
			return itemstack
		else
			add_to_inventory(pos, item, user)
		end
	end
end

local function on_remove_node(itemstack, pos, user, player_name)
	local item = remove_node(pos, user)
	if item then
		add_to_inventory(pos, item, user)
		itemstack:add_wear(65636/200)
		minetest.sound_play("techage_tool1", {
			pos = pos,
			gain = 1,
			max_hear_distance = 10})
	end
	return itemstack
end

----------------------------------------------------------------------------
local function on_place(itemstack, user, pointed_thing)
	local res, pos, player_name = base_checks(user, pointed_thing, true)
	if res then
		return on_place_node(itemstack, pos, user, player_name, pointed_thing)
	end
end

local function on_use(itemstack, user, pointed_thing)
	local res, pos, player_name = base_checks(user, pointed_thing, false)
	if res then
		return on_remove_node(itemstack, pos, user, player_name)
	end
end

----------------------------------------------------------------------------
minetest.register_tool("techage:assembly_tool", {
	description = S("TechAge Assembly Tool"),
	inventory_image = "techage_repairkit.png",
	wield_image = "techage_repairkit.png^[transformR270",
	groups = {cracky=1, book=1},
	on_use = on_use,
	on_place = on_place,
	node_placement_prediction = "",
	stack_max = 1,
})

minetest.register_craft({
	output = "techage:assembly_tool",
	recipe = {
		{"", "techage:screwdriver", ""},
		{"basic_materials:plastic_sheet", "basic_materials:plastic_strip", "basic_materials:plastic_sheet"},
		{"", "techage:end_wrench", ""},
	},
})

minetest.register_alias("techage:repairkit", "techage:assembly_tool")

function techage.disable_block_for_assembly_tool(block_name)
	InvalidBlocks[block_name] = true
end
