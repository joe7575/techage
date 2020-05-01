--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

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
local PWR_NEEDED = 14

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
	swap_node(pos, "techage:furnace_heater_on")
end

local function on_nopower(pos)
	swap_node(pos, "techage:furnace_heater")
end

local function node_timer(pos, elapsed)
	power.consumer_alive(pos, Cable, CYCLE_TIME)
	return true
end

local function after_place_node(pos)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, outdir, tlib2)
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
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = {
		ele1 = {
			sides = {B = true, F = true, L = true, D = true, U = true},
			ntype = "con1",
			on_power = on_power,
			on_nopower = on_nopower,
			nominal = PWR_NEEDED,
		},
	},
	
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
	
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = {
		ele1 = {
			sides = {B = true, F = true, L = true, D = true, U = true},
			ntype = "con1",
			on_power = on_power,
			on_nopower = on_nopower,
			nominal = PWR_NEEDED,
			is_running = function() return true end,
		},
	},
	
	light_source = 8,
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory = 1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Cable:add_secondary_node_names({"techage:furnace_heater", "techage:furnace_heater_on"})

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
		local nvm = techage.get_nvm(pos)
		if topic == "fuel" then
			return power.power_available(pos, Cable)
		elseif topic == "running" then
			return techage.get_node_lvm(pos).name == "techage:furnace_heater_on"
		elseif topic == "start" and not nvm.running then
			if power.power_available(pos, Cable) then
				nvm.running = true
				power.consumer_start(pos, Cable, CYCLE_TIME)
				minetest.get_node_timer(pos):start(CYCLE_TIME)
				return true
			end
		elseif topic == "stop" and nvm.running then
			nvm.running = false
			swap_node(pos, "techage:furnace_heater")
			power.consumer_stop(pos, Cable)
			minetest.get_node_timer(pos):stop()
			return true
		end
	end
})	

Pipe:add_secondary_node_names({"techage:furnace_heater", "techage:furnace_heater_on"})

