--[[

	TechAge
	=======

	Copyright (C) 2019 DS-Minetest, Joachim Stolberg

	GPL v3
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
local PWR_PERF = 80

local Cable = techage.ElectricCable
local power = techage.power

local Rotors = {}

local MAX_NUM_FOREIGN_NODES = 50

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

local function add_rotor(pos, mem, player_name)
	mem.error = false
	
	-- Check for next wind turbine
	local pos1 = {x=pos.x-13, y=pos.y-9, z=pos.z-13}
	local pos2 = {x=pos.x+13, y=pos.y+10, z=pos.z+13}
	local num = #minetest.find_nodes_in_area(pos1, pos2, {"techage:ta4_wind_turbine"})
	if num > 1 then
		if player_name then
			techage.mark_region(player_name, pos1, pos2, "")
			minetest.chat_send_player(player_name, S("[TA4 Wind Turbine]")..
				" "..S("The wind turbines are too close together!"))
		end
		M(pos):set_string("infotext", S("TA4 Wind Turbine").." "..S("Error"))
		mem.error = true
		return
	end
	
	-- Check for water surface (occean)
	pos1 = {x=pos.x-20, y=0, z=pos.z-20}
	pos2 = {x=pos.x+20, y=1, z=pos.z+20}
	local num = #minetest.find_nodes_in_area(pos1, pos2, {"default:water_source", "default:water_flowing", "ignore"})
	if num < (41*41*2-MAX_NUM_FOREIGN_NODES) then
		if player_name then
			techage.mark_region(player_name, pos1, pos2, "")
			minetest.chat_send_player(player_name, S("[TA4 Wind Turbine]")..
				" "..S("More water expected (2 m deep)!"))
		end
		M(pos):set_string("infotext", S("TA4 Wind Turbine").." "..S("Error"))
		mem.error = true
		return
	end
	
	if pos.y < 12 or pos.y > 20 then
		if player_name then
			pos1 = {x=pos.x-13, y=12, z=pos.z-13}
			pos2 = {x=pos.x+13, y=20, z=pos.z+13}
			techage.mark_region(player_name, pos1, pos2, "")
			minetest.chat_send_player(player_name, S("[TA4 Wind Turbine]")..
				" "..S("No wind at this altitude!"))
		end
		M(pos):set_string("infotext", S("TA4 Wind Turbine").." "..S("Error"))
		mem.error = true
		return
	end
	
	local hash = minetest.hash_node_position(pos)
	if not Rotors[hash] then
		local node = minetest.get_node(pos)
		local npos, yaw = pos_and_yaw(pos, node.param2)
		local obj = minetest.add_entity(npos, "techage:rotor_ent")
		obj:set_animation({x = 0, y = 119}, 0, 0, true)
		obj:set_rotation(yaw)
		Rotors[hash] = obj
	end
	
	local own_num = M(pos):get_string("node_number") or ""
	M(pos):set_string("infotext", S("TA4 Wind Turbine").." "..own_num)
end	

local function start_rotor(pos, mem)
	local npos = techage.get_pos(pos, "F")
	local node = minetest.get_node(npos)
	if node.name ~= "techage:ta4_wind_turbine_nacelle" then
		M(pos):set_string("infotext", S("TA4 Wind Turbine").." "..S("Error"))
		mem.error = true
		return
	end
	
	mem.providing = true
	mem.delivered = 0
	power.generator_start(pos, mem, PWR_PERF)
	local hash = minetest.hash_node_position(pos)
	if Rotors[hash] then
		Rotors[hash]:set_animation_frame_speed(50)
	end
end

local function stop_rotor(pos, mem)
	mem.providing = false
	mem.delivered = 0
	power.generator_stop(pos, mem)
	local hash = minetest.hash_node_position(pos)
	if Rotors[hash] then
		Rotors[hash]:set_animation_frame_speed(0)
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	
	if not mem.running then
		return false
	end
	
	local time = minetest.get_timeofday() or 0
	if (time >= 5.00/24.00 and time <= 9.00/24.00) or (time >= 17.00/24.00 and time <= 21.00/24.00) then
		if not mem.providing then
			start_rotor(pos, mem)
		end
	else
		if mem.providing then
			stop_rotor(pos, mem)
		end
	end
	if mem.providing then
		mem.delivered = power.generator_alive(pos, mem)
	end
	return true
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
	
	on_timer = node_timer,
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

techage.power.register_node({"techage:ta4_wind_turbine"}, {
	power_network  = Cable,
	conn_sides = {"D"},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		local own_num = techage.add_node(pos, "techage:ta4_wind_turbine")
		meta:set_string("node_number", own_num)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA4 Wind Turbine").." "..own_num)
		mem.providing = false
		mem.running = true
		add_rotor(pos, mem, placer:get_player_name())
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
	
	after_dig_node = function(pos)
		local hash = minetest.hash_node_position(pos)
		if Rotors[hash] and Rotors[hash]:get_luaentity() then
			Rotors[hash]:remove()
		end
		Rotors[hash] = nil
		techage.remove_node(pos)
		tubelib2.del_mem(pos)
	end,
})

techage.register_node({"techage:ta4_wind_turbine"}, {	
	on_recv_message = function(pos, src, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "state" then
			local node = minetest.get_node(pos)
			if node.name == "ignore" then  -- unloaded node?
				return "unloaded"
			end
			if mem.error then
				return "error"
			elseif mem.running and mem.providing then
				return "running"
			else
				return "stopped"
			end
		elseif topic == "on" then
			mem.running = true
		elseif topic == "off" then
			mem.running = false
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		local mem = tubelib2.get_mem(pos)
		add_rotor(pos, mem)
		mem.providing = false  -- to force the rotor start
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})

minetest.register_craftitem("techage:ta4_epoxy", {
	description = S("TA4 Epoxide Resin"),
	inventory_image = "techage_epoxy.png",
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
		{"techage:ta4_epoxy", "techage:ta4_carbon_fiber", "techage:ta4_epoxy"},
		{"techage:ta4_carbon_fiber", "dye:red", "techage:ta4_carbon_fiber"},
	},
})

techage.furnace.register_recipe({
	output = "techage:ta4_carbon_fiber", 
	recipe = {"default:papyrus", "default:stick", "default:papyrus", "default:stick"}, 
	heat = 4,
	time = 3,
})

techage.furnace.register_recipe({
	output = "techage:ta4_epoxy", 
	recipe = {"basic_materials:oil_extract", "techage:oil_source", 
		"basic_materials:oil_extract", "techage:oil_source"}, 
	heat = 4,
	time = 3,
})
