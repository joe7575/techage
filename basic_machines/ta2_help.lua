--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	TA2 help pages for basic machines
	
]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

techage.register_help_page(I("TA2 Autocrafter"), 
I([[Supports automated crafting of items.
Crafts 1 item in 2 seconds.
Needs axle power: 4]]), "techage:ta2_autocrafter_pas")
