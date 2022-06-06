--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Streetlamp Solar Cell

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2
local PWR_PERF = 1
local PWR_CAPA = 2400 -- ticks (2s) with 1 ku ==> 80 min = 4 game days

local Cable = techage.ElectricCable
local power = networks.power

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.capa = nvm.capa or 0
	pos.y = pos.y + 1
	local light = minetest.get_node_light(pos) or 0
	local t = minetest.get_timeofday()
	pos.y = pos.y - 1

	if t > 0.25 and t < 0.75 then
		if nvm.providing then
			nvm.providing = false
			nvm.provided = 0
		end
		if light >= (minetest.LIGHT_MAX - 1) then
			nvm.capa = math.min(nvm.capa + PWR_PERF * 1.2, PWR_CAPA)
		end
	else
		if nvm.capa > 0 then
			if not nvm.providing then
				power.start_storage_calc(pos, Cable, 5)
				nvm.providing = true
			else
				nvm.provided = power.provide_power(pos, Cable, 5, PWR_PERF)
				nvm.capa = nvm.capa - nvm.provided
			end
		else
			power.start_storage_calc(pos, Cable, 5)
			nvm.providing = false
			nvm.provided = 0
			nvm.capa = 0
		end
	end
	return true
end

local function after_place_node(pos)
	local meta = M(pos)
	local number = techage.add_node(pos, "techage:ta4_solar_minicell")
	meta:set_string("node_number", number)
	meta:set_string("infotext", S("TA4 Streetlamp Solar Cell").." "..number)
	local nvm = techage.get_nvm(pos)
	nvm.capa = 0
	nvm.providing = false
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode, oldmetadata)
	Cable:after_dig_node(pos)
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

minetest.register_node("techage:ta4_solar_minicell", {
	description = S("TA4 Streetlamp Solar Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_solar_cell_mini_top.png",
		"techage_solar_cell_mini_bottom.png",
		"techage_solar_cell_mini_side.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-14/32, -8/32, -14/32,  14/32, -6/32, 14/32},
			{-7/32, -16/32, -7/32,  7/32, -8/32, 7/32},
		},
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	use_texture_alpha = techage.CLIP,

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_timer = node_timer,
})

power.register_nodes({"techage:ta4_solar_minicell"}, Cable, "gen", {"D"})

techage.register_node({"techage:ta4_solar_minicell"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "state" then
			if nvm.providing then
				return "discharging"
			elseif (nvm.capa or 0) > 0 then
				return "charging"
			else
				return "unused"
			end
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 145 then  -- Solar Cell State
			if nvm.providing then
				return 0, {2}
			elseif (nvm.capa or 0) > 0 then
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
})

minetest.register_craft({
	output = "techage:ta4_solar_minicell",
	recipe = {
		{"", "techage:ta4_wlanchip", ""},
		{"techage:ta4_silicon_wafer", "techage:ta4_silicon_wafer", "techage:ta4_silicon_wafer"},
		{"default:tin_ingot", "techage:iron_ingot", "default:copper_ingot"},
	},
})
