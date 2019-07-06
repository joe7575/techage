--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Power Station Turbine

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.SteamPipe

local function transfer_cooler(pos, topic, payload)
	return techage.transfer(pos, 6, topic, payload, Pipe, 
			{"techage:cooler", "techage:cooler_on"})
end

local function transfer_generator(pos, topic, payload)
	return techage.transfer(pos, "R", topic, payload, nil, 
			{"techage:generator", "techage:generator_on"})
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function play_sound(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		mem.handle = minetest.sound_play("techage_turbine", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 15})
		minetest.after(2, play_sound, pos)
	end
end

local function stop_sound(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.running and mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

-- called with any pipe change
local function after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	transfer_cooler(pos, "stop", nil)
	swap_node(pos, "techage:turbine")
	mem.running = false
	stop_sound(pos)
end

minetest.register_node("techage:turbine", {
	description = S("TA3 Turbine"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_appl_turbine.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_turbine.png^techage_frame_ta3.png",
	},
	on_construct = tubelib2.init_mem,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:turbine_on", {
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_turbine4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_turbine4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	after_tube_update = after_tube_update,
	
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

-- for mechanical pipe connections
techage.power.register_node({"techage:turbine", "techage:turbine_on"}, {
	conn_sides = {"L", "U"},
	power_network  = Pipe,
})

-- for logical communication
techage.register_node({"techage:turbine", "techage:turbine_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		--print("turbine", topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "trigger" then
			return transfer_generator(pos, topic, payload)
		elseif topic == "start" then
			if transfer_cooler(pos, topic, payload) then
				swap_node(pos, "techage:turbine_on")
				mem.running = true
				play_sound(pos)
				return true
			end
			return false
		elseif topic == "running" then
			if not transfer_cooler(pos, topic, payload) then
				swap_node(pos, "techage:turbine")
				mem.running = false
				stop_sound(pos)
				return false
			end
			return true
		elseif topic == "stop" then
			transfer_cooler(pos, topic, payload)
			swap_node(pos, "techage:turbine")
			mem.running = false
			stop_sound(pos)
			return true
		end
	end
})

minetest.register_craft({
	output = "techage:turbine",
	recipe = {
		{"basic_materials:steel_bar", "techage:steam_pipeS", "default:wood"},
		{"techage:steam_pipeS", "basic_materials:gear_steel", ""},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})

techage.register_entry_page("ta3ps", "turbine",
	S("TA3 Turbine"), 
	S("Part of the Power Station. Has to be placed side by side with the TA3 Generator.@n"..
		"(see TA3 Power Station)"), 
	"techage:turbine")

minetest.register_lbm({
	label = "[techage] Turbine sound",
	name = "techage:power_station",
	nodenames = {"techage:turbine_on"},
	run_at_every_load = true,
	action = function(pos, node)
		play_sound(pos)
	end
})
