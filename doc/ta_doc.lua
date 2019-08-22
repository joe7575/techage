--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Main module for the in-game TA1 documentation

]]--

local S = techage.S

techage.register_category_page("ta", "Further nodes and tools",
	S("This is a collection of further nodes and tools which do not fit to the stages 1 to 4."),
	"techage:end_wrench", {"end_wrench", "powerswitch", "trowel", "blackhole", "forceload"}
)

techage.register_entry_page("ta", "powerswitch",
	S("TA Power Switch"), 
	S("To turn electrical power on/off.@n"..
		"Has to be placed on a TA Power Switch Box."), 
	"techage:powerswitch")

techage.register_entry_page("ta", "trowel",
	S("TechAge Trowel"), 
	S("Tool to hide and retrieve electrical wiring in walls and floors.@n"..
		"The material for hiding the cables must be in the left stack of the first row in the player inventory."), 
	"techage:trowel")
