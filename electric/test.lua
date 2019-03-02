-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local POWER_CONSUME = 1


local Cable = techage.ElectricCable

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function lamp_turn_on(pos, dir, on)
--	local mem = tubelib2.get_mem(pos)
--	if mem.power_dir == dir or  mem.power_dir == tubelib2.Turn180Deg[dir] then
		if on then
			swap_node(pos, "techage:lamp_on")
		else
			swap_node(pos, "techage:lamp")
		end
--	end
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
		turn_on = lamp_turn_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.ElectricCable,
		power_consume = POWER_CONSUME,
		power_side = 'B',
	},
	
	after_place_node = techage.consumer_after_place_node,
	after_tube_update = techage.consumer_after_tube_update,
	on_destruct = techage.consumer_on_destruct,
	after_dig_node = techage.consumer_after_dig_node,

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
		turn_on = lamp_turn_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.ElectricCable,
		power_consume = POWER_CONSUME,
	},
	
	after_place_node = techage.consumer_after_place_node,
	after_tube_update = techage.consumer_after_tube_update,
	on_destruct = techage.consumer_on_destruct,
	after_dig_node = techage.consumer_after_dig_node,

	paramtype = "light",
	light_source = LIGHT_MAX,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drop = "techage:lamp",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


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
		power_network = Cable,
		power_consumption = techage.generator_power_consumption,
	},
	
	after_place_node = techage.generator_after_place_node,
	after_tube_update = techage.generator_after_tube_update,	
	on_destruct = techage.generator_on_destruct,
	after_dig_node = techage.generator_after_dig_node,

	on_rightclick = function(pos, node, clicker)
		local mem = tubelib2.get_mem(pos)
		print("on_rightclick", mem.power)
		if mem.power_produce and mem.power_produce > 0 then
			techage.generator_off(pos)
		else
			techage.generator_on(pos, 8)
		end
	end,
})

