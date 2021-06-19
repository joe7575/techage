--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA4 Heat Exchanger2 (middle part)

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local Pipe = techage.LiquidPipe
local power = networks.power

local CYCLE_TIME = 2
local GRVL_CAPA = 500
local PWR_CAPA = {
	[5] = GRVL_CAPA * 3 * 3 * 3,  -- 13500 Cyc = 450 min = 22.5 kud
	[7] = GRVL_CAPA * 5 * 5 * 5,  -- 104 kud
	[9] = GRVL_CAPA * 7 * 7 * 7,  -- 286 kuh
}
local DOWN = 5

local function heatexchanger1_cmnd(pos, topic, payload)
	return techage.transfer({x = pos.x, y = pos.y - 1, z = pos.z}, 
		nil, topic, payload, nil,
		{"techage:heatexchanger1"})
end

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
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
end

local function stop_sound(pos)
	local mem = techage.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function can_start(pos, nvm)
	local netID = networks.determine_netID(pos, Cable, DOWN)
	if heatexchanger1_cmnd(pos, "netID") ~= netID then
		return S("Power network connection error")
	end
	local diameter = heatexchanger1_cmnd(pos, "diameter")
	if diameter then
		nvm.capa_max = PWR_CAPA[tonumber(diameter)] or 0
		if nvm.capa_max ~= 0 then
			local owner = M(pos):get_string("owner") or ""
			return heatexchanger1_cmnd(pos, "volume", owner)
		else
			return S("wrong storage diameter")..": "..diameter
		end
	else
		return S("inlet/pipe error")
	end
	return S("did you check the plan?")
end

local function start_node(pos, nvm)
	nvm.running = true
	nvm.win_pos = heatexchanger1_cmnd(pos, "window")
	power.start_storage_calc(pos, Cable, DOWN)
	play_sound(pos)
	heatexchanger1_cmnd(pos, "start")
end

local function stop_node(pos, nvm)
	nvm.running = false
	power.start_storage_calc(pos, Cable, DOWN)
	stop_sound(pos)
	heatexchanger1_cmnd(pos, "stop")
end

local function formspec(self, pos, nvm)
	local data
	
	if nvm.running then
		data = power.get_network_data(pos, Cable, DOWN)
	end
	return techage.storage_formspec(self, pos, nvm, S("TA4 Heat Exchanger"), data, nvm.capa, nvm.capa_max)
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

local function check_TES_integrity(pos, nvm)
	nvm.ticks = (nvm.ticks or 0) + 1
	if (nvm.ticks % 100) == 0 then -- not to often
		return heatexchanger1_cmnd(pos, "volume")
	end
	local netID = networks.determine_netID(pos, Cable, DOWN)
	if heatexchanger1_cmnd(pos, "netID") ~= netID then
		return S("Power network connection error")
	end
	return true
end	

local State = techage.NodeStates:new({
	node_name_passive = "techage:heatexchanger2",
	cycle_time = CYCLE_TIME,
	infotext_name = S("TA4 Heat Exchanger"),
	standby_ticks = 0,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
	formspec_func = formspec,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local res = check_TES_integrity(pos, nvm)
	if res ~= true then
		State:fault(pos, nvm, res)
		heatexchanger1_cmnd(pos, "stop")
	end
	
	nvm.capa = power.get_storage_load(pos, Cable, DOWN, nvm.capa_max)
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return true		
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local nvm = techage.get_nvm(pos)
	return not nvm.running
end

local function on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function after_place_node(pos, placer)
	if techage.orientate_node(pos, "techage:heatexchanger1") then
		return true
	end
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local own_num = techage.add_node(pos, "techage:heatexchanger1")
	meta:set_string("owner", placer:get_player_name())
	meta:set_string("infotext", S("TA4 Heat Exchanger")..": "..own_num)
	meta:set_string("formspec", formspec(State, pos, nvm))
	Cable:after_place_node(pos, {DOWN})
	State:node_init(pos, nvm, own_num)
end
	
local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function get_storage_data(pos, tlib2)
	local nvm = techage.get_nvm(pos)
	nvm.capa_max = nvm.capa_max or 0
	if nvm.running then
		return {level = (nvm.capa or 0) / nvm.capa_max, capa = nvm.capa_max}
	end
end

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
	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	can_dig = can_dig,
	get_storage_data = get_storage_data,

	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

power.register_nodes({"techage:heatexchanger2"}, Cable, "sto", {"D"})

minetest.register_craft({
	output = "techage:heatexchanger2",
	recipe = {
		{"default:tin_ingot", "", "default:steel_ingot"},
		{"", "techage:ta4_wlanchip", ""},
		{"", "techage:baborium_ingot", ""},
	},
})
