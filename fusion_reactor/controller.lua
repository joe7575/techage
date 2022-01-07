--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fusion Reactor Controller

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local Pipe = techage.GasPipe
local power = networks.power
local liquid = networks.liquid
local control = networks.control

minetest.register_node("techage:ta5_fr_controller", {
	description = "TA5 Fusion Reactor Controller",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
	},
	after_place_node = function(pos, placer, itemstack)
		minetest.get_node_timer(pos):start(2)
		Cable:after_place_node(pos)
	end,
	on_timer = function(pos)
		local node = minetest.get_node(pos) or {}
		local outdir = networks.side_to_outdir(pos, "R")
		local mem = techage.get_mem(pos)
		mem.idx = ((mem.idx or 0) + 1) % 4
		local cmnd = ({[0]= "test_plasma", "test_shell", "on", "off"})[mem.idx]
		if mem.idx <= 1 then
			local resp = control.request(
				pos, 
				Cable, 
				outdir, 
				"con", 
				cmnd)
			print(dump(resp))
		else
			local resp = control.send(
				pos, 
				Cable, 
				outdir, 
				"con", 
				cmnd)
			print(dump(resp))
		end
		return true
	end,
	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

power.register_nodes({"techage:ta5_fr_controller"}, Cable, "con", {"L", "R"})