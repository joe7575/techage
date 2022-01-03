--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Petroleum types: bitumen, fueloil, naphtha, gasoline, isobutane, gas (propan)

]]--

local S = techage.S


minetest.register_craftitem("techage:bitumen", {
	description = S("TA3 Bitumen"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#000000",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:fueloil", {
	description = S("TA3 Fuel Oil"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#7E5D0A:180^techage_liquid1_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:naphtha", {
	description = S("TA3 Naphtha"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#AAA820:180^techage_liquid1_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:gasoline", {
	description = S("TA3 Gasoline"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#EEFC52:180^techage_liquid1_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:isobutane", {
	description = S("TA4 Isobutane"),
	inventory_image = "techage_isobutane_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:gas", {
	description = S("TA3 Propane"),
	inventory_image = "techage_gas_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:ta3_cylinder_small_gas", {
	description = S("Propane Cylinder Small"),
	inventory_image = "techage_gas_cylinder_small.png^[colorize:#e51818:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_cylinder_large_gas", {
	description = S("Propane Cylinder Large"),
	inventory_image = "techage_gas_cylinder_large.png^[colorize:#e51818:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta4_cylinder_small_isobutane", {
	description = S("Isobutane Cylinder Small"),
	inventory_image = "techage_gas_cylinder_small.png^[colorize:#18d618:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta4_cylinder_large_isobutane", {
	description = S("Isobutane Cylinder Large"),
	inventory_image = "techage_gas_cylinder_large.png^[colorize:#18d618:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_barrel_bitumen", {
	description = S("TA3 Bitumen Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#000000:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_barrel_fueloil", {
	description = S("TA3 Fuel Oil Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#7E5D0A:180^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_barrel_naphtha", {
	description = S("TA3 Naphtha Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#AAA820:180^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_barrel_gasoline", {
	description = S("TA3 Gasoline Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#EEFC52:180^techage_symbol_liquid.png",
	stack_max = 1,
})


minetest.register_craftitem("techage:ta3_canister_bitumen", {
	description = S("TA3 Bitumen Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#000000:180^techage_canister_frame.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_canister_fueloil", {
	description = S("TA3 Fuel Oil Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#7E5D0A:180^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_canister_naphtha", {
	description = S("TA3 Naphtha Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#AAA820:180^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_canister_gasoline", {
	description = S("TA3 Gasoline Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#EEFC52^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})


minetest.register_craft({
	type = "fuel",
	recipe = "techage:gas",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "techage:isobutane",
	burntime = 40,
})

minetest.register_craft({
	type = "fuel",
	recipe = "techage:gasoline",
	burntime = 50,
})

minetest.register_craft({
	type = "fuel",
	recipe = "techage:naphtha",
	burntime = 45,
})

minetest.register_craft({
	type = "fuel",
	recipe = "techage:fueloil",
	burntime = 40,
})


techage.register_liquid("techage:ta3_barrel_oil", "techage:ta3_barrel_empty", 10, "techage:oil_source")
techage.register_liquid("techage:ta3_barrel_bitumen", "techage:ta3_barrel_empty", 10, "techage:bitumen")
techage.register_liquid("techage:ta3_barrel_fueloil", "techage:ta3_barrel_empty", 10, "techage:fueloil")
techage.register_liquid("techage:ta3_barrel_naphtha", "techage:ta3_barrel_empty", 10, "techage:naphtha")
techage.register_liquid("techage:ta3_barrel_gasoline", "techage:ta3_barrel_empty", 10, "techage:gasoline")
techage.register_liquid("techage:ta3_cylinder_large_gas", "techage:ta3_cylinder_large", 6, "techage:gas")
techage.register_liquid("techage:ta4_cylinder_large_isobutane", "techage:ta3_cylinder_large", 6, "techage:isobutane")

techage.register_liquid("techage:ta3_canister_oil", "techage:ta3_canister_empty", 1, "techage:oil_source")
techage.register_liquid("techage:ta3_canister_bitumen", "techage:ta3_canister_empty", 1, "techage:bitumen")
techage.register_liquid("techage:ta3_canister_fueloil", "techage:ta3_canister_empty", 1, "techage:fueloil")
techage.register_liquid("techage:ta3_canister_naphtha", "techage:ta3_canister_empty", 1, "techage:naphtha")
techage.register_liquid("techage:ta3_canister_gasoline", "techage:ta3_canister_empty", 1, "techage:gasoline")
techage.register_liquid("techage:ta3_cylinder_small_gas", "techage:ta3_cylinder_small", 1, "techage:gas")
techage.register_liquid("techage:ta4_cylinder_small_isobutane", "techage:ta3_cylinder_small", 1, "techage:isobutane")
