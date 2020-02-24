--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Power Switch Box
]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local S = techage.S

local Cable = techage.ElectricCable

-- primary power node
minetest.register_node("techage:powerswitch_box", {
	description = S("TA Power Switch Box"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_switch.png^[transformR90',
		'techage_electric_switch.png^[transformR90',
		'techage_electric_switch.png',
		'techage_electric_switch.png',
		'techage_electric_junction.png',
		'techage_electric_junction.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/4, -1/4, -2/4,  1/4, 1/4, 2/4},
		},
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	
	paramtype = "light",
	sunlight_propagates = true,
	on_rotate = screwdriver.disallow, -- important!
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, techage_trowel = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:powerswitch_box",
	recipe = {
		{"", "basic_materials:plastic_sheet", ""},
		{"techage:electric_cableS", "basic_materials:copper_wire", "techage:electric_cableS"},
		{"", "basic_materials:plastic_sheet", ""},
	},
})
