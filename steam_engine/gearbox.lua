--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
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
local consume_power = techage.power.consume_power

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos)
	local mem = tubelib2.get_mem(pos)
	mem.node_loaded = (mem.node_loaded or 1) - 1
	if mem.node_loaded >= 0 then
		local got = consume_power(pos, PWR_NEEDED)
		if got < PWR_NEEDED and mem.node_on then
			swap_node(pos, "techage:gearbox")
			techage.switch_axles(pos, false)
			mem.node_on = false
		elseif not mem.node_on then
			swap_node(pos, "techage:gearbox_on")
			techage.switch_axles(pos, true)
			mem.node_on = true
		end
		mem.power_available = true
	end
end


local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.node_on and not mem.power_available then
		swap_node(pos, "techage:gearbox")
		techage.switch_axles(pos, false)
		mem.node_on = false
	end
	mem.power_available = false
	mem.node_loaded = CYCLE_TIME/2 + 1
	return true
end

local function on_rightclick(pos, node, clicker)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

minetest.register_node("techage:gearbox", {
	description = S("TA2 Gearbox"),
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
	on_power = on_power,
})
	
minetest.register_craft({
	output = "techage:gearbox 2",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "techage:iron_ingot", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})
