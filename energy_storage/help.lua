--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Energy Storage System Help

]]--

local S = techage.S

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
local GLASS = {"default_obsidian_glass.png", "default:obsidian_glass"}

local Images = {
	{false, false, false, false, false, false, false, false, false, false, false},
	{false, false, false, PN000, PIPEH, PIPEH, PN270, false, false, false, false},
	{false, CONCR, CONCR, INLET, CONCR, CONCR, PIPEV, false, false, false, false},
	{false, CONCR, GRAVL, GRAVL, GRAVL, CONCR, PN090, HEXR1, PIPEH, PN270, false},
	{false, GLASS, GRAVL, GRAVL, GRAVL, CONCR, false, HEXR2, false, PIPEV, false},
	{false, CONCR, GRAVL, GRAVL, GRAVL, CONCR, PN000, HEXR3, PIPEH, TURBN, GENER},
	{false, CONCR, CONCR, INLET, CONCR, CONCR, PIPEV, false, false, false, false},
	{false, false, false, PN090, PIPEH, PIPEH, PN180, false, false, false, false},
}

techage.register_category_page("ta4es",
	S("TA4: Energy Storage System"), 
	S("Build a Energy Storage System to the plan with TA4 Heat Exchanger, TA4 Turbine and TA4 Generator.@n"..
		"- ..."), 
	nil, 
	{},
	Images)

