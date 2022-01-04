--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Plastic

]]--

local S = techage.S

minetest.register_craftitem("techage:plastic_granules", {
	description = S("Plastic Granules"),
	inventory_image = "techage_powder_inv.png^[colorize:#FFFFFF:180",
	groups = {powder = 1},
})

techage.recipes.add("ta4_doser", {
	output = "techage:plastic_granules 1",
	input = {
		"techage:naphtha 1",
	}
})

techage.furnace.register_recipe({
	output = "basic_materials:plastic_sheet 4",
	recipe = {"techage:plastic_granules"},
	time = 2,

})
