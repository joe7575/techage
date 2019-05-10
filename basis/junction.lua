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
-- 'techage' is the power network definition
function techage.register_junction(name, size, boxes, network, node)
	for idx = 0,63 do
		local node1 = table.copy(node)
		node1.groups.techage_trowel = 1
		if idx == 0 then
			node1.groups.not_in_creative_inventory = 0
		else
			node1.groups.not_in_creative_inventory = 1
		end
		node1.drawtype = "nodebox"
		node1.node_box = get_node_box(idx, size, boxes)
		node1.paramtype2 = "facedir"
		node1.on_rotate = screwdriver.disallow
		node1.paramtype = "light" 
		node1.sunlight_propagates = true 
		node1.is_ground_content = false 
		node1.drop = name.."0" 
		--node.techage = techage
		minetest.register_node(name..idx, node1)
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

