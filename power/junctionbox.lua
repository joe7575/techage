--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3/TA4 Junction box for electrical power distribution

]]--

-- for lazy programmers
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local size = 3/32
local Boxes = {
	{{-size, -size,  size, size,  size, 0.5 }}, -- z+
	{{-size, -size, -size, 0.5,   size, size}}, -- x+
	{{-size, -size, -0.5,  size,  size, size}}, -- z-
	{{-0.5,  -size, -size, size,  size, size}}, -- x-
	{{-size, -0.5,  -size, size,  size, size}}, -- y-
	{{-size, -size, -size, size,  0.5,  size}}, -- y+
}

techage.register_junction("techage:electric_junction", 2/8, Boxes, techage.ElectricCable, {
	description = I("TA Electric Junction Box"),
	tiles = {"techage_electric_junction.png"},
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_defaults(),

	on_construct = tubelib2.init_mem,
	after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
		local name = "techage:electric_junction"..techage.junction_type(pos, techage.ElectricCable)
		minetest.swap_node(pos, {name = name, param2 = 0})
	end,
	})

minetest.register_craft({
	output = "techage:electric_junction0 2",
	recipe = {
		{"", "basic_materials:plastic_sheet", ""},
		{"basic_materials:plastic_sheet", "default:copper_ingot", "basic_materials:plastic_sheet"},
		{"", "basic_materials:plastic_sheet", ""},
	},
})