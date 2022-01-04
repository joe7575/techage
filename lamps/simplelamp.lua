--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Lamp

]]--

local S = techage.S

techage.register_lamp("techage:simplelamp", {
	description = S("TA Lamp"),
	tiles = {
		'techage_electric_button.png',
	},
	conn_sides = {"L", "R", "U", "D", "F", "B"},
	paramtype = "light",
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
},{
	description = S("TA Lamp"),
	tiles = {
		'techage_electric_button.png',
	},
	conn_sides = {"L", "R", "U", "D", "F", "B"},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drop = "techage:test_lamp",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:simplelamp_off 2",
	recipe = {
		{"", "", ""},
		{"", "default:glass", ""},
		{"", "basic_materials:heating_element", ""},
	},
})
