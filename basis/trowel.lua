--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Trowel tool to hide/open cable/pipe/tube nodes

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

-- used by other tools: dug_node[player_name] = pos
techage.dug_node = {}

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

-- Determine if one node in the surrounding is a hidden tube/cable/pipe
local function other_hidden_nodes(pos, node_name)
	return M({x=pos.x+1, y=pos.y, z=pos.z}):get_string(node_name) ~= "" or
		M({x=pos.x-1, y=pos.y, z=pos.z}):get_string(node_name) ~= "" or
		M({x=pos.x, y=pos.y+1, z=pos.z}):get_string(node_name) ~= "" or
		M({x=pos.x, y=pos.y-1, z=pos.z}):get_string(node_name) ~= "" or
		M({x=pos.x, y=pos.y, z=pos.z+1}):get_string(node_name) ~= "" or
		M({x=pos.x, y=pos.y, z=pos.z-1}):get_string(node_name) ~= ""
end
	
local function hide_node(pos, node, meta, placer)
	local inv = placer:get_inventory()
	local stack = inv:get_stack("main", 1)
	local taken = stack:take_item(1)
	-- test if it is a simple node without logic
	if taken:get_count() == 1 
	and minetest.registered_nodes[taken:get_name()] 
	and not minetest.registered_nodes[taken:get_name()].after_place_node 
	and not minetest.registered_nodes[taken:get_name()].on_construct then
		meta:set_string("techage_hidden_nodename", node.name)
		meta:set_string("techage_hidden_param2", node.param2)
		local param2 = minetest.dir_to_facedir(placer:get_look_dir(), true)
		minetest.swap_node(pos, {name = taken:get_name(), param2 = param2})
		inv:set_stack("main", 1, stack)
	end
end

local function open_node(pos, node, meta, placer)
	local name = meta:get_string("techage_hidden_nodename")
	local param2 = meta:get_string("techage_hidden_param2")
	minetest.swap_node(pos, {name = name, param2 = param2})
	meta:set_string("techage_hidden_nodename", "")
	meta:set_string("techage_hidden_param2", "")
	local inv = placer:get_inventory()
	inv:add_item("main", ItemStack(node.name))
end

-- Hide or open a node
local function replace_node(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local meta = M(pos)
		local node =  minetest.get_node(pos)
		if minetest.get_item_group(node.name, "techage_trowel") == 1 then
			hide_node(pos, node, meta, placer)
		elseif meta:get_string("techage_hidden_nodename") ~= "" then
			open_node(pos, node, meta, placer)
		end
	end
end

minetest.register_node("techage:trowel", {
	description = I("TechAge Trowel (uses items from the first, left inventory stack)"),
	inventory_image = "techage_trowel.png",
	wield_image = "techage_trowel.png",
	use_texture_alpha = true,
	groups = {cracky=1},
	on_use = replace_node,
	on_place = replace_node,
	node_placement_prediction = "",
	stack_max = 1,
})

minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger then return end
	-- If hidden nodes are arround, the removed one was probably
	-- a hidden node, too.
	if other_hidden_nodes(pos, "techage_hidden_nodename") then
		-- test both hidden networks
		techage.ElectricCable:after_dig_node(pos, oldnode, digger)
		techage.BiogasPipe:after_dig_node(pos, oldnode, digger)
	else
		techage.dug_node[digger:get_player_name()] = pos
	end
end)
