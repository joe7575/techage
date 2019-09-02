--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Energy Storage System Help

]]--

local S = techage.S

local CONCR = "basic_materials_concrete_block.png"
local PIPEH = "techage_gaspipe.png"
local PIPEV = "techage_gaspipe.png^[transformR90"
local PN000 = "techage_gaspipe_knee.png"
local PN090 = "techage_gaspipe_knee.png^[transformR90"
local PN180 = "techage_gaspipe_knee.png^[transformR180"
local PN270 = "techage_gaspipe_knee.png^[transformR270"
local HEXR1 = "techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_ribsT.png"
local HEXR2 = "techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_ribsM.png"
local HEXR3 = "techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_ribsB.png"
local TURBN = "techage_filling_ta4.png^techage_appl_turbine.png^techage_frame_ta4.png"
local GENER = "techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_generator.png^[transformFX]"
local GRAVL = "default_gravel.png"
local FAN   = "techage_filling_ta4.png^techage_appl_compressor.png^techage_frame_ta4.png"
local COREE = "techage_tes_core_elem.png"
local INLET = "techage_tes_inlet_help.png"
local CPI00 = "basic_materials_concrete_block.png^techage_gaspipe.png"
local CPI90 = "basic_materials_concrete_block.png^techage_gaspipe.png^[transformR90"

local Images = {
	{false, false, false, false, false, false, false, false, false, false, false, false},
	{CONCR, CONCR, CONCR, CONCR, CONCR, CONCR, CONCR, false, false, false, false, false},
	{CONCR, GRAVL, GRAVL, GRAVL, GRAVL, GRAVL, CONCR, false, false, false, false, false},
	{CONCR, GRAVL, GRAVL, PN000, PIPEH, PIPEH, CPI00, PIPEH, HEXR1, PIPEH, PN270, false},
	{CONCR, GRAVL, GRAVL, COREE, GRAVL, GRAVL, CONCR, false, HEXR2, false, PIPEV, false},
	{CONCR, GRAVL, GRAVL, PN090, PIPEH, PIPEH, CPI00, PIPEH, HEXR3, PIPEH, TURBN, GENER},
	{CONCR, GRAVL, GRAVL, INLET, GRAVL, GRAVL, CONCR, false, false, false, false, false},
	{CONCR, CONCR, CONCR, CPI90, CONCR, CONCR, CONCR, false, PN000, FAN,   false, false},
	{false, false, false, PN090, PIPEH, PIPEH, PIPEH, PIPEH, PN180, false, false, false},
}

techage.register_category_page("ta4es",
	S("TA4: Energy Storage System"), 
	S("Build a Energy Storage System to the plan with TA4 Heat Exchanger, TA4 Turbine and TA4 Generator.@n"..
		"- ..."), 
	nil, 
	{},
	Images)

