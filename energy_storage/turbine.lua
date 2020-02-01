--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Gas Turbine

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2

local Pipe = techage.LiquidPipe

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_turbine", {
			pos = pos, 
			gain = 0.5,
			max_hear_distance = 10,
			loop = true})
		if mem.handle == -1 then
			minetest.after(1, play_sound, pos)
		end
	end
end

local function stop_sound(pos)
	local mem = techage.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function generator_cmnd(pos, cmnd)
	return techage.transfer(
		pos, 
		"R",  -- outdir
		cmnd,  -- topic
		nil,  -- payload
		nil,  -- network
		{"techage:ta4_generator", "techage:ta4_generator_on"})
end

-- to detect the missing "steam pressure"
local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.remote_trigger = (nvm.remote_trigger or 0) - 1
	if nvm.remote_trigger <= 0 then
		swap_node(pos, "techage:ta4_turbine")
		stop_sound(pos)
		nvm.running = false
	end
	play_sound(pos)
	return true
end


minetest.register_node("techage:ta4_turbine", {
	description = S("TA4 Turbine"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_appl_turbine.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_turbine.png^techage_frame_ta4.png",
	},
	on_timer = node_timer,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta4_turbine_on", {
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		{
			image = "techage_filling4_ta4.png^techage_appl_turbine4.png^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_appl_turbine4.png^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
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

-- for mechanical pipe connections
techage.power.register_node({"techage:ta4_turbine", "techage:ta4_turbine_on"}, {
	conn_sides = {"L", "U"},
	power_network  = Pipe,
	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		nvm.running = false
		nvm.remote_trigger = 0
	end,
})

-- for logical communication
techage.register_node({"techage:ta4_turbine", "techage:ta4_turbine_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "power" then
			nvm.remote_trigger = 2
			return generator_cmnd(pos, topic)
		elseif topic == "start" then
			nvm.remote_trigger = 2
			swap_node(pos, "techage:ta4_turbine_on")
			nvm.running = true
			minetest.get_node_timer(pos):start(CYCLE_TIME)
			play_sound(pos)
			return generator_cmnd(pos, topic)
		elseif topic == "stop" then
			swap_node(pos, "techage:ta4_turbine")
			nvm.running = false
			nvm.remote_trigger = 0
			minetest.get_node_timer(pos):stop()
			stop_sound(pos)
			return generator_cmnd(pos, topic)
		elseif topic == "trigger" then
			nvm.remote_trigger = 2
			return generator_cmnd(pos, topic)
		end
	end
})

minetest.register_craft({
	output = "techage:ta4_turbine",
	recipe = {
		{"", "dye:blue", ""},
		{"", "techage:turbine", ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})

