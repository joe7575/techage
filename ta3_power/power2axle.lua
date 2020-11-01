--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Electric Motor
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

local Cable = techage.ElectricCable
local Axle = techage.Axle
local power = techage.power
local networks = techage.networks

local CYCLE_TIME = 2
local PWR_PERF = 40

-- Axles texture animation
local function switch_axles(pos, on)
	for _,outdir in ipairs(networks.get_node_connections(pos, "axle")) do
		Axle:switch_tube_line(pos, outdir, on and "on" or "off")
	end
end

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos)
	local nvm = techage.get_nvm(pos)
	nvm.ele1 = nvm.ele1 or {}
	nvm.consumer_powered = true
	M(pos):set_string("infotext", S("TA3 Electric Motor"))
	swap_node(pos, "techage:ta3_motor_on")
	nvm.ticks = 0
	local outdir = M(pos):get_int("outdir")
	nvm.ele1.curr_power = techage.power.needed_power(pos, Axle, outdir)
end

local function on_nopower(pos)
	local nvm = techage.get_nvm(pos)
	nvm.consumer_powered = false
	if (nvm.ticks or 0) < 4 then
		M(pos):set_string("infotext", S("TA3 Electric Motor: Overload fault?\n(restart with right-click)"))
	end
	nvm.ticks = 0
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.ele1 = nvm.ele1 or {}
	
	-- trigger network on consumer side
	nvm.ticks = (nvm.ticks or 0) + 1
	if nvm.ticks % 2 then
		power.consumer_alive(pos, Cable, CYCLE_TIME)
	end
	
	-- handle generator side delayed
	if nvm.ticks > 3 then
		local outdir = M(pos):get_int("outdir")
		
		if nvm.consumer_powered and not nvm.running_as_generator then
			nvm.running_as_generator = true
			power.generator_start(pos, Axle, CYCLE_TIME, outdir, nvm.max_power)
			switch_axles(pos, true)
		elseif not nvm.consumer_powered and nvm.running_as_generator then
			nvm.running_as_generator = false
			power.generator_stop(pos, Axle, outdir)
			switch_axles(pos, false)
		end
		
		if nvm.running_as_generator then
			nvm.ele1.curr_power = power.generator_alive(pos, Axle, CYCLE_TIME, outdir, PWR_PERF) + 1
		else
			swap_node(pos, "techage:ta3_motor_off")
		end
	end
	return true
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	local nvm = techage.get_nvm(pos)
	nvm.ele1 = nvm.ele1 or {}
	nvm.ele1.curr_power = 1
	power.update_network(pos, outdir, tlib2)
end

minetest.register_node("techage:ta3_motor_off", {
	description = S("TA3 Electric Motor"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_axle_clutch.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator_red.png^[transformFX]",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator_red.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	after_place_node = function(pos)
		local nvm = techage.get_nvm(pos)
		nvm.ele1 = nvm.ele1 or {}
		nvm.ele1.curr_power = 1
		nvm.consumer_powered = false
		nvm.running_as_generator = false
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		M(pos):set_int("leftdir", networks.side_to_outdir(pos, "L"))
		Cable:after_place_node(pos)
		Axle:after_place_node(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)   
		power.consumer_start(pos, Cable, CYCLE_TIME*2)
		M(pos):set_string("infotext", S("TA3 Electric Motor"))
	end,
	
	on_rightclick = function(pos, node, clicker)
		local nvm = techage.get_nvm(pos)
		nvm.ele1 = nvm.ele1 or {}
		nvm.ele1.curr_power = 1
		M(pos):set_string("infotext", S("TA3 Electric Motor"))
	end,
	
	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		Axle:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	
	tubelib2_on_update2 = tubelib2_on_update2,
	on_timer = node_timer,
	networks = {
		axle = {
			sides = {R = 1},
			ntype = "gen1",
			nominal = PWR_PERF,
		},
		ele1 = {
			sides = {L = 1},
			ntype = "con1",
			on_power = on_power,
			on_nopower = on_nopower,
		},
	}
})

minetest.register_node("techage:ta3_motor_on", {
	description = S("TA3 Electric Motor"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		{
			image = "techage_filling4_ta3.png^techage_axle_clutch4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_electric.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_generator_red4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_generator_red4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	drop = "",
	groups = {not_in_creative_inventory=1},
	diggable = false,

	tubelib2_on_update2 = tubelib2_on_update2,
	on_timer = node_timer,
	networks = {
		axle = {
			sides = {R = 1},
			ntype = "gen1",
			nominal = PWR_PERF,
		},
		ele1 = {
			sides = {L = 1},
			ntype = "con1",
			on_power = on_power,
			on_nopower = on_nopower,
		},
	}
})

techage.register_node({"techage:ta3_motor_off", "techage:ta3_motor_on"}, {
	on_node_load = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})

Cable:add_secondary_node_names({"techage:ta3_motor_off", "techage:ta3_motor_on"})
Axle:add_secondary_node_names({"techage:ta3_motor_off", "techage:ta3_motor_on"})

minetest.register_craft({
	output = "techage:ta3_motor_off",
	recipe = {
		{"basic_materials:steel_bar", "dye:red", "default:wood"},
		{'techage:electric_cableS', 'basic_materials:gear_steel', 'techage:axle'},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})

