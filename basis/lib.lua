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

-- Input data to generate the Param2ToDir table
local Input = {
	8,9,10,11,    -- 1
	16,17,18,19,  -- 2
	4,5,6,7,      -- 3
	12,13,14,15,  -- 4
	0,1,2,3,      -- 5
	20,21,22,23,  -- 6
}

-- translation from param2 to dir (out of the node upwards)
local Param2Dir = {}
for idx,val in ipairs(Input) do
	Param2Dir[val] = math.floor((idx - 1) / 4) + 1
end

-- used by lamps and power switches
function techage.determine_node_bottom_as_dir(node)
	return tubelib2.Turn180Deg[Param2Dir[node.param2] or 1]
end

function techage.determine_node_top_as_dir(node)
	return Param2Dir[node.param2] or 1
end

-- rotation rules (screwdriver) for wallmounted "facedir" nodes
function techage.rotate_wallmounted(param2)
	local offs = math.floor(param2 / 4) * 4
	local rot = ((param2 % 4) + 1) % 4
	return offs + rot
end

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

function techage.index(list, x)
	for idx, v in pairs(list) do
		if v == x then return idx end
	end
	return nil
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

-- returns true, if node can be dug, otherwise false
function techage.can_node_dig(node, ndef)
	if not ndef then return false end
	if node.name == "ignore" then return false end
	if node.name == "air" then return true end
	if ndef.buildable_to == true then return true end
	if ndef.diggable == false then return false end
	if ndef.after_dig_node then return false end
	return true
end	

-- returns the node name, if node can be dropped, otherwise nil
function techage.dropped_node(node, ndef)
	if node.name == "air" then return end
	if ndef.buildable_to == true then return end
	if ndef.drop == "" then return end
	return ndef.drop or node.name
end	
