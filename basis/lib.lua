--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Helper functions

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

function techage.range(val, min, max)
	val = tonumber(val)
	if val < min then return min end
	if val > max then return max end
	return val
end

function techage.one_of(val, selection)
	for _,v in ipairs(selection) do
		if val == v then return val end
	end
	return selection[1]
end

function techage.get_node_lvm(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:index(pos.x, pos.y, pos.z)
	node = {
		name = minetest.get_name_from_content_id(data[idx]),
		param2 = param2_data[idx]
	}
	return node
end



--
-- Functions used to hide electric cable and biogas pipes
--
-- Overridden method of tubelib2!
function techage.get_primary_node_param2(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local param2 = M(npos):get_int("tl2_param2")
	if param2 ~= 0 then
		return param2, npos
	end
end

-- Overridden method of tubelib2!
function techage.is_primary_node(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local param2 = M(npos):get_int("tl2_param2")
	return param2 ~= 0
end

-- returns true if node can be dug
function techage.can_node_dig(node)
	-- don't remove nodes with some intelligence or undiggable nodes
	local ndef = minetest.registered_nodes[node.name]
	if not ndef or node.name == "air" then return false end
	if ndef.drop == "" then return false end
	if ndef.diggable == false then return false end
	if ndef.after_dig_node then return false end
	return true
end	
