--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

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

minetest.register_node("techage:rotor_signal_lamp_off", {
	description = S("TA4 Wind Turbine Signal Lamp"),
	tiles = {"techage_rotor_lamp_off.png"},
	drawtype = "nodebox",
    node_box = {
		type = "fixed",
		fixed = {
			{-2/16, -8/16, -2/16,  2/16, -3/16, 2/16},
		},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_node_timer(pos):start(2)
	end,

	on_timer = function(pos, elapsed)
		minetest.swap_node(pos, {name = "techage:rotor_signal_lamp_on"})
		return true
	end,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	is_ground_content = false,
	drop = "techage:rotor_signal_lamp_off"
})

minetest.register_node("techage:rotor_signal_lamp_on", {
	description = S("TA4 Wind Turbine Signal Lamp"),
	tiles = {"techage_rotor_lamp_on.png"},
	drawtype = "nodebox",
    node_box = {
		type = "fixed",
		fixed = {
			{-2/16, -8/16, -2/16,  2/16, -3/16, 2/16},
		},
	},

	on_timer = function(pos, elapsed)
		minetest.swap_node(pos, {name = "techage:rotor_signal_lamp_off"})
		return true
	end,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	light_source = 8,
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory=1},
	is_ground_content = false,
	drop = "techage:rotor_signal_lamp_off"
})

minetest.register_lbm({
	label = "Restart Lamp",
	name = "techage:rotor_signal_lamp",
	nodenames = {"techage:rotor_signal_lamp_on", "techage:rotor_signal_lamp_off"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(2)
	end,
})


minetest.register_craft({
	output = "techage:rotor_signal_lamp_off",
	recipe = {
		{"", "dye:red", ""},
		{"", "default:torch", ""},
		{"", "default:glass", ""},
	},
})
