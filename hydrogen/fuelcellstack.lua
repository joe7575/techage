--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Hydrogen

]]--

local S = techage.S

minetest.register_craftitem("techage:ta4_fuelcellstack", {
	description = S("TA4 Fuel Cell Stack"),
	inventory_image = "techage_fc_stack_inv.png",
})

minetest.register_craft({
	output = "techage:ta4_fuelcellstack",
	recipe = {
		{'default:copper_ingot', 'techage:ta4_carbon_fiber', 'default:copper_ingot'},
		{'techage:baborium_ingot', 'techage:ta4_carbon_fiber', 'techage:baborium_ingot'},
		{"techage:canister_lye", 'techage:ta4_carbon_fiber', "techage:canister_lye"},
	},
	replacements = {
		{"techage:canister_lye", "techage:ta3_canister_empty"},
		{"techage:canister_lye", "techage:ta3_canister_empty"},
	}
})
