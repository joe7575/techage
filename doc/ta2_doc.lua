--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Main module for the in-game TA1 documentation

]]--

local S = techage.S

techage.register_category_page("ta2", "Steam Age (TA2)",
	S("Steam Age is the second level of the available four technic stages.@n"..
		"The goal of TA2 is to build a coal powered stream engine with drive axles "..
		"and machines to produce ores and vacuum tubes for the first electronic devices and machines in TA3."),
	"techage:charcoal", {
		"steam_engine", "boiler1", "boiler2", "cylinder", "flywheel", 
		"pusher", "distributor", "chest", "grinder", "gravelsieve", "autocrafter", "rinser", 
		"electronic_fab", "liquidsampler"}
)

