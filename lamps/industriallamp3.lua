--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Industrial Lamp 3

]]--

local S = techage.S

local size = {x = 6/32, y = 4/32, z = 6/32}

techage.register_lamp("techage:industriallamp3", {
	description = S("TA Industrial Lamp 3"),
	inventory_image = 'techage_industriallamp_inv3.png',
	tiles = {
		-- up, down, right, left, back, front
		'techage_industriallamp3.png',
		'techage_industriallamp3.png',
		'techage_industriallamp3.png^[transformR180',
		'techage_industriallamp3.png^[transformR180',
		'techage_industriallamp3.png',
		'techage_industriallamp3.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.375, 0.1875},
		},
	},
},{
	tiles = {
		-- up, down, right, left, back, front
		'techage_industriallamp3_on.png',
		'techage_industriallamp3_on.png',
		'techage_industriallamp3_on.png^[transformR180',
		'techage_industriallamp3_on.png^[transformR180',
		'techage_industriallamp3_on.png',
		'techage_industriallamp3_on.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.375, 0.1875},
		},
	},
})

minetest.register_craft({
	output = "techage:industriallamp3_off 2",
	recipe = {
		{"default:glass", "default:glass", ""},
		{"techage:simplelamp_off", "dye:red", ""},
		{"basic_materials:steel_bar", "basic_materials:steel_bar", ""},
	},
})
