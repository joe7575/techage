--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Usminum

]]--

local S = techage.S

minetest.register_craftitem("techage:usmium_nuggets", {
	description = S("Usmium Nuggets"),
	inventory_image = "techage_usmium_nuggets.png",
})

minetest.register_craftitem("techage:usmium_powder", {
	description = S("Usmium Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#46728E:120",
	groups = {powder = 1},
})

techage.add_grinder_recipe({input="techage:usmium_nuggets", output="techage:usmium_powder"})
