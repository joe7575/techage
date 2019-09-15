--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

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
	[4] = GRVL_CAPA * 5 * 5 * 5,  -- ~2.5 days
	[5] = GRVL_CAPA * 7 * 7 * 7,  --   ~6 days
}

local Cable = techage.ElectricCable
local Pipe = techage.BiogasPipe
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
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		mem.handle = minetest.sound_play("techage_booster", {
			pos = pos, 
			gain = 0.5,
			max_hear_distance = 10})
	end
end

local function stop_sound(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.running and mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function charging(pos, mem, is_charging)
	if mem.capa >= mem.capa_max then
		return
	end
	if is_charging ~= mem.was_charging then
		mem.was_charging = is_charging
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

local function glowing(pos, mem, should_glow)
	if mem.win_pos then
		if should_glow then
			swap_node(mem.win_pos, "techage:glow_gravel")
		else
			swap_node(mem.win_pos, "default:gravel")
		end
	end
end

local function formspec(self, pos, mem)
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[0,0.5;1,2;"..techage.power.formspec_power_bar(mem.capa_max, mem.capa).."]"..
		"label[0.2,2.5;Load]"..
		"button[1.1,1;1.8,1;update;"..S("Update").."]"..
		"image_button[3,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"image[4,0.5;1,2;"..techage.power.formspec_load_bar(-(mem.delivered or 0), PWR_PERF).."]"..
		"label[4.2,2.5;Flow]"
end

local function can_start(pos, mem, state)
	if turbine_cmnd(pos, "power") then
		local radius = inlet_cmnd(pos, "radius")
		if radius then
			mem.capa_max = PWR_CAPA[tonumber(radius)] or 0
			local owner = M(pos):get_string("owner") or ""
			return inlet_cmnd(pos, "volume", owner)
		end
	end
	return false
end

local function start_node(pos, mem, state)
	mem.running = true
	mem.delivered = 0
	mem.was_charging = true
	play_sound(pos)
	mem.win_pos = inlet_cmnd(pos, "window")
	power.secondary_start(pos, mem, PWR_PERF, PWR_PERF)
end

local function stop_node(pos, mem, state)
	mem.running = false
	mem.delivered = 0
	turbine_cmnd(pos, "stop")
	power.secondary_stop(pos, mem)
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
	local mem = tubelib2.get_mem(pos)
	if mem.running and turbine_cmnd(pos, "power") then
		mem.capa = mem.capa or 0
		mem.capa_max = mem.capa_max or 0
		mem.delivered = mem.delivered or 0
		mem.delivered = power.secondary_alive(pos, mem, mem.capa, mem.capa_max)
		mem.capa = mem.capa - mem.delivered
		mem.capa = in_range(mem.capa, 0, mem.capa_max)
		glowing(pos, mem, mem.capa > mem.capa_max * 0.8)
		charging(pos, mem, mem.delivered < 0)
	end
	return mem.running
end

local function can_dig(pos, player)
	local mem = tubelib2.get_mem(pos)
	return not mem.running
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
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_hole_biogas.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_hole_biogas.png",
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
		local mem = tubelib2.get_mem(pos1)
		local own_num = M(pos1):get_string("node_number")
		M(pos):set_string("formspec", formspec(State, pos1, mem))
		M(pos):set_string("infotext", S("TA4 Heat Exchanger").." "..own_num)
	end,
	
	on_rightclick = function(pos)
		local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}
		local mem = tubelib2.get_mem(pos1)
		M(pos):set_string("formspec", formspec(State, pos1, mem))
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}
		local mem = tubelib2.get_mem(pos1)
		State:state_button_event(pos1, mem, fields)
		M(pos):set_string("formspec", formspec(State, pos1, mem))
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
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_biogas.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_biogas.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
	},
	
	on_construct = tubelib2.init_mem,
	
	after_place_node = function(pos, placer)
		-- secondary 'after_place_node', called by power. Don't use tubelib2.init_mem(pos)!!!
		local mem = tubelib2.get_mem(pos)
		local meta = M(pos)
		local own_num = techage.add_node(pos, "techage:heatexchanger1")
		meta:set_string("owner", placer:get_player_name())
		State:node_init(pos, mem, own_num)
		mem.capa = 0
	end,
	
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
})

Pipe:add_secondary_node_names({"techage:heatexchanger1", "techage:heatexchanger3"})

-- for logical communication
techage.register_node({"techage:heatexchanger1"}, {
	on_recv_message = function(pos, src, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "capa" then
			return mem.capa or 0
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

--techage.register_entry_page("ta2", "boiler1",
--	S("TA2 Boiler Base"), 
--	S("Part of the steam engine. Has to be placed on top of the Firebox and filled with water.@n"..
--	"(see Steam Engine)"), "techage:boiler1")

--techage.register_entry_page("ta2", "boiler2",
--	S("TA2 Boiler Top"), 
--	S("Part of the steam engine. Has to be placed on top of TA2 Boiler Base.@n(see Steam Engine)"), 
--	"techage:boiler2")

