--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/4 Lamp Holder

]]--

local S = techage.S

local function register_holder(name, description, png)
	minetest.register_node(name, {
		description = description,
		tiles = {png},
		paramtype2 = "facedir", -- important!
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {{ -4/32, -4/32, -4/32,   4/32, 4/32, 4/32}},

			connect_top =    {{ -3/32,  -3/32,  -3/32,  3/32, 16/32,  3/32}},
			connect_bottom = {{ -3/32, -16/32,  -3/32,  3/32,  3/32,  3/32}},
			connect_left =   {{-16/32,  -3/32,  -3/32,  3/32,  3/32,  3/32}},
			connect_right =  {{ -3/32,  -3/32,  -3/32, 16/32,  3/32,  3/32}},
			connect_back =   {{ -3/32,  -3/32,  -3/32,  3/32,  3/32, 16/32}},
			connect_front =  {{ -3/32,  -3/32, -16/32,  3/32,  3/32,  3/32}},
		},
		connects_to = {
			"techage:ceilinglamp_off", "techage:ceilinglamp_on",
			"techage:growlight_off", "techage:growlight_on",
			"techage:industriallamp1_off", "techage:industriallamp1_on",
			"techage:industriallamp2_off", "techage:industriallamp2_on",
			"techage:industriallamp3_off", "techage:industriallamp3_on",
			"techage:industriallamp4_off", "techage:industriallamp4_on",
			"techage:simplelamp_off", "techage:simplelamp_on",
			"techage:streetlamp_off", "techage:streetlamp_on",
			"techage:streetlamp2_off", "techage:streetlamp2_on",
			"techage:streetlamp_arm", "techage:streetlamp_pole",
			"techage:streetlamp2_off", "techage:streetlamp2_on",
			"techage:power_line", "techage:power_lineS", "techage:power_lineA"
		},
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {cracky=2, crumbly=2, choppy=2},
		sounds = default.node_sound_defaults(),
	})
end


register_holder("techage:lampholder1", S("TA Lamp Holder White"), "techage_streetlamp2_housing.png")
register_holder("techage:lampholder2", S("TA Lamp Holder Aspen"), "default_aspen_wood.png")
register_holder("techage:lampholder3", S("TA Lamp Holder Acacia"), "default_acacia_wood.png")
register_holder("techage:lampholder4", S("TA Lamp Holder Apple"), "default_wood.png")
register_holder("techage:lampholder5", S("TA Lamp Holder Copper"), "default_copper_block.png")
register_holder("techage:lampholder6", S("TA Lamp Holder Gold"), "default_gold_block.png")


minetest.register_craft({
	output = "techage:lampholder1 2",
	recipe = {
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
		{"", "dye:white", ""},
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
	},
})

minetest.register_craft({
	output = "techage:lampholder2 2",
	recipe = {
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
		{"", "default:fence_aspen_wood", ""},
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
	},
})

minetest.register_craft({
	output = "techage:lampholder3 2",
	recipe = {
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
		{"", "default:fence_acacia_wood", ""},
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
	},
})

minetest.register_craft({
	output = "techage:lampholder4 2",
	recipe = {
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
		{"", "default:fence_wood", ""},
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
	},
})
minetest.register_craft({
	output = "techage:lampholder5 2",
	recipe = {
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
		{"", "default:copper_ingot", ""},
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
	},
})
minetest.register_craft({
	output = "techage:lampholder6 2",
	recipe = {
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
		{"", "default:gold_ingot", ""},
		{"basic_materials:steel_bar", "", "basic_materials:steel_bar"},
	},
})
