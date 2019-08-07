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
local S = techage.S

local Cable = techage.ElectricCable
local power_switched = techage.power.power_switched
local power_available = techage.power.power_available

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

	on_construct = tubelib2.init_mem,
	after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
		local name = "techage:electric_junction"..techage.junction_type(pos, Cable)
		minetest.swap_node(pos, {name = name, param2 = 0})
		power_switched(pos)
	end,
	is_power_available = function(pos)
		return techage.power.power_accounting(pos)
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