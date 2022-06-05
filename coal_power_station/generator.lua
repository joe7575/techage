--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Power Station Generator

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control

local CYCLE_TIME = 2
local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local PWR_PERF = 80

local function formspec(self, pos, nvm)
	return techage.generator_formspec(self, pos, nvm, S("Generator"), nvm.provided, PWR_PERF)
end

local function transfer_turbine(pos, topic, payload)
	return techage.transfer(pos, "L", topic, payload, nil,
		{"techage:turbine", "techage:turbine_on"})
end

local function can_start(pos, nvm, state)
	return (nvm.firebox_trigger or 0) > 0 -- by means of firebox
end

local function has_fire(nvm)
	nvm.firebox_trigger = (nvm.firebox_trigger or 0) - 1
	return nvm.firebox_trigger > 0
end

local function start_node(pos, nvm, state)
	local meta = M(pos)
	nvm.provided = 0
	local outdir = meta:get_int("outdir")
	transfer_turbine(pos, "start")
	power.start_storage_calc(pos, Cable, outdir)
	techage.evaluate_charge_termination(nvm, meta)
end

local function stop_node(pos, nvm, state)
	nvm.provided = 0
	local outdir = M(pos):get_int("outdir")
	transfer_turbine(pos, "stop")
	power.start_storage_calc(pos, Cable, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:generator",
	node_name_active = "techage:generator_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA3 Generator"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local running = techage.is_running(nvm)
	local fire = has_fire(nvm)
	if running and not fire then
		State:standby(pos, nvm)
		stop_node(pos, nvm, State)
	elseif not running and fire then
		State:start(pos, nvm)
		-- start_node() is called implicit
	elseif running then
		local meta = M(pos)
		local outdir = meta:get_int("outdir")
		local tp1 = tonumber(meta:get_string("termpoint1"))
		local tp2 = tonumber(meta:get_string("termpoint2"))
		nvm.provided = power.provide_power(pos, Cable, outdir, PWR_PERF, tp1, tp2)
		local val = power.get_storage_load(pos, Cable, outdir, PWR_PERF)
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
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	local number = techage.add_node(pos, "techage:generator")
	State:node_init(pos, nvm, number)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec(State, pos, nvm))
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
end

minetest.register_node("techage:generator", {
	description = S("TA3 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png^[transformFX]",
	},

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_generator_data = get_generator_data,
	ta3_formspec = techage.generator_settings("ta3", PWR_PERF),

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:generator_on", {
	description = S("TA3 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_generator4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_generator4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_generator_data = get_generator_data,
	ta3_formspec = techage.generator_settings("ta3", PWR_PERF),

	drop = "",
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:generator", "techage:generator_on"}, Cable, "gen", {"R"})

-- controlled by the turbine
techage.register_node({"techage:generator", "techage:generator_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "trigger" then
			nvm.firebox_trigger = 3
			if techage.is_running(nvm) then
				return math.max((nvm.provided or PWR_PERF) / PWR_PERF, 0.02)
			else
				return 0
			end
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "delivered" then
			return math.floor((nvm.provided or 0) + 0.5)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 135 then  -- Delivered Power
			return 0, {math.floor((nvm.provided or 0) + 0.5)}
		else
			return State:on_beduino_request_data(pos, topic, payload)
		end
	end,
})

-- used by power terminal
control.register_nodes({"techage:generator", "techage:generator_on"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				local meta = M(pos)
				return {
					type = S("TA3 Generator"),
					number = meta:get_string("node_number") or "",
					running = techage.is_running(nvm) or false,
					available = PWR_PERF,
					provided = nvm.provided or 0,
					termpoint = meta:get_string("termpoint"),
				}
			end
			return false
		end,
	}
)

minetest.register_craft({
	output = "techage:generator",
	recipe = {
		{"basic_materials:steel_bar", "dye:green", "default:wood"},
		{"", "basic_materials:gear_steel", "techage:electric_cableS"},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})
