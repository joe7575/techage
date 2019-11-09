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
local Cable = techage.ElectricCable
local power = techage.power

local CYCLE_TIME = 6
local CAPA = 12
local PWR_NEEDED = 14

local function swap_node(pos, on)
	local mem = tubelib2.get_mem(pos)
	if on then
		local node = techage.get_node_lvm(pos)
		node.name = "techage:ta3_reboiler_on"
		minetest.swap_node(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		minetest.sound_play("techage_reboiler", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 10})
	elseif not on and mem.running then
		local node = techage.get_node_lvm(pos)
		node.name = "techage:ta3_reboiler"
		minetest.swap_node(pos, node)
		minetest.get_node_timer(pos):stop()
		mem.running = false
		power.consumer_stop(pos, mem)
	end
end

local function on_power(pos, mem)
	if mem.running then
		swap_node(pos, true)
	end
end

local function on_nopower(pos, mem)
	swap_node(pos, false)
end

local function pump_cmnd(pos, cmnd, payload)
	return techage.transfer(
		pos, 
		"R",  -- outdir
		cmnd,  -- topic
		payload,  -- payload
		Pipe,  -- Pipe
		{"techage:ta3_distiller1"})
end

local function start_node(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.running then return end
	
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	if mem.liquid.amount >= 5 and mem.liquid.name == "techage:oil_source" then
		if power.power_available(pos, mem, PWR_NEEDED) then
			mem.running = true
			power.consumer_start(pos, mem, CYCLE_TIME, PWR_NEEDED)
		end
	end
end
	
local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	
	power.consumer_alive(pos, mem)
	
	if mem.liquid.amount >= 5 and mem.liquid.name == "techage:oil_source" then
		mem.liquid.amount = mem.liquid.amount - 5
		local leftover = pump_cmnd(pos, "put")
		if leftover > 0 then
			swap_node(pos, false)
			return false
		end
		minetest.sound_play("techage_reboiler", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 10})
		return true
	end
	swap_node(pos, false)
	return false
end	

-- liquid
local function tubelib2_on_update2(pos, outdir, tlib2, node)
	liquid.update_network(pos, outdir)
end

-- power
local function after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir) 
	power.after_tube_update2(node, pos, out_dir, peer_pos, peer_in_dir)
end


local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
	power.after_dig_node(pos, oldnode)
	tubelib2.del_mem(pos)
end

local _liquid = {
	capa = CAPA,
	peek = liquid.srv_peek,
	put = function(pos, indir, name, amount)
		start_node(pos)
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
		power.after_place_node(pos)
	end,
	
	tubelib2_on_update2 = tubelib2_on_update2, -- liquid
	after_tube_update = after_tube_update, -- power
	on_timer = node_timer,
	after_dig_node = after_dig_node,
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

	tubelib2_on_update2 = tubelib2_on_update2, -- liquid
	after_tube_update = after_tube_update, -- power
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	liquid = _liquid,
	networks = _networks,
	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

--
-- Liquids
--
Pipe:add_secondary_node_names({"techage:ta3_reboiler", "techage:ta3_reboiler_on"})
 
--
-- Power
--
techage.power.enrich_node({"techage:ta3_reboiler", "techage:ta3_reboiler_on"}, {
	power_network = Cable,
	on_power = on_power,
	on_nopower = on_nopower,
})

minetest.register_craft({
	output = "techage:ta3_reboiler",
	recipe = {
		{"", "basic_materials:heating_element", ""},
		{"default:mese_crystal_fragment", "techage:t3_pump", "default:mese_crystal_fragment"},
		{"", "basic_materials:heating_element", ""},
	},
})

