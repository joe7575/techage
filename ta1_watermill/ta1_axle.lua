--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA1 Axles for the Watermill

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Axle = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 10,
	show_infotext = false,
	tube_type = "axle1",
	primary_node_names = {"techage:ta1_axle"},
	secondary_node_names = {"techage:ta1_mill_gear", "techage:ta1_axle_bearing1", "techage:ta1_axle_bearing2"},
	after_place_tube = function(pos, param2, tube_type, num_tubes, state)
		minetest.swap_node(pos, {name = "techage:ta1_axle", param2 = param2})
	end,
})

Axle:set_valid_sides("techage:ta1_mill_gear", {"F", "B"})
Axle:set_valid_sides("techage:ta1_axle_bearing1", {"F", "B"})
Axle:set_valid_sides("techage:ta1_axle_bearing2", {"F", "B"})

minetest.register_node("techage:ta1_axle", {
	description = S("TA1 Axle"),
	tiles = {
		"techage_axle_bearing.png^[transformR90",
		"techage_axle_bearing.png^[transformR90",
		"techage_axle_bearing.png",
		"techage_axle_bearing.png",
		"techage_axle_bearing.png",
		"techage_axle_bearing.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -1/8, -4/8,  1/8, 1/8, 4/8},
		},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Axle:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Axle:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_wood_defaults(),
})

-- Bearings are defined as secondary nodes which forward received 'on_transfer' commands
minetest.register_node("techage:ta1_axle_bearing1", {
	description = S("TA1 Axle Bearing"),
	tiles = {
		"default_stone_brick.png^techage_axle_bearing.png^[transformR90",
		"default_stone_brick.png^techage_axle_bearing.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, -1/2,   1/2, -1/8,  1/2},
			{-1/8, -1/8, -1/2,   1/8,  1/8,  1/2},
		},
	},

	after_place_node = function(pos, placer)
		Axle:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Axle:after_dig_node(pos)
	end,

	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, crumbly = 2, choppy = 2},
})

minetest.register_node("techage:ta1_axle_bearing2", {
	description = S("TA1 Axle Bearing"),
	tiles = {
		-- up, down, right, left, back, front
		"default_stone_brick.png",
		"default_stone_brick.png",
		"default_stone_brick.png",
		"default_stone_brick.png",
		"default_stone_brick.png^techage_axle_bearing_front.png",
		"default_stone_brick.png^techage_axle_bearing_front.png",
	},

	after_place_node = function(pos, placer)
		Axle:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Axle:after_dig_node(pos)
	end,

	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, crumbly = 2, choppy = 2},
})

techage.register_node({"techage:ta1_axle_bearing1", "techage:ta1_axle_bearing2"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		return techage.transfer(
			pos,
			in_dir,  -- outdir
			topic,
			payload,
			Axle,    -- network
			nil)	 -- valid nodes
	end,
})


minetest.register_craft({
	output = "techage:ta1_axle",
	recipe = {
		{"", "", ""},
		{"techage:iron_ingot", "dye:black", "techage:iron_ingot"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techage:ta1_axle_bearing1",
	recipe = {
		{"", "", ""},
		{"", "techage:ta1_axle", ""},
		{"", "stairs:slab_stonebrick", ""},
	},
})

minetest.register_craft({
	output = "techage:ta1_axle_bearing2",
	recipe = {
		{"", "", ""},
		{"", "techage:ta1_axle", ""},
		{"", "default:stonebrick", ""},
	},
})

techage.TA1Axle = Axle
