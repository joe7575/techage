--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Packing functions

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta

--function techage.pack_nvm(pos)
--	return minetest.serialize(techage.)
--end

--function techage.unpack_nvm(pos)
--end

local function serialize_inventory(tbl)
	local out1 = {}
	for k,v in pairs(tbl) do
		local out2 = {}
		for i,item in ipairs(v) do
			out2[i] = item:to_string()
		end
		out1[k] = minetest.serialize(out2)
	end
	return out1
end

function techage.pack_meta(pos)
	local tbl = M(pos):to_table()
	local fields, inventory
	
	if tbl and tbl.fields then
		fields = minetest.serialize(tbl.fields)
	end
	
	local inv = minetest.get_inventory({type="node", pos=pos})
	local lists = inv:get_lists()
	print(dump(lists))
	if lists then
		inventory = serialize_inventory(lists)
	end
	return minetest.serialize({fields = fields, inventory = inventory})
end

--function techage.unpack_meta(pos, s)
--	local tbl = minetest.deserialize(s or "") or {}
--	local out = {}
--	for i,item in ipairs(tbl) do
--		out[i] = ItemStack(item)
--	end
--	local inv = minetest.get_inventory({type="node", pos=pos})
--end