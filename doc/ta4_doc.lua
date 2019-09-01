--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Main module for the in-game TA4documentation

]]--

local S = techage.S

techage.register_category_page("ta4", 
	S("Future Age (TA4)"),
	S("The Future Age is the forth level of the available technic stages.@n"..
		"The goal of TA4 is to operate your machines only with renewable energy.@n"..
		"Build wind turbines, solar panel plants and biogas plants and use@n"..
		"future technologies."),
	"techage:ta4_wlanchip", 
	{}
)


local ROTOR = "techage_wind_turbine_inv.png"
local CANELLE = "techage_rotor.png"
local PILLAR = "techage_pillar_inv.png"

local Images = {
	{false, false, false, ROTOR, CANELLE, false, false},
	{false, false, false, PILLAR, false,  false, false},
	{false, false, false, PILLAR, false,  false, false},
	{false, false, false, PILLAR, false,  false, false},
	{false, false, false, PILLAR, false,  false, false},
	{false, false, false, PILLAR, false,  false, false},
	{false, false, false, PILLAR, false,  false, false},
	{false, false, false, PILLAR, false,  false, false},
}

--techage.register_entry_page("ta3", "power_station",
techage.register_category_page("ta4wt",
	S("TA4: Wind Turbine"), 
	S("Build a Wind Turbine according to the plan with TA4 Wind Turbine, TA4 Wind Turbine Nacelle and@n"..
		"a pillar by means of TA4 Pillar nodes (power cables have to be inside).@n"..
		"Please note the following limitations:@n"..
		"- pillar height between 10 and 19 m@n"..
		"- can only be built offshore (20 m in all 4 directions is water)@n"..
		"- more than 14 m to the next wind turbine@n"..
		"- the wind blows only between 5 and 9 o'clock and between 17 and 21 o'clock"), 
	nil, 
	{},
	Images)

