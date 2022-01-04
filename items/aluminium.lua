--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Aluminium

]]--

local S = techage.S

minetest.register_craftitem("techage:gibbsite_powder", {
	description = S("Gibbsite Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#C6DCDB:120",
	groups = {powder = 1},
})

minetest.register_craftitem("techage:aluminum", {
	description = S("Aluminum"),
	inventory_image = "techage_aluminum_inv.png",
})

minetest.register_craftitem("techage:redmud", {
	description = S("Red Mud"),
	inventory_image = "techage_liquid2_inv.png^[colorize:#F80E13:140^techage_liquid1_inv.png",
})

minetest.register_craftitem("techage:barrel_redmud", {
	description = S("Red Mud Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#F80E13:140^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:canister_redmud", {
	description = S("Red Mud Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#F80E13:140^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

techage.register_liquid("techage:barrel_redmud", "techage:ta3_barrel_empty", 10, "techage:redmud")
techage.register_liquid("techage:canister_redmud", "techage:ta3_canister_empty", 1, "techage:redmud")

techage.recipes.add("ta4_doser", {
	output = "techage:gibbsite_powder 2",
	waste = "techage:redmud 1",
	input = {
		"techage:bauxite_powder 2",
		"techage:lye 1",
	}
})

techage.furnace.register_recipe({
	output = "techage:aluminum 2",
	recipe = {"techage:gibbsite_powder", "techage:gibbsite_powder",
		"techage:gibbsite_powder", "techage:gibbsite_powder"},
	time = 16,

})
