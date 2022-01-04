--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Ceiling Lamp

]]--

local S = techage.S

techage.register_lamp("techage:ceilinglamp", {
	description = S("TA Ceiling Lamp"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_ceilinglamp_top.png',
		'techage_ceilinglamp_bottom.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-5/16,  -7/16, -5/16, 5/16,  -5/16,  5/16},
			{-4/16,  -8/16, -4/16, 4/16,  -7/16,  4/16},
		},
	},

},{
	description = S("TA Ceiling Lamp"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_ceilinglamp_top.png',
		'techage_ceilinglamp_bottom.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
		'techage_ceilinglamp.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-5/16,  -7/16, -5/16, 5/16,  -5/16,  5/16},
			{-4/16,  -8/16, -4/16, 4/16,  -7/16,  4/16},
		},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:ceilinglamp_off 3",
	recipe = {"techage:simplelamp_off", "default:wood", "default:glass"},
})
