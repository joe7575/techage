-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local POWER_CONSUMPTION = 2
local POWER_CAPACITY = 8


local Cable = techage.ElectricCable
local consumer = techage.consumer
local generator = techage.generator

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function valid_power_dir(pos, mem, in_dir)
	--print("valid_power_dir", mem.power_dir, in_dir)
	return true
end

local function lamp_turn_on_clbk(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	if sum > 0 and mem.running then
		swap_node(pos, "techage:lamp_on")
	else
		swap_node(pos, "techage:lamp")
	end
end	

local function lamp_on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.running then
		swap_node(pos, "techage:lamp_on")
		mem.running = true
		M(pos):set_string("infotext", "On")
		-- last command!!!
		consumer.turn_power_on(pos, POWER_CONSUMPTION)
	else
		swap_node(pos, "techage:lamp")
		mem.running = false
		M(pos):set_string("infotext", "Off")
		-- last command!!!
		consumer.turn_power_on(pos, 0)
	end
end

minetest.register_node("techage:lamp", {
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
		power_network = Cable,
		power_side = "L",
		valid_power_dir = valid_power_dir,
	},
	
	after_place_node = consumer.after_place_node,
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

minetest.register_node("techage:lamp_on", {
	description = "TechAge Lamp",
	tiles = {
		'techage_electric_button.png',
	},
	techage = {
		turn_on = lamp_turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Cable,
		valid_power_dir = valid_power_dir,
	},
	
	after_tube_update = consumer.after_tube_update,
	after_dig_node = consumer.after_dig_node,
	on_rightclick = lamp_on_rightclick,

	paramtype = "light",
	light_source = LIGHT_MAX,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drop = "techage:lamp",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function generator_turn_on_clbk(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	if sum > 0 then
		-- No automatic turn on
	else
		M(pos):set_string("infotext", "Err: "..sum.." / "..8)
	end
end	

local function generator_on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.running then
		generator.turn_power_on(pos, POWER_CAPACITY)
		mem.running = true
		M(pos):set_string("infotext", "On")
	else
		generator.turn_power_on(pos, 0)
		mem.running = false
		M(pos):set_string("infotext", "Off")
	end
end

minetest.register_node("techage:power", {
	description = "TechAge Power",
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png^techage_electric_plug.png',
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png',
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	techage = {
		read_power_consumption = generator.read_power_consumption,
		power_network = Cable,
	},
	
	after_place_node = generator.after_place_node,
	after_tube_update = generator.after_tube_update,	
	after_dig_node = generator.after_dig_node,
	on_rightclick = generator_on_rightclick,
})

