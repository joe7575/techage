--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Constructioon Plans for TA machines

]]--

techage.ConstructionPlans = {}

--
-- TA1: Coal Pile
--
local DDIRT = {"default_dirt.png", "default:dirt"}
local DWOOD = {"default_wood.png" , "default:wood"}
local LIGTR = {"techage_lighter.png", "techage:lighter"}

techage.ConstructionPlans["coalpile"] = {
	{DDIRT, DDIRT, DDIRT, DDIRT, DDIRT},
	{DDIRT, DWOOD, DWOOD, DWOOD, DDIRT},
	{DDIRT, DWOOD, DWOOD, DWOOD, DDIRT},
	{DDIRT, DWOOD, LIGTR, DWOOD, DDIRT},
	{DDIRT, DDIRT, DDIRT, DDIRT, DDIRT},
}

--
-- TA1: Coal Burner
--
local COBBL = {"default_cobble.png", "default:cobble"}
local CCOAL = {"techage_charcoal.png", "techage:charcoal"}
local MEPOT = {"default_cobble.png^techage_meltingpot.png", "techage:meltingpot"}
local FLAME = {"techage_flame.png", nil}

techage.ConstructionPlans["coalburner"] = {
	{false, false, false, MEPOT, false},
	{false, false, false, FLAME, false},
	{false, false, COBBL, CCOAL, COBBL},
	{false, false, COBBL, CCOAL, COBBL},
	{false, false, COBBL, CCOAL, COBBL},
	{false, false, COBBL, CCOAL, COBBL},
	{false, false, false, LIGTR, COBBL},
	{false, false, COBBL, COBBL, COBBL},
}

--
-- Hopper + Sieve
--
local CHEST = {"default_chest_lock.png", "default:chest_locked"}
local HOPPR = {"techage_hopper.png^[transformFX", "techage:hopper_ta1)"}
local SIEVE = {"techage_sieve_sieve_ta1.png", "techage:sieve3"}

techage.ConstructionPlans["hoppersieve"] = {
	{false, false, false, false, false},
	{false, false, false, false, false},
	{false, CHEST, false, false, false},
	{false, HOPPR, SIEVE, false, false},
	{false, false, HOPPR, CHEST, false},
}

--
-- Steam Engine
--
local PK000 = {"techage_steam_knee.png", "techage:steam_pipeS"}
local PK090 = {"techage_steam_knee.png^[transformR90", "techage:steam_pipeS"}
local PK270 = {"techage_steam_knee.png^[transformR270", "techage:steam_pipeS"}
local PI000 = {"techage_steam_pipe.png", "techage:steam_pipeS"}
local PI090 = {'techage_steam_pipe.png^[transformR90', "techage:steam_pipeS"}
local BOIL1 = {"techage:boiler1", "techage:boiler1"}
local BOIL2 = {"techage:boiler2", "techage:boiler2"}
local FIBOX = {"techage_firebox.png^techage_appl_firehole.png^techage_frame_ta2.png", "techage:firebox"}
local CYLIN = {"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png", "techage:cylinder"}
local FLYWH = {"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png^[transformFX]", "techage:flywheel"}

techage.ConstructionPlans["steamengine"] = {
	{false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false},
	{false, false, PK000, PI000, PK270, false, false},
	{false, false, BOIL2, false, PI090, false, false},
	{false, false, BOIL1, false, PI090, false, false},
	{false, false, FIBOX, false, PK090, CYLIN, FLYWH},
} 
		
--
-- Item Transport
--
local PUSHR = {"techage_appl_pusher.png^techage_frame_ta2.png", "techage:ta2_pusher_pas"}
local TB000 = {"techage_tube_tube.png", "techage:tubeS"}
local GRIND = {"techage_filling_ta2.png^techage_appl_grinder2.png^techage_frame_ta2.png", "techage:ta2_grinder_pas"}
local DISTR = {"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_distri_blue.png", "techage:ta2_distributor_pas"}
local SIEV2 = {"techage_filling_ta2.png^techage_appl_sieve.png^techage_frame_ta2.png", "techage:ta2_gravelsieve_pas"}

techage.ConstructionPlans["itemtransport"] = {
	{false, false, false, false, false, false, false, false, false, false, false},
	{false},
	{false},
	{CHEST, PUSHR, TB000, GRIND, PUSHR, DISTR, TB000, SIEV2, PUSHR, TB000, CHEST},
} 

--
-- Gravel Rinser
--
local RINSR = {"techage_filling_ta2.png^techage_appl_rinser.png^techage_frame_ta2.png", "techage:ta2_rinser_pas"}
local GLASS = {"default_glass.png", "default:glass"}
local WATER = {"default_water.png^default_glass.png", "default:water_source"}
local TK000 = {"techage_tube_knee.png", "techage:tubeS"}
local TK270 = {"techage_tube_knee.png^[transformR270", "techage:tubeS"}

techage.ConstructionPlans["gravelrinser"] = {	
	{false, false, false, false, false, false, false, false},
	{false, GLASS, WATER, GLASS, GLASS, GLASS, GLASS, GLASS},
	{false, DDIRT, DDIRT, TK000, RINSR, TK270, HOPPR, CHEST},
}
--local Tube = "techage_tube_knee.png"
--local Tube2 = "techage_tube_knee.png^[transformR270"
--local Rinser = "techage_filling_ta2.png^techage_appl_rinser.png^techage_frame_ta2.png"
--local Hopper = "techage_hopper.png"
--local Glass = "default_glass.png"
--local Water = "default_water.png"
--local Chest = "default_chest_lock.png"
--local Dirt = "default_dirt.png"

--local Images = {
--}


--
-- TA3 Industrial Furnace
--
local Cable = {"techage_electric_cable_inv.png", "techage:electric_cableS"}
local Tubes = {"techage_tube_tube.png", "techage:tubeS"}
local Pushr = {"techage_appl_pusher.png^techage_frame_ta3.png", "techage:ta3_pusher_pas"}
local Boost = {"techage_filling_ta3.png^techage_appl_compressor.png^[transformFX^techage_frame_ta3.png", "techage:ta3_booster"}
local Fibox = {"techage_concrete.png^techage_appl_firehole.png^techage_frame_ta3.png", "techage:furnace_firebox"}
local Furnc = {"techage_concrete.png^techage_appl_furnace.png^techage_frame_ta3.png", "ta3_furnace_pas"}

techage.ConstructionPlans["ta3_furnace"] = {
	{false, false, false, false, false, false, false},
	{Tubes, Pushr, Tubes, Furnc, Tubes, Pushr, Tube},
	{false, Cable, Boost, Fibox, false, false, false},
}


--
-- Thermal Storage System
--
local CONCR = {"basic_materials_concrete_block.png", "basic_materials:concrete_block"}
local PIPEH = {"techage_gaspipe.png", "techage:ta4_pipeS"}
local PIPEV = {"techage_gaspipe.png^[transformR90", "techage:ta4_pipeS"}
local PN000 = {"techage_gaspipe_knee.png", "techage:ta4_pipeS"}
local PN090 = {"techage_gaspipe_knee.png^[transformR90", "techage:ta4_pipeS"}
local PN180 = {"techage_gaspipe_knee.png^[transformR180", "techage:ta4_pipeS"}
local PN270 = {"techage_gaspipe_knee.png^[transformR270", "techage:ta4_pipeS"}
local HEXR1 = {"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_ribsT.png", "techage:heatexchanger3"}
local HEXR2 = {"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_ribsB.png", "techage:heatexchanger2"}
local HEXR3 = {"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png", "techage:heatexchanger1"}
local TURBN = {"techage_filling_ta4.png^techage_appl_turbine.png^techage_frame_ta4.png", "techage:ta4_turbine"}
local GENER = {"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_generator.png^[transformFX]", "techage:ta4_generator"}
local GRAVL = {"default_gravel.png", "default:gravel"}
local INLET = {"basic_materials_concrete_block.png^techage_gaspipe.png^[transformR90", "techage:ta4_pipe_inlet"}
local OGLAS = {"default_obsidian_glass.png", "default:obsidian_glass"}

techage.ConstructionPlans["storagesystem"] = {
	{false, false, false, false, false, false, false, false, false, false, false},
	{false, false, false, PN000, PIPEH, PIPEH, PN270, false, false, false, false},
	{false, CONCR, CONCR, INLET, CONCR, CONCR, PIPEV, false, false, false, false},
	{false, CONCR, GRAVL, GRAVL, GRAVL, CONCR, PN090, HEXR1, PIPEH, PN270, false},
	{false, OGLAS, GRAVL, GRAVL, GRAVL, CONCR, false, HEXR2, false, PIPEV, false},
	{false, CONCR, GRAVL, GRAVL, GRAVL, CONCR, PN000, HEXR3, PIPEH, TURBN, GENER},
	{false, CONCR, CONCR, INLET, CONCR, CONCR, PIPEV, false, false, false, false},
	{false, false, false, PN090, PIPEH, PIPEH, PN180, false, false, false, false},
}

