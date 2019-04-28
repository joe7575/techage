--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Gearbox

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUMPTION = 1

local Axle = techage.Axle
local distributor = techage.distributor

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function turn_on(pos, dir, sum)
	if sum > 0 then
		swap_node(pos, "techage:gearbox_on")
	else
		swap_node(pos, "techage:gearbox")
	end
end

minetest.register_node("techage:gearbox", {
	description = I("TA2 Gearbox"),
	tiles = {"techage_filling_ta2.png^techage_axle_gearbox.png^techage_frame_ta2.png"},
	techage = {
		turn_on = turn_on,
		read_power_consumption = distributor.read_power_consumption,
		power_network = Axle,
		power_consumption = POWER_CONSUMPTION,
		animated_power_network = true,
	},
	
	after_place_node = distributor.after_place_node,
	after_tube_update = distributor.after_tube_update,
	after_dig_node = distributor.after_dig_node,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:gearbox_on", {
	tiles = {
		-- up, down, right, left, back, front
		{
			image = "techage_filling4_ta2.png^techage_axle_gearbox4.png^techage_frame4_ta2.png",
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
		read_power_consumption = distributor.read_power_consumption,
		power_network = Axle,
		power_consumption = POWER_CONSUMPTION,
		animated_power_network = true,
	},
	
	after_tube_update = distributor.after_tube_update,
	after_dig_node = distributor.after_dig_node,
	
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:gearbox 2",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "techage:iron_ingot", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})
