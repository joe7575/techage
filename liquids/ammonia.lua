--[[

	TechAge
	=======

	Copyright (C) 2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Nitrogen

]]--

local S = techage.S

minetest.register_craftitem("techage:ammonia", {
	description = S("TA4 Ammonia"),
	inventory_image = "techage_ammonia_inv.png",
	groups = {ta_liquid = 1},
})

techage.register_liquid("techage:cylinder_small_ammonia", "techage:ta3_cylinder_small", techage.volume_small_gascylinder, "techage:ammonia")
techage.register_liquid("techage:cylinder_large_ammonia", "techage:ta3_cylinder_large", techage.volume_big_gascylinder, "techage:ammonia")

techage.recipes.add("ta4_doser", {
	output = "techage:ammonia 2",
	input = {
		"techage:nitrogen 1", "techage:hydrogen 3"
	},
	catalyst = "techage:iron_powder",
})
