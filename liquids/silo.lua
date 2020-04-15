--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3/TA4 Powder Silo

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local LQD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).liquid end
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local INV_SIZE = 8

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local nvm = techage.get_nvm(pos)
	nvm.item_name = nil
	local inv = minetest.get_meta(pos):get_inventory()
	if inv:is_empty(listname) then
		return stack:get_count()
	end
	if inv:contains_item(listname, ItemStack(stack:get_name())) then
		return stack:get_count()
	end
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local nvm = techage.get_nvm(pos)
	nvm.item_name = nil
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
		local inv = M(pos):get_inventory()
		local stack = ItemStack(name.." "..amount)
		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
			return 0
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
			return inv:remove_item("main", stack):get_count(), name
		end
		return 0
	end,
}

local tNetworks = {
	pipe2 = {
		sides = techage.networks.AllSides, -- Pipe connection sides
		ntype = "tank",
	},
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
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos)
	end,
	liquid = tLiquid,
	networks = tNetworks,
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
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos)
	end,
	liquid = tLiquid,
	networks = tNetworks,
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
			return techage.get_items(pos, inv, "main", num) 
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local inv = M(pos):get_inventory()
		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
			return true
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = M(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local meta = M(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		else
			return "unsupported"
		end
	end,
})	

Pipe:add_secondary_node_names({"techage:ta3_silo", "techage:ta4_silo"})

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
