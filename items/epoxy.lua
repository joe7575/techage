--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Epoxy

]]--

local S = techage.S

minetest.register_craftitem("techage:epoxy", {
	description = S("Epoxide Resin"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#ca2446:140^techage_liquid1_inv.png",
})

minetest.register_craftitem("techage:barrel_epoxy", {
	description = S("Epoxide Resin Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#ca2446:140^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:canister_epoxy", {
	description = S("Epoxide Resin Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#ca2446:140^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

techage.recipes.add("ta4_doser", {
	output = "techage:epoxy 1",
	input = {
		"techage:naphtha 1",
		"techage:needle_powder 1",
	}
})

techage.register_liquid("techage:barrel_epoxy", "techage:ta3_barrel_empty", 10, "techage:epoxy")
techage.register_liquid("techage:canister_epoxy", "techage:ta3_canister_empty", 1, "techage:epoxy")

minetest.register_alias("techage:ta4_epoxy", "techage:canister_epoxy")
