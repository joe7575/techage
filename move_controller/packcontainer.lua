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
	return "size[8,3]" ..
		"box[0,-0.1;7.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", DESCRIPTION) .. "]" ..
		--techage.wrench_image(7.4, -0.05) ..
		"button[0.1,0.7;3.8,1;record;" .. S("Record") .. "]" ..
		"button[4.1,0.7;3.8,1;done;" .. S("Done") .. "]" ..
		"button[0.1,1.5;3.8,1;left;" .. S("Turn left") .. "]" ..
		"button[4.1,1.5;3.8,1;right;" .. S("Turn right") .. "]" ..
		"label[0.3,2.5;" .. status .. "]"
end


minetest.register_node("techage:ta4_turncontroller", {
	description = S("TA4 Turn Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_turn.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		techage.logic.after_place_node(pos, placer, "techage:ta4_turncontroller", S("TA4 Turn Controller"))
		techage.logic.infotext(meta, DESCRIPTION)
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec(nvm, meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)

		if fields.record then
			nvm.lpos1 = {}
			nvm.lpos2 = {}
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all blocks that shall be turned"))
			mark.start(name, MAX_BLOCKS)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.done then
			local name = player:get_player_name()
			local pos_list = mark.get_poslist(name)
			local text = #pos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			nvm.lpos = pos_list
			mark.unmark_all(name)
			mark.stop(name)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.left then
			meta:set_string("status", "")
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "l")
			if new_posses then
				nvm.lpos = new_posses
				local name = player:get_player_name()
				mark.stop(name)
			end
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.right then
			meta:set_string("status", "")
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
			if new_posses then
				nvm.lpos = new_posses
				local name = player:get_player_name()
				mark.stop(name)
			end
			meta:set_string("formspec", formspec(nvm, meta))
		end
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		mark.unmark_all(name)
		mark.stop(name)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local INFO = [[Commands: 'left', 'right', 'uturn']]

techage.register_node({"techage:ta4_turncontroller"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "info" then
			return INFO
		elseif topic == "left" then
			local nvm = techage.get_nvm(pos)
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "l")
			if new_posses then
				nvm.lpos = new_posses
				return true
			end
			return false
		elseif topic == "right" then
			local nvm = techage.get_nvm(pos)
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
			if new_posses then
				nvm.lpos = new_posses
				return true
			end
			return false
		elseif topic == "uturn" then
			local nvm = techage.get_nvm(pos)
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
			if new_posses then
				nvm.lpos = new_posses
				new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
				if new_posses then
					nvm.lpos = new_posses
					return true
				end
			end
			return false
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


local storage = minetest.get_mod_storage()


local function get_number()
	storage:set_int("number", storage:get_int("number") + 1)
	return storage:get_int("number")
end

local function store_node_data(meta, lrpos, data)
	local number = meta:get_string("number")
	local tbl = {lrpos = lrpos, data = data}
	storage:set_string(number, minetest.serialize(tbl))
end

local function get_node_data(meta)
	local number = meta:get_string("number")
	local s = storage:get_string(number)
	storage:set_string(number, "")
	local tbl = minetest.deserialize(s or "")
	if tbl then
		return tbl.lrpos, tbl.data
	end
end

local function has_node_data(meta)
	local number = meta:get_string("number")
	return storage:contains(number)
end


local function pack_nodes(pos, nvm)
	local tbl = {}
	for idx, rpos in ipairs(nvm.lrpos or {}) do
		local pos2 = vector.add(pos, rpos)
		local node = minetest.get_node(pos2)
		print("node", node.name, P2S(pos))
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_pack then
			tbl[rpos] = {name = node.name, param2 = node.param2, data = ndef.on_pack(pos2, node)}
		end
	end
	return tbl
end

local function unpack_nodes(pos, tbl)
	for rpos, item in pairs(tbl or {}) do
		local pos2 = vector.add(pos, rpos)
		local ndef = minetest.registered_nodes[item.name]
		if ndef and ndef.on_unpack then
			ndef.on_unpack(pos2, item.name, item.param2, item.data)
		end
	end
end

local function restore_metadata(itemstack, meta)
	local imeta = itemstack:get_meta()
	if imeta then
		meta:set_string("number", imeta:get_string("number"))
	end
end

local function preserve_metadata(pos, oldnode, oldmetadata, drops)
	local imeta = drops[1]:get_meta()
	imeta:set_string("description", oldmetadata.infotext)
	imeta:set_string("number", oldmetadata.number)
end

local function formspec(meta)
	local status = meta:get_string("status")
	return "size[8,4]" ..
		"button[0.7,1.2;3,1;record;" .. S("Record") .. "]" ..
		"button[4.3,1.2;3,1;ready;" .. S("Done") .. "]" ..
		"button[0.7,2.2;3,1;pack;" .. S("Pack") .. "]" ..
		"button[4.3,2.2;3,1;unpack;" .. S("Unpack") .. "]" ..
		"label[0.5,3.3;" .. status .. "]"
end

local Data = nil

minetest.register_node("test:container", {
	description = S("Test Container"),
	tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_front.png",
		"default_chest_inside.png"
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		restore_metadata(itemstack, meta)
		if not meta:contains("number") then
			meta:set_string("number", get_number())
		end
		meta:set_string("infotext", S("Test Container") .. ": " .. meta:get_string("number"))
		meta:set_string("formspec", formspec(meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		local nvm = tubelib2.get_mem(pos)
		local data
		
		if fields.record then
			local inv = meta:get_inventory()
			nvm.pos_list = nil
			nvm.is_on = false
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all blocks that shall be moved"))
			MarkedNodes[name] = {}
			meta:set_string("formspec", formspec(meta))
		elseif fields.ready then
			local name = player:get_player_name()
			local rpos_list = get_rposlist(pos, name)
			local text = #rpos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			nvm.lrpos = rpos_list
			unmark_all(name)
			meta:set_string("formspec", formspec(meta))
		elseif fields.pack and not has_node_data(meta) then
			data = pack_nodes(pos, nvm)
			store_node_data(meta, nvm.lrpos, data)
			meta:set_string("status", S("Packed"))
			meta:set_string("formspec", formspec(meta))
			local name = player:get_player_name()
			MarkedNodes[name] = nil
		elseif fields.unpack and has_node_data(meta) then
			nvm.lrpos, data = get_node_data(meta)
			unpack_nodes(pos, data)
			meta:set_string("status", S("Unpacked"))
			meta:set_string("formspec", formspec(meta))
			local name = player:get_player_name()
			MarkedNodes[name] = nil
		end
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata)
	end,

	preserve_metadata = preserve_metadata,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if puncher and puncher:is_player() then
		local name = puncher:get_player_name()
		
		if not MarkedNodes[name] then
			return
		end
		
		mark_position(name, pointed_thing.under)
	end
end)
