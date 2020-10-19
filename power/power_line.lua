--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA3/TA4 Power line for electrical landline
]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local networks = techage.networks
local Cable = techage.ElectricCable
local power = techage.power

local function can_dig(pos, digger)
	if M(pos):get_string("owner") == digger:get_player_name() then
		return true
	end
	if minetest.check_player_privs(digger:get_player_name(), "powerline") then
		return true
	end
	return false
end

-- legacy node
minetest.register_node("techage:power_line", {
	description = S("TA Power Line"),
	tiles = {"techage_power_line.png"},
	inventory_image = 'techage_power_line_inv.png',
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Cable:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/32, -1/32, -4/8,  1/32, 1/32, 4/8},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/32, -2/32, -4/8,  2/32, 2/32, 4/8},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "techage:power_lineS",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
})

-- new nodes lineS/lineA
minetest.register_node("techage:power_lineS", {
	description = S("TA Power Line"),
	tiles = {"techage_power_line.png"},
	inventory_image = 'techage_power_line_inv.png',
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Cable:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/32, -1/32, -4/8,  1/32, 1/32, 4/8},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/32, -2/32, -4/8,  2/32, 2/32, 4/8},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "techage:power_lineS",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:power_lineA", {
	description = S("TA Power Line"),
	tiles = {
		"techage_power_line.png",
		"techage_power_line.png^[transformR180",
		"techage_power_line.png^[transformR270",
		"techage_power_line.png",
		"techage_power_line.png",
		"techage_power_line.png",
	},
	inventory_image = 'techage_power_line_inv.png',
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Cable:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/32, -16/32,  -1/32,  1/32, -15/32,   1/32},
			{-1/32, -16/32,  -2/32,  1/32, -14/32,   0/32},
			{-1/32, -15/32,  -3/32,  1/32, -13/32,  -1/32},
			{-1/32, -14/32,  -4/32,  1/32, -12/32,  -2/32},
			{-1/32, -13/32,  -5/32,  1/32, -11/32,  -3/32},
			{-1/32, -12/32,  -6/32,  1/32, -10/32,  -4/32},
			{-1/32, -11/32,  -7/32,  1/32,  -9/32,  -5/32},
			{-1/32, -10/32,  -8/32,  1/32,  -8/32,  -6/32},
			{-1/32,  -9/32,  -9/32,  1/32,  -7/32,  -7/32},
			{-1/32,  -8/32, -10/32,  1/32,  -6/32,  -8/32},
			{-1/32,  -7/32, -11/32,  1/32,  -5/32,  -9/32},
			{-1/32,  -6/32, -12/32,  1/32,  -4/32, -10/32},
			{-1/32,  -5/32, -13/32,  1/32,  -3/32, -11/32},
			{-1/32,  -4/32, -14/32,  1/32,  -2/32, -12/32},
			{-1/32,  -3/32, -15/32,  1/32,  -1/32, -13/32},
			{-1/32,  -2/32, -16/32,  1/32,   0/32, -14/32},
			{-1/32,  -1/32, -16/32,  1/32,   1/32, -15/32},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/32, -16/32, 2/32,  2/32, 2/32, -16/32},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "techage:power_lineS",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:power_pole2", {
	description = S("TA Power Pole Top 2 (for landlines)"),
	tiles = {
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole.png"
	},
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -4/32, -16/32,  -4/32,   4/32, 16/32,   4/32},
			{ -1/32,  -6/32, -16/32,   1/32, -4/32,  16/32},
			{ -2/32,  -4/32, -16/32,   2/32,  4/32, -12/32},
			{ -2/32,  -4/32,  12/32,   2/32,  4/32,  16/32},
		},
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		M(pos):set_string("owner", placer:get_player_name())
		if techage.is_protected(pos, placer:get_player_name()) then
			minetest.chat_send_player(placer:get_player_name(), "position is protected   ")
			minetest.remove_node(pos)
			return true
		end
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.chat_send_player(placer:get_player_name(), "invalid pole position   ")
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	can_dig = can_dig,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Cable:after_dig_tube(pos, oldnode)
		end
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		power.update_network(pos, nil, tlib2)
	end,
	
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

-- dummy node for the inventory and to be placed and imediately replaced
minetest.register_node("techage:power_pole", {
	description = S("TA Power Pole Top (for up to 6 connections)"),
	tiles = {
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole.png"
	},
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -4/32, -16/32,  -4/32,   4/32, 16/32,   4/32},
			{-16/32,  -6/32,  -1/32,  16/32, -4/32,   1/32},
			{ -1/32,  -6/32, -16/32,   1/32, -4/32,  16/32},
			{-16/32,  -4/32,  -2/32, -12/32,  4/32,   2/32},
			{ 12/32,  -4/32,  -2/32,  16/32,  4/32,   2/32},
			{ -2/32,  -4/32, -16/32,   2/32,  4/32, -12/32},
			{ -2/32,  -4/32,  12/32,   2/32,  4/32,  16/32},
		},
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		M(pos):set_string("owner", placer:get_player_name())
		if techage.is_protected(pos, placer:get_player_name()) then
			minetest.chat_send_player(placer:get_player_name(), "position is protected   ")
			minetest.remove_node(pos)
			return true
		end
		local node = minetest.get_node(pos)
		node.name = "techage:power_pole_conn"
		minetest.swap_node(pos, node)
		Cable:after_place_node(pos)
	end,
	
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
})


-- secondary node like a junction
minetest.register_node("techage:power_pole_conn", {
	description = "TA Power Pole Top (for up to 6 connections)",
	tiles = {
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole.png"
	},
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {{ -4/32, -16/32,  -4/32,   4/32, 16/32,   4/32}},
		
		connect_left = {{-16/32, -6/32, -1/32,  1/32,  -4/32, 1/32},	
			{-16/32, -4/32, -2/32, -12/32, 4/32, 2/32}},
		connect_right = {{ -1/32, -6/32, -1/32,  16/32, -4/32, 1/32},	
			{12/32, -4/32, -2/32,  16/32, 4/32, 2/32}},
		connect_back = {{-1/32, -6/32,  -1/32,  1/32, -4/32, 16/32},
			{-2/32, -4/32, 12/32, 2/32, 4/32, 16/32}},
		connect_front = {{-1/32, -6/32, -16/32,  1/32, -4/32, 1/32},
			{-2/32, -4/32, -16/32,  2/32, 4/32, -12/32}},
	},
	connects_to = {"techage:power_line", "techage:power_lineS", "techage:power_lineA"},

	-- after_place_node -- see techage:power_pole
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		power.update_network(pos, nil, tlib2)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
	end,
	can_dig = can_dig,
	networks = {
		ele1 = {
			sides = networks.AllSides, -- connection sides for cables
			ntype = "junc",
		},
	},
	
	drop = "techage:power_pole",
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
})

Cable:add_secondary_node_names({"techage:power_pole_conn"})


minetest.register_node("techage:power_pole3", {
	description = S("TA Power Pole"),
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -4/32, -16/32,  -4/32,   4/32, 16/32,   4/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_craft({
	output = "techage:power_lineS 24",
	recipe = {
		{"default:copper_ingot", "", ""},
		{"", "default:copper_ingot", ""},
		{"", "", "default:copper_ingot"},
	},
})

minetest.register_craft({
	output = "techage:power_pole2",
	recipe = {
		{"", "default:stick", ""},
		{"techage:power_lineS", "default:copper_ingot", "techage:power_lineS"},
		{"", "default:stick", ""},
	},
})

minetest.register_craft({
	output = "techage:power_pole",
	recipe = {
		{"", "", ""},
		{"", "techage:power_pole2", ""},
		{"", "techage:power_pole2", ""},
	},
})

minetest.register_craft({
	output = "techage:power_pole3 4",
	recipe = {
		{"", "group:wood", ""},
		{"", "techage:power_lineS", ""},
		{"", "group:wood", ""},
	},
})

