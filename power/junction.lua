--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	Junction for power distribution

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta


local function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
local function hasbit(x, p)
  return x % (p + p) >= p       
end

local function setbit(x, p)
  return hasbit(x, p) and x or x + p
end
	
local function get_node_box(val, size, boxes)
	local fixed = {{-size, -size, -size, size, size, size}}
	for i = 1,6 do
		if hasbit(val, bit(i)) then
			for _,box in ipairs(boxes[i]) do
				table.insert(fixed, box)
			end
		end
	end
	return {
		type = "fixed",
		fixed = fixed,
	}
end

-- 'size' is the size of the junction cube without any connection, e.g. 1/8
-- 'boxes' is a table with 6 table elements for the 6 possible connection arms
-- 'tlib2' is the tubelib2 instance
-- 'node' is the node definition with tiles, callback functions, and so on
-- 'index' number for the inventory node (default 0)
function techage.register_junction(name, size, boxes, tlib2, node, index)
	for idx = 0,63 do
		local ndef = table.copy(node)
		if idx == (index or 0) then
			ndef.groups.not_in_creative_inventory = 0
		else
			ndef.groups.not_in_creative_inventory = 1
		end
		ndef.groups.techage_trowel = 1
		ndef.drawtype = "nodebox"
		ndef.node_box = get_node_box(idx, size, boxes)
		ndef.paramtype2 = "facedir"
		ndef.on_rotate = screwdriver.disallow
		ndef.paramtype = "light" 
		ndef.sunlight_propagates = true 
		ndef.is_ground_content = false 
		ndef.drop = name..(index or "0")
		minetest.register_node(name..idx, ndef)
		tlib2:add_secondary_node_names({name..idx})
		-- for the case that 'tlib2.force_to_use_tubes' is set
		tlib2:add_special_node_names({name..idx}) 
	end
end

function techage.junction_type(pos, network)
	local val = 0
	for dir = 1,6 do
		if network.force_to_use_tubes then
			if network:friendly_primary_node(pos, dir) then
				val = setbit(val, bit(dir))
			elseif network:is_special_node(pos, dir) then
				val = setbit(val, bit(dir))
			end
		else
			if network:connected(pos, dir) then
				val = setbit(val, bit(dir))
			end
		end
	end
	return val
end	

