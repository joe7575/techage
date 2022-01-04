--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Street Lamp

]]--

local S = techage.S

techage.register_lamp("techage:streetlamp", {
	description = S("TA Street Lamp"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_streetlamp_top.png',
		'techage_streetlamp_top.png',
		'techage_streetlamp_off.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-5/16, -8/16, -5/16, 5/16,  8/16,  5/16},
			{-2/16, -8/16, -2/16, 2/16,  8/16,  2/16},
			{-8/16,  4/16, -8/16, 8/16,  5/16,  8/16},
			{-5/16, -8/16, -5/16, 5/16, -7/16,  5/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,   8/16, 8/16, 8/16},
	},
	on_rotate = screwdriver.disallow,
	conn_sides = {"U", "D"},
},{
	description = S("TA Street Lamp"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_streetlamp_top.png',
		'techage_streetlamp_top.png',
		'techage_streetlamp.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-5/16, -8/16, -5/16,  5/16, 8/16,  5/16},
			{-8/16,  4/16, -8/16,  8/16, 5/16,  8/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,   8/16, 8/16, 8/16},
	},
	on_rotate = screwdriver.disallow,
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:streetlamp_off 2",
	recipe = {"techage:simplelamp_off", "default:steel_ingot", "default:glass"},
})
