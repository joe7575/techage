--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Solar Power DC/AC Inverter

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

local Cable = techage.ElectricCable
local Solar = techage.TA4_Cable
local power = networks.power
local control = networks.control

local CYCLE_TIME = 2
local PWR_PERF = 100
local COUNTDOWN_TICKS = 1

local function determine_power(pos, nvm)
	-- determine DC node position
	local outdir = M(pos):get_int("leftdir")
	local netw = networks.get_network_table(pos, Solar, outdir) or {}
	local num_inv = #(netw.con or {})
	local max_power = 0
	for _, power in ipairs(control.request(pos, Solar, outdir, "junc", "power")) do
		max_power = max_power + power
	end

	if num_inv == 1 then  -- only one inverter is allowed
		nvm.max_power = math.min(PWR_PERF, max_power)
	else
		nvm.max_power = 0
	end
	return max_power, num_inv
end

local function has_dc_power(pos, nvm)
	local time = minetest.get_timeofday() or 0
	if time < 6.00/24.00 or time > 18.00/24.00 then
		nvm.ticks = 0
		nvm.max_power = 0
		return false
	end
	nvm.ticks = nvm.ticks or 0
	if (nvm.ticks % 30) == 0 then -- calculate max_power not to often
		determine_power(pos, nvm)
	else
		nvm.max_power = nvm.max_power or 0
	end
	nvm.ticks = nvm.ticks + 1
	return nvm.max_power > 0
end

local function formspec(self, pos, nvm)
	local max_power = nvm.max_power or 0
	local provided = nvm.provided or 0
	local arrow = "image[2.5,1.5;1,1;techage_form_arrow_bg.png^[transformR270]"
	if techage.is_running(nvm) then
		arrow = "image[2.5,1.5;1,1;techage_form_arrow_fg.png^[transformR270]"
	end
	return "size[6,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;5.8,0.5;#c6e8ff]"..
		"label[2.5,-0.1;"..minetest.colorize( "#000000", S("Inverter")).."]"..
		techage.formspec_power_bar(pos, 0,   0.8, S("Power DC"), max_power, PWR_PERF)..
		techage.formspec_power_bar(pos, 3.5, 0.8, S("Power AC"), provided, max_power)..
		arrow..
		"image_button[2.5,3;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2.5,3;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function can_start(pos, nvm, state)
	local max_power, num_inverter = determine_power(pos, nvm)
	if num_inverter > 1 then return S("solar network error") end
	if max_power == 0 then return S("no solar power") end
	return true
end

local function start_node(pos, nvm, state)
	local meta = M(pos)
	nvm.provided = 0
	nvm.ticks = 0
	local outdir = meta:get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
	techage.evaluate_charge_termination(nvm, meta)
end

local function stop_node(pos, nvm, state)
	nvm.provided = 0
	nvm.running = nil  -- legacy
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_solar_inverter",
	cycle_time = CYCLE_TIME,
	standby_ticks = 2,
	formspec_func = formspec,
	infotext_name = S("TA4 Solar Inverter"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local running = techage.is_running(nvm)
	local has_power = has_dc_power(pos, nvm)
	if running and not has_power then
		State:standby(pos, nvm)
		stop_node(pos, nvm, State)
	elseif not running and has_power then
		State:start(pos, nvm)
        -- start_node() is called implicit
	elseif running then
		local meta = M(pos)
		local outdir = meta:get_int("outdir")
		local tp1 = tonumber(meta:get_string("termpoint1"))
		local tp2 = tonumber(meta:get_string("termpoint2"))
		nvm.provided = power.provide_power(pos, Cable, outdir, nvm.max_power, tp1, tp2)
		local val = power.get_storage_load(pos, Cable, outdir, nvm.max_power)
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
	determine_power(pos, nvm)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		return {level = (nvm.load or 0) / nvm.max_power, perf = nvm.max_power, capa = nvm.max_power * 2}
	end
end

minetest.register_node("techage:ta4_solar_inverter", {
	description = S("TA4 Solar Inverter"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_ta4_cable.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inverter.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inverter.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	after_place_node = function(pos)
		local nvm = techage.get_nvm(pos)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		M(pos):set_int("leftdir", networks.side_to_outdir(pos, "L"))
		Cable:after_place_node(pos)
		Solar:after_place_node(pos)
		local number = techage.add_node(pos, "techage:ta4_solar_inverter")
		State:node_init(pos, nvm, number)
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end,

	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		Solar:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	get_generator_data = get_generator_data,
	ta3_formspec = techage.generator_settings("ta4", PWR_PERF)
})

power.register_nodes({"techage:ta4_solar_inverter"}, Cable, "gen", {"R"})
power.register_nodes({"techage:ta4_solar_inverter"}, Solar, "con", {"L"})

techage.register_node({"techage:ta4_solar_inverter"}, {
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

control.register_nodes({"techage:ta4_solar_inverter"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				local meta = M(pos)
				return {
					type = S("TA4 Solar Inverter"),
					number = meta:get_string("node_number") or "",
					running = techage.is_running(nvm) or false,
					available = nvm.max_power or 0,
					provided = nvm.provided or 0,
					termpoint = meta:get_string("termpoint"),
				}
			end
			return false
		end,
	}
)

minetest.register_craft({
	output = "techage:ta4_solar_inverter",
	recipe = {
		{'default:steel_ingot', 'dye:green', 'default:steel_ingot'},
		{'', 'techage:ta4_wlanchip', 'techage:electric_cableS'},
		{'default:steel_ingot', "techage:baborium_ingot", 'default:steel_ingot'},
	},
})

techage.register_node_for_v1_transition({"techage:ta4_solar_inverter"}, function(pos, node)
	power.update_network(pos, nil, Solar)
end)
