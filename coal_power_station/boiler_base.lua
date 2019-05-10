--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Coal Power Station Boiler Base

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUMPTION = 2

local Pipe = techage.SteamPipe
local consumer = techage.consumer

local function valid_power_dir(pos, power_dir, in_dir)
	return power_dir == in_dir
end

local function turn_on_clbk(pos, in_dir, sum)
	return true
end

minetest.register_node("techage:coalboiler_base", {
	description = I("TA3 Boiler Base"),
	tiles = {"techage_coal_boiler_mesh_base.png"},
	drawtype = "mesh",
	mesh = "techage_boiler_large.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -16/32, -13/32, 13/32, 16/32, 13/32},
	},

	techage = {
		turn_on = turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Pipe,
		power_side = "F",
		valid_power_dir = valid_power_dir,
	},
	
	after_place_node = function(pos, placer)
		local mem = consumer.after_place_node(pos, placer)
		mem.power_consumption = POWER_CONSUMPTION
	end,
	
	after_tube_update = consumer.after_tube_update,
	after_dig_node = consumer.after_dig_node,
	
	drop = "",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})


Pipe:add_secondary_node_names({"techage:coalboiler_base"})
	

minetest.register_craft({
	output = "techage:coalboiler_base",
	recipe = {
		{"default:stone", "", "default:stone"},
		{"techage:iron_ingot", "", "techage:iron_ingot"},
		{"default:stone", "default:stone", "default:stone"},
	},
})

techage.register_help_page(I("TA3 Boiler Base"), 
I([[Part of the Coal Power Station.
Has to be placed on top of the 
TA3 Coal Power Station Firebox
and filled with water.
(see TA3 Coal Power Station)]]), "techage:coalboiler_base")
