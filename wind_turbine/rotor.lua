--[[

	TechAge
	=======

	Copyright (C) 2019-2020 DS-Minetest, Joachim Stolberg

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

local CYCLE_TIME = 2
local PWR_PERF = 70

local Cable = techage.ElectricCable
local power = techage.power

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
	local dir = Face2Dir[param2]
	local yaw = minetest.dir_to_yaw(dir)
	dir = vector.multiply(dir, 1.1)
	pos = vector.add(pos, dir)
	return pos, {x=0, y=yaw, z=0}
end

local function check_rotor(pos, nvm)
	local resp, err = techage.valid_place_for_windturbine(pos, nil, 1)
	if not resp then
		M(pos):set_string("infotext", S("TA4 Wind Turbine")..": "..err)
		nvm.error = true
		return false
	end
	
	local npos = techage.get_pos(pos, "F")
	local node = techage.get_node_lvm(npos)
	if node.name ~= "techage:ta4_wind_turbine_nacelle" then
		M(pos):set_string("infotext", S("TA4 Wind Turbine").." "..S("Nacelle is missing"))
		nvm.error = true
		return false
	end
	
	local own_num = M(pos):get_string("node_number") or ""
	M(pos):set_string("infotext", S("TA4 Wind Turbine").." "..own_num)
	nvm.error = false
	return true
end
	
local function add_rotor(pos, nvm)
	if check_rotor(pos, nvm) then
		local hash = minetest.hash_node_position(pos)
		if not Rotors[hash] then
			local node = minetest.get_node(pos)
			local npos, yaw = pos_and_yaw(pos, node.param2)
			local obj = minetest.add_entity(npos, "techage:rotor_ent")
			obj:set_animation({x = 0, y = 119}, 0, 0, true)
			obj:set_rotation(yaw)
			Rotors[hash] = obj
		end
	end
end	

local function start_rotor(pos, nvm)
	if not nvm.error then
		nvm.providing = true
		nvm.delivered = 0
		power.generator_start(pos, Cable, CYCLE_TIME, 5)
		local hash = minetest.hash_node_position(pos)
		if Rotors[hash] then
			Rotors[hash]:set_animation_frame_speed(50)
		end
	end
end

local function stop_rotor(pos, nvm)
	nvm.providing = false
	nvm.delivered = 0
	power.generator_stop(pos, Cable, 5)
	local hash = minetest.hash_node_position(pos)
	if Rotors[hash] then
		Rotors[hash]:set_animation_frame_speed(0)
	end
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	
	if not nvm.running or nvm.error then
		return false
	end
	
	local time = minetest.get_timeofday() or 0
	if (time >= 5.00/24.00 and time <= 9.00/24.00) or (time >= 17.00/24.00 and time <= 21.00/24.00) then
		if not nvm.providing then
			start_rotor(pos, nvm)
		end
	else
		if nvm.providing then
			stop_rotor(pos, nvm)
		end
	end
	nvm.delivered = power.generator_alive(pos, Cable, CYCLE_TIME, 5, (nvm.providing and PWR_PERF) or 0)
	return true
end

local function after_place_node(pos, placer)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local own_num = techage.add_node(pos, "techage:ta4_wind_turbine")
	meta:set_string("node_number", own_num)
	meta:set_string("owner", placer:get_player_name())
	nvm.providing = false
	nvm.running = true
	add_rotor(pos, nvm)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	Cable:after_place_node(pos)
end

local function on_punch(pos, node, puncher, pointed_thing)
	if minetest.is_protected(pos, puncher:get_player_name()) then
		return
	end
	
	local nvm = techage.get_nvm(pos)
	add_rotor(pos, nvm)
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

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, outdir, tlib2)
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
	
	networks = {
		ele1 = {
			sides = {D = 1},
			ntype = "gen1",
			nominal = PWR_PERF,
			regenerative = true,
		},
	},
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	on_timer = node_timer,
	on_punch = on_punch,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})


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

Cable:add_secondary_node_names({"techage:ta4_wind_turbine"})

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
			elseif nvm.running and nvm.providing then
				return "running"
			else
				return "stopped"
			end
		elseif topic == "delivered" then
			return nvm.delivered or 0
		elseif topic == "on" then
			nvm.running = true
		elseif topic == "off" then
			nvm.running = false
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		local nvm = techage.get_nvm(pos)
		add_rotor(pos, nvm)
		nvm.providing = false  -- to force the rotor start
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
