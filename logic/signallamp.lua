--[[

	TechAge
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Colored Signal Lamps (with unifieddyes support)

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic

local COLORED = minetest.get_modpath("unifieddyes") and minetest.global_exists("unifieddyes")

local LampsOff = {}
local LampsOn = {}

local function switch_on(pos, node, player, color)
	if player and minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	color = tonumber(color) or node.param2
	if LampsOff[node.name] then
		node.name = LampsOff[node.name]
		node.param2 = color
		minetest.swap_node(pos, node)
	elseif LampsOn[node.name] and color ~= node.param2 then
		node.param2 = color
		minetest.swap_node(pos, node)
	end
end

local function switch_off(pos, node, player)
	if player and minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	if LampsOn[node.name] then
		node.name = LampsOn[node.name]
		minetest.swap_node(pos, node)
	end
end

local function register_signallamp(name, description, tiles_off, tiles_on, node_box)
	LampsOff[name .. "_off"] = name .. "_on"
	LampsOn[name .. "_on"] = name .. "_off"

	minetest.register_node(name .. "_off", {
		description = description,
		tiles = tiles_off,
		drawtype = node_box and "nodebox",
		node_box = node_box,

		after_place_node = function(pos, placer, itemstack, pointed_thing)
			logic.after_place_node(pos, placer, name .. "_off", description)
			logic.infotext(M(pos), description)
			if COLORED then
				unifieddyes.recolor_on_place(pos, placer, itemstack, pointed_thing)
			else
				local node = minetest.get_node(pos)
				node.param2 = 35
				minetest.swap_node(pos, node)
			end
		end,

		on_rightclick = switch_on,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			techage.remove_node(pos, oldnode, oldmetadata)
			if COLORED then
				unifieddyes.after_dig_node(pos, oldnode, oldmetadata, digger)
			end
		end,

		on_construct = COLORED and unifieddyes.on_construct or nil,
		on_dig = COLORED and unifieddyes.on_dig or nil,

		paramtype = "light",
		paramtype2 = "color",
		--palette = "techage_palette256.png",
		palette = COLORED and "unifieddyes_palette_extended.png" or "techage_palette256.png",
		place_param2 = 240,
		sunlight_propagates = true,
		sounds = default.node_sound_glass_defaults(),
		groups = {choppy=2, cracky=1, ud_param2_colorable = 1},
		is_ground_content = false,
		drop = name .. "_off"
	})

	minetest.register_node(name .. "_on", {
		description = description,
		tiles = tiles_on,
		drawtype = node_box and "nodebox",
		node_box = node_box,

		on_rightclick = switch_off,

		paramtype = "light",
		paramtype2 = "color",
		palette = COLORED and "unifieddyes_palette_extended.png" or "techage_palette256.png",
		groups = {choppy=2, cracky=1, not_in_creative_inventory=1, ud_param2_colorable = 1},

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			techage.remove_node(pos, oldnode, oldmetadata)
			if COLORED then
				unifieddyes.after_dig_node(pos, oldnode, oldmetadata, digger)
			end
		end,

		on_dig = COLORED and unifieddyes.on_dig or nil,
		light_source = 10,
		is_ground_content = false,
		drop = name .. "_off"
	})

	techage.register_node({name .. "_off", name .. "_on"}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "on" then
				local node = techage.get_node_lvm(pos)
				switch_on(pos, node)
				return true
			elseif topic == "off" then
				local node = techage.get_node_lvm(pos)
				switch_off(pos, node)
				return true
			elseif topic == "color" then
				local node = techage.get_node_lvm(pos)
				switch_on(pos, node, nil, payload)
				return true
			else
				return "unsupported"
			end
		end,
		on_beduino_receive_cmnd = function(pos, src, topic, payload)
			if topic == 1 and payload[1] == 1 then
				local node = techage.get_node_lvm(pos)
				switch_on(pos, node)
				return 0
			elseif topic == 1 and payload[1] == 0 then
				local node = techage.get_node_lvm(pos)
				switch_off(pos, node)
				return 0
			elseif topic == 70 or topic == 22 then
				local node = techage.get_node_lvm(pos)
				switch_on(pos, node, nil, payload[1])
				return 0
			else
				return 2
			end
		end,
	})
end

register_signallamp("techage:color_lamp",
	S("TechAge Color Lamp"),
	{"techage_signal_lamp.png^[colorize:#000000:80"},
	{"techage_signal_lamp.png"},
	{
		type = "fixed",
		fixed = {
			{-6/16, -6/16, -6/16,  6/16, 6/16, 6/16},
			{-4/16, -10/16, -4/16,  4/16, -6/16, 4/16},
		}
	}
)

register_signallamp("techage:color_lamp2",
	S("TechAge Color Lamp 2"),
	{"techage_signallamp2.png^[colorize:#000000:80"},
	{"techage_signallamp2.png"}
)

minetest.register_craft({
		output = "techage:signal_lamp_off",
		recipe = {
			{"", "wool:white", ""},
			{"", "default:torch", ""},
			{"", "techage:vacuum_tube", ""},
		},
	})

minetest.register_craft({
		output = "techage:signal_lamp2_off",
		recipe = {
			{"", "default:glass", ""},
			{"", "default:torch", ""},
			{"", "techage:vacuum_tube", ""},
		},
	})

minetest.register_alias("techage:signal_lamp_off", "techage:color_lamp_off")
minetest.register_alias("techage:signal_lamp2_off", "techage:color_lamp2_off")
minetest.register_alias("techage:signal_lamp_on", "techage:color_lamp_on")
minetest.register_alias("techage:signal_lamp2_on", "techage:color_lamp2_on")
