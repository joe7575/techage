--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Powder Silo

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local LQD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).liquid end
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

local INV_SIZE = 8
local STACKMAX = 99

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	-- check if it is powder or techage liquid item (migration function)
	local ndef = minetest.registered_craftitems[stack:get_name()] or
			minetest.registered_items[stack:get_name()] or {}
	if ndef.groups and (ndef.groups.powder == 1 or ndef.groups.ta_liquid == 1) then
		local nvm = techage.get_nvm(pos)
		nvm.item_name = nil
		nvm.item_count = nil
		local inv = minetest.get_meta(pos):get_inventory()
		if inv:is_empty(listname) then
			return stack:get_count()
		end
		if inv:contains_item(listname, ItemStack(stack:get_name())) then
			return stack:get_count()
		end
	end
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local nvm = techage.get_nvm(pos)
	nvm.item_name = nil
	nvm.item_count = nil
	return stack:get_count()
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("main")
end

local function get_item_name(nvm, inv)
	for idx = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", idx)
		if stack:get_count() > 0 then
			nvm.item_name = stack:get_name()
			return nvm.item_name
		end
	end
end

local function get_item_count(pos)
	local inv = M(pos):get_inventory()
	local count = 0
	for idx = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", idx)
		count = count + stack:get_count()
	end
	return count
end

local function get_silo_capa(pos)
	local inv = M(pos):get_inventory()
	for idx = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", idx)
		if stack:get_count() > 0 then
			return inv:get_size("main") * stack:get_stack_max()
		end
	end
	return inv:get_size("main") * STACKMAX
end

local function formspec3()
	return "size[8,5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0,0;8,1;]"..
	"list[current_player;main;0,1.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

local function formspec4()
	return "size[8,6]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0,0;8,2;]"..
	"list[current_player;main;0,2.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

local tLiquid = {
	capa = 0,
	peek = function(pos, indir)
		local nvm = techage.get_nvm(pos)
		local inv = M(pos):get_inventory()
		if not inv:is_empty("main") then
			return nvm.item_name or get_item_name(nvm, inv)
		end
	end,
	put = function(pos, indir, name, amount)
		-- check if it is powder
		local nvm = techage.get_nvm(pos)
		local ndef = minetest.registered_craftitems[name] or {}
		if ndef.groups and ndef.groups.powder == 1 then
			local inv = M(pos):get_inventory()
			local stack = ItemStack(name.." "..amount)
			if inv:room_for_item("main", stack) then
				nvm.item_count = nvm.item_count or get_item_count(pos)
				inv:add_item("main", stack)
				nvm.item_count = nvm.item_count + stack:get_count()
				return 0
			end
		end
		return amount
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local inv = M(pos):get_inventory()
		if not name then
			name = nvm.item_name or get_item_name(nvm, inv)
		end
		if name then
			local stack = ItemStack(name.." "..amount)
			nvm.item_count = nvm.item_count or get_item_count(pos)
			local count = inv:remove_item("main", stack):get_count()
			nvm.item_count = nvm.item_count - count
			return count, name
		end
		return 0
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local inv = M(pos):get_inventory()
		local stack = ItemStack(name.." "..amount)
		if inv:room_for_item("main", stack) then
			nvm.item_count = nvm.item_count or get_item_count(pos)
			inv:add_item("main", stack)
			nvm.item_count = nvm.item_count + stack:get_count()
			return 0
		end
		return amount
	end,
}

minetest.register_node("techage:ta3_silo", {
	description = S("TA3 Silo"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_silo.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_silo.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_silo.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_silo.png",
	},
	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('main', INV_SIZE)
	end,
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local number = techage.add_node(pos, "techage:ta3_silo")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec3(nvm))
		meta:set_string("infotext", S("TA3 Silo").." "..number)
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_silo", {
	description = S("TA4 Silo"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_silo.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_silo.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_silo.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_silo.png",
	},
	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('main', INV_SIZE * 2)
	end,
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local number = techage.add_node(pos, "techage:ta4_silo")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec4(nvm))
		meta:set_string("infotext", S("TA4 Silo").." "..number)
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})


techage.register_node({"techage:ta3_silo", "techage:ta4_silo"}, {
	on_pull_item = function(pos, in_dir, num)
		local inv = M(pos):get_inventory()
		if not inv:is_empty("main") then
			local taken = techage.get_items(pos, inv, "main", num)
			local nvm = techage.get_nvm(pos)
			nvm.item_count = nvm.item_count or get_item_count(pos)
			nvm.item_count = nvm.item_count - taken:get_count()
			return taken
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		-- check if it is powder
		local name = stack:get_name()
		local ndef = minetest.registered_craftitems[name] or {}
		if ndef.groups and ndef.groups.powder == 1 then
			local inv = M(pos):get_inventory()

			if inv:is_empty("main")  then
				inv:add_item("main", stack)
				local nvm = techage.get_nvm(pos)
				nvm.item_count = nvm.item_count or get_item_count(pos)
				nvm.item_count = nvm.item_count + stack:get_count()
				return true
			end

			if inv:contains_item("main", name) and inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
				local nvm = techage.get_nvm(pos)
				nvm.item_count = nvm.item_count or get_item_count(pos)
				nvm.item_count = nvm.item_count + stack:get_count()
				return true
			end
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = M(pos)
		local inv = meta:get_inventory()
		local nvm = techage.get_nvm(pos)
		nvm.item_count = nvm.item_count or get_item_count(pos)
		nvm.item_count = nvm.item_count + stack:get_count()
		return techage.put_items(inv, "main", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local meta = M(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		elseif topic == "load" then
			local inv = M(pos):get_inventory()
			local nvm = techage.get_nvm(pos)
			nvm.item_count = nvm.item_count or get_item_count(pos)
			nvm.capa = nvm.capa or get_silo_capa(pos)
			return techage.power.percent(nvm.capa, nvm.item_count), nvm.item_count
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 131 then  -- Chest State
			local meta = M(pos)
			local inv = meta:get_inventory()
			return 0, {techage.get_inv_state_num(inv, "main")}
		elseif topic == 134 then
			local inv = M(pos):get_inventory()
			local nvm = techage.get_nvm(pos)
			nvm.item_count = nvm.item_count or get_item_count(pos)
			nvm.capa = nvm.capa or get_silo_capa(pos)
			if payload[1] == 1 then
				return 0, {techage.power.percent(nvm.capa, nvm.item_count)}
			else
				return 0, {nvm.item_count}
			end
		else
			return 2, ""
		end
	end,
	on_node_load = function(pos)
		local nvm = techage.get_nvm(pos)
		nvm.item_count = nil
	end,
})

liquid.register_nodes({"techage:ta3_silo", "techage:ta4_silo"},	Pipe, "tank", nil, tLiquid)

minetest.register_craft({
	output = "techage:ta3_silo",
	recipe = {
		{"", "", ""},
		{"techage:tubeS", "techage:chest_ta3", "techage:ta3_pipeS"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_silo",
	recipe = {
		{"default:tin_ingot", "dye:blue", "default:steel_ingot"},
		{"", "techage:ta3_silo", ""},
		{"", "", ""},
	},
})
