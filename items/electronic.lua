--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Bauxite
	
]]--

local S = techage.S

minetest.register_craftitem("techage:vacuum_tube", {
	description = S("TA3 Vacuum Tube"),
	inventory_image = "techage_vacuum_tube.png",
})

minetest.register_craftitem("techage:ta4_wlanchip", {
	description = S("TA4 WLAN Chip"),
	inventory_image = "techage_wlanchip.png",
})

minetest.register_craftitem("techage:wlanchip", {
	description = S("WLAN Chip"),
	inventory_image = "techage_wlanchip.png",
})

minetest.register_craftitem("techage:ta4_ramchip", {
	description = S("TA4 RAM Chip"),
	inventory_image = "techage_ramchip.png",
})

minetest.register_craftitem("techage:ta4_leds", {
	description = S("TA4 LEDs"),
	inventory_image = "techage_leds.png",
})


techage.recipes.add("ta2_electronic_fab", {
	output = "techage:vacuum_tube 2",
	input = {"default:glass 1", "basic_materials:copper_wire 1", "basic_materials:plastic_sheet 1", "techage:usmium_nuggets 1"}
})

techage.recipes.add("ta3_electronic_fab", {
	output = "techage:vacuum_tube 2",
	input = {"default:glass 1", "basic_materials:copper_wire 1", "basic_materials:plastic_sheet 1", "techage:usmium_nuggets 1"}
})

techage.recipes.add("ta3_electronic_fab", {
	output = "techage:ta4_wlanchip 8",
	input = {"default:mese_crystal 1", "default:copper_ingot 1", "default:gold_ingot 1", "techage:ta4_silicon_wafer 1"}
})

techage.recipes.add("ta3_electronic_fab", {
	output = "techage:ta4_ramchip 8",
	input = {"default:mese_crystal 1", "default:gold_ingot 1", "default:copper_ingot 1", "techage:ta4_silicon_wafer 1"}
})

techage.recipes.add("ta4_electronic_fab", {
	output = "techage:ta4_wlanchip 8",
	input = {"default:mese_crystal 1", "default:copper_ingot 1", "default:gold_ingot 1", "techage:ta4_silicon_wafer 1"}
})

techage.recipes.add("ta4_electronic_fab", {
	output = "techage:ta4_ramchip 8",
	input = {"default:mese_crystal 1", "default:gold_ingot 1", "default:copper_ingot 1", "techage:ta4_silicon_wafer 1"}
})

techage.recipes.add("ta4_electronic_fab", {
	output = "techage:ta4_leds 8",
	input = {"basic_materials:plastic_sheet 4", "basic_materials:copper_wire 1", "techage:ta4_silicon_wafer 1"}
})
