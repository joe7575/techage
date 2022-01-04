--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Industrial Furnace Heater

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local PWR_NEEDED = 14
local CYCLE_TIME = 2

local Cable = techage.ElectricCable
local power = networks.power

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end


local function after_place_node(pos)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
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

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed == PWR_NEEDED then
			swap_node(pos, "techage:furnace_heater_on")
		end
		return true
	end,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

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

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed < PWR_NEEDED then
			swap_node(pos, "techage:furnace_heater")
		end
		return true
	end,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	light_source = 8,
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory = 1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:furnace_heater", "techage:furnace_heater_on"}, Cable, "con", {"B", "F", "L", "D", "U"})

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
				minetest.get_node_timer(pos):start(CYCLE_TIME)
				return true
			end
		elseif topic == "stop" and nvm.running then
			nvm.running = false
			swap_node(pos, "techage:furnace_heater")
			minetest.get_node_timer(pos):stop()
			return true
		end
	end
})

minetest.register_craft({
	output = "techage:furnace_heater",
	recipe = {
		{'techage:aluminum', 'default:steel_ingot', 'techage:aluminum'},
		{'techage:basalt_stone', 'basic_materials:heating_element', 'techage:basalt_stone'},
		{'techage:aluminum', 'techage:ta4_furnace_ceramic', 'techage:aluminum'},
	},
})
