--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Gas Pipes

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local MAX_PIPE_LENGHT = 100

local power = networks.power

local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = MAX_PIPE_LENGHT,
	show_infotext = false,
	force_to_use_tubes = false,
	tube_type = "pipe3",
	primary_node_names = {
		"techage:ta5_pipeS", "techage:ta5_pipeA",
	},
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		local name = minetest.get_node(pos).name
		if not networks.hidden_name(pos) then
			minetest.swap_node(pos, {name = "techage:ta5_pipe"..tube_type, param2 = param2 % 32})
		end
		M(pos):set_int("netw_param2", param2) 
	end,
})

-- Enable hidden cables
networks.use_metadata(Pipe)

-- Use global callback instead of node related functions
Pipe:register_on_tube_update2(function(pos, outdir, tlib2, node)
	power.update_network(pos, outdir, tlib2, node)
end)

minetest.register_node("techage:ta5_pipeS", {
	description = S("TA5 Pipe"),
	tiles = {
		"techage_ta5_gaspipe.png^[transformR90",
		"techage_ta5_gaspipe.png^[transformR90",
		"techage_ta5_gaspipe.png",
		"techage_ta5_gaspipe.png",
		"techage_ta5_gaspipe_hole2.png",
		"techage_ta5_gaspipe_hole2.png",
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
			{-1/16, -1/16, -8/16,  1/16, 1/16, 8/16},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta5_pipeA", {
	description = S("TA5 Pipe"),
	tiles = {
		"techage_ta5_gaspipe_knee2.png",
		"techage_ta5_gaspipe_hole2.png^[transformR180",
		"techage_ta5_gaspipe_knee.png^[transformR270",
		"techage_ta5_gaspipe_knee.png",
		"techage_ta5_gaspipe_knee2.png",
		"techage_ta5_gaspipe_hole2.png",
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 1/16,   1/16},
			{-2/16, -0.5,  -2/16, 2/16, -13/32, 2/16},
			{-1/16, -1/16, -8/16, 1/16, 1/16,   -1/16},
			{-2/16, -2/16, -0.5,  2/16, 2/16,   -13/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, 
		not_in_creative_inventory=1, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta5_pipeS",
})

local size1 = 1/16
local size2 = 2/16
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
		{-size1, -size1, -0.5,  size1,  size1,  size1}, -- z- 2d5627
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

local names = networks.register_junction("techage:ta5_junctionpipe", 1/8, Boxes, Pipe, {
	description = S("TA5 Junction Pipe"),
	tiles = {"techage_ta5_gaspipe_junction.png"},
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "techage:ta5_junctionpipe" .. networks.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		if not networks.hidden_name(pos) then
			local name = "techage:ta5_junctionpipe" .. networks.junction_type(pos, Pipe)
			minetest.swap_node(pos, {name = name, param2 = 0})
		end
		power.update_network(pos, 0, tlib2, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
}, 25)

power.register_nodes(names, Pipe, "junc")

--minetest.register_craft({
--	output = "techage:ta3_junctionpipe25 2",
--	recipe = {
--		{"", "techage:ta3_pipeS", ""},
--		{"techage:ta3_pipeS", "", "techage:ta3_pipeS"},
--		{"", "techage:ta3_pipeS", ""},
--	},
--})

--minetest.register_craft({
--	output = "techage:ta3_pipeS 6",
--	recipe = {
--		{'', '', "techage:iron_ingot"},
--		{'dye:yellow', 'default:steel_ingot', ''},
--		{"techage:iron_ingot", '', ''},
--	},
--})

techage.GasPipe = Pipe
