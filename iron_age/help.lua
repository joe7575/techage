--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Help pages

]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local S, NS = dofile(MP.."/intllib.lua")

local IronAgeHelp = S([[Iron Age is the first level of the available technic stages.
The goal of TA1 is to collect and craft enough XYZ Ingots
to be able to build machines for stage 2 (TA2).
1. You have to collect dirt and wood to build a Coal Pile.
    (The Coal Pile is needed to produce charcoal)
2. Build a Coal Burner to melt iron to steel ingots.
3. Craft a Gravel Sieve and collect gravel.
    (A Hammer can be used to smash cobble to gravel)
4. Sieve the gravel to get the necessary ores
]])	
	
local PileHelp = S([[Coal Pile to produce charcoal:
- build a 5x5 block dirt base
- place a lighter in the centre
- build a 3x3x3 wood cube around
- cover all with dirt to a 5x5x5 cube
- keep a hole to the lighter
- ignite the lighter and immediately
- close the pile with one wood and one dirt
- open the pile after the smoke disappeared]])

local BurnerHelp = S([[Coal Burner to heat the melting pot:
- build a 3x3xN cobble tower
- more height means more flame heat   
- keep a hole open on one side
- put a lighter in
- fill the tower from the top with charcoal
- ignite the lighter
- place the pot in the flame, (one block above the tower)]])

local PileImages = {
	{"default_dirt", "default_dirt", "default_dirt",    "default_dirt", "default_dirt"},
	{"default_dirt", "default_wood", "default_wood",    "default_wood", "default_dirt"},
	{"default_dirt", "default_wood", "default_wood",    "default_wood", "default_dirt"},
	{"default_dirt", "default_wood", "techage_lighter", "default_wood", "default_dirt"},
	{"default_dirt", "default_dirt", "default_dirt",    "default_dirt", "default_dirt"},
}

local BurnerImages = {
	
	{false, false, false, "default_cobble.png^techage_meltingpot", false},
	{false, false, false, false, false},
	{false, false, "default_cobble", "techage_charcoal", "default_cobble"},
	{false, false, "default_cobble", "techage_charcoal", "default_cobble"},
	{false, false, "default_cobble", "techage_charcoal", "default_cobble"},
	{false, false, "default_cobble", "techage_charcoal", "default_cobble"},
	{false, false, false,            "techage_lighter",  "default_cobble"},
	{false, false, "default_cobble", "default_cobble",   "default_cobble"},
}

techage.register_chap_page("Iron Age (TA1)", IronAgeHelp)
techage.register_help_page("Coal Pile", PileHelp, PileImages)
techage.register_help_page("Coal Burner", BurnerHelp, BurnerImages)