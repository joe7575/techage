--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Consumer

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local POWER_CONSUMPTION = 4

local Axle = techage.Axle
local consumer = techage.consumer

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

-- To be able to check if power connection is on the 
-- correct node side (power_dir == in_dir)
local function valid_power_dir(pos, power_dir, in_dir)
	return power_dir == in_dir
end

local function turn_on_clbk(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	if sum > 0 then
		swap_node(pos, "techage:consumer_on")
	else
		swap_node(pos, "techage:consumer")
	end
end	

minetest.register_node("techage:consumer", {
	description = "TechAge Consumer",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta2.png^techage_frame_ta2.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
		'techage_filling_ta2.png^techage_frame_ta2.png^techage_axle_clutch.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
	},
	techage = {
		turn_on = turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Axle,
		power_side = "L",
		valid_power_dir = valid_power_dir,
		animated_power_network = true,
	},
	
	after_place_node = function(pos, placer)
		local mem = consumer.after_place_node(pos, placer)
		mem.power_consumption = POWER_CONSUMPTION
	end,
	
	after_tube_update = consumer.after_tube_update,
	after_dig_node = consumer.after_dig_node,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:consumer_on", {
	description = "TechAge Consumer",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta2.png^techage_frame_ta2.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
		{
			image = "techage_filling4_ta2.png^techage_frame4_ta2.png^techage_appl_compressor4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		'techage_filling_ta2.png^techage_frame_ta2.png^techage_axle_clutch.png',
		{
			image = "techage_filling4_ta2.png^techage_frame4_ta2.png^techage_appl_compressor4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			image = "techage_filling4_ta2.png^techage_frame4_ta2.png^techage_appl_compressor4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
	},
	techage = {
		turn_on = turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Axle,
		power_side = "L",
		valid_power_dir = valid_power_dir,
		animated_power_network = true,
	},
	
	after_tube_update = consumer.after_tube_update,
	after_dig_node = consumer.after_dig_node,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	drop = "techage:consumer",
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

