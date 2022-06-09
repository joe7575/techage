--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Heat Exchanger2 (middle part)
	(alternatively used as cooler for the TA4 collider)

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local Pipe = techage.LiquidPipe
local power = networks.power
local control = networks.control

local CYCLE_TIME = 2
local GRVL_CAPA = 500
local PWR_CAPA = {
	[5] = GRVL_CAPA * 3 * 3 * 3,  -- 13500 Cyc = 450 min = 22.5 kud
	[7] = GRVL_CAPA * 5 * 5 * 5,  -- 104 kud
	[9] = GRVL_CAPA * 7 * 7 * 7,  -- 286 kuh
}
local DOWN = 5
local PWR_NEEDED = 5

local function heatexchanger1_cmnd(pos, topic, payload)
	return techage.transfer({x = pos.x, y = pos.y - 1, z = pos.z},
		nil, topic, payload, nil,
		{"techage:heatexchanger1"})
end

local function heatexchanger3_cmnd(pos, topic, payload)
	return techage.transfer({x = pos.x, y = pos.y + 1, z = pos.z},
		nil, topic, payload, nil,
		{"techage:heatexchanger3"})
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

local function cooler_formspec(self, pos, nvm)
	return "size[4,2]"..
		"box[0,-0.1;3.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", S("TA4 Heat Exchanger")) .. "]" ..
		"image_button[1.5,1;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[1.5,1;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function can_start(pos, nvm)
	-- Used as cooler for the collider?
	if heatexchanger1_cmnd(pos, "detector") then
		if power.power_available(pos, Cable, DOWN) then
			nvm.used_as_cooler = true
			return true
		else
			return S("No power")
		end
	end
	-- Used as heat exchanger
	local netID = networks.determine_netID(pos, Cable, DOWN)
	if heatexchanger1_cmnd(pos, "netID") ~= netID then
		return S("Power network connection error")
	end
	local diameter = heatexchanger1_cmnd(pos, "diameter")
	if diameter then
		nvm.capa_max = PWR_CAPA[tonumber(diameter)] or 0
		if nvm.capa_max ~= 0 then
			nvm.capa = math.min(nvm.capa or 0, nvm.capa_max)
			local owner = M(pos):get_string("owner") or ""
			return heatexchanger1_cmnd(pos, "volume", owner)
		else
			return S("wrong storage diameter") .. ": " .. diameter
		end
	else
		return S("inlet/pipe error")
	end
	return S("did you check the plan?")
end

local function start_node(pos, nvm)
	if nvm.used_as_cooler then
		play_sound(pos)
	else
		nvm.win_pos = heatexchanger1_cmnd(pos, "window")
		power.start_storage_calc(pos, Cable, DOWN)
		play_sound(pos)
		heatexchanger1_cmnd(pos, "start")
	end
end

local function stop_node(pos, nvm)
	if nvm.used_as_cooler then
		stop_sound(pos)
	else
		power.start_storage_calc(pos, Cable, DOWN)
		stop_sound(pos)
		heatexchanger1_cmnd(pos, "stop")
	end
end

local function formspec(self, pos, nvm)
	local data

	if nvm.used_as_cooler then
		return cooler_formspec(self, pos, nvm)
	end
	if techage.is_running(nvm) then
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
	if (nvm.ticks % 5) == 0 then -- every 10 saec
		glowing(pos, nvm, (nvm.capa or 0) / (nvm.capa_max or 1) > 0.8)
	end
	if (nvm.ticks % 30) == 0 then -- every minute
		return heatexchanger1_cmnd(pos, "volume")
	elseif (nvm.ticks % 30) == 10 then -- every minute
		return heatexchanger1_cmnd(pos, "diameter") ~= nil or S("inlet/pipe error")
	elseif (nvm.ticks % 30) == 20 then -- every minute
		return heatexchanger3_cmnd(pos, "diameter") ~= nil or S("inlet/pipe error")
	end
	local netID = networks.determine_netID(pos, Cable, DOWN)
	if heatexchanger1_cmnd(pos, "netID") ~= netID then
		if nvm.check_once_again then
			nvm.check_once_again = false
			return true
		else
			return S("Power network connection error")
		end
	end
	nvm.check_once_again = true
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

local function cooler_timer(pos, nvm)
	local err = false
	if power.consume_power(pos, Cable, DOWN, PWR_NEEDED) ~= PWR_NEEDED then
		State:fault(pos, nvm, "No power")
		stop_sound(pos)
		return true
	end

	-- Cyclically check pipe connections
	nvm.ticks = (nvm.ticks or 0) + 1
	if (nvm.ticks % 5) == 0 then -- every 10 s
		err = heatexchanger1_cmnd(pos, "detector") ~= true
	elseif (nvm.ticks % 5) == 1 then -- every 10 s
		err = heatexchanger3_cmnd(pos, "detector") ~= true
	elseif (nvm.ticks % 5) == 2 then -- every 10 s
		err = heatexchanger1_cmnd(pos, "cooler") ~= true
	elseif (nvm.ticks % 5) == 3 then -- every 10 s
		err = heatexchanger3_cmnd(pos, "cooler") ~= true
	end
	if err then
		State:fault(pos, nvm, "Pipe connection error")
		stop_sound(pos)
	end
	return true
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	if nvm.used_as_cooler then
		cooler_timer(pos, nvm)
		return true
	end
	local res = check_TES_integrity(pos, nvm)
	if res ~= true then
		State:fault(pos, nvm, res)
		heatexchanger1_cmnd(pos, "stop")
		power.start_storage_calc(pos, Cable, DOWN)
	end

	if techage.is_running(nvm) then
		local capa = power.get_storage_load(pos, Cable, DOWN, nvm.capa_max) or 0
		if capa > 0 then
			nvm.capa = capa
		end
	end
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
	return not techage.is_running(nvm)
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

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function get_storage_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	nvm.capa_max = nvm.capa_max or 1
	if techage.is_running(nvm) then
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
	after_dig_node = after_dig_node,
	get_storage_data = get_storage_data,

	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

power.register_nodes({"techage:heatexchanger2"}, Cable, "sto", {"D"})

techage.register_node({"techage:heatexchanger2"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "state" then
			if techage.is_running(nvm) then
				return "running"
			else
				return "stopped"
			end
		elseif topic == "delivered" then
			local data = power.get_network_data(pos, Cable, DOWN)
			return data.consumed - data.provided
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
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 1 and payload[1] == 1 then
			start_node(pos, techage.get_nvm(pos))
			return 0
		elseif topic == 1 and payload[1] == 0 then
			stop_node(pos, techage.get_nvm(pos))
			return 0
		else
			return 2, ""
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 128 then
			return 0, techage.get_node_lvm(pos).name
		elseif topic == 129 then -- State
			if techage.is_running(nvm) then
				return 0, {techage.RUNNING}
			else
				return 0, {techage.STOPPED}
			end
		elseif topic == 135 then  -- Delivered Power
			local data = power.get_network_data(pos, Cable, DOWN)
			return 0, {data.consumed - data.provided}
		elseif topic == 134 then  -- Tank Load Percent
			return 0, {techage.power.percent(nvm.capa_max, nvm.capa)}
		else
			return 2, ""
		end
	end,
	on_node_load = function(pos, node)
		local nvm = techage.get_nvm(pos)
		if techage.is_running(nvm) then
			play_sound(pos)
		else
			stop_sound(pos)
		end
		-- Attempt to restart the system as the heat exchanger goes into error state
		-- when parts of the storage block are unloaded.
		if nvm.techage_state == techage.FAULT then
			start_node(pos, nvm)
		end
	end,
})

control.register_nodes({"techage:heatexchanger2"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				return {
					type = S("TA4 Heat Exchanger"),
					number = M(pos):get_string("node_number") or "",
					running = techage.is_running(nvm) or false,
					capa = nvm.capa_max or 1,
					load = nvm.capa or 0,
				}
			end
			return false
		end,
	}
)

minetest.register_craft({
	output = "techage:heatexchanger2",
	recipe = {
		{"default:tin_ingot", "", "default:steel_ingot"},
		{"", "techage:ta4_wlanchip", ""},
		{"", "techage:baborium_ingot", ""},
	},
})
