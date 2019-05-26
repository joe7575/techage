--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Power Station Generator

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local Param2ToDir = {
	[0] = 6,
	[1] = 5,
	[2] = 2,
	[3] = 4,
	[4] = 1,
	[5] = 3,
}

local function switch_on(pos, node, clicker)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	node.name = "techage:powerswitch_on"
	minetest.swap_node(pos, node)
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
	local dir = Param2ToDir[node.param2]
	techage.power.power_cut(pos, dir, techage.ElectricCable, false)
end

local function switch_off(pos, node, clicker)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	node.name = "techage:powerswitch"
	minetest.swap_node(pos, node)
	minetest.get_node_timer(pos):stop()
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
	local dir = Param2ToDir[node.param2]
	techage.power.power_cut(pos, dir, techage.ElectricCable, true)
end


minetest.register_node("techage:powerswitch", {
	description = I("TA Power Switch"),
	inventory_image = "techage_appl_switch_inv.png",
	tiles = {
		'techage_appl_switch_off.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/4, -8/16, -1/4,  1/4, -7/16, 1/4},
		},
	},
	
	on_rightclick = function(pos, node, clicker)
		switch_on(pos, node, clicker)
	end,

	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:powerswitch_on", {
	description = I("TA Power Switch"),
	inventory_image = "techage_appl_switch_inv.png",
	tiles = {
		'techage_appl_switch_on.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/4, -8/16, -1/4,  1/4, -7/16, 1/4},
		},
	},
	
	on_rightclick = function(pos, node, clicker)
		switch_off(pos, node, clicker)
	end,

	drop = "techage:powerswitch",
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:powerswitch 2",
	recipe = {
		{"", "", ""},
		{"dye:yellow", "dye:red", "dye:yellow"},
		{"basic_materials:plastic_sheet", "basic_materials:copper_wire", "basic_materials:plastic_sheet"},
	},
})

