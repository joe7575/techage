--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Main module for the in-game documentation

]]--

local S = techage.S

techage.register_category_page("techage", "Tech Age",
	S("Tech Age is a technic mod with four technic stages.@n@n"..
		"Iron Age (TA1): Use tools like coal pile, coal burner, gravel sieve, hammer and hopper to obtain the necessary metals and ores to further machines and tools for TA2@n@n"..
		"Steam Age (TA2): Build a steam engine with drive axles to run first simple machines.@n@n"..
		"Oil Age (TA3): Drill and pump oil, build your transport routes with Minecarts and power and control TA3 machines and lamps with electrical energy.@n@n"..
		"Future Age (TA4): Build regenerative power plants and intelligent machines, travel at high speed and use other future technologies."),
	"techage:ta4_wlanchip", 
	{}
)
