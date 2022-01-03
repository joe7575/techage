--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Chest for TA2 gravity-based energy storage

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local function valid_weight_items(stack)
	local name = stack:get_name()
	local ndef = minetest.registered_nodes[name]
	if ndef then
		if minetest.get_item_group(name, "stone") > 0 then
			return true
		end
		if minetest.get_item_group(name, "cobble") > 0 then
			return true
		end
		if minetest.get_item_group(name, "gravel") > 0 then
			return true
		end
		if minetest.get_item_group(name, "sand") > 0 then
			return true
		end
	end
end

minetest.register_entity("techage:ta2_weight_chest_entity", {
	initial_properties = {
		physical = true,
		pointable = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "wielditem",
		textures = {"techage:ta2_weight_chest"},
		visual_size = {x=0.66, y=0.66, z=0.66},
		static_save = false,
	},
})

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if not valid_weight_items(stack) then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("main")
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos, oldnode, oldmetadata)
end

local function formspec()
	return "size[8,6.7]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;1.5,0.2;5,2;]"..
	"list[current_player;main;0,3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

minetest.register_node("techage:ta2_weight_chest", {
	description = S("TA2 Weight Chest"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_weight_bottom.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_weight_bottom.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png^techage_weight_side.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png^techage_weight_side.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png^techage_weight_side.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png^techage_weight_side.png",
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 10)
	end,

	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec())
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return techage.logic.set_numbers(pos, numbers, player_name, S("TA2 Weight Chest"))
	end,

	can_dig = can_dig,
	after_dig_node = after_dig_node,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:ta2_weight_chest",
	recipe = {
		{"", "", ""},
		{"basic_materials:steel_strip", "techage:chest_ta2", "basic_materials:steel_strip"},
		{"", "", ""},
	},
})
