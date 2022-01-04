--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Industrial Lamp 2

]]--

local S = techage.S

local size = {x = 8/32, y = 8/32, z = 5/32}

techage.register_lamp("techage:industriallamp2", {
	description = S("TA Industrial Lamp 2"),
	inventory_image = 'techage_industriallamp_inv2.png',
	tiles = {
		-- up, down, right, left, back, front
		'techage_industriallamp2.png',
		'techage_industriallamp2.png',
		'techage_industriallamp2.png^[transformR180',
		'techage_industriallamp2.png^[transformR180',
		'techage_industriallamp2.png',
		'techage_industriallamp2.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/32, -16/32, -4/32, 8/32, -9/32, 4/32},
			{-7/32, -16/32, -5/32, 7/32, -9/32, 5/32},
			{-7/32,  -9/32, -4/32, 7/32, -8/32, 4/32},
		},
	},
},{
	tiles = {
		-- up, down, right, left, back, front
		'techage_industriallamp2_on.png',
		'techage_industriallamp2_on.png',
		'techage_industriallamp2_on.png^[transformR180',
		'techage_industriallamp2_on.png^[transformR180',
		'techage_industriallamp2_on.png',
		'techage_industriallamp2_on.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/32, -16/32, -4/32, 8/32, -9/32, 4/32},
			{-7/32, -16/32, -5/32, 7/32, -9/32, 5/32},
			{-7/32,  -9/32, -4/32, 7/32, -8/32, 4/32},
		},
	},
})

minetest.register_craft({
	output = "techage:industriallamp2_off 2",
	recipe = {
		{"default:glass", "default:glass", ""},
		{"techage:simplelamp_off", "dye:black", ""},
		{"basic_materials:steel_bar", "basic_materials:steel_bar", ""},
	},
})
