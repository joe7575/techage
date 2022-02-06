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
	print("on_pack_fallback_",P2S(pos), node.name)
	local smeta = techage.pack_meta(pos)
	local snvm = techage.pack_nvm(pos)
	minetest.remove_node(pos)
	return {smeta = smeta, snvm = snvm}
end

local function on_unpack_fallback(pos, name, param2, data)
	print("on_unpack_fallback",P2S(pos), name)
	minetest.add_node(pos, {name = name, param2 = param2})
	techage.unpack_meta(pos, data.smeta)
	if data.snvm then
		techage.unpack_nvm(pos, data.snvm)
	end
end

-- cpos is the center pos
-- npos the the node pos
-- turn is one of "l", "r", "2l", "2r"
local function get_new_node_pos(cpos, npos, turn, item)
	item.param2 = techage.rotate_param2(item, turn)
	return techage.rotate_around_axis(npos, cpos, turn)
end

-- pack/unpack API functions
function techage.pack_nodes(pos, pos_list)
	print("pack_nodes", P2S(pos), #pos_list)
	local tbl = {}
	for idx, rpos in ipairs(pos_list or {}) do
		local pos2 = vector.add(pos, rpos)
		local node = minetest.get_node(pos2)
		--print("node", node.name, P2S(pos))
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_pack then
			tbl[rpos] = {name = node.name, param2 = node.param2, data = ndef.on_pack(pos2, node)}
		else
			tbl[rpos] = {name = node.name, param2 = node.param2, data = on_pack_fallback_(pos2, node)}
		end
	end
	return tbl
end

function techage.unpack_nodes(pos, tbl, turn)
	print("unpack_nodes", P2S(pos), turn)
	-- Check positions
	for rpos, item in pairs(tbl or {}) do
		local pos2 = vector.add(pos, rpos)
		pos2 = techage.rotate_around_axis(pos2, pos, turn)
		local node = minetest.get_node(pos2)
		if not techage.is_air_like(node.name) then
			return false
		end
	end
	-- Place nodes
	local out = {}
	for rpos, item in pairs(tbl or {}) do
		local pos2 = vector.add(pos, rpos)
		item.param2 = techage.rotate_param2(item, turn)
		pos2 = techage.rotate_around_axis(pos2, pos, turn)
		local ndef = minetest.registered_nodes[item.name]
		if ndef and ndef.on_unpack then
			ndef.on_unpack(pos2, item.name, item.param2, item.data)
		else
			on_unpack_fallback(pos2, item.name, item.param2, item.data)
		end
		-- Because of the rotated arrangement, generate a new rel-pos table
		table.insert(out, vector.subtract(pos2, pos))
	end
	return out
end

