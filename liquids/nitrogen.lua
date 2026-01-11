--[[

	TechAge
	=======

	Copyright (C) 2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Nitrogen

]]--

local S = techage.S

minetest.register_craftitem("techage:nitrogen", {
	description = S("TA4 Nitrogen"),
	inventory_image = "techage_nitrogen_inv.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage:cylinder_small_nitrogen", {
	description = S("Nitrogen Cylinder Small"),
	inventory_image = "techage_gas_cylinder_small.png^[colorize:#DCC710:120",
	stack_max = 1,
})

minetest.register_craftitem("techage:cylinder_large_nitrogen", {
	description = S("Nitrogen Cylinder Large"),
	inventory_image = "techage_gas_cylinder_large.png^[colorize:#DCC710:120",
	stack_max = 1,
})

techage.register_liquid("techage:cylinder_small_nitrogen", "techage:ta3_cylinder_small", techage.volume_small_gascylinder, "techage:nitrogen")
techage.register_liquid("techage:cylinder_large_nitrogen", "techage:ta3_cylinder_large", techage.volume_big_gascylinder, "techage:nitrogen")








