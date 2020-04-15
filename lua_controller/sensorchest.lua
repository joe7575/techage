--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Sensor Chest
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local PlayerActions = {}
local InventoryState = {}


local function store_action(pos, player, action)
	local meta = minetest.get_meta(pos)
	local name = player and player:get_player_name() or ""
	local number = meta:get_string("node_number")
	PlayerActions[number] = {name, action}
end	

local function send_off_command(pos)
	local meta = minetest.get_meta(pos)
	local number = meta:get_string("number")
	if number ~= "" then
		local own_num = meta:get_string("node_number")
		techage.send_single(own_num, number, "off")
	end
end

local function send_command(pos)
	local meta = minetest.get_meta(pos)
	local number = meta:get_string("number")
	if number ~= "" then
		local own_num = meta:get_string("node_number")
		techage.send_single(own_num, number, "on")
		minetest.after(0.2, send_off_command, pos)
	end
end

local function get_stacks(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local a = safer_lua.Array()
	for idx = 1,4 do
		local stack = inv:get_stack("main", idx)
		local s = safer_lua.Store()
		if stack:get_count() > 0 then
			s.set("name", stack:get_name())
			s.set("count", stack:get_count())
			a.add(s)
		end
	end
	return a
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	store_action(pos, player, "put")
	send_command(pos)
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	store_action(pos, player, "take")
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

local function formspec1()
	return "size[6,4]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"field[0.5,1;5,1;number;TA4 Lua Controller number:;]" ..
	"button_exit[1.5,2.5;2,1;exit;Save]"
end

local function formspec2(pos)
	local text = M(pos):get_string("text")
	return "size[8,6]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0,0;2,2;]"..
	"button[2,0;1,1;f1;F1]"..
	"button[2,1;1,1;f2;F2]"..
	"label[3,0;"..text.."]"..
	"list[current_player;main;0,2.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

minetest.register_node("techage:ta4_sensor_chest", {
	description = S("TA4 Sensor Chest"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png^techage_appl_sensor.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png^techage_appl_sensor.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png^techage_appl_sensor.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_front_ta4.png^techage_appl_sensor.png",
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 4)
	end,
	
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:ta4_sensor_chest")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("text", "Text to be changed\nby command.")
		meta:set_string("formspec", formspec1())
		meta:set_string("infotext", S("TA4 Sensor Chest").." "..number..": "..S("not connected"))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		if fields.number and fields.number ~= "" then
			local owner = meta:get_string("owner")
			if techage.check_numbers(fields.number, owner) then
				meta:set_string("number", fields.number)
				local node_number = meta:get_string("node_number")
				meta:set_string("infotext", S("TA4 Sensor Chest").." "..node_number..": "..S("connected with").." "..fields.number)
				meta:set_string("formspec", formspec2(pos))
			end
		elseif fields.f1 then
			store_action(pos, player, "f1")
			send_command(pos)
			meta:set_string("formspec", formspec2(pos))
		elseif fields.f2 then
			store_action(pos, player, "f2")
			send_command(pos)
			meta:set_string("formspec", formspec2(pos))
		end
	end,
	
	techage_set_numbers = function(pos, numbers, player_name)
		return techage.logic.set_numbers(pos, numbers, player_name, S("TA4 Sensor Chest"))
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

techage.register_node({"techage:ta4_sensor_chest"}, {
	on_pull_item = function(pos, in_dir, num)
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
		elseif topic == "action" then
			local meta = minetest.get_meta(pos)
			local number = meta:get_string("node_number")
			return PlayerActions[number][1], PlayerActions[number][2]
		elseif topic == "stacks" then
			return get_stacks(pos)
		elseif topic == "text" then
			local meta = minetest.get_meta(pos)
			meta:set_string("text", tostring(payload))
			meta:set_string("formspec", formspec2(pos))
		else
			return "unsupported"
		end
	end,
})	

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta4_sensor_chest",
	recipe = {"techage:chest_ta4", "techage:ta4_wlanchip"}
})

