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
local STANDBY_TICKS = 4
local CYCLE_TIME = 4

local Pipe = techage.SteamPipe
local consumer = techage.consumer

local function valid_power_dir(pos, power_dir, in_dir)
	return power_dir == in_dir
end

local function start_node(pos, mem, state)
	consumer.turn_power_on(pos, POWER_CONSUMPTION)
end

local function stop_node(pos, mem, state)
	consumer.turn_power_on(pos, 0)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:coalboiler_base",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	start_node = start_node,
	stop_node = stop_node,
})
	
local function turn_on_clbk(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	local state = State:get_state(mem)
	
	if sum > 0 and state == techage.STOPPED then
		State:start(pos, mem)
	elseif sum <= 0 and state == techage.RUNNING then
		State:stop(pos, mem)
	end
end

local function node_timer(pos, elapsed)
	print("node_timer")
	local mem = tubelib2.get_mem(pos)
	return State:is_active(mem)
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
		State:node_init(pos, mem, "")
		State:start(pos, mem)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		consumer.after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = consumer.after_tube_update,
	--on_timer = node_timer,
	
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
