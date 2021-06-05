--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2/TA3/TA4 Power Test Source
	
]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Axle = techage.Axle
--local Pipe = techage.SteamPipe
local Cable = techage.ElectricCable
local power = networks.power
--local networks = techage.networks

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local PWR_PERF = 100

local function formspec2(self, pos, nvm)
	return "size[4,4]"..
		"box[0,-0.1;3.8,0.5;#c6e8ff]"..
		"label[1,-0.1;"..minetest.colorize( "#000000", S("Power Source")).."]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		techage.power.formspec_label_bar(pos, 0, 0.8, Axle, S("power"), PWR_PERF, nvm.provided)..
		"image_button[2.8,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2.8,2;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function formspec4(self, pos, nvm)
	return "size[4,4]"..
		"box[0,-0.1;3.8,0.5;#c6e8ff]"..
		"label[1,-0.1;"..minetest.colorize( "#000000", S("Power Source")).."]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		techage.power.formspec_label_bar(pos, 0, 0.8, Cable, S("power"), PWR_PERF, nvm.provided)..
		"image_button[2.8,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2.8,2;1,1;"..self:get_state_tooltip(nvm).."]"
end

-- Axles texture animation
local function switch_axles(pos, on)
	local outdir = M(pos):get_int("outdir")
	Axle:switch_tube_line(pos, outdir, on and "on" or "off")
end

local function start_node2(pos, nvm, state)
	nvm.generating = true
	nvm.provided = 0
	local outdir = M(pos):get_int("outdir")
	switch_axles(pos, true)
	power.start_storage_calc(pos, Axle, outdir)
end

local function stop_node2(pos, nvm, state)
	nvm.generating = false
	nvm.provided = 0
	nvm.load = 0
	local outdir = M(pos):get_int("outdir")
	switch_axles(pos, false)
	power.start_storage_calc(pos, Axle, outdir)
end

--local function start_node3(pos, nvm, state)
--	nvm.generating = true
--	local outdir = M(pos):get_int("outdir")
--	power.generator_start(pos, Pipe, CYCLE_TIME, outdir)
--end

--local function stop_node3(pos, nvm, state)
--	nvm.generating = false
--	nvm.provided = 0
--	local outdir = M(pos):get_int("outdir")
--	power.generator_stop(pos, Pipe, outdir)
--end

local function start_node4(pos, nvm, state)
	nvm.generating = true
	nvm.provided = 0
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
end

local function stop_node4(pos, nvm, state)
	nvm.generating = false
	nvm.provided = 0
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
end

local State2 = techage.NodeStates:new({
	node_name_passive = "techage:t2_source",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec2,
	start_node = start_node2,
	stop_node = stop_node2,
})

--local State3 = techage.NodeStates:new({
--	node_name_passive = "techage:t3_source",
--	cycle_time = CYCLE_TIME,
--	standby_ticks = STANDBY_TICKS,
--	formspec_func = formspec3,
--	start_node = start_node3,
--	stop_node = stop_node3,
--})

local State4 = techage.NodeStates:new({
	node_name_passive = "techage:t4_source",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec4,
	start_node = start_node4,
	stop_node = stop_node4,
})

local function node_timer2(pos, elapsed)
	--print("node_timer2")
	local nvm = techage.get_nvm(pos)
	local outdir = M(pos):get_int("outdir")
	nvm.provided = power.provide_power(pos, Axle, outdir, PWR_PERF)
	local data = power.get_storage_data(pos, Axle, outdir)
	if data then
		nvm.load = data.level * PWR_PERF * 4
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec2(State2, pos, nvm))
	end
	return true
end

--local function node_timer3(pos, elapsed)
--	--print("node_timer3")
--	local nvm = techage.get_nvm(pos)
--	local outdir = M(pos):get_int("outdir")
--	nvm.provided = power.generator_alive(pos, Pipe, CYCLE_TIME, outdir)
--	if techage.is_activeformspec(pos) then
--		M(pos):set_string("formspec", formspec3(State3, pos, nvm))
--	end
--	return true
--end

local function node_timer4(pos, elapsed)
	--print("node_timer4")
	local nvm = techage.get_nvm(pos)
	local outdir = M(pos):get_int("outdir")
	nvm.provided = power.provide_power(pos, Cable, outdir, PWR_PERF)
	local data = power.get_storage_data(pos, Cable, outdir)
	if data then
		nvm.load = data.level * PWR_PERF
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec4(State4, pos, nvm))
	end
	return true
end

local function on_receive_fields2(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State2:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec2(State2, pos, nvm))
end

--local function on_receive_fields3(pos, formname, fields, player)
--	if minetest.is_protected(pos, player:get_player_name()) then
--		return
--	end
--	local nvm = techage.get_nvm(pos)
--	State3:state_button_event(pos, nvm, fields)
--	M(pos):set_string("formspec", formspec3(State3, pos, nvm))
--end

local function on_receive_fields4(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State4:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec4(State4, pos, nvm))
end

local function on_rightclick2(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec2(State2, pos, nvm))
end

--local function on_rightclick3(pos, node, clicker)
--	techage.set_activeformspec(pos, clicker)
--	local nvm = techage.get_nvm(pos)
--	M(pos):set_string("formspec", formspec3(State3, pos, nvm))
--end

local function on_rightclick4(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec4(State4, pos, nvm))
end

local function after_place_node2(pos)
	local nvm = techage.get_nvm(pos)
	State2:node_init(pos, nvm, "")
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec2(State2, pos, nvm))
	Axle:after_place_node(pos)
end

--local function after_place_node3(pos)
--	local nvm = techage.get_nvm(pos)
--	State3:node_init(pos, nvm, "")
--	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
--	M(pos):set_string("formspec", formspec3(State3, pos, nvm))
--	Pipe:after_place_node(pos)
--end

local function after_place_node4(pos)
	local nvm = techage.get_nvm(pos)
	State4:node_init(pos, nvm, "")
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	M(pos):set_string("formspec", formspec4(State4, pos, nvm))
	Cable:after_place_node(pos)
end

local function after_dig_node2(pos, oldnode)
	Axle:after_dig_node(pos)
	techage.del_mem(pos)
end

--local function after_dig_node3(pos, oldnode)
--	Pipe:after_dig_node(pos)
--	techage.del_mem(pos)
--end

local function after_dig_node4(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function get_generator_data(pos, tlib2)
	local nvm = techage.get_nvm(pos)
	if nvm.generating then
		return {level = (nvm.load or 0) / PWR_PERF, capa = PWR_PERF * 4}
	else
		return {level = 0, capa = PWR_PERF * 4}
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

--minetest.register_node("techage:t3_source", {
--	description = S("Steam Power Source"),
--	tiles = {
--		-- up, down, right, left, back, front
--		"techage_filling_ta3.png^techage_frame_ta3_top.png",
--		"techage_filling_ta3.png^techage_frame_ta3.png",
--		"techage_filling_ta3.png^techage_steam_hole.png^techage_frame_ta3.png",
--		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
--		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
--		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
--	},
--	paramtype2 = "facedir",
--	groups = {cracky=2, crumbly=2, choppy=2},
--	on_rotate = screwdriver.disallow,
--	is_ground_content = false,
--	on_receive_fields = on_receive_fields3,
--	on_rightclick = on_rightclick3,
--	on_timer = node_timer3,
--	after_place_node = after_place_node3,
--	after_dig_node = after_dig_node3,
--	get_generator_data = get_generator_data,
--})

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
	on_receive_fields = on_receive_fields4,
	on_rightclick = on_rightclick4,
	on_timer = node_timer4,
	after_place_node = after_place_node4,
	after_dig_node = after_dig_node4,
	get_generator_data = get_generator_data,
})

power.register_nodes({"techage:t2_source"}, Axle, "gen", {"R"})
--power.register_nodes({"techage:t3_source"}, Pipe, "gen", {"R"})
power.register_nodes({"techage:t4_source"}, Cable, "gen", {"R"})
