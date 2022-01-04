--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Industrial Lamp 4

]]--

local S = techage.S

local function on_switch_lamp(pos, on)
	techage.light_ring({x = pos.x, y = pos.y - 3, z = pos.z}, on)
end

techage.register_lamp("techage:industriallamp4", {
	description = S("TA4 LED Industrial Lamp"),
	tiles = {
		'techage_growlight_off.png',
		'techage_growlight_back.png',
		'techage_growlight_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  -8/16, -8/16, 8/16,  -13/32,  8/16},
		},
	},
	on_switch_lamp = on_switch_lamp,
	conn_sides = {"U"},
	high_power = true,
},{
	description = S("TA4 LED Industrial Lamp"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_industlight4_on.png',
		'techage_growlight_back.png',
		'techage_growlight_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  -8/16, -8/16, 8/16,  -13/32,  8/16},
		},
	},
	on_switch_lamp = on_switch_lamp,
	high_power = true,
})

minetest.register_craft({
	output = "techage:industriallamp4_off",
	recipe = {
		{"basic_materials:steel_strip", "basic_materials:steel_strip", "basic_materials:steel_strip"},
		{"techage:ta4_leds", "techage:ta4_leds", "techage:ta4_leds"},
		{"techage:ta4_leds", "techage:basalt_glass_thin", "techage:ta4_leds"},
	},
})
