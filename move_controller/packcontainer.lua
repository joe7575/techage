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
		"label[0.3,3.9;" .. status .. "]"
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
	if oldmetadata.data_stored == "1" then
		local meta = drops[1]:get_meta()
		meta:set_string("storage_pos", P2S(pos))
		meta:set_string("node_name", oldmetadata.node_name or "")
		meta:set_string("status", oldmetadata.status or "")
		meta:set_int("data_stored", 1)
		meta:set_string("description", DESCRIPTION .. ' "' .. (oldmetadata.node_name or "") .. '"')
	end
end

local function get_storage_pos(pos, nvm, itemstack)
	local imeta = itemstack:get_meta()
	if imeta then
		local meta = M(pos)
		meta:set_string("node_name", imeta:get_string("node_name"))
		meta:set_string("status", imeta:get_string("status"))
		meta:set_int("data_stored", imeta:get_int("data_stored"))
		nvm.storage_pos = S2P(imeta:get_string("storage_pos"))
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

local function determine_rotation(old_param2, new_param2)
	local offs = new_param2 - old_param2
	print("determine_rotation", offs)
	if     offs ==  0 then return ""
	elseif offs == -1 then return "l"
	elseif offs ==  1 then return "r"
	else return "2r" end
end

local function after_place_node(pos, placer, itemstack)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	meta:set_string("infotext", DESCRIPTION)
	meta:set_string("owner", placer:get_player_name())
	if get_storage_pos(pos, nvm, itemstack) then
		local node = techage.get_node_lvm(nvm.storage_pos)
		if node.name == "techage:ta5_packcontainer_storage" then
			nvm.turn = determine_rotation(node.param2, minetest.get_node(pos).param2)
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
	local data_stored = meta:get_int("data_stored") == 1

	if fields.record and not data_stored then
		nvm.lrpos = nil
		meta:set_string("status", S("Recording..."))
		local name = player:get_player_name()
		minetest.chat_send_player(name, S("Click on all blocks that shall be turned"))
		mark.start(name, MAX_BLOCKS)
		meta:set_string("formspec", formspec(nvm, meta))
	elseif fields.store and not data_stored then
		meta:set_string("node_name", fields.node_name)
		meta:set_string("formspec", formspec(nvm, meta))
	elseif fields.done and not data_stored then
		local name = player:get_player_name()
		local pos_list = mark.get_poslist(name)
		local text = #pos_list.." "..S("block positions are stored.")
		meta:set_string("status", text)
		meta:set_string("node_name", fields.node_name)
		nvm.lrpos = get_rposlist(pos, pos_list)
		mark.unmark_all(name)
		mark.stop(name)
		meta:set_string("formspec", formspec(nvm, meta))
	elseif fields.pack and nvm.lrpos and #nvm.lrpos > 0 and not data_stored then
		nvm.pack_tbl = techage.pack_nodes(pos, nvm.lrpos or {})
		meta:set_string("status", S("Blocks stored"))
		meta:set_string("formspec", formspec(nvm, meta))
		meta:set_int("data_stored", 1)
	elseif fields.unpack and data_stored then
		local tbl = techage.unpack_nodes(pos, nvm.pack_tbl, nvm.turn or "")
		if tbl then
			nvm.lrpos = tbl
			meta:set_string("status", S("Blocks placed"))
			meta:set_string("formspec", formspec(nvm, meta))
			meta:set_int("data_stored", 0)
			nvm.turn = ""
		else
			meta:set_string("status", S("Position(s) occupied"))
			meta:set_string("formspec", formspec(nvm, meta))
		end
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	local name = digger:get_player_name()
	mark.unmark_all(name)
	mark.stop(name)

	if oldmetadata.fields.data_stored == "1" then
		minetest.set_node(pos, {name = "techage:ta5_packcontainer_storage", param2 = oldnode.param2})
		local owner = oldmetadata.fields.owner or ""
		M(pos):set_string("infotext", S("@1's @2 storage", owner, DESCRIPTION))
	else
		techage.del_mem(pos)
	end
end

minetest.register_node("techage:ta5_packcontainer", {
	description = DESCRIPTION,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_pack.png",
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
			{ -5/16, -8/16, -5/16, 5/16, -5/16, 5/16},
		},
	},
	tiles = {
		-- up, down, right, left, back, front
		"techage_pack_storage.png",
	},
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 5,
	glow = 12,
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
