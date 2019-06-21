--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3/TA4 Power line for electrical landline
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local Cable = techage.ElectricCable


-- Primary techage.ElectricCable node
minetest.register_node("techage:power_line", {
	description = I("TA Power Line"),
	tiles = {"techage_power_line.png"},
	inventory_image = 'techage_power_line_inv.png',
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Cable:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/32, -1/32, -4/8,  1/32, 1/32, 4/8},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/32, -2/32, -4/8,  2/32, 2/32, 4/8},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:power_pole", {
	description = I("TA Power Pole"),
	--tiles = {"techage_power_pole.png"},
	tiles = {
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole_top.png",
		"default_wood.png^techage_power_pole.png"
	},
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -4/32, -16/32,  -4/32,   4/32, 16/32,   4/32},
			{-16/32,  -6/32,  -1/32,  16/32, -4/32,   1/32},
			{ -1/32,  -6/32, -16/32,   1/32, -4/32,  16/32},
			{-16/32,  -4/32,  -2/32, -12/32,  4/32,   2/32},
			{ 12/32,  -4/32,  -2/32,  16/32,  4/32,   2/32},
			{ -2/32,  -4/32, -16/32,   2/32,  4/32, -12/32},
			{ -2/32,  -4/32,  12/32,   2/32,  4/32,  16/32},
			--{ -1/32,  -1/32,   -4/8,   1/32,  1/32,    4/8},
			--{  -4/8,  -1/32,  -1/32,    4/8,  1/32,   1/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

techage.power.register_node({"techage:power_pole"}, {
	power_network  = Cable,
})

minetest.register_craft({
	output = "techage:power_line 24",
	recipe = {
		{"default:copper_ingot", "", ""},
		{"", "default:copper_ingot", ""},
		{"", "", "default:copper_ingot"},
	},
})

minetest.register_craft({
	output = "techage:power_pole",
	recipe = {
		{"default:stick", "techage:power_line", "default:stick"},
		{"techage:power_line", "default:copper_ingot", "techage:power_line"},
		{"default:stick", "techage:power_line", "default:stick"},
	},
})
