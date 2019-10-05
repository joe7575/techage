--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA2 Steam Engine Cylinder

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.SteamPipe

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

minetest.register_node("techage:cylinder", {
	description = S("TA2 Cylinder"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_steam_hole.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
	},
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:cylinder_on", {
	description = S("TA2 Cylinder"),
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
	after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
		local mem = tubelib2.get_mem(pos)
		mem.running = false
		swap_node(pos, "techage:cylinder")
	end,
})

-- used by firebox
techage.register_node({"techage:cylinder", "techage:cylinder_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "trigger" then
			local power = techage.transfer(pos, "R", "trigger", nil, nil, {
						"techage:flywheel", "techage:flywheel_on"}) or 0

			if not power then
				return 0
			elseif power > 0 and not mem.running then
				swap_node(pos, "techage:cylinder_on")
				mem.running = true
				return power
			elseif power <= 0 and mem.running then
				swap_node(pos, "techage:cylinder")
				mem.running = false
				return 0
			else
				return power
			end
		elseif topic == "stop" then
			swap_node(pos, "techage:cylinder")
			mem.running = false
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

