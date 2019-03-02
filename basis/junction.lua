--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
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
-- 'network' is the tubelib2 instance
-- 'node' is the node definition with tiles, callback functions, and so on
function techage.register_junction(name, size, boxes, network, node)
	for idx = 0,63 do
		node.groups.techage_trowel = 1
		node.groups.not_in_creative_inventory = idx
		node.drawtype = "nodebox"
		node.node_box = get_node_box(idx, size, boxes)
		node.paramtype2 = "facedir"  -- important!
		node.on_rotate = screwdriver.disallow  -- important!
		node.paramtype = "light" 
		node.sunlight_propagates = true 
		node.is_ground_content = false 
		node.drop = name.."0" 
		
		minetest.register_node(name..idx, table.copy(node))
		network:add_secondary_node_names({name..idx})
	end
end

function techage.junction_type(conn)
	local val = 0
	for idx = 1,6 do
		if conn[idx] then
			val = setbit(val, bit(idx))
		end
	end
	return val
end	
