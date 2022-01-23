--[[

	TechAge
	=======

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Ceramic

]]--

local S = techage.S

minetest.register_craftitem("techage:ta4_ceramic_material", {
	description = S("TA4 Ceramic Material"),
	inventory_image = "techage_ceramic_material.png",
	groups = {powder = 1},
})

techage.recipes.add("ta4_doser", {
	output = "techage:ta4_ceramic_material 2",
	input = {
		"techage:clay_powder 1",
		"techage:aluminum_powder 1",
		"techage:silver_sandstone_powder 1",
		"techage:water 1",
	}
})

minetest.register_craft({
	output = "techage:ta4_ceramic_material 2",
	recipe = {
		{"techage:clay_powder", "techage:aluminum_powder", ""},
		{"techage:silver_sandstone_powder", "bucket:bucket_water", ""},
		{"", "", ""},
	},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
})

minetest.register_craftitem("techage:ta4_furnace_ceramic", {
	description = S("TA4 Furnace Ceramic"),
	inventory_image = "techage_furnace_ceramic.png",
})

techage.furnace.register_recipe({
	output = "techage:ta4_furnace_ceramic",
	recipe = {
		"techage:ta4_ceramic_material",
		"techage:ta4_ceramic_material",
	},
	time = 16,
})

minetest.register_craftitem("techage:ta4_round_ceramic", {
	description = S("TA4 Round Ceramic"),
	inventory_image = "techage_round_ceramic.png",
})

minetest.register_craftitem("techage:ta5_ceramic_turbine", {
	description = S("TA5 Ceramic Turbine"),
	inventory_image = "techage_ceramic_turbine.png",
})

techage.furnace.register_recipe({
	output = "techage:ta4_round_ceramic 2",
	recipe = {
		"techage:ta4_ceramic_material", "techage:ta4_ceramic_material",
		"techage:ta4_ceramic_material", "techage:ta4_ceramic_material",
	},
	time = 16,
})

techage.furnace.register_recipe({
	output = "techage:ta5_ceramic_turbine",
	recipe = {
		"techage:ta4_ceramic_material",
		"techage:ta4_ceramic_material",
		"techage:graphite_powder",
	},
	time = 16,
})
