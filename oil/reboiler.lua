--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

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

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_reboiler", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 15,
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

local function swap_node(pos, on)
	local nvm = techage.get_nvm(pos)
	if on then
		local node = techage.get_node_lvm(pos)
		node.name = "techage:ta3_reboiler_on"
		minetest.swap_node(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		play_sound(pos)
	elseif not on and nvm.running then
		local node = techage.get_node_lvm(pos)
		node.name = "techage:ta3_reboiler"
		minetest.swap_node(pos, node)
		minetest.get_node_timer(pos):stop()
		nvm.running = false
		power.consumer_stop(pos, Cable)
		stop_sound(pos)
	end
end

local function on_power(pos)
	swap_node(pos, true)
end

local function on_nopower(pos)
	swap_node(pos, false)
end

local function is_running(pos, nvm) 
	return nvm.running 
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
	local nvm = techage.get_nvm(pos)
	if nvm.running then return end
	
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	if nvm.liquid.amount >= 5 and nvm.liquid.name == "techage:oil_source" then
		if power.power_available(pos, Cable) then
			nvm.running = true
			power.consumer_start(pos, Cable, CYCLE_TIME)
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end
end
	
local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	
	if not nvm.error or nvm.error == 0 then
		power.consumer_alive(pos, Cable, CYCLE_TIME)
	end
	
	if nvm.liquid.amount >= 5 and nvm.liquid.name == "techage:oil_source" then
		nvm.liquid.amount = nvm.liquid.amount - 5
		local leftover = pump_cmnd(pos, "put")
		if (tonumber(leftover) or 1) > 0 then
			nvm.liquid.amount = nvm.liquid.amount + 5
			nvm.error = 2 -- = 2 pump cycles
			M(pos):set_string("infotext", S("TA3 Oil Reboiler: blocked"))
			swap_node(pos, false)
			return false
		end
		return true
	end
	swap_node(pos, false)
	return false
end	

local function after_place_node(pos)
	Pipe:after_place_node(pos)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Pipe:after_dig_node(pos)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	if tlib2.tube_type == "pipe2" then
		liquid.update_network(pos, outdir, tlib2)
	else
		power.update_network(pos, outdir, tlib2)
	end
end

local liquid_def = {
	capa = CAPA,
	peek = liquid.srv_peek,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		if nvm.error and nvm.error > 0 then
			nvm.error = nvm.error - 1
			if nvm.error <= 0 then
				M(pos):set_string("infotext", S("TA3 Oil Reboiler"))
				start_node(pos)
				return liquid.srv_put(pos, indir, name, amount)
			else
				return amount
			end
		else
			start_node(pos)
			return liquid.srv_put(pos, indir, name, amount)
		end
	end,
	take = liquid.srv_take,
}

local net_def = {
	pipe2 = {
		sides = {L = true, R = true}, -- Pipe connection sides
		ntype = "tank",
	},
	ele1 = {
		sides = techage.networks.AllSides, -- Cable connection sides
		ntype = "con1",
		on_power = on_power,
		on_nopower = on_nopower,
		nominal = PWR_NEEDED,
		is_running = is_running,
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
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local meta = M(pos)
		meta:set_string("infotext", S("TA3 Oil Reboiler"))
		meta:set_int("outdir", networks.side_to_outdir(pos, "R"))
		local number = techage.add_node(pos, "techage:ta3_reboiler")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		Pipe:after_place_node(pos)
		power.after_place_node(pos)
	end,
	
	tubelib2_on_update2 = tubelib2_on_update2,
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	after_dig_node = after_dig_node,
	liquid = liquid_def,
	networks = net_def,
	
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
	liquid = liquid_def,
	networks = net_def,
	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:ta3_reboiler", "techage:ta3_reboiler_on"})
Cable:add_secondary_node_names({"techage:ta3_reboiler", "techage:ta3_reboiler_on"})

techage.register_node({"techage:ta3_reboiler", "techage:ta3_reboiler_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "on" then
			start_node(pos)
			return true
		elseif topic == "off" then
			swap_node(pos, false)
			return true
		elseif topic == "state" then
			if nvm.error and nvm.error > 0 then
				return "blocked"
			elseif nvm.running then
				return "running"
			end
			return "stopped"
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos, node)
		if node.name == "techage:ta3_reboiler_on" then
			play_sound(pos)
		end	
	end,
})

minetest.register_craft({
	output = "techage:ta3_reboiler",
	recipe = {
		{"", "basic_materials:heating_element", ""},
		{"default:mese_crystal_fragment", "techage:t3_pump", "default:mese_crystal_fragment"},
		{"", "basic_materials:heating_element", ""},
	},
})

