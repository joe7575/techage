--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Low Power Cable for solar plants

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local power = networks.power

local ELE2_MAX_CABLE_LENGHT = 200

local Cable = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = ELE2_MAX_CABLE_LENGHT,
	show_infotext = false,
	tube_type = "ele2",
	primary_node_names = {"techage:ta4_power_cableS", "techage:ta4_power_cableA",
		"techage:ta4_cable_wall_entry"},
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		local name = minetest.get_node(pos).name
		if name == "techage:ta4_cable_wall_entry" then
			minetest.swap_node(pos, {name = "techage:ta4_cable_wall_entry", param2 = param2})
		else
			minetest.swap_node(pos, {name = "techage:ta4_power_cable"..tube_type, param2 = param2})
		end
	end,
})

-- Use global callback instead of node related functions
Cable:register_on_tube_update2(function(pos, outdir, tlib2, node)
	power.update_network(pos, outdir, tlib2, node)
end)

minetest.register_node("techage:ta4_power_cableS", {
	description = S("TA4 Low Power Cable"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_ta4_cable.png",
		"techage_ta4_cable.png",
		"techage_ta4_cable.png",
		"techage_ta4_cable.png",
		"techage_ta4_cable_end.png",
		"techage_ta4_cable_end.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode)
	end,

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/16, -1/16, -4/8,  1/16, 1/16, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:ta4_power_cableA", {
	description = S("TA4 Low Power Cable"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_ta4_cable.png",
		"techage_ta4_cable_end.png",
		"techage_ta4_cable.png",
		"techage_ta4_cable.png",
		"techage_ta4_cable.png",
		"techage_ta4_cable_end.png",
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode)
	end,

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/16, -4/8, -1/16,  1/16, 1/16,  1/16},
			{-1/16, -1/16, -4/8,  1/16, 1/16, -1/16},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
	drop = "techage:ta4_power_cableS",
})

minetest.register_node("techage:ta4_power_box", {
	description = S("TA4 Low Power Box"),
	tiles = {
		"techage_ta4_junctionbox_top.png",
		"techage_ta4_junctionbox_top.png",
		"techage_ta4_junctionbox_side.png^techage_appl_ta4_cable.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {
			{ -3/16, -3/16, -3/16,   3/16, 3/16, 3/16},  -- box
			{ -1/16, -7/16, -1/16,   1/16, -4/16, 1/16}, -- post
			{ -3/16, -8/16, -3/16,   3/16, -7/16, 3/16}, -- base
		},

		connect_left  = {{ -1/2, -1/16, -1/16,   0, 1/16, 1/16}},
		connect_right = {{    0, -1/16, -1/16, 1/2, 1/16, 1/16}},
		connect_back  = {{-1/16, -1/16,    0, 1/16, 1/16, 1/2}},
		connect_front = {{-1/16, -1/16, -1/2, 1/16, 1/16,   0}},
	},
	connects_to = {"techage:ta4_power_cableA", "techage:ta4_power_cableS",
		"techage:ta4_solar_inverter", "techage:ta4_solar_carrier",
		"techage:ta4_solar_carrierB", "techage:ta4_cable_wall_entry"},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		Cable:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		power.update_network(pos, 0, tlib2, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
	end,

	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

power.register_nodes({"techage:ta4_power_box"}, Cable, "junc", {"L", "R", "F", "B"})

minetest.register_craft({
	output = "techage:ta4_power_cableS 8",
	recipe = {
		{"basic_materials:plastic_sheet", "dye:red", ""},
		{"", "default:copper_ingot", ""},
		{"", "dye:red", "basic_materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output = "techage:ta4_power_box 2",
	recipe = {
		{"techage:ta4_power_cableS", "basic_materials:plastic_sheet", "techage:ta4_power_cableS"},
		{"basic_materials:plastic_sheet", "default:copper_ingot", "basic_materials:plastic_sheet"},
		{"techage:ta4_power_cableS", "basic_materials:plastic_sheet", "techage:ta4_power_cableS"},
	},})

techage.TA4_Cable = Cable
