--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 LED Street Lamp

]]--

local S = techage.S

local function on_switch_lamp(pos, on)
	techage.light_ring({x = pos.x, y = pos.y - 3, z = pos.z}, on, true)
end

techage.register_lamp("techage:streetlamp2", {
	description = S("TA4 LED Street Lamp"),
	tiles = {
		"techage_streetlamp2_housing.png",
		"techage_streetlamp2_housing.png^techage_streetlamp2_off.png",
		"techage_streetlamp2_housing.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{ -8/32, 8/32, -16/32, 8/32, 15/32, 16/32}},
	},
	on_switch_lamp = on_switch_lamp,
	on_rotate = screwdriver.disallow,
	conn_sides = {"F", "B"},
	high_power = true,
},{
	description = S("TA4 LED Street Lamp"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_streetlamp2_housing_on.png",
		"techage_streetlamp2_housing_on.png^techage_streetlamp2_on.png",
		"techage_streetlamp2_housing_on.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{ -8/32, 8/32, -16/32, 8/32, 15/32, 16/32}},
	},
	on_switch_lamp = on_switch_lamp,
	on_rotate = screwdriver.disallow,
	conn_sides = {"F", "B"},
	high_power = true,
})

minetest.register_node("techage:streetlamp_pole", {
	description = S("TA4 LED Street Lamp Pole"),
	tiles = {
		"techage_streetlamp2_housing.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {{ -5/32, -16/32,  -5/32,   5/32, 16/32,   5/32}},

		connect_left =  {{-16/32, 8/32, -3/32,   3/32, 14/32, 3/32}},
		connect_right = {{ -3/32, 8/32, -3/32,  16/32, 14/32, 3/32}},
		connect_back =  {{ -3/32, 8/32, -3/32,   3/32, 14/32, 16/32}},
		connect_front = {{ -3/32, 8/32, -16/32,  3/32, 14/32, 3/32}},
	},
	connects_to = {"techage:streetlamp_arm", "techage:streetlamp2_off", "techage:streetlamp2_on"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:streetlamp_arm", {
	description = S("TA4 LED Street Lamp Arm"),
	tiles = {
		"techage_streetlamp2_housing.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{ -3/32, 8/32, -16/32, 3/32, 14/32, 16/32}},
	},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_craft({
	output = "techage:streetlamp2_off",
	recipe = {
		{"basic_materials:steel_strip", "dye:white", "basic_materials:steel_strip"},
		{"techage:ta4_leds", "techage:ta4_leds", "techage:ta4_leds"},
		{"techage:ta4_leds", "techage:basalt_glass_thin", "techage:ta4_leds"},
	},
})

minetest.register_craft({
	output = "techage:streetlamp_pole 2",
	recipe = {
		{"", "basic_materials:steel_bar", ""},
		{"", "basic_materials:steel_bar", "dye:white"},
		{"", "basic_materials:steel_bar", ""},
	},
})

minetest.register_craft({
	output = "techage:streetlamp_arm 2",
	recipe = {
		{"", "dye:white", ""},
		{"basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar"},
		{"", "", ""},
	},
})
