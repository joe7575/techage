--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

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
local power = networks.power

local CYCLE_TIME = 2
local PWR_PERF = 40

-- Axles texture animation
local function switch_axles(pos, on)
	local outdir = M(pos):get_int("outdir")
	Axle:switch_tube_line(pos, outdir, on and "on" or "off")
end

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function node_timer_on(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local outdir = M(pos):get_int("outdir")
	nvm.buffer = nvm.buffer or 0

	local amount = math.min(PWR_PERF * 2 - nvm.buffer, PWR_PERF)
	local taken = power.consume_power(pos, Cable, networks.Flip[outdir], amount)
	nvm.buffer = nvm.buffer + taken - 1  -- some loss

	if nvm.buffer >= PWR_PERF then
		nvm.provided = power.provide_power(pos, Axle, outdir, PWR_PERF)
		nvm.load = power.get_storage_load(pos, Axle, outdir, PWR_PERF)
		nvm.buffer = nvm.buffer - nvm.provided
	end
	if amount > 0 and taken == 0 then
		swap_node(pos, "techage:ta3_motor_off")
		switch_axles(pos, false)
		local outdir = M(pos):get_int("outdir")
		nvm.running = false
		power.start_storage_calc(pos, Cable, outdir)
	end
	return true
end

local function node_timer_off(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local outdir = M(pos):get_int("outdir")

	if power.power_available(pos, Cable) then
		swap_node(pos, "techage:ta3_motor_on")
		switch_axles(pos, true)
		nvm.running = true
		power.start_storage_calc(pos, Cable, outdir)
	end
	return true
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if nvm.running then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
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
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Cable:after_place_node(pos)
		Axle:after_place_node(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		M(pos):set_string("infotext", S("TA3 Electric Motor"))
	end,

	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		Axle:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	on_timer = node_timer_off,
	get_generator_data = get_generator_data,
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

	on_timer = node_timer_on,
	get_generator_data = get_generator_data,
})

techage.register_node({"techage:ta3_motor_off", "techage:ta3_motor_on"}, {
	on_node_load = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})

power.register_nodes({"techage:ta3_motor_off", "techage:ta3_motor_on"}, Axle, "gen", {"R"})
power.register_nodes({"techage:ta3_motor_off", "techage:ta3_motor_on"}, Cable, "con", {"L"})

minetest.register_craft({
	output = "techage:ta3_motor_off",
	recipe = {
		{"basic_materials:steel_bar", "dye:red", "default:wood"},
		{'techage:electric_cableS', 'basic_materials:gear_steel', 'techage:axle'},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})
