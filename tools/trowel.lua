--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Trowel tool to hide/open cable/pipe/tube nodes

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S


-- used by other tools: dug_node[player_name] = pos
techage.dug_node = {}

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
	local ndef = minetest.registered_nodes[taken:get_name()]
	-- test if it is a simple node without logic
	if taken:get_count() == 1
	and ndef
	and not ndef.groups.soil 
	and not ndef.after_place_node 
	and not ndef.on_construct then
		meta:set_string("techage_hidden_nodename", node.name)
		meta:set_string("techage_hidden_param2", node.param2)
		local param2 = 0
		if ndef.paramtype2 and ndef.paramtype2 == "facedir" then
			param2 = minetest.dir_to_facedir(placer:get_look_dir(), true)
		end
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
		minetest.sound_play("default_dig_snappy", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 5})
	end
end

minetest.register_node("techage:trowel", {
	description = S("TechAge Trowel"),
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
		-- probably a hidden node with mem data
		tubelib2.del_mem(pos)
	else
		-- store pos for other tools without own 'register_on_dignode'
		techage.dug_node[digger:get_player_name()] = pos
	end
end)

minetest.register_craft({
	output = "techage:trowel",
	recipe = {
		{"basic_materials:steel_bar", "basic_materials:steel_bar", ""},
		{"basic_materials:steel_bar", "default:stick", ""},
		{"", "", "default:stick"},
	},
})

