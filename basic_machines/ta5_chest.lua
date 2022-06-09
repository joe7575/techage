--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Hyperloop Chest

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local TA4_INV_SIZE = 32
local EX_POINTS = 20

local hyperloop = techage.hyperloop
local remote_pos = techage.hyperloop.remote_pos
local shared_inv = techage.shared_inv
local menu = techage.menu

local function formspec(pos)
	local ndef = minetest.registered_nodes["techage:ta5_hl_chest"]
	local status = M(pos):get_string("conn_status")
	if hyperloop.is_client(pos) or hyperloop.is_server(pos) then
		local title = ndef.description .. " " .. status
		return "size[8,9]"..
			"box[0,-0.1;7.8,0.5;#c6e8ff]" ..
			"label[0.2,-0.1;" .. minetest.colorize( "#000000", title) .. "]" ..
			"list[context;main;0,1;8,4;]"..
			"list[current_player;main;0,5.3;8,4;]"..
			"listring[context;main]"..
			"listring[current_player;main]"
	else
		return menu.generate_formspec(pos, ndef, hyperloop.SUBMENU)
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	shared_inv.before_inv_access(pos, listname)
	local inv = minetest.get_inventory({type="node", pos=pos})
	if inv:room_for_item(listname, stack) then
		return stack:get_count()
	end
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	shared_inv.before_inv_access(pos, listname)
	local inv = minetest.get_inventory({type="node", pos=pos})
	if inv:contains_item(listname, stack) then
		return stack:get_count()
	end
	return 0
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if shared_inv.before_inv_access(pos, "main") then
		return 0
	end
	return count
end

minetest.register_node("techage:ta5_hl_chest", {
	description = S("TA5 Hyperloop Chest"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_chest_front_ta4.png",
	},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 32)
		local number = techage.add_node(pos, "techage:ta5_hl_chest")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec(pos))
		meta:set_string("infotext", S("TA5 Hyperloop Chest").." "..number)
		hyperloop.after_place_node(pos, placer, "chest")
	end,
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		if techage.get_expoints(player) >= EX_POINTS then
			if techage.menu.eval_input(pos, hyperloop.SUBMENU, fields) then
				hyperloop.after_formspec(pos, fields)
				shared_inv.on_rightclick(pos, player, "main")
				M(pos):set_string("formspec", formspec(pos))
			end
		end
	end,
	on_timer = shared_inv.node_timer,
	on_rightclick = function(pos, node, clicker)
		shared_inv.on_rightclick(pos, clicker, "main")
		M(pos):set_string("formspec", formspec(pos))
	end,
	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		shared_inv.before_inv_access(pos, "main")
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("main")
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		hyperloop.after_dig_node(pos, oldnode, oldmetadata, digger)
		techage.del_mem(pos)
	end,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	on_metadata_inventory_put = shared_inv.after_inv_access,
	on_metadata_inventory_take = shared_inv.after_inv_access,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


techage.register_node({"techage:ta5_hl_chest"}, {
	on_inv_request = function(pos, in_dir, access_type)
		pos = remote_pos(pos)
		local meta = minetest.get_meta(pos)
		return meta:get_inventory(), "main"
	end,
	on_pull_item = function(pos, in_dir, num, item_name)
		pos = remote_pos(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "main", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		if techage.hyperloop.is_paired(pos) then
			pos = remote_pos(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.put_items(inv, "main", stack)
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		pos = remote_pos(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			pos = remote_pos(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 131 then  -- Chest State
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return 0, {techage.get_inv_state_num(inv, "main")}
		else
			return 2, ""
		end
	end,
})


minetest.register_craft({
	type = "shapeless",
	output = "techage:ta5_hl_chest",
	recipe = {"techage:chest_ta4", "techage:ta5_aichip"}
})
