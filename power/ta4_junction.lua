--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Junction Pipes

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.BiogasPipe
local power = techage.power

local size1 = 1/8
local size2 = 2/8
local size3 = 13/32
--local size3 = 1/8
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

techage.register_junction("techage:ta4_junctionpipe", 1/8, Boxes, Pipe, {
	description = S("TA4 Junction Pipe"),
	tiles = {"techage_gaspipe_junction.png"},
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),

	on_construct = tubelib2.init_mem,
	after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
		local name = "techage:ta4_junctionpipe"..techage.junction_type(pos, Pipe)
		minetest.swap_node(pos, {name = name, param2 = 0})
		power.network_changed(pos, tubelib2.get_mem(pos))
	end,
	is_power_available = function(pos)
		return techage.power.power_accounting(pos, tubelib2.get_mem(pos))
	end,
}, 25)

minetest.register_craft({
	output = "techage:ta4_junctionpipe25 2",
	recipe = {
		{"", "techage:ta4_pipeS", ""},
		{"techage:ta4_pipeS", "", "techage:ta4_pipeS"},
		{"", "techage:ta4_pipeS", ""},
	},
})