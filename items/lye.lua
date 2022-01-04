--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Lye

]]--

local S = techage.S

minetest.register_craftitem("techage:lye", {
	description = S("Lye"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#7fd44c:120^techage_liquid1_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:barrel_lye", {
	description = S("Lye Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#7fd44c:120^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:canister_lye", {
	description = S("Lye Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#7fd44c:120^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

techage.recipes.add("ta4_doser", {
	output = "techage:lye 4",
	input = {
		"techage:water 3",
		"techage:usmium_powder 1",
	}
})

techage.register_liquid("techage:barrel_lye", "techage:ta3_barrel_empty", 10, "techage:lye")
techage.register_liquid("techage:canister_lye", "techage:ta3_canister_empty", 1, "techage:lye")
