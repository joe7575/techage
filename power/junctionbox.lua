--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA3/TA4 Junction box for electrical power distribution

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local networks = techage.networks
local Cable = techage.ElectricCable
local power = techage.power

local size = 3/32
local Boxes = {
	{{-size, -size,  size, size,  size, 0.5 }}, -- z+
	{{-size, -size, -size, 0.5,   size, size}}, -- x+
	{{-size, -size, -0.5,  size,  size, size}}, -- z-
	{{-0.5,  -size, -size, size,  size, size}}, -- x-
	{{-size, -0.5,  -size, size,  size, size}}, -- y-
	{{-size, -size, -size, size,  0.5,  size}}, -- y+
}

techage.register_junction("techage:electric_junction", 2/8, Boxes, Cable, {
	description = S("TA Electric Junction Box"),
	tiles = {"techage_electric_junction.png"},
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = "techage:electric_junction"..techage.junction_type(pos, Cable)
		minetest.swap_node(pos, {name = name, param2 = 0})
		Cable:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		local name = "techage:electric_junction"..techage.junction_type(pos, Cable)
		minetest.swap_node(pos, {name = name, param2 = 0})
		power.update_network(pos, nil, tlib2)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
	end,
	networks = {
		ele1 = {
			sides = networks.AllSides, -- connection sides for cables
			ntype = "junc",
		},
	},
})

minetest.register_craft({
	output = "techage:electric_junction0 2",
	recipe = {
		{"", "basic_materials:plastic_sheet", ""},
		{"basic_materials:plastic_sheet", "default:copper_ingot", "basic_materials:plastic_sheet"},
		{"", "basic_materials:plastic_sheet", ""},
	},
})
