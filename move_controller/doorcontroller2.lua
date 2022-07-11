--[[

	TechAge
	=======

	Copyright (C) 2020-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Door/Gate Controller II

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S = techage.S

local MP = minetest.get_modpath("techage")
local flylib = dofile(MP .. "/basis/fly_lib.lua")
local logic = techage.logic

local MarkedNodes = {} -- t[player] = {{entity, pos},...}
local CurrentPos  -- to mark punched entities

local function is_simple_node(name)
	local ndef = minetest.registered_nodes[name]
	return techage.can_dig_node(name, ndef)
end

local function unmark_position(name, pos)
	pos = vector.round(pos)
	for idx,item in ipairs(MarkedNodes[name] or {}) do
		if vector.equals(pos, item.pos) then
			item.entity:remove()
			table.remove(MarkedNodes[name], idx)
			CurrentPos = pos
			return
		end
	end
end

local function unmark_all(name)
	for _,item in ipairs(MarkedNodes[name] or {}) do
		item.entity:remove()
	end
	MarkedNodes[name] = nil
end

local function mark_position(name, pos)
	MarkedNodes[name] = MarkedNodes[name] or {}
	pos = vector.round(pos)
	if not CurrentPos or not vector.equals(pos, CurrentPos) then -- entity not punched?
		local entity = minetest.add_entity(pos, "techage:marker")
		if entity ~= nil then
			entity:get_luaentity().player_name = name
			table.insert(MarkedNodes[name], {pos = pos, entity = entity})
		end
		CurrentPos = nil
		return true
	end
	CurrentPos = nil
end

local function get_poslist(name)
	local lst = {}
	for _,item in ipairs(MarkedNodes[name] or {}) do
		table.insert(lst, item.pos)
	end
	return lst
end

minetest.register_entity(":techage:marker", {
	initial_properties = {
		visual = "cube",
		textures = {
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
		},
		physical = false,
		visual_size = {x = 1.1, y = 1.1},
		collisionbox = {-0.55,-0.55,-0.55, 0.55,0.55,0.55},
		glow = 8,
	},
	on_step = function(self, dtime)
		self.ttl = (self.ttl or 2400) - 1
		if self.ttl <= 0 then
			local pos = self.object:get_pos()
			unmark_position(self.player_name, pos)
		end
	end,
	on_punch = function(self, hitter)
		local pos = self.object:get_pos()
		local name = hitter:get_player_name()
		if name == self.player_name then
			unmark_position(name, pos)
		end
	end,
})

local function formspec1(nvm, meta)
	local status = meta:get_string("status")
	local play_sound = dump(nvm.play_sound or false)
	return "size[8,7]"..
		"tabheader[0,0;tab;"..S("Ctrl,Inv")..";1;;true]"..
		"button[0.7,0.2;3,1;record;"..S("Record").."]"..
		"button[4.3,0.2;3,1;ready;"..S("Done").."]"..
		"button[0.7,1.2;3,1;show;"..S("Set").."]"..
		"button[4.3,1.2;3,1;hide;"..S("Remove").."]"..
		"checkbox[4.3,2.1;play_sound;"..S("with door sound")..";"..play_sound.."]"..
		"label[0.5,2.3;"..status.."]"..
		"list[current_player;main;0,3.3;8,4;]"
end

local function formspec2()
	return "size[8,7]"..
		"tabheader[0,0;tab;"..S("Ctrl,Inv")..";2;;true]"..
		"label[0.3,0.0;1]"..
		"label[7.3,0.0;8]"..
		"label[0.3,2.4;9]"..
		"label[7.3,2.4;16]"..
		"list[context;main;0,0.5;8,2;]"..
		"list[current_player;main;0,3.3;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
end

local function play_sound(pos)
	minetest.sound_play("techage_button", {
		pos = pos,
		gain = 1,
		max_hear_distance = 15})
end

local function exchange_node(pos, item, param2)
	local node = minetest.get_node_or_nil(pos)
	if node and is_simple_node(node.name) then
		if item and item:get_name() ~= "" and minetest.registered_nodes[item:get_name()] then
			flylib.exchange_node(pos, item:get_name(), param2)
		else
			flylib.remove_node(pos)
		end
		if not techage.is_air_like(node.name) then
			return ItemStack(node.name), node.param2
		else
			return ItemStack(), nil
		end
	end
	return item, param2
end

local function exchange_nodes(pos, nvm, slot, force)
	local meta = M(pos)
	local inv = meta:get_inventory()

	local item_list = inv:get_list("main")
	local owner = meta:get_string("owner")
	local res = false
	nvm.pos_list = nvm.pos_list or {}
	nvm.param2_list = nvm.param2_list or {}

	for idx = (slot or 1), (slot or 16) do
		local pos = nvm.pos_list[idx]
		local item = item_list[idx]
		if pos then
			if (force == nil)
			or (force == "dig" and item:get_count() == 0)
			or (force == "set" and item:get_count() > 0) then
				item_list[idx], nvm.param2_list[idx] = exchange_node(pos, item, nvm.param2_list[idx])
				res = true
			end
		end
	end

	inv:set_list("main", item_list)
	return res
end

local function get_node_name(nvm, slot)
	local pos = nvm.pos_list[slot]
	if pos then
		return techage.get_node_lvm(pos).name
	end
	return "unknown"
end

local function show_nodes(pos)
	local nvm = techage.get_nvm(pos)
	if not nvm.is_on then
		nvm.is_on = true
		if nvm.play_sound then
			minetest.sound_play("doors_door_close", {
				pos = pos,
				gain = 1,
				max_hear_distance = 15})
		end
		return exchange_nodes(pos, nvm)
	end
end

local function hide_nodes(pos)
	local nvm = techage.get_nvm(pos)
	if nvm.is_on then
		nvm.is_on = false
		if nvm.play_sound then
			minetest.sound_play("doors_door_open", {
				pos = pos,
				gain = 1,
				max_hear_distance = 15})
		end
		return exchange_nodes(pos, nvm)
	end
end

minetest.register_node("techage:ta3_doorcontroller2", {
	description = S("TA3 Door Controller II"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_doorcontroller.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 16)
		logic.after_place_node(pos, placer, "techage:ta3_doorcontroller2", S("TA3 Door Controller II"))
		logic.infotext(meta, S("TA3 Door Controller II"))
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec1(nvm, meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)

		if fields.tab == "2" then
			meta:set_string("formspec", formspec2(meta))
			return
		elseif fields.tab == "1" then
			meta:set_string("formspec", formspec1(nvm, meta))
			return
		elseif fields.record then
			local inv = meta:get_inventory()
			nvm.pos_list = nil
			nvm.is_on = false
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all the blocks that are part of the door/gate"))
			MarkedNodes[name] = {}
			meta:set_string("formspec", formspec1(nvm, meta))
		elseif fields.ready then
			local name = player:get_player_name()
			local pos_list = get_poslist(name)
			local text = #pos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			nvm.pos_list = pos_list
			nvm.is_on = true
			unmark_all(name)
			meta:set_string("formspec", formspec1(nvm, meta))
		elseif fields.show then
			if show_nodes(pos) then
				play_sound(pos)
				meta:set_string("status", S("Blocks are back"))
				meta:set_string("formspec", formspec1(nvm, meta))
				local name = player:get_player_name()
				MarkedNodes[name] = nil
			end
		elseif fields.hide then
			if hide_nodes(pos) then
				play_sound(pos)
				meta:set_string("status", S("Blocks are disappeared"))
				meta:set_string("formspec", formspec1(nvm, meta))
				local name = player:get_player_name()
				MarkedNodes[name] = nil
			end
		elseif fields.play_sound then
			nvm.play_sound = fields.play_sound == "true"
			meta:set_string("formspec", formspec1(nvm, meta))
		end
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return 1
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return 1
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		if is_simple_node(stack:get_name()) then
			return 1
		end
		return 0
	end,

	can_dig = function(pos, player)
		if player and minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		local inv = minetest.get_inventory({type="node", pos=pos})
		return inv:is_empty("main")
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		unmark_all(name)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.register_node({"techage:ta3_doorcontroller2"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "on" then
			return hide_nodes(pos)
		elseif topic == "off" then
			return show_nodes(pos)
		elseif topic == "exchange" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload))
		elseif topic == "set" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload), "set")
		elseif topic == "dig" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload), "dig")
		elseif topic == "get" then
			local nvm = techage.get_nvm(pos)
			return get_node_name(nvm, tonumber(payload))
		end
		return false
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 1 and payload[1] == 1 then
			return hide_nodes(pos) and 0 or 3
		elseif topic == 1 and payload[1] == 0 then
			return show_nodes(pos) and 0 or 3
		elseif topic == 9 and payload[1] == 0 then  -- Exchange Block
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1) and 0 or 3
		elseif topic == 9 and payload[1] == 1 then  -- Set Block
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1, "set") and 0 or 3
		elseif topic == 9 and payload[1] == 2 then  -- Dig Block
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1, "dig") and 0 or 3
		end
		return 2
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 147 then  -- Get Name
			local nvm = techage.get_nvm(pos)
			return 0, get_node_name(nvm, payload[1] or 1)
		end
		return 2, ""
	end,
	on_node_load = function(pos)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		meta:set_string("status", "")
		meta:set_string("formspec", formspec1(nvm, meta))
		local pos_list = minetest.deserialize(meta:get_string("pos_list"))
		if pos_list then
			nvm.pos_list = pos_list
			meta:set_string("pos_list", "")
			local inv = meta:get_inventory()
			if inv:is_empty("main") then
				nvm.is_on = true
			end
		end
		local param2_list = minetest.deserialize(meta:get_string("param2_list"))
		if param2_list then
			nvm.param2_list = param2_list
			meta:set_string("param2_list", "")
		end
	end,
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta3_doorcontroller2",
	recipe = {"techage:ta3_doorcontroller"},
})

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if puncher and puncher:is_player() then
		local name = puncher:get_player_name()

		if not MarkedNodes[name] then
			return
		end

		if not minetest.is_protected(pointed_thing.under, name) then
			mark_position(name, pointed_thing.under)
		end
	end
end)

local Doors = {
	"doors:door_steel",
	"doors:prison_door",
	"doors:rusty_prison_door",
	"doors:trapdoor_steel",
	"doors:door_glass",
	"doors:door_obsidian_glass",
	"doors:japanese_door",
	"doors:screen_door",
	"doors:slide_door",
	"doors:trapdoor",
	"doors:woodglass_door",
	"xpanes:door_steel_bar",
	"xpanes:trapdoor_steel_bar",
}

for _, name in ipairs(Doors) do
	for _, postfix in ipairs({"a", "b", "c", "d"}) do
		techage.register_simple_nodes({name .. "_" .. postfix}, true)
		flylib.protect_door_from_being_opened(name .. "_" .. postfix)
	end
end

local ProtectorDoors = {
	"protector:door_steel",
	"protector:door_wood",
	"protector:trapdoor",
	"protector:trapdoor_steel",
}

for _, name in ipairs(ProtectorDoors) do
	for _, postfix in ipairs({"b_1", "b_2", "t_1", "t_2"}) do
		techage.register_simple_nodes({name .. "_" .. postfix}, true)
		flylib.protect_door_from_being_opened(name .. "_" .. postfix)
	end
end
