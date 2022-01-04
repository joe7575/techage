--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	pillar

]]--

local S = techage.S

minetest.register_craftitem("techage:steelmat", {
	description = S("TechAge Steel Mat"),
	inventory_image = "techage_steelmat.png",
})

minetest.register_craft({
	output = 'techage:steelmat 16',
	recipe = {
		{"", "techage:iron_ingot", ""},
		{"default:steel_ingot", "techage:iron_ingot", "default:steel_ingot"},
		{"", "techage:iron_ingot", ""},
	},
})
