--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA4 Silicon Wafer
	
]]--

local S = techage.S

minetest.register_craftitem("techage:ta4_silicon_wafer", {
	description = S("TA4 Silicon Wafer"),
	inventory_image = "techage_silicon_wafer.png",
})

techage.furnace.register_recipe({
	output = "techage:ta4_silicon_wafer 8",
	recipe = {
		"basic_materials:silicon", 
	},
	time = 6,
})