--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Oil Help

]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local S, NS = dofile(MP.."/intllib.lua")

local HelpText = S([[In the TA3 age, oil (petroleum) 
serves as an almost infinite fuel.
But oil is difficult and expensive to recover:
1: Search for oil with the TA3 Oil Explorer
2: Drill for oil with the TA3 Oil Drill Box (oil derrick)
3: Recover the oil with the TA3 Oil Pumpjack
4: A power station nearby provides the necessary 
     electrical power for the derrick and pumpjack.
5: Tubes or rails are used for oil transportation.
]])

techage.register_chap_page(S("TA3 Oil Age"), HelpText, "techage:oil_source")

