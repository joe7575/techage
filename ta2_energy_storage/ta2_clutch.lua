--[[

	TechAge
	=======

	Copyright (C) 2019-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Axle clutch

]]--

-- for lazy programmers
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2
local PWR_PERF = 100
local DESCR = S("TA2 Clutch")

local Axle = techage.Axle
local power = networks.power

-- Axles texture animation
local function switch_axles(pos, on)
	local outdir = M(pos):get_int("outdir")
	Axle:switch_tube_line(pos, outdir, on and "on" or "off")
end

local function start_node(pos, nvm, state)
	local outdir = M(pos):get_int("outdir")
	switch_axles(pos, true)
	nvm.load = 0
	power.start_storage_calc(pos, Axle, outdir)
	outdir = networks.Flip[outdir]
	power.start_storage_calc(pos, Axle, outdir)
end

local function stop_node(pos, nvm, state)
	local outdir = M(pos):get_int("outdir")
	switch_axles(pos, false)
	power.start_storage_calc(pos, Axle, outdir)
	outdir = networks.Flip[outdir]
	power.start_storage_calc(pos, Axle, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta2_clutch_off",
	node_name_active = "techage:ta2_clutch_on",
	infotext_name = DESCR,
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local outdir2 = M(pos):get_int("outdir")
	local outdir1 = networks.Flip[outdir2]
	local data = power.transfer_duplex(pos, Axle, outdir1, Axle, outdir2, PWR_PERF)
	local power_flow = (data.curr_load1 == 0 and data.curr_load2 == 0) or (data.curr_load1 > 0 and data.curr_load2 > 0)
	if not power_flow then
		power.start_storage_calc(pos, Axle, outdir1)
		power.start_storage_calc(pos, Axle, outdir2)
	end
	return true
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		State:stop(pos, nvm)
	else
		State:start(pos, nvm)
	end
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5})
end

local function after_place_node(pos, placer, itemstack)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local own_num = techage.add_node(pos, "techage:ta2_clutch_off")
	meta:set_string("owner", placer:get_player_name())
	local outdir = networks.side_to_outdir(pos, "R")
	meta:set_int("outdir", outdir)
	Axle:after_place_node(pos, {outdir, networks.Flip[outdir]})
	State:node_init(pos, nvm, own_num)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	local outdir = tonumber(oldmetadata.fields.outdir or 0)
	Axle:after_dig_node(pos, {outdir, networks.Flip[outdir]})
	techage.del_mem(pos)
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
end

minetest.register_node("techage:ta2_clutch_off", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2_top.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_axle_gearbox.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_axle_gearbox.png",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png",
	},

	on_timer = node_timer,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_generator_data = get_generator_data,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta2_clutch_on", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2_top.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		{
			name = "techage_filling4_ta2.png^techage_axle_gearbox4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			name = "techage_filling4_ta2.png^techage_axle_gearbox4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png",
	},

	on_timer = node_timer,
	on_rightclick = on_rightclick,
	get_generator_data = get_generator_data,
	paramtype2 = "facedir",
	drop = "",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:ta2_clutch_off", "techage:ta2_clutch_on"}, Axle, "gen", {"R", "L"})

minetest.register_craft({
	output = "techage:ta2_clutch_off",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "basic_materials:gear_steel", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})
