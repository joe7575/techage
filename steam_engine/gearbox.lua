--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA2 Gearbox

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local PWR_NEEDED = 1
local CYCLE_TIME = 4

local Axle = techage.Axle
local power = techage.power

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos, mem)
	swap_node(pos, "techage:gearbox_on")
	techage.switch_axles(pos, true)
end

local function on_nopower(pos, mem)
	swap_node(pos, "techage:gearbox")
	techage.switch_axles(pos, false)
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	power.consumer_alive(pos, mem)
	return true
end

-- to be able to restart the node after server crashes
local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	power.consumer_start(pos, mem, CYCLE_TIME, PWR_NEEDED)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	-- secondary 'after_place_node', called by power. Don't use tubelib2.init_mem(pos)!!!
	local mem = tubelib2.get_mem(pos)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	power.consumer_start(pos, mem, CYCLE_TIME, PWR_NEEDED)
end

local function after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	techage.switch_axles(pos, node.name == "techage:gearbox_on")
end

minetest.register_node("techage:gearbox", {
	description = S("TA2 Gearbox"),
	tiles = {"techage_filling_ta2.png^techage_axle_gearbox.png^techage_frame_ta2.png"},
	
	on_construct = tubelib2.init_mem,
	after_place_node = after_place_node,
	on_rightclick = on_rightclick,
	after_tube_update = after_tube_update,
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
	after_tube_update = after_tube_update,
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
	on_power = on_power,
	on_nopower = on_nopower,
})
	
minetest.register_craft({
	output = "techage:gearbox 2",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "techage:iron_ingot", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})
