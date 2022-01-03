--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2/TA3 Power Test Source

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Axle = techage.Axle
--local Pipe = techage.SteamPipe
local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control

local STANDBY_TICKS = 4
local CYCLE_TIME = 2
local PWR_PERF = 100

local function formspec(self, pos, nvm)
	return techage.generator_formspec(self, pos, nvm, S("Power Source"), nvm.provided, PWR_PERF)
end

-- Axles texture animation
local function switch_axles(pos, on)
	local outdir = M(pos):get_int("outdir")
	Axle:switch_tube_line(pos, outdir, on and "on" or "off")
end

local function start_node2(pos, nvm, state)
	nvm.running = true
	nvm.provided = 0
	local outdir = M(pos):get_int("outdir")
	switch_axles(pos, true)
	power.start_storage_calc(pos, Axle, outdir)
end

local function stop_node2(pos, nvm, state)
	nvm.running = false
	nvm.provided = 0
	nvm.load = 0
	local outdir = M(pos):get_int("outdir")
	switch_axles(pos, false)
	power.start_storage_calc(pos, Axle, outdir)
end

local function start_node3(pos, nvm, state)
	local meta = M(pos)
	nvm.running = true
	nvm.provided = 0
	techage.evaluate_charge_termination(nvm, meta)
	local outdir = meta:get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
end

local function stop_node3(pos, nvm, state)
	nvm.running = false
	nvm.provided = 0
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
end

local State2 = techage.NodeStates:new({
	node_name_passive = "techage:t2_source",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	start_node = start_node2,
	stop_node = stop_node2,
})

local State3 = techage.NodeStates:new({
	node_name_passive = "techage:t4_source",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	start_node = start_node3,
	stop_node = stop_node3,
})

local function node_timer2(pos, elapsed)
	--print("node_timer2")
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local outdir = meta:get_int("outdir")
	local tp1 = tonumber(meta:get_string("termpoint1"))
	local tp2 = tonumber(meta:get_string("termpoint2"))
	nvm.provided = power.provide_power(pos, Axle, outdir, PWR_PERF, tp1, tp2)
	nvm.load = power.get_storage_load(pos, Axle, outdir, PWR_PERF)
	if techage.is_activeformspec(pos) then
		meta:set_string("formspec", formspec(State2, pos, nvm))
	end
	return true
end

local function node_timer3(pos, elapsed)
	--print("node_timer4")
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local outdir = M(pos):get_int("outdir")
	local tp1 = tonumber(meta:get_string("termpoint1"))
	local tp2 = tonumber(meta:get_string("termpoint2"))
	nvm.provided = power.provide_power(pos, Cable, outdir, PWR_PERF, tp1, tp2)
	nvm.load = power.get_storage_load(pos, Cable, outdir, PWR_PERF)
	if techage.is_activeformspec(pos) then
		meta:set_string("formspec", formspec(State3, pos, nvm))
	end
	return true
end

local function on_receive_fields2(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State2:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State2, pos, nvm))
end

local function on_receive_fields3(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State3:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State3, pos, nvm))
end

local function on_rightclick2(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State2, pos, nvm))
end

local function on_rightclick3(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State3, pos, nvm))
end

local function after_place_node2(pos)
	local nvm = techage.get_nvm(pos)
	State2:node_init(pos, nvm, "")
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec(State2, pos, nvm))
	Axle:after_place_node(pos)
end

local function after_place_node3(pos)
	local nvm = techage.get_nvm(pos)
	local number = techage.add_node(pos, "techage:t4_source")
	State3:node_init(pos, nvm, number)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec(State3, pos, nvm))
	Cable:after_place_node(pos)
end

local function after_dig_node2(pos, oldnode)
	Axle:after_dig_node(pos)
	techage.del_mem(pos)
end

local function after_dig_node3(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if nvm.running then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
end

minetest.register_node("techage:t2_source", {
	description = S("Axle Power Source"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2_top.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_axle_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_source.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_source.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_source.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	on_receive_fields = on_receive_fields2,
	on_rightclick = on_rightclick2,
	on_timer = node_timer2,
	after_place_node = after_place_node2,
	after_dig_node = after_dig_node2,
	get_generator_data = get_generator_data,
})

minetest.register_node("techage:t4_source", {
	description = S("Ele Power Source"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_hole_electric.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_source.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_source.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_source.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	on_receive_fields = on_receive_fields3,
	on_rightclick = on_rightclick3,
	on_timer = node_timer3,
	after_place_node = after_place_node3,
	after_dig_node = after_dig_node3,
	get_generator_data = get_generator_data,
	ta3_formspec = techage.generator_settings("ta3", PWR_PERF),
})

power.register_nodes({"techage:t2_source"}, Axle, "gen", {"R"})
power.register_nodes({"techage:t4_source"}, Cable, "gen", {"R"})

techage.register_node({"techage:t4_source"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "delivered" then
			return nvm.provided or 0
		else
			return State3:on_receive_message(pos, topic, payload)
		end
	end,
})

control.register_nodes({"techage:t4_source"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				local meta = M(pos)
				return {
					type = S("Ele Power Source"),
					number = meta:get_string("node_number") or "",
					running = nvm.running or false,
					available = PWR_PERF,
					provided = nvm.provided or 0,
					termpoint = meta:get_string("termpoint"),
				}
			end
			return false
		end,
	}
)
