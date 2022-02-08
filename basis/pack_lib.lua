--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Packing functions

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta

-- string/usercode conversion
local function usercode_to_string(tbl)
	if tbl and tbl.inventory then
		for list_name,list in pairs(tbl.inventory) do
			for i,item in ipairs(list) do
				tbl.inventory[list_name][i] = item:to_string()
			end
		end
	end
end

local function string_to_usercode(tbl)
	if tbl and tbl.inventory then
		for list_name,list in pairs(tbl.inventory) do
			for i,item in ipairs(list) do
				tbl.inventory[list_name][i] = ItemStack(item)
			end
		end
	end
end

-- pack/unpack node nvm data
function techage.pack_nvm(pos)
	if techage.has_nvm(pos) then
		local s = minetest.serialize(techage.get_nvm(pos))
		techage.del_mem(pos)
		return s
	end
end

function techage.unpack_nvm(pos, s)
	local tbl = minetest.deserialize(s)
	local nvm = techage.get_nvm(pos)
	for k,v in pairs(tbl) do
		nvm.k = v
	end
end

-- pack/unpack node metedata
function techage.pack_meta(pos)
	local tbl = M(pos):to_table() or {}
	usercode_to_string(tbl)
	return minetest.serialize(tbl)
end

function techage.unpack_meta(pos, s)
	local tbl = minetest.deserialize(s) or {}
	string_to_usercode(tbl)
	M(pos):from_table(tbl)
end

-- on_pack/on_unpack fallback functions
local function on_pack_fallback_(pos, node)
	--print("on_pack_fallback_",P2S(pos), node.name)
	local smeta = techage.pack_meta(pos)
	local snvm = techage.pack_nvm(pos)
	minetest.remove_node(pos)
	return {smeta = smeta, snvm = snvm}
end

local function on_unpack_fallback(pos, name, param2, data)
	--print("on_unpack_fallback",P2S(pos), name)
	minetest.add_node(pos, {name = name, param2 = param2})
	techage.unpack_meta(pos, data.smeta)
	if data.snvm then
		techage.unpack_nvm(pos, data.snvm)
	end
end

-------------------------------------------------------------------------------
-- pack/unpack API functions
-------------------------------------------------------------------------------
-- pos_list is a list of node positions
function techage.pack_nodes(pos_list)
	local pack_tbl = {}
	for _, pos2 in ipairs(pos_list or {}) do
		local node = minetest.get_node(pos2)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_pack then
			pack_tbl[pos2] = {name = node.name, param2 = node.param2, data = ndef.on_pack(pos2, node)}
		else
			pack_tbl[pos2] = {name = node.name, param2 = node.param2, data = on_pack_fallback_(pos2, node)}
		end
	end
	return pack_tbl
end

function techage.unpack_nodes(pack_tbl)
	-- Check positions
	for pos2, _ in pairs(pack_tbl or {}) do
		local node = minetest.get_node(pos2)
		if not techage.is_air_like(node.name) then
			return false
		end
	end
	-- Place nodes
	for pos2, item in pairs(pack_tbl or {}) do
		local ndef = minetest.registered_nodes[item.name]
		if ndef and ndef.on_unpack then
			ndef.on_unpack(pos2, item.name, item.param2, item.data)
		else
			on_unpack_fallback(pos2, item.name, item.param2, item.data)
		end
	end
	return true
end

-------------------------------------------------------------------------------
-- move/turn API functions
-------------------------------------------------------------------------------
function techage.determine_turn_rotation(old_param2, new_param2)
	local offs = new_param2 - old_param2
	if offs == -1 or offs == 3 then return "l"
	elseif offs == 1 or offs == -3 then return "r"
	elseif offs == 2 or offs == -2 then return "2r"
	else return "" end
end

-- move is the distance between old and new pos as vector
function techage.adjust_pos_list_move(pos_list, move)
	local out = {}
	for idx, pos in ipairs(pos_list or {}) do
		local pos2 = vector.add(pos, move)
		out[idx] = pos2
	end
	return out
end

-- Adjust the data for a turn of all nodes around cpos
-- turn is one of "l", "r", "2l", "2r"
function techage.adjust_pos_list_turn(cpos, pos_list, turn)
	local out = {}
	for idx, npos in ipairs(pos_list or {}) do
		local pos2 = techage.rotate_around_axis(npos, cpos, turn)
		out[idx] = pos2
	end
	return out
end

-- move is the distance between old and new pos as vector
function techage.adjust_pack_tbl_move(pack_tbl, move)
	local out = {}
	for pos, item in pairs(pack_tbl or {}) do
		local pos2 = vector.add(pos, move)
		out[pos2] = item
	end
	return out
end

-- Adjust the data for a turn of all nodes around cpos
-- turn is one of "l", "r", "2l", "2r"
function techage.adjust_pack_tbl_turn(cpos, pack_tbl, turn)
	local out = {}
	for npos, item in pairs(pack_tbl or {}) do
		item.param2 = techage.rotate_param2(item, turn)
		local pos2 = techage.rotate_around_axis(npos, cpos, turn)
		out[pos2] = item
	end
	return out
end

