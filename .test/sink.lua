--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Demo for a electrical power consuming node

]]--

-- for lazy programmers
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local PWR_NEEDED = 5
local CYCLE_TIME = 2

local Cable = techage.ElectricCable
local power = techage.power

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos)
	--print("on_power sink "..P2S(pos))
	swap_node(pos, "techage:sink_on")
	M(pos):set_string("infotext", "on")
end

local function on_nopower(pos)
	--print("on_nopower sink "..P2S(pos))
	swap_node(pos, "techage:sink")
	M(pos):set_string("infotext", "off")
end

local function node_timer(pos, elapsed)
	--print("node_timer sink "..P2S(pos))
	local nvm = techage.get_nvm(pos)
	power.consumer_alive(pos, Cable, CYCLE_TIME)
	return true
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	if not nvm.running and power.power_available(pos, Cable) then
		nvm.running = true
		-- swap will be performed via on_power()
		power.consumer_start(pos, Cable, CYCLE_TIME)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		M(pos):set_string("infotext", "...")
	else
		nvm.running = false
		swap_node(pos, "techage:sink")
		power.consumer_stop(pos, Cable)
		minetest.get_node_timer(pos):stop()
		M(pos):set_string("infotext", "off")
	end
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("infotext", "off")
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, outdir, tlib2)
end

local net_def = {
	ele1 = {
		sides = techage.networks.AllSides, -- Cable connection sides
		ntype = "con1",
		on_power = on_power,
		on_nopower = on_nopower,
		nominal = PWR_NEEDED,
	},
}

minetest.register_node("techage:sink", {
	description = "Sink",
	tiles = {'techage_electric_button.png'},
	
	on_timer = node_timer,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,

	paramtype = "light",
	light_source = 0,	
	paramtype2 = "facedir",
	groups = {choppy = 2, cracky = 2, crumbly = 2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:sink_on", {
	description = "Sink",
	tiles = {'techage_electric_button.png'},

	on_timer = node_timer,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,

	paramtype = "light",
	light_source = minetest.LIGHT_MAX,	
	paramtype2 = "facedir",
	diggable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Cable:add_secondary_node_names({"techage:sink", "techage:sink_on"})

