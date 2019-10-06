--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Hydrogen

]]--

local S = techage.S

minetest.register_craftitem("techage:hydrogen", {
	description = S("TA4 Hydrogen"),
	inventory_image = "techage_hydrogen_inv.png",
})

minetest.register_craftitem("techage:ta4_fuelcellstack", {
	description = S("TA4 Fuell Cell Stack"),
	inventory_image = "techage_fc_stack_inv.png",
})

minetest.register_craft({
	output = "techage:ta4_fuelcellstack",
	recipe = {
		{'techage:baborium_ingot', 'techage:ta4_carbon_fiber', 'default:copper_ingot'},
		{'default:gold_ingot', 'techage:ta4_carbon_fiber', 'default:tin_ingot'},
		{"techage:baborium_ingot", 'techage:ta4_carbon_fiber', 'default:copper_ingot'},
	},
})
