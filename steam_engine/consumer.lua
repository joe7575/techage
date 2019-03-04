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

local POWER_CONSUME = 4


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
	return mem.power_dir == in_dir
end

local function turn_on(pos, in_dir, on)
		if on then
			swap_node(pos, "techage:consumer_on")
		else
			swap_node(pos, "techage:consumer")
		end
--	end
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
		turn_on = turn_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.Axle,
		power_consume = POWER_CONSUME,
		animated_power_network = true,
		power_side = "L",
		valid_power_dir = valid_power_dir,
		
	},
	
	after_place_node = function(pos, placer)
		local mem = techage.consumer_after_place_node(pos, placer)
		mem.power_consume = POWER_CONSUME
	end,
	
	after_tube_update = techage.consumer_after_tube_update,
	after_dig_node = techage.consumer_after_dig_node,

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
		turn_on = turn_on,
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.Axle,
		power_consume = POWER_CONSUME,
		animated_power_network = true,
		valid_power_dir = valid_power_dir,
	},
	
	after_place_node = techage.consumer_after_place_node,
	after_tube_update = techage.consumer_after_tube_update,
	after_dig_node = techage.consumer_after_dig_node,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	drop = "techage:consumer",
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

