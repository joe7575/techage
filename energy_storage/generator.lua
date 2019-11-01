--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Dummy Generator for the TES

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2

local Cable = techage.ElectricCable
local power = techage.power

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

-- to detect the missing turbine
local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	mem.remote_trigger = (mem.remote_trigger or 0) - 1
	if mem.remote_trigger <= 0 then
		swap_node(pos, "techage:ta4_generator")
		mem.running = false
	end
	return true
end

minetest.register_node("techage:ta4_generator", {
	description = S("TA4 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_hole_electric.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_generator.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_generator.png^[transformFX]",
	},
	on_timer = node_timer,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta4_generator_on", {
	description = S("TA4 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_hole_electric.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta4.png",
		{
			image = "techage_filling4_ta4.png^techage_appl_generator4.png^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_appl_generator4.png^[transformFX]^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},
	
	on_rightclick = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
	
	on_timer = node_timer,
	drop = "",
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:ta4_generator",
	recipe = {
		{"", "dye:blue", ""},
		{"", "techage:generator", ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})

-- need a dummy power connection
techage.power.register_node({"techage:ta4_generator", "techage:ta4_generator_on"}, {
	conn_sides = {"R"},
	power_network = Cable,
	after_place_node = function(pos, placer)
		local mem = tubelib2.init_mem(pos)
		mem.running = false
		mem.remote_trigger = 0
	end,

})

-- controlled by the turbine
techage.register_node({"techage:ta4_generator", "techage:ta4_generator_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "power" then
			mem.remote_trigger = 2
			return techage.power.power_network_available(pos)
		elseif topic == "start" then
			mem.remote_trigger = 2
			swap_node(pos, "techage:ta4_generator_on")
			mem.running = true
			minetest.get_node_timer(pos):start(CYCLE_TIME)
			return true
		elseif topic == "stop" then
			swap_node(pos, "techage:ta4_generator")
			mem.running = false
			mem.remote_trigger = 0
			minetest.get_node_timer(pos):stop()
			return true
		elseif topic == "trigger" then
			mem.remote_trigger = 2
			return true
		end
	end,
})

