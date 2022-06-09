--[[

	TechAge
	=======

	Copyright (C) 2019-2022 DS-Minetest, Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Power Wind Turbine Rotor

	Code by Joachim Stolberg, derived from DS-Minetest [1]
	Rotor model and texture designed by DS-Minetest [1] (CC-0)

	[1] https://github.com/DS-Minetest/wind_turbine

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local STANDBY_TICKS = 4
local CYCLE_TIME = 2
local PWR_PERF = 70
local COUNTDOWN_TICKS = 2

local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control

local Rotors = {}

local Face2Dir = {[0]=
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0, z=-1},
	{x=-1, y=0,  z=0},
	{x=0,  y=-1, z=0},
	{x=0,  y=1,  z=0}
}

local function pos_and_yaw(pos, param2)
	local dir = Face2Dir[param2] or  Face2Dir[0]
	local yaw = minetest.dir_to_yaw(dir)
	dir = vector.multiply(dir, 1.1)
	pos = vector.add(pos, dir)
	return pos, {x=0, y=yaw, z=0}
end

local function is_windy()
	local time = minetest.get_timeofday() or 0
	return (time >= 5.00/24.00 and time <= 9.00/24.00) or (time >= 17.00/24.00 and time <= 21.00/24.00)
end

local function check_rotor(pos, nvm)
	local resp, err = techage.valid_place_for_windturbine(pos, nil, 1)
	if not resp then
		nvm.error = err
		return false
	end

	local npos = techage.get_pos(pos, "F")
	local node = techage.get_node_lvm(npos)
	if node.name ~= "techage:ta4_wind_turbine_nacelle" then
		nvm.error = S("Nacelle is missing")
		return false
	end

	local own_num = M(pos):get_string("node_number") or ""
	M(pos):set_string("infotext", S("TA4 Wind Turbine")..": "..own_num)
	nvm.error = false
	return true
end

local function formspec(self, pos, nvm)
	return techage.generator_formspec(self, pos, nvm, S("TA4 Wind Turbine"), nvm.provided, PWR_PERF)
end

local function add_rotor(pos, nvm, force)
	if (force and not nvm.error) or check_rotor(pos, nvm) then
		local hash = minetest.hash_node_position(pos)
		if Rotors[hash] then
			Rotors[hash]:remove()
		end
		local node = minetest.get_node(pos)
		local npos, yaw = pos_and_yaw(pos, node.param2)
		local obj = minetest.add_entity(npos, "techage:rotor_ent")
		obj:set_animation({x = 0, y = 119}, 0, 0, true)
		obj:set_rotation(yaw)
		Rotors[hash] = obj
	end
end

local function start_rotor(pos, nvm, state)
	if not nvm.error then
		local meta = M(pos)
		nvm.provided = 0
		techage.evaluate_charge_termination(nvm, meta)
		power.start_storage_calc(pos, Cable, 5)
		local hash = minetest.hash_node_position(pos)
		if Rotors[hash] and is_windy() then
			Rotors[hash]:set_animation_frame_speed(50)
		end
	end
end

local function stop_rotor(pos, nvm, state)
	nvm.provided = 0
	nvm.load = 0
	power.start_storage_calc(pos, Cable, 5)
	local hash = minetest.hash_node_position(pos)
	if Rotors[hash] then
		Rotors[hash]:set_animation_frame_speed(0)
	end
end

local function can_start(pos, nvm)
	check_rotor(pos, nvm)
	if nvm.error then
		return nvm.error
	end
	add_rotor(pos, nvm)
	return true
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_wind_turbine",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	start_node = start_rotor,
	stop_node = stop_rotor,
	can_start = can_start,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local running = techage.is_running(nvm)
	local windy = is_windy()
	if running and not windy then
		State:standby(pos, nvm)
		stop_rotor(pos, nvm, State)
	elseif not running and windy then
		State:start(pos, nvm)
		-- start_node() is called implicit
	elseif running then
		local meta = M(pos)
		local tp1 = tonumber(meta:get_string("termpoint1"))
		local tp2 = tonumber(meta:get_string("termpoint2"))
		nvm.provided = power.provide_power(pos, Cable, 5, PWR_PERF, tp1, tp2)
		local val = power.get_storage_load(pos, Cable, 5, PWR_PERF)
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

local function on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
end

local function after_place_node(pos, placer)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local number = techage.add_node(pos, "techage:ta4_wind_turbine")
	State:node_init(pos, nvm, number)
	meta:set_string("owner", placer:get_player_name())
	M(pos):set_string("formspec", formspec(State, pos, nvm))
	add_rotor(pos, nvm)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode, oldmetadata)
	local hash = minetest.hash_node_position(pos)
	if Rotors[hash] and Rotors[hash]:get_luaentity() then
		Rotors[hash]:remove()
	end
	Rotors[hash] = nil
	Cable:after_dig_node(pos)
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

minetest.register_node("techage:ta4_wind_turbine", {
	description = S("TA4 Wind Turbine"),
	inventory_image = "techage_wind_turbine_inv.png",
	tiles = {
		-- up, down, right, left, back, front
		"techage_rotor_top.png",
		"techage_rotor_top.png^techage_appl_hole_electric.png",
		"techage_rotor.png",
		"techage_rotor.png",
		"techage_rotor.png",
		"techage_rotor.png^techage_appl_open.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_generator_data = get_generator_data,
	on_timer = node_timer,
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	ta4_formspec = techage.generator_settings("ta4", PWR_PERF),
})

power.register_nodes({"techage:ta4_wind_turbine"}, Cable, "gen", {"D"})

control.register_nodes({"techage:ta4_wind_turbine"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				local meta = M(pos)
				return {
					type = S("TA4 Wind Turbine"),
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

minetest.register_node("techage:ta4_wind_turbine_nacelle", {
	description = S("TA4 Wind Turbine Nacelle"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_rotor_top.png",
		"techage_rotor_top.png",
		"techage_rotor.png",
		"techage_rotor.png",
		"techage_rotor.png^techage_appl_open.png",
		"techage_rotor.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_entity("techage:rotor_ent", {initial_properties = {
	physical = false,
	pointable = false,
	visual = "mesh",
	visual_size = {x = 1.5, y = 1.5, z = 1.5},
	mesh = "techage_rotor.b3d",
	textures = {"techage_rotor_blades.png"},
	static_save = false,
}})

techage.register_node({"techage:ta4_wind_turbine"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "state" then
			local node = minetest.get_node(pos)
			if node.name == "ignore" then  -- unloaded node?
				return "unloaded"
			end
			if nvm.error then
				return "error"
			elseif techage.is_running(nvm) then
				return "running"
			else
				return "stopped"
			end
		elseif topic == "delivered" then
			return nvm.delivered or 0
		elseif topic == "on" then
			State:start(pos, nvm)
		elseif topic == "off" then
			State:stop(pos, nvm)
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 1 and payload[1] == 1 then
			State:start(pos, nvm)
		elseif topic == 1 and payload[1] == 0 then
			State:stop(pos, nvm)
		else
			return 2
		end
		return 0
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 129 then
			local node = minetest.get_node(pos)
			if node.name == "ignore" then  -- unloaded node?
				return 0, {techage.UNLOADED}
			end
			if nvm.error then
				return 0, {techage.FAULT}
			elseif techage.is_running(nvm) then
				return 0, {techage.RUNNING}
			else
				return 0, {techage.STOPPED}
			end
		elseif topic == 135 then  -- Delivered Power
			return 0, {nvm.delivered or 0}
		else
			return 2, ""
		end
	end,
	on_node_load = function(pos)
		local nvm = techage.get_nvm(pos)
		add_rotor(pos, nvm, true)
		start_rotor(pos, nvm)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})

minetest.register_craftitem("techage:ta4_carbon_fiber", {
	description = S("TA4 Carbon Fiber"),
	inventory_image = "techage_carbon_fiber.png",
})

minetest.register_craftitem("techage:ta4_rotor_blade", {
	description = S("TA4 Rotor Blade"),
	inventory_image = "techage_rotor_blade.png",
})


minetest.register_craft({
	output = "techage:ta4_wind_turbine",
	recipe = {
		{"dye:white", "techage:ta4_rotor_blade", "dye:red"},
		{"basic_materials:gear_steel", "techage:generator", "basic_materials:gear_steel"},
		{"techage:ta4_rotor_blade", "techage:electric_cableS", "techage:ta4_rotor_blade"},
	},
})

minetest.register_craft({
	output = "techage:ta4_wind_turbine_nacelle",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"dye:white", "techage:ta4_wlanchip", "dye:red"},
		{"", "default:copper_ingot", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_rotor_blade",
	recipe = {
		{"techage:ta4_carbon_fiber", "dye:white", "techage:ta4_carbon_fiber"},
		{"techage:canister_epoxy", "techage:ta4_carbon_fiber", "techage:canister_epoxy"},
		{"techage:ta4_carbon_fiber", "dye:red", "techage:ta4_carbon_fiber"},
	},
	replacements = {
		{"techage:canister_epoxy", "techage:ta3_canister_empty"},
		{"techage:canister_epoxy", "techage:ta3_canister_empty"},
	},
})

techage.furnace.register_recipe({
	output = "techage:ta4_carbon_fiber",
	recipe = {"default:papyrus", "default:stick", "default:papyrus", "default:stick"},
	heat = 4,
	time = 3,
})
