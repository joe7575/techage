--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Steam Engine Cylinder

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local Pipe = techage.SteamPipe

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

-- called from flywheel
local function start_cylinder(pos, on)
	local mem = tubelib2.get_mem(pos)
	if on and mem.running then
		swap_node(pos, "techage:cylinder_on")
		techage.power.power_distribution(pos)
		return true
	else
		swap_node(pos, "techage:cylinder")
		techage.power.power_distribution(pos)
		return false
	end
end	

-- called with any pipe change
local function after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	mem.running = false
end

minetest.register_node("techage:cylinder", {
	description = I("TA2 Cylinder"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_steam_hole.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
	},
	
	on_construct = tubelib2.init_mem,
	start_cylinder = start_cylinder,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:cylinder_on", {
	description = I("TA2 Cylinder"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_steam_hole.png",
		{
			image = "techage_filling4_ta2.png^techage_cylinder4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta2.png^techage_cylinder4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	
	start_cylinder = start_cylinder,
	after_tube_update = after_tube_update,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:cylinder", "techage:cylinder_on"}, {
	conn_sides = {"L"},
	power_network  = Pipe,
})

-- used by firebox
techage.register_node({"techage:cylinder", "techage:cylinder_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if  topic == "start" then
			mem.running = true
			return true
		elseif topic == "stop" then
			mem.running = false
			return false
		end
	end
})

minetest.register_craft({
	output = "techage:cylinder",
	recipe = {
		{"basic_materials:steel_bar", "techage:iron_ingot", "default:wood"},
		{"techage:steam_pipeS", "basic_materials:gear_steel", ""},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})

techage.register_help_page(I("TA2 Cylinder"), 
I([[Part of the steam engine.
Has to be placed side by side
with the TA2 Flywheel.
(see TA2 Steam Engine)]]), "techage:cylinder")
