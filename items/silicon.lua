--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Silicon Wafer

]]--

local S = techage.S

minetest.register_craftitem("techage:ta4_silicon_wafer", {
	description = S("TA4 Silicon Wafer"),
	inventory_image = "techage_silicon_wafer.png",
})

if minetest.global_exists("mesecon") then
	techage.furnace.register_recipe({
		output = "techage:ta4_silicon_wafer 16",
		recipe = {
			"mesecons_materials:silicon",
			"mesecons_materials:silicon",
			"mesecons_materials:silicon",
			"techage:baborium_ingot"
		},
		time = 6,
	})
end
techage.furnace.register_recipe({
	output = "techage:ta4_silicon_wafer 16",
	recipe = {
		"basic_materials:silicon",
		"basic_materials:silicon",
		"basic_materials:silicon",
		"techage:baborium_ingot"
	},
	time = 6,
})


