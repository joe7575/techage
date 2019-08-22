--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA2 Steam Engine Help

]]--

local S = techage.S

local HelpText = S("Build a steam engine according to the plan with TA2 Firebox, TA2 Boiler, Steam Pipes, TA2 Cylinder and TA2 Flywheel.@n"..
	"- Heat the Firebox with coal/charcoal@n"..
	"- Fill the boiler with water (more than one bucket is needed)@n"..
	"- Wait until the water is heated@n"..
	"- Open the steam ventil@n"..
	"- Start the Flywheel@n"..
	"- Connect the Flywheel with your machines by means of Axles and Gearboxes")

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

techage.register_entry_page("ta2", "steam_engine",
	S("Steam Engine"), HelpText, nil, Images)


