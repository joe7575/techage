--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Steam Engine Flywheel

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local PWR_PERF = 25

local Axle = techage.Axle
local power = networks.power

-- Axles texture animation
local function switch_axles(pos, on)
	local outdir = M(pos):get_int("outdir")
	Axle:switch_tube_line(pos, outdir, on and "on" or "off")
end

local function formspec(self, pos, nvm)
	return techage.generator_formspec(self, pos, nvm, S("Flywheel"), nvm.provided, PWR_PERF, true)
end

local function transfer_cylinder(pos, topic, payload)
	return techage.transfer(pos, "L", topic, payload, nil,
		{"techage:cylinder", "techage:cylinder_on"})
end

local function can_start(pos, nvm, state)
	return (nvm.firebox_trigger or 0) > 0 -- by means of firebox
end

local function start_node(pos, nvm, state)
	switch_axles(pos, true)
	local outdir = M(pos):get_int("outdir")
	transfer_cylinder(pos, "start")
	power.start_storage_calc(pos, Axle, outdir)
end

local function stop_node(pos, nvm, state)
	switch_axles(pos, false)
	local outdir = M(pos):get_int("outdir")
	nvm.provided = 0
	transfer_cylinder(pos, "stop")
	power.start_storage_calc(pos, Axle, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:flywheel",
	node_name_active = "techage:flywheel_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.firebox_trigger = (nvm.firebox_trigger or 0) - 1
	local running = techage.is_running(nvm)
	if running and nvm.firebox_trigger <= 0 then
		State:standby(pos, nvm)
		stop_node(pos, nvm, State)
	elseif not running and nvm.firebox_trigger > 0 then
		State:start(pos, nvm)
		-- start_node() is called implicit
	elseif running then
		local outdir = M(pos):get_int("outdir")
		nvm.provided = power.provide_power(pos, Axle, outdir, PWR_PERF)
		local val = power.get_storage_load(pos, Axle, outdir, PWR_PERF)
		if val > 0 then
			nvm.load = val
		end
		State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return State:is_active(nvm)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm,_ = techage.get_nvm(pos, true)
	State:state_button_event(pos, nvm, fields)
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	State:node_init(pos, nvm, "")
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec(State, pos, nvm))
	Axle:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Axle:after_dig_node(pos)
	techage.del_mem(pos)
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 4}
	end
end

minetest.register_node("techage:flywheel", {
	description = S("TA2 Flywheel"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_axle_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png^[transformFX]",
	},

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_generator_data = get_generator_data,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:flywheel_on", {
	description = S("TA2 Flywheel"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		{
			image = "techage_filling4_ta2.png^techage_axle_clutch4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		{
			image = "techage_filling8_ta2.png^techage_frame8_ta2.png^techage_flywheel8.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 1.2,
			},
		},
		{
			image = "techage_filling8_ta2.png^techage_frame8_ta2.png^techage_flywheel8.png^[transformFX]",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 1.2,
			},
		},
	},

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_generator_data = get_generator_data,

	drop = "",
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:flywheel", "techage:flywheel_on"}, Axle, "gen", {"R"})

techage.register_node({"techage:flywheel", "techage:flywheel_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "trigger" then
			nvm.firebox_trigger = 3
			if techage.is_running(nvm) then
				return math.max((nvm.provided or PWR_PERF) / PWR_PERF, 0.1)
			else
				return 0
			end
		end
	end,
	on_node_load = function(pos, node)
		State:on_node_load(pos)
	end,
})

minetest.register_craft({
	output = "techage:flywheel",
	recipe = {
		{"basic_materials:steel_bar", "dye:red", "default:wood"},
		{"", "basic_materials:gear_steel", "techage:axle"},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})
