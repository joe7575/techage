--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2/TA3/TA4 Chest

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local TA4_INV_SIZE = 50

local MP = minetest.get_modpath(minetest.get_current_modname())
local mConf = dofile(MP.."/basis/conf_inv.lua")

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
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
	techage.del_mem(pos)
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
	description = S("TA2 Protected Chest"),
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
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec2())
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return techage.logic.set_numbers(pos, numbers, player_name, S("TA2 Protected Chest"))
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
	description = S("TA3 Protected Chest"),
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
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec3())
		meta:set_string("infotext", S("TA3 Protected Chest").." "..number)
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return techage.logic.set_numbers(pos, numbers, player_name, S("TA3 Protected Chest"))
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

techage.register_node({"techage:chest_ta2", "techage:chest_ta3"}, {
	on_inv_request = function(pos, in_dir, access_type)
		local meta = minetest.get_meta(pos)
		return meta:get_inventory(), "main"
	end,
	on_pull_item = function(pos, in_dir, num, item_name)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "main", num)
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
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 131 then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return 0, {techage.get_inv_state_num(inv, "main")}
		else
			return 2, ""
		end
	end,
})


local function formspec4(pos)
	return "size[10,9]"..
	"tabheader[0,0;tab;"..S("Inventory,Pre-Assignment,Config")..";1;;true]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0,0;10,5;]"..
	mConf.preassigned_stacks(pos, 10, 5)..
	"list[current_player;main;1,5.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

local function formspec4_pre(pos)
	return "size[10,9]"..
	"tabheader[0,0;tab;"..S("Inventory,Pre-Assignment,Config")..";2;;true]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;conf;0,0;10,5;]"..
	"list[current_player;main;1,5.3;8,4;]"..
	"listring[context;conf]"..
	"listring[current_player;main]"
end

local function formspec4_cfg(pos)
	local meta = minetest.get_meta(pos)
	local label = meta:get_string("label") or ""
	local public = dump((meta:get_int("public") or 0) == 1)
	return "size[10,5]"..
	"tabheader[0,0;tab;"..S("Inventory,Pre-Assignment,Config")..";3;;true]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"field[0.5,1;9,1;label;"..S("Node label:")..";"..label.."]" ..
	"checkbox[1,2;public;"..S("Allow public access to the chest")..";"..public.."]"..
	"button_exit[3.5,4;3,1;exit;"..S("Save").."]"
end

local function ta4_allow_metadata_inventory_put(pos, listname, index, stack, player)
	local public = M(pos):get_int("public") == 1
	if not public and minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	if listname == "main" then
		return stack:get_count()
	else
		return mConf.allow_conf_inv_put(pos, listname, index, stack, player)
	end
end

local function ta4_allow_metadata_inventory_take(pos, listname, index, stack, player)
	local public = M(pos):get_int("public") == 1
	if not public and minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	if listname == "main" then
		return stack:get_count()
	else
		return mConf.allow_conf_inv_take(pos, listname, index, stack, player)
	end
end

local function ta4_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local public = M(pos):get_int("public") == 1
	if not public and minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	if from_list == "main" then
		return count
	else
		return mConf.allow_conf_inv_move(pos, from_list, from_index, to_list, to_index, count, player)
	end
end

minetest.register_node("techage:chest_ta4", {
	description = S("TA4 Protected Chest"),
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
		inv:set_size('conf', 50)
	end,

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:chest_ta4")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec4(pos))
		meta:set_string("infotext", S("TA4 Protected Chest").." "..number)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)
		local mem = techage.get_mem(pos)
		if fields.tab == "1" then
			mem.filter = nil
			meta:set_string("formspec", formspec4(pos))
		elseif fields.tab == "2" then
			meta:set_string("formspec", formspec4_pre(pos))
		elseif fields.tab == "3" then
			meta:set_string("formspec", formspec4_cfg(pos))
		elseif fields.quit == "true" then
			mem.filter = nil
		end
		if fields.public then
			meta:set_int("public", fields.public == "true" and 1 or 0)
		end
		if fields.exit then
			local number = meta:get_string("node_number")
			if fields.label ~= "" then
				meta:set_string("infotext", minetest.formspec_escape(fields.label).." #"..number)
			else
				meta:set_string("infotext", S("TA4 Protected Chest").." "..number)
			end
			meta:set_string("label", fields.label)
			meta:set_string("formspec", formspec4_cfg(pos))
		end
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return techage.logic.set_numbers(pos, numbers, player_name, S("TA4 Protected Chest"))
	end,

	can_dig = can_dig,
	after_dig_node = after_dig_node,
	allow_metadata_inventory_put = ta4_allow_metadata_inventory_put,
	allow_metadata_inventory_take = ta4_allow_metadata_inventory_take,
	allow_metadata_inventory_move = ta4_allow_metadata_inventory_move,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


techage.register_node({"techage:chest_ta4"}, {
	on_inv_request = function(pos, in_dir, access_type)
		local meta = minetest.get_meta(pos)
		return meta:get_inventory(), "main"
	end,
	on_pull_item = function(pos, in_dir, num, item_name)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local mem = techage.get_mem(pos)

		mem.filter = mem.filter or mConf.item_filter(pos, TA4_INV_SIZE)
		mem.chest_configured = mem.chest_configured or not inv:is_empty("conf")

		if inv:is_empty("main") then
			return nil
		end

		if item_name then
			if mem.filter[item_name] or not mem.chest_configured then
				local taken = inv:remove_item("main", {name = item_name, count = num})
				if taken:get_count() > 0 then
					return taken
				end
			end
		else -- no item given
			if mem.chest_configured then
				return mConf.take_item(pos, inv, "main", num, mem.filter["unconfigured"])
			else
				return techage.get_items(pos, inv, "main", num)
			end
		end
	end,
	on_push_item = function(pos, in_dir, item, idx)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local mem = techage.get_mem(pos)

		mem.filter = mem.filter or mConf.item_filter(pos, TA4_INV_SIZE)
		mem.chest_configured = mem.chest_configured or not inv:is_empty("conf")

		if mem.chest_configured then
			local name = item:get_name()
			local stacks = mem.filter[name] or mem.filter["unconfigured"]
			return mConf.put_items(pos, inv, "main", item, stacks, idx)
		else
			return techage.put_items(inv, "main", item, idx)
		end
	end,
	on_unpull_item = function(pos, in_dir, item)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local mem = techage.get_mem(pos)

		mem.filter = mem.filter or mConf.item_filter(pos, TA4_INV_SIZE)
		mem.chest_configured = mem.chest_configured or not inv:is_empty("conf")

		if mem.chest_configured then
			local name = item:get_name()
			local stacks = mem.filter[name] or mem.filter["unconfigured"]
			return mConf.put_items(pos, inv, "main", item, stacks)
		else
			return techage.put_items(inv, "main", item)
		end
	end,

	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 131 then
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
	output = "techage:chest_ta2",
	recipe = {"default:chest", "techage:tubeS", "techage:iron_ingot"}
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:chest_ta2",
	recipe = {"default:chest_locked", "techage:tubeS", "techage:iron_ingot"}
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:chest_ta2",
	recipe = {"protector:chest", "techage:tubeS", "techage:iron_ingot"}
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:chest_ta3",
	recipe = {"techage:chest_ta2", "default:chest"}
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:chest_ta4",
	recipe = {"techage:chest_ta3", "default:chest"}
})
