--[[

	TechAge
	=======

	Copyright (C) 2020-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Door/Gate Controller II

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S = techage.S

local MP = minetest.get_modpath("techage")
local mark = dofile(MP .. "/basis/mark_lib.lua")
local logic = techage.logic
local fly = techage.flylib

local NUMSLOTS = 16

--------------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------------
local function get_positions(nvm)
	local lpos = {}
	for idx,cfg in ipairs(nvm.config or {}) do
		lpos[idx] = cfg.pos
	end
	return lpos
end

-- Slot state: 1 = Initial state (reset), 2 = Exchange state
local function get_state(nvm, number)
	if nvm.config[number] then
		return nvm.config[number].state and 1 or 2
	end
	return 0
end

local function is_simple_node(pos, name)
	if not minecart.is_rail(pos, name) then
		local ndef = minetest.registered_nodes[name]
		return techage.can_dig_node(name, ndef) or minecart.is_cart(name) or 
		       doors.registered_doors[name] or doors.registered_trapdoors[name]
	end
	return false
end

-- Slot Configuration {
--   pos,    -- pos from the node in the inventory
--   param2, -- param2 from the node in the inventory
--   state,  -- false = block is dug/slot is filled (set), true = block is set/slot is empty (reset)
--   nameS,  -- name of the node in the world, if state = false (set)
--   nameR,  -- name of the node in the worls, if state = true (reset)
-- }
local function gen_config(pos, pos_list)
	local nvm = techage.get_nvm(pos)
	nvm.config = {}
	for idx,pos in ipairs(pos_list) do
		local node = techage.get_node_lvm(pos)
		nvm.config[idx] = {pos = pos, param2 = node.param2, state = true, nameR = node.name, nameS = "air"}
	end
end

local function gen_config_initial(pos)
	local inv = M(pos):get_inventory()
	local item_list = inv:get_list("main")
	local nvm = techage.get_nvm(pos)
	nvm.config = {}
	nvm.pos_list = nvm.pos_list or {}
	nvm.param2_list = nvm.param2_list or {}
	local len = #nvm.pos_list
	for idx = 1, len do
		-- The status is not yet known. It is assumed that the block is set (status = true)
		-- if the inventory is empty.
		local item = item_list[idx]
		local node = techage.get_node_lvm(nvm.pos_list[idx])
		local state = (item and item:get_count() > 0) == false
		if state then
			nvm.config[idx] = {pos = nvm.pos_list[idx], param2 = nvm.param2_list[idx], state = state, nameR = node.name, nameS = "air"}
		else
			nvm.config[idx] = {pos = nvm.pos_list[idx], param2 = nvm.param2_list[idx], state = state, nameR = "air", nameS = node.name}
		end
	end
	nvm.pos_list = nil
	nvm.param2_list = nil
end

local function add_node_names(pos, nvm)
	local inv = M(pos):get_inventory()
	local item_list = inv:get_list("main")
	for idx = 1, #nvm.config do
		local node = techage.get_node_lvm(nvm.config[idx].pos)
		local item = item_list[idx]
		if nvm.config[idx].state then
			nvm.config[idx].nameR = node.name
			nvm.config[idx].nameS = item:get_count() > 0 and item:get_name() or "air"
		else
			nvm.config[idx].nameR = item:get_count() > 0 and item:get_name() or "air"
			nvm.config[idx].nameS = node.name
		end
	end
end

--------------------------------------------------------------------------
-- formspec
--------------------------------------------------------------------------
local function formspec1(nvm, meta)
	local status = meta:get_string("status")
	local play_sound = dump(nvm.play_sound or false)
	return "size[8,7]"..
		"tabheader[0,0;tab;"..S("Ctrl,Inv")..";1;;true]"..
		"button_exit[0.7,0.0;3,1;record;"..S("Record").."]"..
		"button[4.3,0.0;3,1;ready;"..S("Done").."]"..
		"button_exit[0.7,0.9;3,1;reset;"..S("Reset").."]"..
		"button_exit[4.3,0.9;3,1;exchange;"..S("Exchange").."]"..
		"button_exit[0.7,1.8;3,1;show;"..S("Show positions").."]"..
		"checkbox[4.3,1.8;play_sound;"..S("with door sound")..";"..play_sound.."]"..
		"label[0.5,2.8;"..status.."]"..
		"list[current_player;main;0,3.3;8,4;]"
end

local function formspec2(nvm)
	local lbls = {}
	for idx,item in ipairs(nvm.config or {}) do
		local x = ((idx-1) % 8) + 0.3
		local y = math.floor((idx-1) / 8) * 2.4
		if item.state then
			lbls[idx] = "label[" .. x .."," .. y .. ";" .. idx .. "]"
		else
			lbls[idx] = "label[" .. x .."," .. y .. ";" .. idx .. " *]"
		end
	end
	return "size[8,7]"..
		"tabheader[0,0;tab;"..S("Ctrl,Inv")..";2;;true]"..
		table.concat(lbls, "")..
		"list[context;main;0,0.5;8,2;]"..
		"list[current_player;main;0,3.3;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
end

--------------------------------------------------------------------------
-- Exchange nodes
--------------------------------------------------------------------------
local function remove_hidden_door_node(pos)
	local above = vector.offset(pos, 0, 1, 0)
	if minetest.get_node(above).name == "doors:hidden" then
		minetest.remove_node(above)
	end
end

local function exchange_node(cfg, item)
	local node = techage.get_node_lvm(cfg.pos)
	if is_simple_node(cfg.pos, node.name) then
		local name = item:get_count() > 0 and item:get_name() or "air"
		local expected_node_name = cfg.state and cfg.nameR or cfg.nameS
		if fly.exchange_node(cfg.pos, name, cfg.param2, expected_node_name) then
			remove_hidden_door_node(cfg.pos)
			cfg.param2 = node.param2
			cfg.state = not cfg.state
			if node.name ~= "air" then
				return ItemStack(node.name)
			else
				return ItemStack()
			end
		end
	end
	return item
end

local function exchange_nodes(pos, nvm, slot, force)
	local inv = M(pos):get_inventory()
	local item_list = inv:get_list("main")
	local res = false
	nvm.config = nvm.config or {}
	local len = #nvm.config

	for idx = (slot or 1), (slot or len) do
		local cfg = nvm.config[idx]
		local state = cfg.state
		local item = item_list[idx]
		if (force == nil)
		or (force == "exch")
		or (force == "dig" and item:get_count() == 0)
		or (force == "set" and item:get_count() > 0)
		or (force == "to2" and state)
		or (force == "to1" and not state) then
			item_list[idx] = exchange_node(cfg, item)
			nvm.config[idx].state = not state
			res = true
		end
	end
	inv:set_list("main", item_list)
	return res
end

local function reset_config(pos, nvm)
	local inv = M(pos):get_inventory()
	local item_list = inv:get_list("main")

	for idx, cfg in ipairs(nvm.config or {}) do
		local item = item_list[idx]
		if not cfg.state then
			item_list[idx] = exchange_node(cfg, item)
		end
	end
	inv:set_list("main", item_list)
end

local function exchange_with_sound(pos)
	local nvm = techage.get_nvm(pos)
	if nvm.play_sound then
		minetest.sound_play("doors_door_open", {
			pos = pos,
			gain = 1,
			max_hear_distance = 15})
	end
	return exchange_nodes(pos, nvm)
end

local function exchange_with_learning(pos)
	local nvm = techage.get_nvm(pos)
	add_node_names(pos, nvm)
	return exchange_with_sound(pos)
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
		inv:set_size('main', NUMSLOTS)
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
		nvm.fs2_active = false

		if fields.tab == "2" then
			meta:set_string("formspec", formspec2(nvm))
			nvm.fs2_active = true
			return
		elseif fields.tab == "1" then
			meta:set_string("formspec", formspec1(nvm, meta))
			nvm.fs2_active = true
			return
		elseif fields.record then
			nvm.recording = true
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all the blocks that are part of the door/gate"))
			mark.unmark_all(name)
			mark.start(name, NUMSLOTS)
			meta:set_string("stored_config", "")
			meta:set_string("formspec", formspec1(nvm, meta))
		elseif fields.ready and nvm.recording then
			nvm.recording = false
			local name = player:get_player_name()
			local pos_list = mark.get_poslist(name)
			gen_config(pos, pos_list)
			local text = #pos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			mark.unmark_all(name)
			mark.stop(name)
			meta:set_string("stored_config", "")
			meta:set_string("formspec", formspec1(nvm, meta))
		elseif fields.exchange then
			if exchange_with_learning(pos) then
				meta:set_string("status", S("Blocks exchanged"))
				meta:set_string("formspec", formspec1(nvm, meta))
				local name = player:get_player_name()
				mark.stop(name)
			end
		elseif fields.show then
			local name = player:get_player_name()
			local lpos = get_positions(nvm)
			mark.mark_positions(name, lpos, 300)
		elseif fields.reset then
			reset_config(pos, nvm)
			meta:set_string("status", S("Blocks reset"))
			meta:set_string("formspec", formspec1(nvm, meta))
			local name = player:get_player_name()
			mark.stop(name)
		elseif fields.play_sound then
			nvm.play_sound = fields.play_sound == "true"
			meta:set_string("formspec", formspec1(nvm, meta))
		end
	end,

	allow_metadata_inventory_move = function()
		return 0
	end,
	allow_metadata_inventory_take = function()
		return 0
	end,
	allow_metadata_inventory_put = function()
		return 0
	end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		if nvm.fs2_active then
			meta:set_string("formspec", formspec2(nvm))
		else
			meta:set_string("formspec", formspec1(nvm, meta))
		end
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
		mark.unmark_all(name)
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
			return exchange_with_sound(pos)
		elseif topic == "off" then
			return exchange_with_sound(pos)
		elseif topic == "exchange" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload), "exch")
		elseif topic == "to1" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload), "to1")
		elseif topic == "to2" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload), "to2")
		elseif topic == "set" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload), "set")
		elseif topic == "dig" then
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, tonumber(payload), "dig")
		elseif topic == "get" then
			local nvm = techage.get_nvm(pos)
			return get_state(nvm, tonumber(payload))
		elseif topic == "reset" then
			local nvm = techage.get_nvm(pos)
			return reset_config(pos, nvm)
		end
		return false
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 1 and payload[1] == 1 then
			return exchange_with_sound(pos) and 0 or 3
		elseif topic == 1 and payload[1] == 0 then
			return exchange_with_sound(pos) and 0 or 3
		elseif topic == 9 and payload[1] == 0 then  -- Exchange Block
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1, "exch") and 0 or 3
		elseif topic == 9 and payload[1] == 1 then  -- Set Block
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1, "set") and 0 or 3
		elseif topic == 9 and payload[1] == 2 then  -- Dig Block
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1, "dig") and 0 or 3
		elseif topic == 9 and payload[1] == 3 then  -- reset
			local nvm = techage.get_nvm(pos)
			return reset_config(pos, nvm) and 0 or 3
		elseif topic == 9 and payload[1] == 4 then  -- to1
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1, "to1") and 0 or 3
		elseif topic == 9 and payload[1] == 5 then  -- to2
			local nvm = techage.get_nvm(pos)
			return exchange_nodes(pos, nvm, payload[2] or 1, "to2") and 0 or 3
		end
		return 2
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 147 then  -- Get State
			local nvm = techage.get_nvm(pos)
			return 0, {get_state(nvm, tonumber(payload[1]))}
		end
		return 2, {0}
	end,
	on_node_load = function(pos)
		local nvm = techage.get_nvm(pos)
		if nvm.config == nil then
			gen_config_initial(pos)
		elseif nvm.config[1] and nvm.config[1].nameS == nil then
			add_node_names(pos, nvm) 
		end
	end,
})

minetest.register_alias("techage:ta3_doorcontroller3", "techage:ta3_doorcontroller2")

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta3_doorcontroller2",
	recipe = {"techage:ta3_doorcontroller"},
})

local Doors = {
	"doors:door_steel",
	"doors:prison_door",
	"doors:rusty_prison_door",
	"doors:trapdoor_steel",
	"doors:door_glass",
	"doors:door_wood",
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
		fly.protect_door_from_being_opened(name .. "_" .. postfix)
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
		fly.protect_door_from_being_opened(name .. "_" .. postfix)
	end
end
