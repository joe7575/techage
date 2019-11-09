--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Helper functions for liquid transportation (peer, put, take)

]]--

local S = techage.S

minetest.register_craftitem("techage:ta3_barrel_empty", {
	description = S("TA Empty Barrel"),
	inventory_image = "techage_barrel_inv.png",
})

minetest.register_craft({
	output = 'techage:ta3_barrel_empty 6',
	recipe = {
		{'techage:iron_ingot', 'techage:iron_ingot', 'techage:iron_ingot'},
		{'techage:iron_ingot', '', 'techage:iron_ingot'},
		{'techage:iron_ingot', 'techage:iron_ingot', 'techage:iron_ingot'},
	}
})

minetest.register_craftitem("techage:liquid", {
	description = S("empty"),
	inventory_image = "techage_liquid_inv.png",
	groups = {not_in_creative_inventory=1},
	
})

minetest.register_craftitem("techage:ta3_canister_empty", {
	description = S("TA3 Canister"),
	inventory_image = "techage_canister_inv.png",
})

minetest.register_craft({
	output = 'techage:ta3_canister_empty 6',
	recipe = {
		{'basic_materials:plastic_sheet', 'basic_materials:plastic_sheet', 'basic_materials:plastic_sheet'},
		{'basic_materials:plastic_sheet', '', 'basic_materials:plastic_sheet'},
		{'basic_materials:plastic_sheet', 'basic_materials:plastic_sheet', 'basic_materials:plastic_sheet'},
	}
})
