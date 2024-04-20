--[[

	TechAge
	=======

	Copyright (C) 2019-2024 Joachim Stolberg

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
local function pack_nvm(pos)
	if techage.has_nvm(pos) then
		local s = minetest.serialize(techage.get_nvm(pos))
		techage.del_mem(pos)
		return s
	end
end

local function unpack_nvm(pos, s)
	if s and s ~= "" then
		local tbl = minetest.deserialize(s)
		local nvm = techage.get_nvm(pos)
		for k,v in pairs(tbl) do
			nvm.k = v
		end
	end
end

-- pack/unpack node metedata
local function pack_meta(pos)
	local tbl = M(pos):to_table() or {}
	usercode_to_string(tbl)
	return minetest.serialize(tbl)
end

local function unpack_meta(pos, s)
	if s and s ~= "" then
		local tbl = minetest.deserialize(s) or {}
		string_to_usercode(tbl)
		M(pos):from_table(tbl)
	end
end

-------------------------------------------------------------------------------
-- preserve/restore API functions
-------------------------------------------------------------------------------

function techage.preserve_nodedata(pos)
	local smeta = pack_meta(pos)
	local snvm = pack_nvm(pos)
	return minetest.serialize({smeta = smeta, snvm = snvm})
end

function techage.restore_nodedata(pos, s)
	local tbl = minetest.deserialize(s) or {}
	unpack_nvm(pos, tbl.snvm)
	unpack_meta(pos, tbl.smeta)
end
