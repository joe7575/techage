--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Heat Exchanger1 (bottom part)

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2
local PWR_PERF = 60
local GRVL_CAPA = 700
local PWR_CAPA = {
	[3] = GRVL_CAPA * 3 * 3 * 3,  -- 18900 Cyc = 630 min = 31.5 Tage bei einem ku, oder 31,5 * 24 kuh = 756 kuh = 12,6 h bei 60 ku
	[5] = GRVL_CAPA * 5 * 5 * 5,  -- ~2.5 days
	[7] = GRVL_CAPA * 7 * 7 * 7,  --   ~6 days
}

local Cable = techage.ElectricCable
local Pipe = techage.LiquidPipe
local power = techage.power
local in_range = techage.in_range

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function glowing(pos, nvm, should_glow)
	if nvm.win_pos then
		if should_glow then
			swap_node(nvm.win_pos, "techage:glow_gravel")
		else
			swap_node(nvm.win_pos, "default:gravel")
		end
	end
end

local function turbine_cmnd(pos, topic, payload)
	return techage.transfer(pos, "R", topic, payload, Pipe,
		{"techage:ta4_turbine", "techage:ta4_turbine_on"})
end

local function inlet_cmnd(pos, topic, payload)
	return techage.transfer(pos, "L", topic, payload, Pipe,
		{"techage:ta4_pipe_inlet"})
end

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_booster", {
			pos = pos, 
			gain = 0.3,
			max_hear_distance = 10,
			loop = true})
		if mem.handle == -1 then
			minetest.after(1, play_sound, pos)
		end
	end
	local nvm = techage.get_nvm(pos)
	nvm.charging = true
end

local function stop_sound(pos)
	local mem = techage.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
	local nvm = techage.get_nvm(pos)
	nvm.charging = false
end

local function on_power(pos)
end

local function on_nopower(pos)
end

local function is_running(pos, nvm) 
	return nvm.charging 
end

local function start_node(pos, nvm)
	nvm.running = true
	nvm.needed = 0
	nvm.win_pos = inlet_cmnd(pos, "window")
	power.consumer_start(pos, Cable, CYCLE_TIME)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	return true
end

local function stop_node(pos, nvm)
	nvm.running = false
	nvm.needed = 0
	power.consumer_stop(pos, Cable)
	minetest.get_node_timer(pos):stop()
	stop_sound(pos)
	return true
end

local function after_place_node(pos, placer, itemstack)
	local nvm = techage.get_nvm(pos)
	nvm.capa = 0
	M(pos):set_string("owner", placer:get_player_name())
	local number = techage.add_node(pos, "techage:heatexchanger1")
	M(pos):set_string("node_number", number)
	M(pos):set_string("infotext", S("TA4 Heat Exchanger 1").." "..number)
	Cable:after_place_node(pos)
	Pipe:after_place_node(pos)
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local nvm = techage.get_nvm(pos)
	return not nvm.running
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Cable:after_dig_node(pos)
	Pipe:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	nvm.running = false
end

local function can_start(pos, nvm)
	-- the heat exchanger shall be able to start even without
	-- having power. Therefore, no "if power.power_available(pos, Cable) then"
	local diameter = inlet_cmnd(pos, "diameter")
	if diameter then
		nvm.capa_max = PWR_CAPA[tonumber(diameter)] or 0
		if nvm.capa_max ~= 0 then
			local owner = M(pos):get_string("owner") or ""
			return inlet_cmnd(pos, "volume", owner)
		else
			return S("wrong storage diameter")..": "..diameter
		end
	else
		return S("inlet/pipe error")
	end
	return S("did you check the plan?")
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.capa = nvm.capa or 0
	nvm.capa_max = nvm.capa_max or 0
	local taken = 0
	local given = 0
	
	if nvm.capa < (nvm.capa_max * 0.9) and not nvm.charging then
		taken = power.consumer_alive(pos, Cable, CYCLE_TIME)
	elseif nvm.capa < nvm.capa_max and nvm.charging then
		taken = power.consumer_alive(pos, Cable, CYCLE_TIME)
	end
	if nvm.capa > 0 then
		given = turbine_cmnd(pos, "trigger") or 0
	end
	
	if taken > 0 and not nvm.charging then
		play_sound(pos)
	elseif taken == 0 and nvm.charging then
		stop_sound(pos)
	end
	
	nvm.needed = taken - given
	nvm.capa = in_range(nvm.capa + nvm.needed, 0, nvm.capa_max)
	glowing(pos, nvm, nvm.capa > nvm.capa_max * 0.8)
	--print("node_timer TES "..P2S(pos), nvm.needed, nvm.capa, nvm.capa_max)
	return true		
end

local net_def = {
	ele1 = {
		sides = {F = 1, B = 1},
		ntype = "con2",
		nominal = PWR_PERF,
		on_power = on_power,
		on_nopower = on_nopower,
		is_running = is_running,
	},
	pipe2 = {
		sides = {L = 1, R = 1},
		ntype = "con1",
	},
}

minetest.register_node("techage:heatexchanger1", {
	description = S("TA4 Heat Exchanger 1"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_hole_ta4.png^techage_appl_arrow_white.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
	},
	
	on_timer = node_timer,
	after_place_node = after_place_node,
	can_dig = can_dig,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,
	
	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:heatexchanger1"})
Cable:add_secondary_node_names({"techage:heatexchanger1"})

-- command interface
techage.register_node({"techage:heatexchanger1"}, {
	on_transfer = function(pos, indir, topic, payload)
		local nvm = techage.get_nvm(pos)
		-- used by heatexchanger2
		if topic == "state" then
			return (nvm.capa_max or 0), (nvm.capa or 0), PWR_PERF, math.max(nvm.needed or 0, 0)
		elseif topic == "integrity" then
			return inlet_cmnd(pos, "volume", payload)
		elseif topic == "state" then
			return inlet_cmnd(pos, "volume", payload)
		elseif topic == "can_start" then
			return can_start(pos, nvm)
		elseif topic == "start" then
			return start_node(pos, nvm)
		elseif topic == "stop" then
			return stop_node(pos, nvm)
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "state" then
			if nvm.charging then
				return "running"
			elseif nvm.running then
				return "standby"
			else
				return "stopped"
			end
		elseif topic == "delivered" then
			return -math.max(nvm.needed or 0, 0)
		elseif topic == "load" then
			return techage.power.percent(nvm.capa_max, nvm.capa)
		elseif topic == "on" then
			start_node(pos, techage.get_nvm(pos))
			return true
		elseif topic == "off" then
			stop_node(pos, techage.get_nvm(pos))
			return true
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos, node)
		local nvm = techage.get_nvm(pos)
		if nvm.running and nvm.charging then
			play_sound(pos)
		else
			stop_sound(pos)
		end	
		local mem = tubelib2.get_mem(pos)
		nvm.capa = (nvm.capa or 0) + (mem.capa or 0)
		--tubelib2.del_mem(pos)
	end,
})

minetest.register_craft({
	output = "techage:heatexchanger1",
	recipe = {
		{"default:tin_ingot", "techage:electric_cableS", "default:steel_ingot"},
		{"techage:ta4_pipeS", "basic_materials:gear_steel", "techage:ta4_pipeS"},
		{"", "techage:baborium_ingot", ""},
	},
})

