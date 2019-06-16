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

local PWR_NEEDED = 1
local CYCLE_TIME = 2

local Axle = techage.Axle
local consume_power = techage.power.consume_power

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local got = consume_power(pos, PWR_NEEDED)
	if mem.running and got < PWR_NEEDED then
		swap_node(pos, "techage:gearbox")
		techage.switch_axles(pos, false)
		mem.running = false
	elseif not mem.running and got == PWR_NEEDED then
		swap_node(pos, "techage:gearbox_on")
		techage.switch_axles(pos, true)
		mem.running = true
	end
	return true
end

local function on_rightclick(pos, node, clicker)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

minetest.register_node("techage:gearbox", {
	description = I("TA2 Gearbox"),
	tiles = {"techage_filling_ta2.png^techage_axle_gearbox.png^techage_frame_ta2.png"},
	
	on_construct = tubelib2.init_mem,
	after_place_node = after_place_node,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
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
	
	after_place_node = after_place_node,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	drop = "",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:gearbox", "techage:gearbox_on"}, {
	power_network  = Axle,
})
	
minetest.register_craft({
	output = "techage:gearbox 2",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "techage:iron_ingot", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})
