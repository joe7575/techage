--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Heat Exchanger2 (middle part)

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control
local sched = techage.scheduler

local CYCLE_TIME = 2
local PWR_NEEDED = 5
local COUNTDOWN_TICKS = 1
local DOWN = 5  -- dir
local DESCRIPTION = S("TA5 Heat Exchanger 2")
local EXPECT_BLUE = 56
local EXPECT_GREEN = 52
local CALL_RATE1 = 16  -- 2s * 16 = 32s
local CALL_RATE2 = 8  -- 2s * 8 = 16s
local EX_POINTS = 60

local function heatexchanger1_cmnd(pos, topic, payload)
	return techage.transfer({x = pos.x, y = pos.y - 1, z = pos.z},
		nil, topic, payload, nil,
		{"techage:ta5_heatexchanger1"})
end

local function heatexchanger3_cmnd(pos, topic, payload)
	return techage.transfer({x = pos.x, y = pos.y + 1, z = pos.z},
		nil, topic, payload, nil,
		{"techage:ta5_heatexchanger3"})
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

local function count_trues(t)
	local cnt = 0
	for _,v in ipairs(t) do
		if v then
			cnt = cnt + 1
		end
	end
	return cnt
end

local tSched = {}

sched.register(tSched, CALL_RATE1, 0, function(pos)
		if not heatexchanger1_cmnd(pos, "turbine") then
			return S("Turbine error")
		end
		return true
	end)
sched.register(tSched, CALL_RATE1, 1, function(pos)
		if not heatexchanger3_cmnd(pos, "turbine") then
			return S("Cooler error")
		end
		return true
	end)
sched.register(tSched, CALL_RATE1, 2, function(pos)
		local resp = heatexchanger1_cmnd(pos, "test_gas_blue")
		local cnt = count_trues(resp)
		if cnt ~= EXPECT_BLUE then
			return S("Blue pipe connection error\n(@1 found / @2 expected)", cnt, EXPECT_BLUE)
		end
		return true
	end)
sched.register(tSched, CALL_RATE1, 3, function(pos)
		local resp = heatexchanger3_cmnd(pos, "test_gas_green")
		local cnt = count_trues(resp)
		if cnt ~= EXPECT_GREEN then
			return S("Green pipe connection error\n(@1 found / @2 expected)", cnt, EXPECT_GREEN)
		end
		return true
	end)
sched.register(tSched, CALL_RATE2, 4, function(pos)
		local resp = heatexchanger3_cmnd(pos, "dec_power")
		local cnt = count_trues(resp)
		--print("dec_power", cnt)
		if cnt < 52 then
			return 0
		end
		return 1
	end)

local function can_start(pos, nvm)
	if not power.power_available(pos, Cable, DOWN) then
		return S("No power")
	end
	heatexchanger3_cmnd(pos, "rst_power")
	for i = 0,4 do
		local res = tSched[i](pos)
		if res ~= true and res ~= 1 then return res end
	end
	return true
end

local function start_node(pos, nvm)
	play_sound(pos)
	sched.init(pos)
	nvm.temperature = nvm.temperature or 0
	local mem = techage.get_mem(pos)
	local t = minetest.get_gametime() - (mem.stopped_at or 0)
	nvm.temperature = math.max(nvm.temperature - math.floor(t/2), 0)
	nvm.temperature = math.min(nvm.temperature, 70)
end

local function stop_node(pos, nvm)
	stop_sound(pos)
	heatexchanger1_cmnd(pos, "stop")
	local mem = techage.get_mem(pos)
	mem.stopped_at = minetest.get_gametime()
end

local function temp_indicator (nvm, x, y)
	local temp = techage.is_running(nvm) and nvm.temperature or 0
	return "image["  .. x .. "," .. y .. ";1,2;techage_form_temp_bg.png^[lowpart:" ..
		temp .. ":techage_form_temp_fg.png]" ..
		"tooltip["  .. x .. "," .. y .. ";1,2;" .. S("water temperature") .. ";#0C3D32;#FFFFFF]"
end

local function formspec(self, pos, nvm)
	return "size[5,3]"..
		"box[0,-0.1;4.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", DESCRIPTION) .. "]" ..
		temp_indicator (nvm, 1, 1) ..
		"image_button[3.2,1.5;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[3.2,1.5;1,1;"..self:get_state_tooltip(nvm).."]"
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta5_heatexchanger2",
	cycle_time = CYCLE_TIME,
	infotext_name = DESCRIPTION,
	standby_ticks = 0,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
	formspec_func = formspec,
})

local function steam_management(pos, nvm)
	local resp = sched.get(pos, tSched, function() return true end)(pos)

	if resp == 0 then  -- has no power
		nvm.temperature = math.max(nvm.temperature - 10, 0)
	elseif resp == 1 then  -- has power
		nvm.temperature = math.min(nvm.temperature + 10, 100)
	elseif resp ~= true then
		State:fault(pos, nvm, resp)
		State:stop(pos, nvm)
		return false
	end

	if resp == 0 and nvm.temperature == 70 then
		heatexchanger1_cmnd(pos, "stop")
	elseif nvm.temperature == 80 then
		if resp == 1 then
			heatexchanger1_cmnd(pos, "start")
			local owner = M(pos):get_string("owner")
			minetest.log("action", "[techage] " .. owner .. " starts the TA5 Fusion Reactor at " .. P2S(pos))
		else
			heatexchanger1_cmnd(pos, "trigger")
		end
	elseif nvm.temperature > 80 then
		heatexchanger1_cmnd(pos, "trigger")
	end
	return true
end

local function consume_power(pos, nvm)
	if techage.needs_power(nvm) then
		local taken = power.consume_power(pos, Cable, DOWN, PWR_NEEDED)
		if techage.is_running(nvm) then
			if taken < PWR_NEEDED then
				State:nopower(pos, nvm, S("No power"))
				stop_sound(pos)
				heatexchanger1_cmnd(pos, "stop")
			else
				return true  -- keep running
			end
		end
	end
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.temperature = nvm.temperature or 0
	--print("node_timer", nvm.temperature)
	if consume_power(pos, nvm) then
		if steam_management(pos, nvm) then
			State:keep_running(pos, nvm, COUNTDOWN_TICKS)
		end
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return State:is_active(nvm) or nvm.temperature > 0
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
	if techage.orientate_node(pos, "techage:ta5_heatexchanger1") then
		return true
	end
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local own_num = techage.add_node(pos, "techage:ta5_heatexchanger2")
	meta:set_string("owner", placer:get_player_name())
	meta:set_string("infotext", DESCRIPTION..": "..own_num)
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

	if techage.get_expoints(player) >= EX_POINTS then
		local nvm = techage.get_nvm(pos)
		State:state_button_event(pos, nvm, fields)
		--M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
end

-- Middle node with the formspec from the bottom node
minetest.register_node("techage:ta5_heatexchanger2", {
	description = DESCRIPTION,
	tiles = {
		-- up, down, right, left, back, front
		"techage_hole_ta4.png",
		"techage_hole_ta4.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_tes_turb.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png",
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

	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

power.register_nodes({"techage:ta5_heatexchanger2"}, Cable, "con", {"D"})

techage.register_node({"techage:ta5_heatexchanger2"}, {
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
		elseif topic == "on" then
			State:start(pos, nvm)
			return true
		elseif topic == "off" then
			State:stop(pos, nvm)
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
			State:start(pos, nvm)
		end
	end,
})

control.register_nodes({"techage:ta5_heatexchanger2"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				return {
					type = DESCRIPTION,
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
	output = "techage:ta5_heatexchanger2",
	recipe = {
		{"default:tin_ingot", "", "default:steel_ingot"},
		{"", "techage:ta5_aichip2", ""},
		{"", "techage:baborium_ingot", ""},
	},
})
