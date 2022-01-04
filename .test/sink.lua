--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

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
--local Cable = techage.Axle
local power = networks.power

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	if not nvm.running and power.power_available(pos, Cable) then
		nvm.running = true
		swap_node(pos, "techage:sink_on")
		M(pos):set_string("infotext", "on")
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	else
		nvm.running = false
		swap_node(pos, "techage:sink")
		M(pos):set_string("infotext", "off")
		minetest.get_node_timer(pos):stop()
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

minetest.register_node("techage:sink", {
	description = "Sink",
	tiles = {'techage_electric_button.png^[colorize:#000000:50'},

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed == PWR_NEEDED then
			swap_node(pos, "techage:sink_on")
			M(pos):set_string("infotext", "on")
		end
		return true
	end,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

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

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed < PWR_NEEDED then
			swap_node(pos, "techage:sink")
			M(pos):set_string("infotext", "off")
		end
		return true
	end,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	paramtype2 = "facedir",
	diggable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:sink", "techage:sink_on"}, Cable, "con")
