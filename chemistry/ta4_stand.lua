--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Reactor Stand and Base

]]--

local S = techage.S
local M = minetest.get_meta
local Cable = techage.ElectricCable
local power = techage.power
local Pipe = techage.LiquidPipe
local networks = techage.networks
local liquid = techage.liquid

local PWR_NEEDED = 8
local CYCLE_TIME = 4

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_reactor", {
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

local function on_power(pos)
	M(pos):set_string("infotext", S("on"))
	play_sound(pos)
	local nvm = techage.get_nvm(pos)
	nvm.has_power = true
end

local function on_nopower(pos)
	M(pos):set_string("infotext", S("no power"))
	stop_sound(pos)
	local nvm = techage.get_nvm(pos)
	nvm.has_power = false
end

minetest.register_node("techage:ta4_reactor_stand", {
	description = S("TA4 Reactor Stand"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_reactor_stand_top.png^[transformR90",
		"techage_reactor_stand_bottom.png^[transformFY^[transformR270",
		"techage_reactor_stand_front.png",
		"techage_reactor_stand_back.png",
		"techage_reactor_stand_side.png^[transformFX",
		"techage_reactor_stand_side.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {	
			{ -8/16,  2/16, -8/16,   8/16, 4/16,   8/16 },
			
			{ -8/16, -8/16, -8/16,  -6/16,  8/16, -6/16 },
			{  6/16, -8/16, -8/16,   8/16,  8/16, -6/16 },
			{ -8/16, -8/16,  6/16,  -6/16,  8/16,  8/16 },
			{  6/16, -8/16,  6/16,   8/16,  8/16,  8/16 },
			
			{-1/8, -4/8, -1/8,   1/8, 4/8, 1/8},
			{-4/8, -1/8, -1/8,   4/8, 1/8,  1/8},
			{-4/8, -1/8, -3/8,  -3/8, 1/8,  3/8},
			{ 3/8, -1/8, -3/8,   4/8, 1/8,  3/8},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	
	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("infotext", S("off"))
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		if tlib2.tube_type == "ele1" then
			power.update_network(pos, dir, tlib2)
		else
			liquid.update_network(pos, dir, tlib2)
		end
	end,
	on_timer = function(pos, elapsed)
		power.consumer_alive(pos, Cable, CYCLE_TIME)
		return true
	end,
	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	
	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	networks = {
		pipe2 = {
			sides = {R=1}, 
			ntype = "pump",
		},
		ele1 = {
			sides = {L=1},
			ntype = "con1",
			on_power = on_power,
			on_nopower = on_nopower,
			nominal = PWR_NEEDED,
		},
	},
})

-- controlled by the fillerpipe
techage.register_node({"techage:ta4_reactor_stand"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "power" then
			return nvm.has_power or power.power_available(pos, Cable)
		elseif topic == "output" then
			local outdir = M(pos):get_int("outdir")
			return liquid.put(pos, outdir, payload.name, payload.amount, payload.player_name)
		elseif topic == "can_start" then
			return power.power_available(pos, Cable)
		elseif topic == "start" then
			nvm.has_power = false
			power.consumer_start(pos, Cable, CYCLE_TIME)
			minetest.get_node_timer(pos):start(CYCLE_TIME)
			M(pos):set_string("infotext", "...")
			return true
		elseif topic == "stop" then
			nvm.has_power = false
			power.consumer_stop(pos, Cable)
			stop_sound(pos)
			minetest.get_node_timer(pos):stop()
			M(pos):set_string("infotext", S("off"))
			return true
		end
	end,
	on_node_load = function(pos, node)
		local nvm = techage.get_nvm(pos)
		if nvm.has_power then
			play_sound(pos)
		end	
	end,
})

minetest.register_node("techage:ta4_reactor_base", {
	description = S("TA4 Reactor Base"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_arrowXL.png^techage_appl_hole_pipe.png^[transformR270",
		"techage_concrete.png",
		"techage_concrete.png^techage_appl_hole_pipe.png",
		"techage_concrete.png",
		"techage_concrete.png",
		"techage_concrete.png",
	},
	
	after_place_node = function(pos, placer)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos, dir, tlib2)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	networks = {
		pipe2 = {
			sides = {R=1}, -- Pipe connection sides
			ntype = "pump",
		},
	},
})

Pipe:add_secondary_node_names({
		"techage:ta4_reactor_base", 
		"techage:ta4_reactor_stand",
})

Cable:add_secondary_node_names({"techage:ta4_reactor_stand"})

minetest.register_craft({
	output = 'techage:ta4_reactor_stand',
	recipe = {
		{'', 'dye:blue', ''},
		{'basic_materials:steel_bar', 'techage:ta3_pipeS', 'basic_materials:steel_bar'},
		{'basic_materials:steel_bar', '', 'basic_materials:steel_bar'},
	}
})

minetest.register_craft({
	output = 'techage:ta4_reactor_base',
	recipe = {
		{'basic_materials:concrete_block', '', ''},
		{'techage:ta3_pipeS', '', ''},
		{'', '', ''},
	}
})
