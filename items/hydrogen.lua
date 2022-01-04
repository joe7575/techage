--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Hydrogen

]]--

local S = techage.S

minetest.register_craftitem("techage:hydrogen", {
	description = S("TA4 Hydrogen"),
	inventory_image = "techage_hydrogen_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:cylinder_small_hydrogen", {
	description = S("Hydrogen Cylinder Small"),
	inventory_image = "techage_gas_cylinder_small.png^[colorize:#00528A:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:cylinder_large_hydrogen", {
	description = S("Hydrogen Cylinder Large"),
	inventory_image = "techage_gas_cylinder_large.png^[colorize:#00528A:120",
	stack_max = 1,
})

techage.register_liquid("techage:cylinder_small_hydrogen", "techage:ta3_cylinder_small", 1, "techage:hydrogen")
techage.register_liquid("techage:cylinder_large_hydrogen", "techage:ta3_cylinder_large", 6, "techage:hydrogen")

techage.recipes.add("ta4_doser", {
	output = "techage:hydrogen 1",
	input = {
		"techage:gas 1",
	}
})
