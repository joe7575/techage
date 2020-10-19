--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA2 Gearbox

]]--

-- for lazy programmers
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local PWR_NEEDED = 1
local CYCLE_TIME = 4

local Axle = techage.Axle
local power = techage.power
local networks = techage.networks

-- Axles texture animation
local function switch_axles(pos, on)
	for _,outdir in ipairs(networks.get_node_connections(pos, "axle")) do
		Axle:switch_tube_line(pos, outdir, on and "on" or "off")
	end
end

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos)
	swap_node(pos, "techage:gearbox_on")
	switch_axles(pos, true)
end

local function on_nopower(pos)
	swap_node(pos, "techage:gearbox")
	switch_axles(pos, false)
end

local function node_timer(pos, elapsed)
	power.consumer_alive(pos, Axle, CYCLE_TIME)
	return true
end

-- to be able to restart the node after server crashes
local function techage_on_repair(pos)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	power.consumer_start(pos, Axle, CYCLE_TIME)
end

local function after_place_node(pos)
	Axle:after_place_node(pos)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	power.consumer_start(pos, Axle, CYCLE_TIME)
end

local function after_dig_node(pos, oldnode)
	Axle:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, nil, tlib2)
end

local net_def = {
	axle = {
		sides = techage.networks.AllSides, -- Cable connection sides
		ntype = {"con1", "junc"},
		on_power = on_power,
		on_nopower = on_nopower,
		nominal = PWR_NEEDED,
	},
}

minetest.register_node("techage:gearbox", {
	description = S("TA2 Gearbox"),
	tiles = {"techage_filling_ta2.png^techage_axle_gearbox.png^techage_frame_ta2.png"},
	
	on_timer = node_timer,
	techage_on_repair = techage_on_repair,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,

	paramtype = "light",
	light_source = 0,	
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
	
	on_timer = node_timer,
	techage_on_repair = techage_on_repair,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	drop = "",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Axle:add_secondary_node_names({"techage:gearbox", "techage:gearbox_on"})
	
minetest.register_craft({
	output = "techage:gearbox 2",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "techage:iron_ingot", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})

