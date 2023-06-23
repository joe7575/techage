--[[

	TechAge
	=======

	Copyright (C) 2017-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Gaze Sensor

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic
local CYCLE_TIME = 2
local DESCR = S("TA4 Gaze Sensor")
local MAX_PLAYER_DIST = 30

local WRENCH_MENU = {
	{
		type = "ascii",
		name = "names",
		label = S("Player Names"),
		tooltip = S("Input the player name(s) separated by blanks.\nIf empty, only the owner is accepted."),
		default = "",
	},
	{
		type = "numbers",
		name = "numbers",
		label = S("Number"),
		tooltip = S("Destination block number(s)"),
		default = "",
		check = techage.check_numbers,
	},
	{
		type = "ascii",
		name = "command1",
		label = "On " .. S("Command"),
		tooltip = S("Command to send when sensor is viewed"),
		default = "on",
	},
	{
		type = "ascii",
		name = "command2",
		label = "Off " .. S("Command"),
		tooltip = S("Command to send when sensor is no longer viewed"),
		default = "off",
	},
}

local function switch_on(pos)
	if logic.swap_node(pos, "techage:ta4_gaze_sensor_on") then
		logic.send_cmnd(pos, "command1", "on")
	end
end

local function switch_off(pos)
	if logic.swap_node(pos, "techage:ta4_gaze_sensor_off") then
		logic.send_cmnd(pos, "command2", "off")
	end
end

local function get_players(pos)
	local meta = minetest.get_meta(pos)
	local names = meta:get_string("names") or ""
	local t = string.split(names, " ") or {}
	t[#t + 1] = meta:get_string("owner")
	return t
end

local function player_focuses_block(pos, name, obj)
	obj = obj or minetest.get_player_by_name(name)
	if obj then
		local player_pos = obj:get_pos()
		player_pos.y = player_pos.y + 1.5
		local dist = vector.distance(pos, player_pos)
		if dist < MAX_PLAYER_DIST then
			local dir = obj:get_look_dir()
			if dir then
				local vec1 = vector.multiply(dir, dist)
				local pos1 = vector.round(vector.add(player_pos, vec1))
				if vector.equals(pos, pos1) then
					local item = obj:get_wielded_item()
					if not item or item:get_name() ~= "techage:end_wrench" then
						return true
					end
				end
			end
		end
	end
	return false
end

local function scan_for_player(pos)
	local mem = techage.get_mem(pos)
	mem.players = mem.players or get_players(pos)
	if mem.players[1] == "***" then
		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, MAX_PLAYER_DIST)) do
			if player_focuses_block(pos, "", obj) then
				mem.player_name = obj:get_player_name()
				return true
			end
		end
	else
		for _, name in ipairs(mem.players) do
			if player_focuses_block(pos, name, nil) then
				mem.player_name = name
				return true
			end
		end
	end
	mem.player_name = ""
	return false
end

local function ta_after_formspec(pos, fields, playername)
	if fields.save then
		local mem = techage.get_mem(pos)
		mem.players = nil
	end
end

minetest.register_node("techage:ta4_gaze_sensor_off", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_gaze_sensor.png",
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta4_gaze_sensor_off", DESCR)
		logic.infotext(meta, DESCR)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_timer = function (pos, elapsed)
		if scan_for_player(pos) then
			switch_on(pos)
		end
		return true
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return logic.set_numbers(pos, numbers, player_name, DESCR)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	ta4_formspec = WRENCH_MENU,
	ta_after_formspec = ta_after_formspec,
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta4_gaze_sensor_on", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_gaze_sensor_on.png",
	},

	on_timer = function (pos, elapsed)
		if not scan_for_player(pos) then
			switch_off(pos)
		end
		return true
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return logic.set_numbers(pos, numbers, player_name, DESCR)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	ta4_formspec = WRENCH_MENU,
	ta_after_formspec = ta_after_formspec,
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta4_gaze_sensor_off"
})

minetest.register_craft({
	output = "techage:ta4_gaze_sensor_off",
	recipe = {
		{"dye:blue", "techage:aluminum", "dye:blue"},
		{"default:copper_ingot", "techage:ta4_wlanchip", "default:wood"},
	},
})

techage.register_node({
		"techage:ta4_gaze_sensor_off", "techage:ta4_gaze_sensor_on",
	}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "name" then
				local mem = techage.get_mem(pos)
				return mem.player_name or ""
			elseif topic == "state" then
				local node = techage.get_node_lvm(pos)
				if node.name == "techage:ta4_gaze_sensor_on" then
					return "on"
				else
					return "off"
				end
			else
				return "unsupported"
			end
		end,
		on_beduino_request_data = function(pos, src, topic, payload)
			if topic == 144 then  -- Player Name
				local mem = techage.get_mem(pos)
				return 0, mem.player_name or ""
			elseif topic == 142 then  -- Binary State
				local node = techage.get_node_lvm(pos)
				if node.name == "techage:ta4_gaze_sensor_on" then
					return 0, {1}
				else
					return 0, {0}
				end
			else
				return 2, ""
			end
		end,
		on_node_load = function(pos)
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end,
	}
)
