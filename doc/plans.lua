--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	Constructioon Plans for TA machines

]]--

techage.ConstructionPlans = {}


local IMG_1 = {"", "techage_ta1.png"}
local IMG_2 = {"", "techage_ta2.png"}
local IMG_3 = {"", "techage_ta3.png"}
local IMG31 = {"", "techage_ta3b.png"}
local IMG_4 = {"", "techage_ta4.png"}
local IMG41 = {"", "techage_ta4_tes.png"}
local IMG42 = {"", "techage_ta4_solar.png"}
local IMG43 = {"", "techage_reactor_inv.png"}
local IMG44 = {"", "techage_ta4_filter.png"}

local TOP_V = {"top_view", ""}
local SIDEV = {"side_view", ""}

--
-- TA1: Coal Pile
--
local DDIRT = {"default_dirt.png", "default:dirt"}
local DWOOD = {"default_wood.png" , "default:wood"}
local LIGTR = {"techage_lighter.png", "techage:lighter"}

techage.ConstructionPlans["coalpile"] = {
	{false, false, SIDEV, false, false, false, false, false, TOP_V, false, false},
	{false, false, false, false, false, false, false, false, false, false, false},
	{DDIRT, DDIRT, DDIRT, DDIRT, DDIRT, false, DDIRT, DDIRT, DDIRT, DDIRT, DDIRT},
	{DDIRT, DWOOD, DWOOD, DWOOD, DDIRT, false, DDIRT, DWOOD, DWOOD, DWOOD, DDIRT},
	{DDIRT, DWOOD, DWOOD, DWOOD, DDIRT, false, DDIRT, DWOOD, LIGTR, DWOOD, DDIRT},
	{DDIRT, DWOOD, LIGTR, DWOOD, DDIRT, false, DDIRT, DWOOD, DWOOD, DWOOD, DDIRT},
	{DDIRT, DDIRT, DDIRT, DDIRT, DDIRT, false, DDIRT, DDIRT, DDIRT, DDIRT, DDIRT},
	{false, false, false, false, false, false, false, false, false, false, false},
}

--
-- TA1: Coal Burner
--
local COBBL = {"default_cobble.png", "default:cobble"}
local CCOAL = {"techage_charcoal.png", "techage:charcoal"}
local MEPOT = {"default_cobble.png^techage_meltingpot.png", "techage:meltingpot"}
local FLAME = {"techage_flame.png", nil}

techage.ConstructionPlans["coalburner"] = {
	{false, false, SIDEV, false, false, false, false},
	{false, false, MEPOT, false, false, IMG_1, false},
	{false, false, FLAME, false},
	{false, COBBL, CCOAL, COBBL},
	{false, COBBL, CCOAL, COBBL},
	{false, COBBL, CCOAL, COBBL},
	{false, COBBL, CCOAL, COBBL},
	{false, false, LIGTR, COBBL},
	{false, COBBL, COBBL, COBBL},
}

--
-- Hopper + Sieve
--
local CHEST = {"default_chest_lock.png", "default:chest_locked"}
local HOPPR = {"techage_hopper.png^[transformFX", "minecart:hopper"}
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
	{false, false, false, false, false, IMG_2, false},
	{false, false, false, false, false, false, false},
	{false, PK000, PI000, PK270, false, false, false},
	{false, BOIL2, false, PI090, false, false, false},
	{false, BOIL1, false, PI090, false, false, false},
	{false, FIBOX, false, PK090, CYLIN, FLYWH, false},
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
local WATR2 = {"default_water.png", "default:water_source"}
local TK000 = {"techage_tube_knee.png", "techage:tubeS"} -- like 'r'
local TK090 = {"techage_tube_knee.png^[transformR90", "techage:tubeS"} -- '7'
local TK180 = {"techage_tube_knee.png^[transformR180", "techage:tubeS"}
local TK270 = {"techage_tube_knee.png^[transformR270", "techage:tubeS"}

techage.ConstructionPlans["gravelrinser"] = {	
	{false, false, false, SIDEV, false, false, false, false},
	{false, GLASS, WATER, GLASS, GLASS, GLASS, GLASS, GLASS},
	{false, DDIRT, DDIRT, TK000, RINSR, TK270, HOPPR, CHEST},
	{false, false, false, false, false, false, false, false},
	{false, false, false, TOP_V, false, false, false, false},
	{false, GLASS, GLASS, GLASS, GLASS, GLASS, GLASS, GLASS},
	{false, GLASS, WATR2, TK000, RINSR, TK270, HOPPR, GLASS},
	{false, GLASS, GLASS, GLASS, GLASS, GLASS, GLASS, GLASS},
}

--
-- Coal Power Station
--
local BOIL3 = {"techage:coalboiler_top", "techage:coalboiler_top"}
local BOIL4 = {"techage:coalboiler_base", "techage:coalboiler_base"}
local FBOX3 = {"techage:coalfirebox", "techage:coalfirebox"}
local TURB3 = {"techage_filling_ta3.png^techage_appl_turbine.png^techage_frame_ta3.png", "techage:turbine"}
local GENE3 = {"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png", "techage:generator"}
local COOL3 = {"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png", "techage:cooler"}
local PK180 = {"techage_steam_knee.png^[transformR180", "techage:steam_pipeS"}

techage.ConstructionPlans["coalpowerstation"] = {
	{false, false, false, false, false, false, false, false},
	{false, PK000, PI000, PI000, PI000, PI000, PI000, PK270},
	{false, PI090, BOIL3, PI000, PK270, PK000, COOL3, PK180},
	{false, PK090, BOIL4, false, PI090, PI090},
	{false, false, FBOX3, false, PK090, TURB3, GENE3},
}


--
-- TA3 Industrial Furnace
--
local Cable = {"techage_electric_cable_inv.png", "techage:electric_cableS"}
local Tubes = {"techage_tube_tube.png", "techage:tubeS"}
local PushR = {"techage_appl_pusher.png^techage_frame_ta3.png", "techage:ta3_pusher_pas"}
local PushL = {"techage_appl_pusher.png^techage_frame_ta3.png^[transformFX", "techage:ta3_pusher_pas"}
local Boost = {"techage_filling_ta3.png^techage_appl_compressor.png^[transformFX^techage_frame_ta3.png", "techage:ta3_booster"}
local Fibox = {"techage_concrete.png^techage_appl_firehole.png^techage_frame_ta3.png", "techage:furnace_firebox"}
local Furnc = {"techage_concrete.png^techage_appl_furnace.png^techage_frame_ta3.png", "techage:ta3_furnace_pas"}

techage.ConstructionPlans["ta3_furnace"] = {
	{false, false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false},
	{false, Tubes, PushR, Tubes, Furnc, Tubes, PushR, Tubes},
	{false, false, Cable, Boost, Fibox, false, false, false},
}


--
-- TA3 Tank Pump Pusher
--
local Pump = {"techage_filling_ta3.png^techage_appl_pump.png^techage_frame_ta3.png", "techage:t3_pump"}
local TANK3 = {"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png", "techage:ta3_tank"}
local Fillr = {"techage_filling_ta3.png^techage_appl_liquid_hopper.png^techage_frame_ta3.png", "techage:filler"}
local PIPEH = {"techage_gaspipe.png", "techage:ta4_pipeS"}
local PIPEV = {"techage_gaspipe.png^[transformR90", "techage:ta4_pipeS"}
local PN000 = {"techage_gaspipe_knee.png", "techage:ta4_pipeS"}  -- r
local PN090 = {"techage_gaspipe_knee.png^[transformR90", "techage:ta4_pipeS"}   -- L
local PN180 = {"techage_gaspipe_knee.png^[transformR180", "techage:ta4_pipeS"}  -- J
local PN270 = {"techage_gaspipe_knee.png^[transformR270", "techage:ta4_pipeS"}  -- 7

techage.ConstructionPlans["ta3_tank"] = {
	{false, false, false, false, SIDEV, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false},
	{false, Tubes, PushR, Tubes, Fillr, Tubes, PushR, Tubes, false, false},
	{false, false, false, false, TANK3, PIPEH, PIPEH, Pump,  PIPEH, false},
	{false, false, false, false, false, false, false, false, false, false},
}


--
-- TA3 Oil Loading station
--
local MCART = {minetest.inventorycube("carts_cart_top.png", 
		"carts_cart_side.png^minecart_logo.png", "carts_cart_side.png^minecart_logo.png"), 
		"minecart:cart"}
local PRAIL = {"carts_rail_straight_pwr.png", "carts:powerrail"}
local PRAIH = {"carts_rail_straight_pwr.png^[transformR90", "carts:powerrail"}
local TRAIL = {"carts_rail_t_junction.png^[transformR90", "carts:rail"}
local RAILH = {"carts_rail_straight.png^[transformR90", "carts:rail"}
local CRAIL = {"carts_rail_curved.png^[transformR90", "carts:rail"}
local BUFFR = {"default_junglewood.png^minecart_buffer.png", "minecart:buffer"}

techage.ConstructionPlans["ta3_loading"] = {
	{false, false, PIPEH, Pump,  PIPEH, PN270, SIDEV, false, false, false, false},
	{false, false, false, false, false, PIPEV, false, false, false, false, false},
	{false, MCART, false, false, false, PN090, TANK3, false, false, false, false},
	{false, HOPPR, CHEST, Tubes, PushR, Tubes, Fillr, PushR, Tubes, MCART, false},
	{false, false, false, false, false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false},
	{false, BUFFR, false, false, false, TOP_V, false, false, false, BUFFR, false},
	{false, PRAIL, false, false, false, false, false, false, false, PRAIL, false},
	{false, CRAIL, RAILH, PRAIH, RAILH, RAILH, PRAIH, RAILH, RAILH, TRAIL, RAILH},
}


--
-- Distiller
--
local DIST4 = {"techage_distiller_inv.png", "techage:ta3_distiller4"}
local DIST3 = {"techage_distiller_inv.png", "techage:ta3_distiller3"}
local DIST2 = {"techage_distiller_inv.png", "techage:ta3_distiller2"}
local DIST1 = {"techage_distiller_inv.png", "techage:ta3_distiller1"}
local DBASE = {"techage_concrete.png", "techage:ta3_distiller_base"}
local REBIO = {"techage_filling_ta3.png^techage_appl_reboiler.png^techage_frame_ta3.png", "techage:ta3_reboiler"}

techage.ConstructionPlans["ta3_distiller"] = {
	{false, false, false, false, false, SIDEV, false, PN000, PIPEH, TANK3, false},
	{false, IMG31, false, false, false, false, false, DIST4, false, false, false},
	{false, false, false, false, false, false, false, DIST3, PIPEH, TANK3, false},
	{false, false, false, false, false, false, false, DIST2, false, false, false},
	{false, false, false, false, false, false, false, DIST3, PIPEH, TANK3, false},
	{false, false, false, false, false, false, false, DIST2, false, false, false},
	{false, false, false, false, false, false, false, DIST3, PIPEH, TANK3, false},
	{false, false, false, false, false, false, false, DIST2, false, false, false},
	{false, TANK3, PIPEH, Pump,  PIPEH, REBIO, PIPEH, DIST1, false, false, false},
	{false, false, false, false, false, false, false, DBASE, PIPEH, TANK3, false},
}

--
-- Chemical Reactor
--
local RBASE = {"techage_concrete.png", "techage:ta4_reactor_stand"}
local STAND = {"techage_reactor_stand_side.png", "techage:ta4_reactor_stand"}
local REACT = {"techage_reactor_plan.png", "techage:ta4_reactor"}
local FILLR = {"techage_reactor_filler_plan.png", "techage:ta4_reactor_fillerpipe"}
local DOSER = {"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_pump_up.png", "techage:ta4_doser"}
local SILO  = {"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_silo.png", "techage:ta3_silo"}

techage.ConstructionPlans["ta4_reactor"] = {
	{false, false, false, false, false, false, SIDEV, false, false, false, false},
	{false, IMG43, false, false, false, false, false, false, false, false, false},
	{false, false, false, false, PN000, PIPEH, PIPEH, PN270, false, false, false},
	{false, false, false, false, PIPEV, false, false, FILLR, false, false, false},
	{false, false, false, false, PIPEV, false, false, REACT, false, false, false},
	{false, false, false, false, PIPEV, false, false, STAND, PIPEH, PIPEH, SILO},
	{false, TANK3, PIPEH, PIPEH, DOSER, PN270, false, RBASE, PIPEH, PIPEH, TANK3},
	{false, SILO,  PIPEH, PIPEH, PIPEH, PN180, false, false, false, false, false},
}

--
-- Wind Turbine
--
local ROTOR = {"techage_wind_turbine_inv.png", "techage:ta4_wind_turbine"}
local NCLLE = {"techage_rotor.png", "techage:ta4_wind_turbine_nacelle"}
local PILLR = {"techage:pillar", "techage:pillar"}
local SLAMP = {"techage:rotor_signal_lamp_off", "techage:rotor_signal_lamp_off"}

techage.ConstructionPlans["ta4_windturbine"] = {
	{false, false, false, SIDEV, false,  false, false},
	{false, false, false, SLAMP, false,  false, IMG_4, false},
	{false, false, false, ROTOR, NCLLE, false, false},
	{false, false, false, PILLR, false,  false, false},
	{false, false, false, PILLR, false,  false, false},
	{false, false, false, PILLR, false,  false, false},
	{false, false, false, PILLR, false,  false, false},
	{false, false, false, PILLR, false,  false, false},
	{false, false, false, PILLR, false,  false, false},
	{false, false, false, PILLR, false,  false, false},
}

--
-- Thermal Storage System
--
local CONCR = {"basic_materials_concrete_block.png", "basic_materials:concrete_block"}
local HEXR1 = {"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_ribsT.png", "techage:heatexchanger3"}
local HEXR2 = {"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_ribsB.png", "techage:heatexchanger2"}
local HEXR3 = {"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png", "techage:heatexchanger1"}
local TURBN = {"techage_filling_ta4.png^techage_appl_turbine.png^techage_frame_ta4.png", "techage:ta4_turbine"}
local GENER = {"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_generator.png^[transformFX]", "techage:ta4_generator"}
local GRAVL = {"default_gravel.png", "default:gravel"}
local INLET = {"basic_materials_concrete_block.png^techage_gaspipe.png^[transformR90", "techage:ta4_pipe_inlet"}
local OGLAS = {"default_obsidian_glass.png", "default:obsidian_glass"}

techage.ConstructionPlans["ta4_storagesystem"] = {
	{false, false, TOP_V, false, false, false, false, SIDEV, false, IMG41, false},
	{false, false, PN000, PIPEH, PIPEH, PIPEH, PN270, false, false, false, false},
	{CONCR, CONCR, INLET, CONCR, CONCR, false, PIPEV, false, false, false, false},
	{CONCR, GRAVL, GRAVL, GRAVL, CONCR, false, PN090, HEXR1, PIPEH, PN270, false},
	{OGLAS, GRAVL, GRAVL, GRAVL, CONCR, false, false, HEXR2, false, PIPEV, false},
	{CONCR, GRAVL, GRAVL, GRAVL, CONCR, false, PN000, HEXR3, PIPEH, TURBN, GENER},
	{CONCR, CONCR, INLET, CONCR, CONCR, false, PIPEV, false, false, false, false},
	{false, false, PN090, PIPEH, PIPEH, PIPEH, PN180, false, false, false, false},
}

--
-- Solar Plant
--

local SOLAR = {"techage_solar_module_top.png", "techage:ta4_solar_module"}
local RCBLE = {"techage_ta4_cable_inv.png", "techage:ta4_power_cableS"}
local CARRI = {"techage:ta4_solar_carrier", "techage:ta4_solar_carrier"}
local INVAC = {"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inverter.png", "techage:ta4_solar_inverter"}

techage.ConstructionPlans["ta4_solarplant"] = {
	{false, false, false, false, false, false, false, false, false, IMG42, false},
	{false, false, TOP_V, false, false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false},
    {false, SOLAR, SOLAR, SOLAR},
    {false, CARRI, CARRI, CARRI, RCBLE, RCBLE, RCBLE, INVAC, Cable},
    {false, SOLAR, SOLAR, SOLAR},
}


--
-- Liquid Filter
--

local LFSNK = {"basic_materials_concrete_block.png^techage_appl_arrow.png", "techage:ta4_liquid_filter_sink"}
local PWETR = {"basic_materials_concrete_block.png^techage_gaspipe.png", "techage:ta3_pipe_wall_entry"}
local TANK4 = {"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png", "techage:ta4_tank"}
local LFFIL = {"basic_materials_concrete_block.png^techage_gaspipe_hole.png", "techage:ta4_liquid_filter_filler"}

techage.ConstructionPlans["ta4_liquid_filter_base"] = {
	{false, false, false, false, false, false, false, false, IMG44, false},
	{false, false, false, TOP_V, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false},
	{false, CONCR, CONCR, CONCR, CONCR, CONCR},
	{false, CONCR, CONCR, CONCR, CONCR, CONCR},
	{false, CONCR, CONCR, LFSNK, PWETR, PWETR, PIPEH, PIPEH, TANK4},
	{false, CONCR, CONCR, CONCR, CONCR, CONCR},
	{false, CONCR, CONCR, CONCR, CONCR, CONCR},
}

techage.ConstructionPlans["ta4_liquid_filter_gravel"] = {
	{false, false, false, false, false, false, false, false, IMG44, false},
	{false, false, false, TOP_V, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false},
	{false, CONCR, OGLAS, OGLAS, OGLAS, CONCR},
	{false, OGLAS, GRAVL, GRAVL, GRAVL, OGLAS},
	{false, OGLAS, GRAVL, GRAVL, GRAVL, OGLAS},
	{false, OGLAS, GRAVL, GRAVL, GRAVL, OGLAS},
	{false, CONCR, OGLAS, OGLAS, OGLAS, CONCR},
}

techage.ConstructionPlans["ta4_liquid_filter_top"] = {
	{false, false, false, false, false, false, false, false, IMG44, false},
	{false, false, false, TOP_V, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false},
	{false, CONCR, CONCR, CONCR, CONCR, CONCR},
	{false, CONCR, false, false, false, CONCR},
	{false, CONCR, false, LFFIL, false, CONCR},
	{false, CONCR, false, false, false, CONCR},
	{false, CONCR, CONCR, CONCR, CONCR, CONCR},
}

function techage.add_manual_plans(table_with_plans)
	for name, tbl in pairs(table_with_plans) do
		techage.ConstructionPlans[name] = tbl
	end
end
