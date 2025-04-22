--[[

	TechAge
	=======

	Copyright (C) 2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Powder

]]--

local S = techage.S

minetest.register_craftitem("techage:gun_powder", {
	description = S("Gun Powder"),
	inventory_image = "tnt_gunpowder_inventory.png",
	groups = {powder = 1},
})

minetest.clear_craft({output = "tnt:gunpowder"})
core.register_alias_force("tnt:gunpowder", "techage:gun_powder")

techage.recipes.add("ta4_doser", {
	output = "techage:gun_powder 1",
	input = {
		"techage:ammonia 1", "techage:silver_sandstone_powder 3", "techage:graphite_powder 3"
	}
})
