--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	TA3 Petroleum types: bitumen, fueloil, naphtha, gasoline, gas
	
]]--

local S = techage.S


minetest.register_craftitem("techage:bitumen", {
	description = S("TA3 Bitumen"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#000000",
})

minetest.register_craftitem("techage:fueloil", {
	description = S("TA3 Fuel Oil"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#4b3f11^techage_liquid1_inv.png",
})

minetest.register_craftitem("techage:naphtha", {
	description = S("TA3 Naphtha"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#897937^techage_liquid1_inv.png",
})

minetest.register_craftitem("techage:gasoline", {
	description = S("TA3 Gasoline"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#bfaf6e^techage_liquid1_inv.png",
})

minetest.register_craftitem("techage:gas", {
	description = S("TA3 Gas"),
	inventory_image = "techage_gas_inv.png",
	groups = {not_in_creative_inventory=1},
})


minetest.register_craftitem("techage:ta3_barrel_bitumen", {
	description = S("TA3 Bitumen Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#000000:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_barrel_fueloil", {
	description = S("TA3 Fuel Oil Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#4b3f11:120^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_barrel_naphtha", {
	description = S("TA3 Naphtha Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#897937:120^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_barrel_gasoline", {
	description = S("TA3 Gasoline Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#bfaf6e:120^techage_symbol_liquid.png",
	stack_max = 1,
})


minetest.register_craftitem("techage:ta3_canister_bitumen", {
	description = S("TA3 Bitumen Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#000000^techage_canister_frame.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_canister_fueloil", {
	description = S("TA3 Fuel Oil Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#4b3f11^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_canister_naphtha", {
	description = S("TA3 Naphtha Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#897937^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_canister_gasoline", {
	description = S("TA3 Gasoline Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#bfaf6e^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})


minetest.register_craft({
	type = "fuel",
	recipe = "techage:gas",
	burntime = 30,
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

techage.register_liquid("techage:ta3_canister_oil", "techage:ta3_canister_empty", 1, "techage:oil_source")
techage.register_liquid("techage:ta3_canister_bitumen", "techage:ta3_canister_empty", 1, "techage:bitumen")
techage.register_liquid("techage:ta3_canister_fueloil", "techage:ta3_canister_empty", 1, "techage:fueloil")
techage.register_liquid("techage:ta3_canister_naphtha", "techage:ta3_canister_empty", 1, "techage:naphtha")
techage.register_liquid("techage:ta3_canister_gasoline", "techage:ta3_canister_empty", 1, "techage:gasoline")

