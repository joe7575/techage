--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Pump

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local networks = techage.networks

minetest.register_node("techage:ta4_pump", {
	description = S("TA4 Pump"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_hole_biogas.png^techage_appl_color_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_pump.png^techage_appl_hole_biogas.png",
	},
	after_place_node = function(pos, placer)
		M(pos):set_int("pipe_dir", networks.side_to_outdir(pos, "R"))
		Pipe:after_place_node(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_timer = function(pos, elapsed)
--		networks.connection_walk(pos, Pipe, function(pos, node)
--				print("on_timer", P2S(pos), node.name)
--			end)
		local mem = tubelib2.get_mem(pos)
		local nw = networks.get_network(pos, Pipe)
		if nw then
			for _,pos in ipairs(nw.tank or {}) do
				techage.mark_position("singleplayer", pos, "", "", 3)
			end
		end
		return true
	end,
	tubelib2_on_update2 = function(pos, node, tlib2)
		networks.update_network(pos, tlib2)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	networks = {
		pipe = {
			sides = {R = 1}, -- Pipe connection side
			ntype = "pump",
		},
	},
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_pump_on", {
	description = S("TA4 Pump"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_hole_biogas.png^techage_appl_color_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		{
			image = "techage_filling8_ta4.png^techage_frame8_ta4.png^techage_appl_pump8.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

 Pipe:add_secondary_node_names({"techage:ta4_pump", "techage:ta4_pump_on"})