--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

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

local liquid = networks.liquid

local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = MAX_PIPE_LENGHT,
	show_infotext = false,
	force_to_use_tubes = false,
	tube_type = "pipe3",
	primary_node_names = {
		"techage:ta5_pipe1S", "techage:ta5_pipe1A",
		"techage:ta5_pipe2S", "techage:ta5_pipe2A",
	},
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		local name = minetest.get_node(pos).name
		if not networks.hidden_name(pos) then
			local name = minetest.get_node(pos).name
			if name == "techage:ta5_pipe1S" or name == "techage:ta5_pipe1A" then
				minetest.swap_node(pos, {name = "techage:ta5_pipe1"..tube_type, param2 = param2 % 32})
			else
				minetest.swap_node(pos, {name = "techage:ta5_pipe2"..tube_type, param2 = param2 % 32})
			end
		end
		M(pos):set_int("netw_param2", param2)
	end,
})

-- Enable hidden cables
networks.use_metadata(Pipe)

-- Use global callback instead of node related functions
Pipe:register_on_tube_update2(function(pos, outdir, tlib2, node)
	liquid.update_network(pos, outdir, tlib2, node)
end)

minetest.register_node("techage:ta5_pipe1S", {
	description = S("TA5 Pipe"),
	tiles = {
		"techage_ta5_gaspipe.png^[transformR90^[colorize:#000080:160",
		"techage_ta5_gaspipe.png^[transformR90^[colorize:#000080:160",
		"techage_ta5_gaspipe.png^[colorize:#000080:160",
		"techage_ta5_gaspipe.png^[colorize:#000080:160",
		"techage_ta5_gaspipe_hole2.png^[colorize:#000080:160",
		"techage_ta5_gaspipe_hole2.png^[colorize:#000080:160",
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

minetest.register_node("techage:ta5_pipe1A", {
	description = S("TA5 Pipe"),
	tiles = {
		"techage_ta5_gaspipe_knee2.png^[colorize:#000080:160",
		"techage_ta5_gaspipe_hole2.png^[transformR180^[colorize:#000080:160",
		"techage_ta5_gaspipe_knee.png^[transformR270^[colorize:#000080:160",
		"techage_ta5_gaspipe_knee.png^[colorize:#000080:160",
		"techage_ta5_gaspipe_knee2.png^[colorize:#000080:160",
		"techage_ta5_gaspipe_hole2.png^[colorize:#000080:160",
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
	drop = "techage:ta5_pipe1S",
})

minetest.register_node("techage:ta5_pipe2S", {
	description = S("TA5 Pipe"),
	tiles = {
		"techage_ta5_gaspipe.png^[transformR90^[colorize:#008000:160",
		"techage_ta5_gaspipe.png^[transformR90^[colorize:#008000:160",
		"techage_ta5_gaspipe.png^[colorize:#008000:160",
		"techage_ta5_gaspipe.png^[colorize:#008000:160",
		"techage_ta5_gaspipe_hole2.png^[colorize:#008000:160",
		"techage_ta5_gaspipe_hole2.png^[colorize:#008000:160",
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

minetest.register_node("techage:ta5_pipe2A", {
	description = S("TA5 Pipe"),
	tiles = {
		"techage_ta5_gaspipe_knee2.png^[colorize:#008000:160",
		"techage_ta5_gaspipe_hole2.png^[transformR180^[colorize:#008000:160",
		"techage_ta5_gaspipe_knee.png^[transformR270^[colorize:#008000:160",
		"techage_ta5_gaspipe_knee.png^[colorize:#008000:160",
		"techage_ta5_gaspipe_knee2.png^[colorize:#008000:160",
		"techage_ta5_gaspipe_hole2.png^[colorize:#008000:160",
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
	drop = "techage:ta5_pipe2S",
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

local names1 = networks.register_junction("techage:ta5_junctionpipe1", 1/8, Boxes, Pipe, {
	description = S("TA5 Junction Pipe"),
	tiles = {"techage_ta5_gaspipe_junction.png^[colorize:#000080:160"},
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "techage:ta5_junctionpipe1" .. networks.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		if not networks.hidden_name(pos) then
			local name = "techage:ta5_junctionpipe1" .. networks.junction_type(pos, Pipe)
			minetest.swap_node(pos, {name = name, param2 = 0})
		end
		liquid.update_network(pos, 0, tlib2, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
}, 25)

local names2 = networks.register_junction("techage:ta5_junctionpipe2", 1/8, Boxes, Pipe, {
	description = S("TA5 Junction Pipe"),
	tiles = {"techage_ta5_gaspipe_junction.png^[colorize:#008000:160"},
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "techage:ta5_junctionpipe2" .. networks.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		if not networks.hidden_name(pos) then
			local name = "techage:ta5_junctionpipe2" .. networks.junction_type(pos, Pipe)
			minetest.swap_node(pos, {name = name, param2 = 0})
		end
		liquid.update_network(pos, 0, tlib2, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
}, 25)

liquid.register_nodes(names1, Pipe, "junc")
liquid.register_nodes(names2, Pipe, "junc")

minetest.register_craft({
	output = "techage:ta5_pipe1S 6",
	recipe = {
		{'', '', "default:steel_ingot"},
		{'', 'dye:blue', 'techage:ta4_carbon_fiber'},
		{"", '', 'techage:aluminum'},
	},
})

minetest.register_craft({
	output = "techage:ta5_pipe2S 6",
	recipe = {
		{'', '', "default:steel_ingot"},
		{'', 'dye:green', 'techage:ta4_carbon_fiber'},
		{"", '', 'techage:aluminum'},
	},
})

minetest.register_craft({
	output = "techage:ta5_junctionpipe125 2",
	recipe = {
		{"", "techage:ta5_pipe1S", ""},
		{"techage:ta5_pipe1S", "", "techage:ta5_pipe1S"},
		{"", "techage:ta5_pipe1S", ""},
	},
})

minetest.register_craft({
	output = "techage:ta5_junctionpipe225 2",
	recipe = {
		{"", "techage:ta5_pipe2S", ""},
		{"techage:ta5_pipe2S", "", "techage:ta5_pipe2S"},
		{"", "techage:ta5_pipe2S", ""},
	},
})

techage.GasPipe = Pipe
