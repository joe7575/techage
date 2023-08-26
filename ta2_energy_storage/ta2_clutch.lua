--[[

	TechAge
	=======

	Copyright (C) 2019-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Axle clutch

]]--

-- for lazy programmers
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local DESCR = S("TA2 Clutch")

local Axle = techage.Axle

local function switch_on(pos, node)
	if node.name == "techage:ta2_clutch_off" then
		node.name = "techage:ta2_clutch_on"
		minetest.swap_node(pos, node)
		Axle:after_place_tube(pos)
		minetest.sound_play("techage_button", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 5})
	end
end

local function switch_off(pos, node)
	if node.name == "techage:ta2_clutch_on" then
		node.name = "techage:ta2_clutch_off"
		minetest.swap_node(pos, node)
		Axle:after_dig_tube(pos, node)
		minetest.sound_play("techage_button", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 5})
	end
end

minetest.register_node("techage:ta2_clutch_off", {
	description = DESCR,
	tiles = {
		-- back, front, up, down, right, left
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png^[transformR90",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png^[transformR90",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Axle:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Axle:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	on_rightclick = switch_on,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta2_clutch_on", {
	description = DESCR,
	tiles = {
		-- back, front, up, down, right, left
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png^[transformR90",
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png^[transformR90",
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Axle:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	on_rightclick = switch_off,
	paramtype2 = "facedir",
	drop = "techage:ta2_clutch_off",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:ta2_clutch_off",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "basic_materials:gear_steel", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})
