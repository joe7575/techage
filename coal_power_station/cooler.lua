--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Cooler

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.SteamPipe

local function transfer(pos, in_dir, topic, payload)
	return techage.transfer(pos, in_dir, topic, payload, Pipe, 
			{"techage:coalboiler_base"})
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

minetest.register_node("techage:cooler", {
	description = S("TA3 Cooler"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_appl_cooler.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_cooler.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
	},
	
	on_construct = tubelib2.init_mem,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:cooler_on", {
	tiles = {
		-- up, down, right, left, back, front
		{
			image = "techage_filling4_ta3.png^techage_appl_cooler4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_cooler4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
	},
	
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

-- for mechanical pipe connections
techage.power.register_node({"techage:cooler", "techage:cooler_on"}, {
	conn_sides = {"L", "R"},
	power_network = Pipe,
	after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
		swap_node(pos, "techage:cooler")
	end,
})

-- for logical communication
techage.register_node({"techage:cooler", "techage:cooler_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "start" then
			if transfer(pos, in_dir, topic, nil) then
				swap_node(pos, "techage:cooler_on")
				return true
			end
		elseif topic == "stop" then
			swap_node(pos, "techage:cooler")
			return transfer(pos, in_dir, topic, nil)
		elseif topic == "running" then
			if transfer(pos, in_dir, topic, nil) then
				return true
			end
			swap_node(pos, "techage:cooler")
		end
		return false
	end
})

minetest.register_craft({
	output = "techage:cooler",
	recipe = {
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
		{"techage:steam_pipeS", "basic_materials:gear_steel", "techage:steam_pipeS"},
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
	},
})

