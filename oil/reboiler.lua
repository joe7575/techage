--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Oil Reboiler

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local networks = techage.networks
local liquid = techage.liquid
local Flip = techage.networks.Flip

local CYCLE_TIME = 4
local CAPA = 12

local function swap_node(pos)
	local node = techage.get_node_lvm(pos)
	if node.name == "techage:ta3_reboiler" then
		node.name = "techage:ta3_reboiler_on"
	else
		node.name = "techage:ta3_reboiler"
	end
	minetest.swap_node(pos, node)
end

--local function pumping(pos, mem, state, capa)
--	local outdir = M(pos):get_int("outdir")
--	local taken, name = liquid.take(pos, Flip[outdir], nil, capa)
--	if taken > 0 then
--		local leftover = liquid.put(pos, outdir, name, taken)
--		if leftover and leftover > 0 then
--			liquid.put(pos, Flip[outdir], name, leftover)
--			state:blocked(pos, mem)
--			return
--		end
--		state:keep_running(pos, mem, COUNTDOWN_TICKS)
--		return
--	end
--	state:idle(pos, mem)
--end

local function after_place_node(pos, placer)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	Pipe:after_place_node(pos)
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	pumping(pos, mem, State3, CAPA)
	return State3:is_active(mem)
end	

local function tubelib2_on_update2(pos, outdir, tlib2, node)
	liquid.update_network(pos, outdir)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
end

local _liquid = {
	capa = CAPA,
	peek = liquid.srv_peek,
	put = function(pos, indir, name, amount)
		--start timer
		return liquid.srv_put(pos, indir, name, amount)
	end,
	take = liquid.srv_take,
}

local _networks = {
	pipe = {
		sides = {L = true, R = true}, -- Pipe connection sides
		ntype = "tank",
	},
}

local function on_rightclick(pos, node, clicker)
	swap_node(pos)
end

minetest.register_node("techage:ta3_reboiler", {
	description = S("TA3 Oil Reboiler"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_reboiler.png^techage_frame_ta3.png^[transformFX",
		"techage_filling_ta3.png^techage_appl_reboiler.png^techage_frame_ta3.png",
	},

	after_place_node = function(pos, placer)
		local mem = tubelib2.init_mem(pos)
		mem.liquid = {}
		local meta = M(pos)
		meta:set_string("infotext", S("TA3 Oil Reboiler"))
		meta:set_int("outdir", networks.side_to_outdir(pos, "R"))
		Pipe:after_place_node(pos)
	end,
	
	tubelib2_on_update2 = tubelib2_on_update2,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	on_rightclick = on_rightclick,
	liquid = _liquid,
	networks = _networks,
	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta3_reboiler_on", {
	description = S("TA3 Oil Reboiler"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
	{
		image = "techage_filling4_ta3.png^techage_appl_reboiler4.png^techage_frame4_ta3.png^[transformFX",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	{
		image = "techage_filling4_ta3.png^techage_appl_reboiler4.png^techage_frame4_ta3.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	},

	tubelib2_on_update2 = tubelib2_on_update2,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	on_rightclick = on_rightclick,
	liquid = _liquid,
	networks = _networks,
	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:ta3_reboiler", "techage:ta3_reboiler_on"})
 
--minetest.register_craft({
--	output = "techage:t3_pump 2",
--	recipe = {
--		{"group:wood", "techage:iron_ingot", "group:wood"},
--		{"techage:ta3_pipeS", "techage:usmium_nuggets", "techage:ta3_pipeS"},
--		{"group:wood", "techage:iron_ingot", "group:wood"},
--	},
--})

--minetest.register_craft({
--	output = "techage:t4_pump",
--	recipe = {
--		{"default:tin_ingot", "dye:blue", "default:steel_ingot"},
--		{"", "techage:t3_pump", ""},
--		{"", "", ""},
--	},
--})
