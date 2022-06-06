--[[

	TechAge
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Colored Signal Lamp (requires unifieddyes)

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic

local COLORED = minetest.get_modpath("unifieddyes") and minetest.global_exists("unifieddyes")


local function switch_on(pos, node)
	node.name = "techage:signal_lamp_on"
	minetest.swap_node(pos, node)
end

local function switch_off(pos, node)
	node.name = "techage:signal_lamp_off"
	minetest.swap_node(pos, node)
end

minetest.register_node("techage:signal_lamp_off", {
	description = S("TechAge Signal Lamp (can be colored)"),
	tiles = {"techage_signal_lamp.png^[colorize:#000000:100"},
	drawtype = "nodebox",
    node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16, -6/16,  6/16, 6/16, 6/16},
			{-4/16, -10/16, -4/16,  4/16, -6/16, 4/16},
		},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		logic.after_place_node(pos, placer, "techage:signal_lamp_off", S("TechAge Signal Lamp"))
		logic.infotext(M(pos), S("TechAge Signal Lamp"))
		if COLORED then
			unifieddyes.recolor_on_place(pos, placer, itemstack, pointed_thing)
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
	palette = COLORED and "unifieddyes_palette_extended.png" or 'techage_color16.png',
	place_param2 = 241,
	sunlight_propagates = true,
	sounds = default.node_sound_stone_defaults(),
	groups = {choppy=2, cracky=1, ud_param2_colorable = 1},
	is_ground_content = false,
	drop = "techage:signal_lamp_off"
})


minetest.register_node("techage:signal_lamp_on", {
	description = S("TechAge Signal Lamp"),
	tiles = {"techage_signal_lamp.png"},
	drawtype = "nodebox",
    node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16, -6/16,  6/16, 6/16, 6/16},
			{-4/16, -10/16, -4/16,  4/16, -6/16, 4/16},
		},
	},
	on_rightclick = switch_off,

	paramtype = "light",
	paramtype2 = "color",
	palette = COLORED and "unifieddyes_palette_extended.png" or 'techage_color16.png',
	groups = {choppy=2, cracky=1, not_in_creative_inventory=1, ud_param2_colorable = 1},

	on_construct = COLORED and unifieddyes.on_construct or nil,
	after_place_node = COLORED and unifieddyes.recolor_on_place or nil,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		if COLORED then
			unifieddyes.after_dig_node(pos, oldnode, oldmetadata, digger)
		end
	end,

	on_dig = COLORED and unifieddyes.on_dig or nil,
	light_source = 10,
	is_ground_content = false,
	drop = "techage:signal_lamp_off"
})

techage.register_node({"techage:signal_lamp_off", "techage:signal_lamp_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "on" then
			local node = techage.get_node_lvm(pos)
			switch_on(pos, node)
		elseif topic == "off" then
			local node = techage.get_node_lvm(pos)
			switch_off(pos, node)
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
		else
			return 2
		end
	end,
})

minetest.register_craft({
	output = "techage:signal_lamp_off",
	recipe = {
		{"", "wool:white", ""},
		{"", "default:torch", ""},
		{"", "techage:vacuum_tube", ""},
	},
})
