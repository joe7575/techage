--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2/TA3/TA4 Chest
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local PlayerActions = {}
local InventoryState = {}


local function store_action(pos, player, action, stack)
	local meta = minetest.get_meta(pos)
	local name = player and player:get_player_name() or ""
	local number = meta:get_string("number")
	local item = stack:get_name().." "..stack:get_count()
	PlayerActions[number] = {name, action, item}
end	

local function send_off_command(pos)
	local meta = minetest.get_meta(pos)
	local dest_num = meta:get_string("dest_num")
	local own_num = meta:get_string("number")
	local owner = meta:get_string("owner")
	techage.send_message(dest_num, owner, nil, "off", own_num)
end


local function send_command(pos)
	local meta = minetest.get_meta(pos)
	local dest_num = meta:get_string("dest_num")
	if dest_num ~= "" then
		local own_num = meta:get_string("number")
		local owner = meta:get_string("owner")
		techage.send_message(dest_num, owner, nil, "on", own_num)
		minetest.after(1, send_off_command, pos)
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	store_action(pos, player, "put", stack)
	send_command(pos)
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	store_action(pos, player, "take", stack)
	send_command(pos)
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
	techage.remove_node(pos)
end

local function formspec2()
	return "size[9,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0.5,0;8,4;]"..
	"list[current_player;main;0.5,4.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

minetest.register_node("techage:chest_ta2", {
	description = I("TA2 Protected Chest"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_front_ta3.png",
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 32)
	end,
	
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:chest_ta2")
		meta:set_string("number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec2())
		meta:set_string("infotext", I("TA2 Protected Chest").." "..number)
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

local function formspec3()
	return "size[10,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0,0;10,4;]"..
	"list[current_player;main;1,4.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

minetest.register_node("techage:chest_ta3", {
	description = I("TA3 Protected Chest"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_front_ta3.png",
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 40)
	end,
	
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:chest_ta3")
		meta:set_string("number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec3())
		meta:set_string("infotext", I("TA3 Protected Chest").." "..number)
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

local function formspec4()
	return "size[10,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0,0;10,5;]"..
	"list[current_player;main;1,5.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

minetest.register_node("techage:chest_ta4", {
	description = I("TA4 Protected Chest"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_front_ta4.png",
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 50)
	end,
	
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:chest_ta4")
		meta:set_string("number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec4())
		meta:set_string("infotext", I("TA4 Protected Chest").." "..number)
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
	type = "shapeless",
	output = "techage:chest_ta2",
	recipe = {"default:chest", "techage:tubeS", "default:steel_ingot"}
})

techage.register_node("techage:chest_ta2", {"techage:chest_ta3", "techage:chest_ta4"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(inv, "main", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	
	on_recv_message = function(pos, topic, payload)
		if topic == "state" then
			local meta = minetest.get_meta(pos)
			return techage.get_inv_state(meta, "main")
		elseif topic == "player_action" then
			local meta = minetest.get_meta(pos)
			local number = meta:get_string("number")
			return PlayerActions[number]
		elseif topic == "set_numbers" then
			if techage.check_numbers(payload) then
				local meta = minetest.get_meta(pos)
				meta:set_string("dest_num", payload)
				local number = meta:get_string("number")
				meta:set_string("infotext", I("TA2 Protected Chest").." "..number.." connected with "..payload)
				return true
			end
		else
			return "unsupported"
		end
	end,
})	
