--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	TA3 help pages for basic machines
	
]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

techage.register_help_page(I("TA3 Autocrafter"), 
I([[Supports automated crafting of items.
Crafts 2 items in 2 seconds.
Needs electrical power: 6]]), "techage:ta3_autocrafter_pas")
