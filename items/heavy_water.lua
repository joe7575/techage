--[[

	TechAge
	=======

	Copyright (C) 2026

	AGPL v3
	See LICENSE.txt for more information

	Heavy water and isotope membrane

]]--

local S = techage.S


minetest.register_craftitem("techage:heavy_water", {
	description = S("Heavy Water"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#0c1984:140^[multiply:#909090^techage_liquid1_inv.png",
	groups = {ta_liquid = 1},
})


minetest.register_craftitem("techage:barrel_heavy_water", {
	description = S("Heavy Water Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#0c1984:120^techage_symbol_liquid.png",
	stack_max = 1,
})


techage.register_liquid("techage:barrel_heavy_water", "techage:ta3_barrel_empty", techage.volume_barrel, "techage:heavy_water")


minetest.register_node("techage:isotope_membrane_filter", {
	description = S("Isotope Membrane Filter"),
	tiles = {"techage_isotope_membrane.png"},
	groups = {choppy = 2, cracky = 2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:spent_membrane_filter", {
	description = S("Spent Isotope Membrane"),
	tiles = {"techage_isotope_membrane_spent.png"},
	groups = {choppy = 2, cracky = 2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "techage:isotope_membrane_filter 8",
	recipe = {
		{"techage:ta4_carbon_fiber", "techage:graphite_powder", "techage:ta4_carbon_fiber"},
		{"techage:ta4_carbon_fiber", "techage:gibbsite_powder", "techage:ta4_carbon_fiber"},
		{"techage:ta4_carbon_fiber", "techage:usmium_powder", "techage:ta4_carbon_fiber"},
	},
})


techage.add_grinder_recipe({input = "techage:spent_membrane_filter", output = "default:clay"})