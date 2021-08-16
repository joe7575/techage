--[[

	TechAge
	=======

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA1 Sluice Gate
	
]]--

local M = minetest.get_meta
local S = techage.S

local RADIUS = 8
local DEPTH = 2
local AMOUNT = RADIUS * RADIUS * 1.5

local function check_position(pos, facedir)
	local dir = minetest.facedir_to_dir(facedir)
	local pos_ = vector.add(pos, dir) 
	local node = minetest.get_node(pos_)
	
	if node.name ~= "default:water_source" then
		return
	end
	
	dir = vector.multiply(dir, RADIUS)
	local center = vector.add(pos, dir) 
	local pos1 = {x = center.x - RADIUS, y = center.y - DEPTH, z = center.z - RADIUS}
	local pos2 = {x = center.x + RADIUS, y = center.y + 0, z = center.z + RADIUS}
	local _, nodes = minetest.find_nodes_in_area(pos1, pos2, {"default:water_source"})
	return (nodes["default:water_source"] and nodes["default:water_source"] > AMOUNT) or false
end

-- Function checks if a millpond is avaliable and 
-- returns the pos for the new water block, and the type of block.
local function has_water(pos, facedir, player)
	local facedir2, res, dir, pos2
	
	-- check left side
	facedir2 = (facedir + 3) % 4
	res = check_position(pos, facedir2)
	facedir2 = (facedir + 1) % 4
	dir = minetest.facedir_to_dir(facedir2)
	pos2 =  vector.add(pos, dir) 
	
	if res == nil then 
		return pos2, "air"
	elseif res == true then 
		return pos2, "water"
	else
		minetest.chat_send_player(player:get_player_name(), S("Your pond is too small!"))
		return pos2, "air"
	end
	
	-- check right side
	facedir2 = (facedir + 1) % 4
	res = check_position(pos, facedir2)
	facedir2 = (facedir + 3) % 4
	dir = minetest.facedir_to_dir(facedir2)
	pos2 =  vector.add(pos, dir) 
	
	if res == nil then 
		return  pos2, "air"
	elseif res == true then 
		return pos2, "water"
	else
		minetest.chat_send_player(player:get_player_name(), S("Your pond is too small!"))
		return pos2, "air"
	end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local pos2 = vector.add(pos, {x = 0, y = -1, z = 0})
	local node2 = minetest.get_node(pos2)
	local pos3, res = has_water(pos2, node2.param2, clicker)
	local node3 = minetest.get_node(pos3)
	
	if node2.name == "techage:ta1_sluice_closed" then
		minetest.swap_node(pos, {name = "techage:ta1_sluice_handle_open", param2 = node.param2})
		minetest.swap_node(pos2, {name = "techage:ta1_sluice_open", param2 = node.param2})
		if res == "water" then
			if node3.name == "air" or node3.name == "techage:water_flowing" then
				minetest.add_node(pos3, {name = "techage:water_source"})
				minetest.get_node_timer(pos3):start(2)
			end
		else
			minetest.add_node(pos3, {name = "air"})
		end
		minetest.sound_play("doors_door_open", {gain = 0.5, pos = pos,
			max_hear_distance = 10}, true)
	elseif node2.name == "techage:ta1_sluice_open" then
		minetest.swap_node(pos, {name = "techage:ta1_sluice_handle_closed", param2 = node.param2})
		minetest.swap_node(pos2, {name = "techage:ta1_sluice_closed", param2 = node.param2})
		if res == "water" then
			if node3.name == "techage:water_source" then
				minetest.add_node(pos3, {name = "techage:water_flowing"})
			end
		else
			if node3.name == "techage:water_flowing" then
				minetest.add_node(pos3, {name = "air"})
			end
		end
		minetest.sound_play("doors_door_close", {gain = 0.5, pos = pos,
			max_hear_distance = 10}, true)
	end
end

minetest.register_node("techage:ta1_sluice_closed", {
	description = S("TA1 Sluice Gate"),
	tiles = {
		"default_wood.png^techage_junglewood_top.png",
		"default_wood.png",
		"default_wood.png^techage_junglewood.png",
		"default_wood.png^techage_junglewood.png",
		"default_wood.png",
		"default_wood.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16,  5/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16,  8/16, -5/16},
			{-8/16, -8/16, -8/16,  8/16, -5/16,  8/16},
			{-1/16, -5/16, -7/16,  1/16,  8/16,  7/16},
		},
	},
	
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta1_sluice_open", {
	description = S("TA1 Sluice Gate"),
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16,  5/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16,  8/16, -5/16},
			{-8/16, -8/16, -8/16,  8/16, -5/16,  8/16},
		},
	},
	
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:sluice_closed",
})

minetest.register_node("techage:ta1_sluice_handle_closed", {
	description = S("TA1 Sluice Handle"),
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16, 0/16,  8/16},
			{-1/16,  0/16, -1/16,  1/16, 4/16,  1/16},
			{-1/16,  2/16, -4/16,  1/16, 4/16,  4/16},
		},
	},
	on_rightclick = on_rightclick,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta1_sluice_handle_open", {
	description = S("TA1 Sluice Handle"),
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16,  0/16,  8/16},
			{-1/16,  0/16, -1/16,  1/16, 14/16,  1/16},
			{-1/16, 14/16, -4/16,  1/16, 16/16,  4/16},
		},
	},
	on_rightclick = on_rightclick,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:sluice_handle_closed",
})

minetest.register_craft({
	output = "techage:ta1_sluice_closed",
	recipe = {
		{"", "", ""},
		{"techage:ta1_board1_apple", "techage:ta1_board1_jungle", "techage:ta1_board1_apple"},
		{"", "techage:ta1_board1_apple", ""},
	},
})

minetest.register_craft({
	output = "techage:ta1_sluice_handle_closed",
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"", "default:stick", ""},
		{"", "stairs:slab_wood", ""},
	},
})
