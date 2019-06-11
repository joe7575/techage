--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Furnace Help

]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local S, NS = dofile(MP.."/intllib.lua")

local HelpText = S([[1. Build the Furnace with 
TA3 Furnace Firebox, TA3 Furnace Top, 
and TA3 Booster according to the plan.
2. Heat the Firebox with coal/charcoal/oil
3. Power the Booster with electrical power.
4. Select one of the possible outputs
5. Connect the TA3 Furnace Top with your machines by means of tubes.
6. Start the Furnace]])

local Cable = "techage_electric_cable_inv.png"
local Tube = "techage_tube_tube.png"
local Pusher = "techage_appl_pusher.png^techage_frame_ta3.png"
local Booster = "techage_filling_ta3.png^techage_appl_compressor.png^[transformFX^techage_frame_ta3.png"
local Firebox = "techage_concrete.png^techage_appl_firehole.png^techage_frame_ta3.png"
local Furnace = "techage_concrete.png^techage_appl_furnace.png^techage_frame_ta3.png"

local Images = {
	{false, false, false, false, false, false, false},
	{Tube, Pusher, Tube, Furnace, Tube, Pusher, Tube},
	{false, Cable, Booster, Firebox, false, false, false},
}

techage.register_help_page(S("TA3 Industrial Furnace"), HelpText, nil, Images)


