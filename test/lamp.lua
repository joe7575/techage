-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUMPTION = 2

local Power = techage.ElectricCable
local consumer = techage.consumer

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

-- called from pipe network
local function valid_power_dir(pos, power_dir, in_dir)
	print("valid_power_dir", power_dir, in_dir)
	return true
end

local function lamp_turn_on_clbk(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	print("lamp_turn_on_clbk", sum, dump(mem))
	if sum > 0 and mem.running then
		swap_node(pos, "techage:test_lamp_on")
	else
		swap_node(pos, "techage:test_lamp")
	end
end	

local function lamp_on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	print("lamp_on_rightclick", dump(mem))
	if not mem.running then
		swap_node(pos, "techage:test_lamp_on")
		mem.running = true
		M(pos):set_string("infotext", "On")
		consumer.turn_power_on(pos, POWER_CONSUMPTION)
	else
		swap_node(pos, "techage:test_lamp")
		mem.running = false
		M(pos):set_string("infotext", "Off")
		consumer.turn_power_on(pos, 0)
	end
end

minetest.register_node("techage:test_lamp", {
	description = "TechAge Lamp",
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_button.png',
		'techage_electric_button.png',
		'techage_electric_button.png',
		'techage_electric_button.png',
		'techage_electric_button.png',
		'techage_electric_button.png',
	},
	techage = {
		turn_on = lamp_turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Power,
		power_side = "L",
		valid_power_dir = valid_power_dir,
	},
	
	after_place_node = function(pos, placer)
		local mem = consumer.after_place_node(pos, placer)
		mem.power_consumption = POWER_CONSUMPTION
	end,
	
	after_tube_update = consumer.after_tube_update,
	after_dig_node = consumer.after_dig_node,
	on_rightclick = lamp_on_rightclick,

	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:test_lamp_on", {
	description = "TechAge Lamp",
	tiles = {
		'techage_electric_button.png',
	},
	techage = {
		turn_on = lamp_turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Power,
		power_side = "L",
		valid_power_dir = valid_power_dir,
	},
	
	after_tube_update = consumer.after_tube_update,
	after_dig_node = consumer.after_dig_node,
	on_rightclick = lamp_on_rightclick,

	paramtype = "light",
	light_source = LIGHT_MAX,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drop = "techage:test_lamp",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Power:add_secondary_node_names({"techage:test_lamp", "techage:test_lamp_on"})
