--[[

	TechAge
	=======

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA1 Sluice Gate

]]--

local S = techage.S

local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

local function check_position(pos, facedir)
	local dir = minetest.facedir_to_dir(facedir)
	local pos_ = vector.add(pos, dir)
	local node = minetest.get_node(pos_)
	return (node.name == "default:water_source" or node.name == "default:water_flowing"), pos_
end

-- Function checks if water is avaliable and
-- returns the pos for the new water block, and the result (true/false).
local function has_water(pos, facedir)
	local res1, pos1 = check_position(pos, (facedir + 1) % 4)
	local res2, pos2 = check_position(pos, (facedir + 3) % 4)

	if res1 and not res2 then
		M(pos):set_string("millrace_pos", P2S(pos2))
		return pos2, true
	end

	if not res1 and res2 then
		M(pos):set_string("millrace_pos", P2S(pos1))
		return pos1, true
	end

	local pos3 = S2P(M(pos):get_string("millrace_pos"))
	if pos3 then
		return pos3, true
	end
	return pos1, false
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end

	local pos2 = vector.add(pos, {x = 0, y = -1, z = 0})
	local node2 = minetest.get_node(pos2)
	local pos3, res = has_water(pos2, node2.param2)
	local node3 = minetest.get_node(pos3)

	if node2.name == "techage:ta1_sluice_closed" then
		minetest.swap_node(pos, {name = "techage:ta1_sluice_handle_open", param2 = node.param2})
		minetest.swap_node(pos2, {name = "techage:ta1_sluice_open", param2 = node.param2})
		if res then
			minetest.add_node(pos3, {name = "default:water_source"})
			minetest.get_node_timer(pos3):start(2)
		end
		minetest.sound_play("doors_door_open", {gain = 0.5, pos = pos,
			max_hear_distance = 10}, true)
	elseif node2.name == "techage:ta1_sluice_open" then
		minetest.swap_node(pos, {name = "techage:ta1_sluice_handle_closed", param2 = node.param2})
		minetest.swap_node(pos2, {name = "techage:ta1_sluice_closed", param2 = node.param2})
		if res then
			minetest.add_node(pos3, {name = "air"})
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
	drop = "techage:ta1_sluice_closed",
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
	drop = "techage:ta1_sluice_handle_closed",
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
