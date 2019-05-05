--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Steam Engine Help

]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local S, NS = dofile(MP.."/intllib.lua")

techage.register_chap_page(S("Steam Age (TA2)"), S([[Steam Age is the second level of the available technic stages.
The goal of TA2 is build a steam engine and machines
to produce ores and vacuum tubes for the first 
electronic devices and machines in TA3.]]), "techage:vacuum_tube")

local HelpText = S([[1. Build a steam machine according
to the plan with TA2 Firebox, TA2 Boiler, 
Steam Pipes, TA2 Cyclinder and TA2 Flywheel.
2. Heat the Firebox with coal/charcoal
3. Fill the boiler with water (more than one bucket is needed)
4. Wait until the water is heated
5. Open the steam ventil
6. Start the Flywheel
7. Connect the Flywheel with your machines by means of Axles and Gearboxes]])

local Images = {
	
	{false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false},
	{false, false, "techage_steam_knee.png", 'techage_steam_pipe.png', "techage_steam_knee.png^[transformR270"},
	{false, false, "techage_boiler_top_ta2.png", false, 'techage_steam_pipe.png^[transformR90'},
	{false, false, "techage_boiler_bottom_ta2.png", false, 'techage_steam_pipe.png^[transformR90'},
	{false, false, "techage_firebox.png^techage_appl_firehole.png^techage_frame_ta2.png", false, 
		"techage_steam_knee.png^[transformR90", 
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png", 
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png^[transformFX]"},
}

techage.register_help_page("Steam Machine", HelpText, nil, Images)


