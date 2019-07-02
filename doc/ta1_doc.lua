--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Main module for the in-game TA1 documentation

]]--

local S = techage.S

techage.register_category_page("ta1", "Iron Age (TA1)",
	S("Iron Age is the first level of the available four technic stages.@n"..
		"The goal of TA1 is to collect and craft enough Iron Ingots@n"..
		"to be able to build machines for stage 2 (TA2).@n"..
		"1. You have to collect dirt and wood to build a Coal Pile.@n"..
		"    (The Coal Pile is needed to produce charcoal)@n"..
		"2. Build a Coal Burner to melt iron to iron ingots.@n"..
		"3. Craft a Gravel Sieve and collect gravel.@n"..
		"    (A Hammer can be used to smash cobble to gravel)@n"..
		"4. Sieve the gravel to get the necessary ores or go mining."),
	"techage:iron_ingot", 
	{"coalpile", "burner", "meltingpot", "lighter", "meridium", "iron", "hammer", "sieve", "hopper"}
)
