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

-- To be able to check if power connection is on the 
-- correct node side (mem.power_dir == in_dir)
local function valid_power_dir(pos, mem, in_dir)
	print("valid_power_dir", mem.power_dir, in_dir)
	return true
end

local function lamp_turn_on(pos, in_dir, on)
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
		power_side = "L",
		valid_power_dir = valid_power_dir,
		
	},
	
	after_place_node = function(pos, placer)
		local mem = techage.consumer_after_place_node(pos, placer)
		mem.power_consume = POWER_CONSUME
	end,
	
	after_tube_update = techage.consumer_after_tube_update,
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
		valid_power_dir = valid_power_dir,
	},
	
	after_place_node = techage.consumer_after_place_node,
	after_tube_update = techage.consumer_after_tube_update,
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

