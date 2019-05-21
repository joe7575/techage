-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUMPTION = 1

local Power = techage.ElectricCable

local function swap_node(pos, name, infotext)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
	M(pos):set_string("infotext", infotext)
end

local function on_power_pass1(pos, mem)
	if mem.running then
		mem.correction = POWER_CONSUMPTION
	else
		mem.correction = 0
	end
	return mem.correction
end	
		
local function on_power_pass2(pos, mem, sum)
	if sum > 0 and mem.running then
		swap_node(pos, "techage:test_lamp_on", "On")
		return 0
	else
		swap_node(pos, "techage:test_lamp", "Off")
		return -mem.correction
	end
end

local function lamp_on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.running then
		mem.running = true
	else
		mem.running = false
	end
	techage.power.power_distribution(pos)
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
	
	on_construct = tubelib2.init_mem,
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
	
	on_rightclick = lamp_on_rightclick,

	paramtype = "light",
	light_source = minetest.LIGHT_MAX,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drop = "techage:test_lamp",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:test_lamp", "techage:test_lamp_on"}, {
	on_power_pass1 = on_power_pass1,
	on_power_pass2 = on_power_pass2,
	power_network  = Power,
})

