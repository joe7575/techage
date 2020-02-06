--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Heat Exchanger

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

local function in_range(val, min, max)
	if val < min then return min end
	if val > max then return max end
	return val
end

-- commands for 'techage:heatexchanger1'
local function turbine_cmnd(pos, cmnd)
	return techage.transfer(
		pos, 
		"R",  -- outdir
		cmnd,  -- topic
		nil,  -- payload
		Pipe,  -- Pipe
		{"techage:ta4_turbine", "techage:ta4_turbine_on"})
end

local function heatexchanger3_cmnd(pos, cmnd)
	return techage.transfer(
		{x = pos.x, y = pos.y + 1, z = pos.z}, 
		"U",  -- outdir
		cmnd,  -- topic
		nil,  -- payload
		nil,  -- Pipe
		{"techage:heatexchanger3"})
end

local function inlet_cmnd(pos, cmnd, payload)
	return techage.transfer(
		pos, 
		"L",  -- outdir
		cmnd,  -- topic
		payload,  -- payload
		Pipe,  -- Pipe
		{"techage:ta4_pipe_inlet"})
end

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_booster", {
			pos = pos, 
			gain = 0.5,
			max_hear_distance = 10,
			loop = true})
		if mem.handle == -1 then
			minetest.after(1, play_sound, pos)
		end
	end
end

local function stop_sound(pos)
	local mem = techage.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function charging(pos, nvm, is_charging)
	if nvm.capa >= nvm.capa_max then
		return
	end
	if is_charging ~= nvm.was_charging then
		nvm.was_charging = is_charging
		if is_charging then
			turbine_cmnd(pos, "stop")
			play_sound(pos)
		else
			turbine_cmnd(pos, "start")
			stop_sound(pos)
		end
	elseif is_charging then
		play_sound(pos)
	end
end

local function delivering(pos, nvm, delivered)
	if nvm.capa <= 0 then
		return
	end
	if delivered ~= nvm.had_delivered then
		nvm.had_delivered = delivered
		if delivered > 0 then
			turbine_cmnd(pos, "start")
		elseif delivered == 0 then
			turbine_cmnd(pos, "stop")
		end
	end
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

local function formspec(self, pos, nvm)
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[0,0.5;1,2;"..techage.power.formspec_power_bar(nvm.capa_max, nvm.capa).."]"..
		"label[0.2,2.5;Load]"..
		"button[1.1,1;1.8,1;update;"..S("Update").."]"..
		"image_button[3,1;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"image[4,0.5;1,2;"..techage.power.formspec_load_bar(-(nvm.delivered or 0), PWR_PERF).."]"..
		"label[4.2,2.5;Flow]"
end

local function error_info(pos, err)
	local own_num = M(pos):get_string("node_number")
	local pos1 = {x = pos.x, y = pos.y + 1, z = pos.z}
	M(pos1):set_string("infotext", S("TA4 Heat Exchanger").." "..own_num.." : "..err)
end

local function can_start(pos, nvm, state)
	if turbine_cmnd(pos, "power") then
		local diameter = inlet_cmnd(pos, "diameter")
		if diameter then
			nvm.capa_max = PWR_CAPA[tonumber(diameter)] or 0
			if nvm.capa_max ~= 0 then
				local owner = M(pos):get_string("owner") or ""
				if inlet_cmnd(pos, "volume", owner) then
					error_info(pos, "")
					return true
				else
					error_info(pos, "storage volume error")
					return false
				end
			else
				error_info(pos, "wrong storage diameter: "..diameter)
				return false
			end
		else
			error_info(pos, "inlet/pipe error")
			return false
		end
	else
		error_info(pos, "power network error")
		return false
	end
	return false
end

local function start_node(pos, nvm, state)
	nvm.running = true
	nvm.delivered = 0
	nvm.was_charging = true
	nvm.had_delivered = nil
	play_sound(pos)
	nvm.win_pos = inlet_cmnd(pos, "window")
	power.secondary_start(pos, nvm, PWR_PERF, PWR_PERF)
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	nvm.delivered = 0
	turbine_cmnd(pos, "stop")
	power.secondary_stop(pos, nvm)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:heatexchanger1",
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	if nvm.running and turbine_cmnd(pos, "power") then
		nvm.capa = nvm.capa or 0
		nvm.capa_max = nvm.capa_max or 0
		nvm.delivered = nvm.delivered or 0
		nvm.delivered = power.secondary_alive(pos, nvm, nvm.capa, nvm.capa_max)
		nvm.capa = nvm.capa - nvm.delivered
		nvm.capa = in_range(nvm.capa, 0, nvm.capa_max)
		glowing(pos, nvm, nvm.capa > nvm.capa_max * 0.8)
		charging(pos, nvm, nvm.delivered < 0)
		delivering(pos, nvm, nvm.delivered) 
	end
	return nvm.running
end

local function can_dig(pos, player)
	local nvm = techage.get_nvm(pos)
	return not nvm.running
end

local function orientate_node(pos, name)
	local node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
	if node.name == name then
		local param2 = node.param2
		node = minetest.get_node(pos)
		node.param2 = param2
		minetest.swap_node(pos, node)
	else
		minetest.remove_node(pos)
		return true
	end
end

-- Top
minetest.register_node("techage:heatexchanger3", {
	description = S("TA4 Heat Exchanger 3"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_hole_ta4.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_ribsT.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_ribsT.png",
	},
	
	after_place_node = function(pos, placer)
		return orientate_node(pos, "techage:heatexchanger2")
	end,
	
	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

-- Middle node with the formspec from the bottom node
minetest.register_node("techage:heatexchanger2", {
	description = S("TA4 Heat Exchanger 2"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_hole_ta4.png",
		"techage_hole_ta4.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_tes_turb.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_tes_core.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_ribsB.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_ribsB.png",
	},
	
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1.5/2, -1/2, 1/2, 1/2, 1/2},
	},
	
	after_place_node = function(pos, placer)
		if orientate_node(pos, "techage:heatexchanger1") then
			return true
		end
		local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}
		local nvm = techage.get_nvm(pos1)
		local own_num = M(pos1):get_string("node_number")
		M(pos):set_string("formspec", formspec(State, pos1, nvm))
		M(pos):set_string("infotext", S("TA4 Heat Exchanger").." "..own_num)
	end,
	
	on_rightclick = function(pos)
		local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}
		local nvm = techage.get_nvm(pos1)
		M(pos):set_string("formspec", formspec(State, pos1, nvm))
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}
		local nvm = techage.get_nvm(pos1)
		State:state_button_event(pos1, nvm, fields)
		M(pos):set_string("formspec", formspec(State, pos1, nvm))
	end,

	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

-- Base
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
	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

techage.power.register_node({"techage:heatexchanger1"}, {
	conn_sides = {"F", "B"},
	power_network  = Cable,
	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		local meta = M(pos)
		local own_num = techage.add_node(pos, "techage:heatexchanger1")
		meta:set_string("owner", placer:get_player_name())
		State:node_init(pos, nvm, own_num)
		nvm.capa = 0
	end,
})

Pipe:add_secondary_node_names({"techage:heatexchanger1", "techage:heatexchanger3"})

-- for logical communication
techage.register_node({"techage:heatexchanger1"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "load" then
			return techage.power.percent(nvm.capa_max, nvm.capa)
		elseif topic == "size" then
			return (nvm.capa_max or 0) / GRVL_CAPA
		else
			return State:on_receive_message(pos, topic, payload)
		end
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

minetest.register_craft({
	output = "techage:heatexchanger2",
	recipe = {
		{"default:tin_ingot", "", "default:steel_ingot"},
		{"", "techage:ta4_wlanchip", ""},
		{"", "techage:baborium_ingot", ""},
	},
})

minetest.register_craft({
	output = "techage:heatexchanger3",
	recipe = {
		{"default:tin_ingot", "dye:blue", "default:steel_ingot"},
		{"techage:ta4_pipeS", "basic_materials:gear_steel", "techage:ta4_pipeS"},
		{"", "techage:baborium_ingot", ""},
	},
})

