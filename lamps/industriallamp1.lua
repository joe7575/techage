--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Industrial Lamp 1

]]--

local S = techage.S

techage.register_lamp("techage:industriallamp1", {
	description = S("TA Industrial Lamp 1"),
	inventory_image = 'techage_industriallamp_inv1.png',
	tiles = {
		-- up, down, right, left, back, front
		'techage_industriallamp1.png',
		'techage_industriallamp1.png',
		'techage_industriallamp1.png^[transformR180',
		'techage_industriallamp1.png^[transformR180',
		'techage_industriallamp1.png',
		'techage_industriallamp1.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  -8/16, -3/32, -6/16,  -9/32,  3/32},
			{ 6/16,  -8/16, -3/32,  8/16,  -9/32,  3/32},
			{-6/16,  -7/16, -1/16,  6/16,  -5/16,  1/16},
		},
	},
},{
	tiles = {
		-- up, down, right, left, back, front
		'techage_industriallamp1_on.png',
		'techage_industriallamp1_on.png',
		'techage_industriallamp1_on.png^[transformR180',
		'techage_industriallamp1_on.png^[transformR180',
		'techage_industriallamp1_on.png',
		'techage_industriallamp1_on.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  -8/16, -3/32, -6/16,  -9/32,  3/32},
			{ 6/16,  -8/16, -3/32,  8/16,  -9/32,  3/32},
			{-6/16,  -7/16, -1/16,  6/16,  -5/16,  1/16},
		},
	},
})

minetest.register_craft({
	output = "techage:industriallamp1_off 2",
	recipe = {
		{"", "", ""},
		{"default:glass", "techage:simplelamp_off", "dye:grey"},
		{"basic_materials:plastic_strip", "default:copper_ingot", "basic_materials:plastic_strip"},
	},
})
