--[[

	TechAge
	=======

	Copyright (C) 2020-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Pack Container
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S

local MP = minetest.get_modpath("techage")
local fly  = dofile(MP .. "/basis/fly_lib.lua")
local mark = dofile(MP .. "/basis/mark_lib.lua")

local MAX_BLOCKS = 16
local DESCRIPTION = S("TA5 Pack Container")

local function formspec(nvm, meta)
	local status = meta:get_string("status")
	local path = meta:contains("path") and meta:get_string("path") or "0,3,0"
	local node_name = meta:get_string("node_name")
	return "size[8,4.3]" ..
		"box[0,-0.1;7.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", DESCRIPTION) .. "]" ..
		--techage.wrench_image(7.4, -0.05) ..
		"field[0.4,1.2;3.8,1;node_name;" .. S("Node name") .. ";" .. node_name .. "]" ..
		"button[4.1,0.9;3.8,1;store;" .. S("Store") .. "]" ..
		"button[0.1,2.1;3.8,1;record;" .. S("Record") .. "]" ..
		"box[0,1.9;7.8,0.02;#ffffff]" ..
		"button[4.1,2.1;3.8,1;done;" .. S("Done") .. "]" ..
		"button[0.1,2.9;3.8,1;pack;" .. S("Pack") .. "]" ..
		"button[4.1,2.9;3.8,1;unpack;" .. S("Unpack") .. "]" ..
		"label[0.3,9;" .. status .. "]"
end

local function get_rposlist(pos, pos_list)
	local lst = {}
	for _,item_pos in ipairs(pos_list or {}) do
		local rpos = vector.subtract(item_pos, pos)
		table.insert(lst, rpos)
	end
	return lst
end

local function set_storage_pos(pos, oldnode, oldmetadata, drops)
	local meta = drops[1]:get_meta()
	meta:set_string("storage_pos", P2S(pos))
	meta:set_string("node_name", (oldmetadata.node_name or ""))
	meta:set_string("description", DESCRIPTION .. ' "' .. (oldmetadata.node_name or "") .. '"')
end

local function get_storage_pos(pos, nvm, itemstack)
	print("get_storage_pos")
	local imeta = itemstack:get_meta()
	if imeta then
	print("get_storage_pos2")
		local meta = M(pos)
		meta:set_string("node_name", imeta:get_string("node_name"))
		nvm.storage_pos = S2P(imeta:get_string("storage_pos"))
		print("get_storage_pos3", dump(nvm))
		return nvm.storage_pos ~= nil
	end
end

local function copy_data_and_remove_node(mypos, rmtpos)
	local nvm1 = techage.get_nvm(mypos)
	local nvm2 = techage.get_nvm(rmtpos)
	nvm1.lrpos = nvm2.lrpos
	nvm1.pack_tbl = nvm2.pack_tbl
	minetest.remove_node(rmtpos)
	techage.del_mem(rmtpos)
end

local function after_place_node(pos, placer, itemstack)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	meta:set_string("infotext", DESCRIPTION)
	if get_storage_pos(pos, nvm, itemstack) then
		if techage.get_node_lvm(nvm.storage_pos).name == "techage:ta5_packcontainer_storage" then
			copy_data_and_remove_node(pos, nvm.storage_pos)
			nvm.storage_pos = nil
		end
	end
	meta:set_string("formspec", formspec(nvm, meta))
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = M(pos)
	local nvm = techage.get_nvm(pos)

	if fields.record then
		nvm.lrpos = {}
		meta:set_string("status", S("Recording..."))
		local name = player:get_player_name()
		minetest.chat_send_player(name, S("Click on all blocks that shall be turned"))
		mark.start(name, MAX_BLOCKS)
		meta:set_string("formspec", formspec(nvm, meta))
	elseif fields.store then
		meta:set_string("node_name", fields.node_name)
		meta:set_string("formspec", formspec(nvm, meta))
	elseif fields.done then
		local name = player:get_player_name()
		local pos_list = mark.get_poslist(name)
		local text = #pos_list.." "..S("block positions are stored.")
		meta:set_string("status", text)
		meta:set_string("node_name", fields.node_name)
		nvm.lrpos = get_rposlist(pos, pos_list)
		mark.unmark_all(name)
		mark.stop(name)
		meta:set_string("formspec", formspec(nvm, meta))
	elseif fields.pack then
		nvm.pack_tbl = techage.pack_nodes(pos, nvm.lrpos or {})
		meta:set_string("status", S("Packed"))
		meta:set_string("formspec", formspec(nvm, meta))
		meta:set_int("data_stored", 1)
		local name = player:get_player_name()
		mark.stop(name)
	elseif fields.unpack then
		techage.unpack_nodes(pos, nvm.pack_tbl)
		meta:set_string("status", S("Unpacked"))
		meta:set_string("formspec", formspec(nvm, meta))
		meta:set_int("data_stored", 0)
		local name = player:get_player_name()
		mark.stop(name)
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	local name = digger:get_player_name()
	mark.unmark_all(name)
	mark.stop(name)

	if oldmetadata.fields.data_stored == "1" then
		minetest.set_node(pos, {name = "techage:ta5_packcontainer_storage"})
	else
		techage.del_mem(pos)
	end
end

minetest.register_node("techage:ta5_packcontainer", {
	description = DESCRIPTION,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_turn.png",
	},
	after_place_node = after_place_node,
	on_receive_fields = on_receive_fields,
	after_dig_node = after_dig_node,
	preserve_metadata = set_storage_pos,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local INFO = [[Commands: 'left', 'right', 'uturn']]

techage.register_node({"techage:ta5_packcontainer"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "info" then
			return INFO
		end
		return false
	end,
})

minetest.register_craft({
	output = "techage:ta4_turncontroller",
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"techage:aluminum", "techage:baborium_ingot", "techage:aluminum"},
		{"group:wood", "basic_materials:gear_steel", "group:wood"},
	},
})

minetest.register_node("techage:ta5_packcontainer_storage", {
	description = DESCRIPTION,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -11/32, -1/2, -11/32, 11/32, -5/16, 11/32},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"signs_bot_sensor2.png^signs_bot_sensor_bot.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
		"signs_bot_sensor2.png",
	},
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	on_blast = function() end,
	on_destruct = function () end,
	can_dig = function() return false end,
	diggable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
})

techage.register_node({"techage:ta5_packcontainer_storage"})
