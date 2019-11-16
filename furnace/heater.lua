--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Industrial Furnace Heater

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local firebox = techage.firebox
local fuel = techage.fuel
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CYCLE_TIME = 2
local PWR_NEEDED = 8

local Power = techage.ElectricCable
local power = techage.power

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos, mem)
	if mem.running then
		swap_node(pos, "techage:furnace_heater_on")
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
	mem.has_power = true
end

local function on_nopower(pos, mem)
	swap_node(pos, "techage:furnace_heater")
	mem.has_power = false
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	power.consumer_alive(pos, mem)
	return mem.running
end

minetest.register_node("techage:furnace_heater", {
	description = S("TA4 Furnace Heater"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png^techage_appl_hole_electric.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_heater.png^techage_frame_ta3.png",
	},
	on_timer = node_timer,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:furnace_heater_on", {
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png^techage_appl_hole_electric.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_heater_on.png^techage_frame_ta3.png",
	},
	
	light_source = 8,
	on_timer = node_timer,
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory = 1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:furnace_heater", "techage:furnace_heater_on"}, {
	power_network = Power,
	conn_sides = {"F", "B", "U", "D", "L"},
	on_power = on_power,
	on_nopower = on_nopower,
	after_place_node = function(pos, placer)
		local mem = tubelib2.init_mem(pos)
	end,
})

minetest.register_craft({
	output = "techage:furnace_heater",
	recipe = {
		{'techage:basalt_stone', 'default:steel_ingot', 'techage:basalt_stone'},
		{'default:steel_ingot', 'basic_materials:heating_element', 'default:steel_ingot'},
		{'techage:basalt_stone', 'techage:basalt_stone', 'techage:basalt_stone'},
	},
})

techage.register_node({"techage:furnace_heater", "techage:furnace_heater_on"}, {
	-- called from furnace_top
	on_transfer = function(pos, in_dir, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "fuel" then
			return mem.has_power or power.power_available(pos, mem, 0)
		elseif topic == "running" then
			return mem.running and (mem.has_power or power.power_available(pos, mem, 0))
		elseif topic == "start" and not mem.running then
			if power.power_available(pos, mem, 0) then
				mem.running = true
				mem.has_power = false
				power.consumer_start(pos, mem, CYCLE_TIME, PWR_NEEDED)
				return true
			end
		elseif topic == "stop" and mem.running then
			mem.running = false
			swap_node(pos, "techage:furnace_heater")
			power.consumer_stop(pos, mem)
			minetest.get_node_timer(pos):stop()
			return true
		end
	end
})	

Pipe:add_secondary_node_names({"techage:furnace_heater", "techage:furnace_heater_on"})

