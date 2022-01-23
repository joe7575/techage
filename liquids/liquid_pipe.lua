--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Liquid Pipes

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local MAX_PIPE_LENGHT = 100

local liquid = networks.liquid

local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = MAX_PIPE_LENGHT,
	show_infotext = false,
	force_to_use_tubes = false,
	tube_type = "pipe2",
	primary_node_names = {
		"techage:ta3_pipeS", "techage:ta3_pipeA",
		"techage:ta3_pipe_wall_entry", "techage:ta3_valve_open",
	},
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		local name = minetest.get_node(pos).name
		if name == "techage:ta3_pipe_wall_entry" then
			minetest.swap_node(pos, {name = "techage:ta3_pipe_wall_entry", param2 = param2})
		elseif name == "techage:ta3_valve_open" then
			minetest.swap_node(pos, {name = "techage:ta3_valve_open", param2 = param2})
		else
			minetest.swap_node(pos, {name = "techage:ta3_pipe"..tube_type, param2 = param2})
		end
	end,
})

-- Use global callback instead of node related functions
Pipe:register_on_tube_update2(function(pos, outdir, tlib2, node)
	liquid.update_network(pos, outdir, tlib2, node)
end)

minetest.register_node("techage:ta3_pipeS", {
	description = S("TA Pipe"),
	tiles = {
		"techage_gaspipe.png^[transformR90",
		"techage_gaspipe.png^[transformR90",
		"techage_gaspipe.png",
		"techage_gaspipe.png",
		"techage_gaspipe_hole2.png",
		"techage_gaspipe_hole2.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -1/8, -4/8,  1/8, 1/8, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta3_pipeA", {
	description = S("TA Pipe"),
	tiles = {
		"techage_gaspipe_knee2.png",
		"techage_gaspipe_hole2.png^[transformR180",
		"techage_gaspipe_knee.png^[transformR270",
		"techage_gaspipe_knee.png",
		"techage_gaspipe_knee2.png",
		"techage_gaspipe_hole2.png",
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -4/8, -1/8, 1/8, 1/8,    1/8},
			{-2/8, -0.5, -2/8, 2/8, -13/32, 2/8},
			{-1/8, -1/8, -4/8, 1/8, 1/8,    -1/8},
			{-2/8, -2/8, -0.5, 2/8, 2/8,    -13/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta3_pipeS",
})

local size1 = 1/8
local size2 = 2/8
local size3 = 13/32
local Boxes = {
	{
		{-size1, -size1,  size1, size1,  size1, 0.5 }, -- z+
		{-size2, -size2,  size3, size2,  size2, 0.5 }, -- z+
	},
	{
		{-size1, -size1, -size1, 0.5, size1, size1}, -- x+
		{ size3, -size2, -size2, 0.5, size2,  size2}, -- x+
	},
	{
		{-size1, -size1, -0.5,  size1,  size1,  size1}, -- z-
		{-size2, -size2, -0.5,  size2,  size2, -size3}, -- z-
	},
	{
		{-0.5,  -size1, -size1,  size1,  size1, size1}, -- x-
		{-0.5,  -size2, -size2, -size3,  size2, size2}, -- x-
	},
	{
		{-size1, -0.5,  -size1, size1,  size1, size1}, -- y-
		{-size2, -0.5,  -size2, size2, -size3, size2}, -- y-
	},
	{
		{-size1, -size1, -size1, size1,  0.5,  size1}, -- y+
		{-size2, size3,  -size2, size2,  0.5,  size2}, -- y+
	}
}

local names = networks.register_junction("techage:ta3_junctionpipe", 1/8, Boxes, Pipe, {
	description = S("TA Junction Pipe"),
	tiles = {"techage_gaspipe_junction.png"},
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "techage:ta3_junctionpipe" .. networks.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		local name = "techage:ta3_junctionpipe" .. networks.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		liquid.update_network(pos, 0, tlib2, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
}, 25)

liquid.register_nodes(names, Pipe, "junc")

minetest.register_craft({
	output = "techage:ta3_junctionpipe25 2",
	recipe = {
		{"", "techage:ta3_pipeS", ""},
		{"techage:ta3_pipeS", "", "techage:ta3_pipeS"},
		{"", "techage:ta3_pipeS", ""},
	},
})

minetest.register_craft({
	output = "techage:ta3_pipeS 6",
	recipe = {
		{'', '', "techage:iron_ingot"},
		{'dye:yellow', 'default:steel_ingot', ''},
		{"techage:iron_ingot", '', ''},
	},
})

minetest.register_alias("techage:ta4_pipeA", "techage:ta3_pipeA")
minetest.register_alias("techage:ta4_pipeS", "techage:ta3_pipeS")

techage.LiquidPipe = Pipe
