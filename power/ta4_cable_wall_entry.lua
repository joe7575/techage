--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 cable wall entry

]]--

local S = techage.S

local TA4_Cable = techage.TA4_Cable

minetest.register_node("techage:ta4_cable_wall_entry", {
	description = S("TA4 Cable Wall Entry"),
	tiles = {
		-- up, down, right, left, back, front
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png^techage_ta4_cable_hole.png",
		"basic_materials_concrete_block.png^techage_ta4_cable_hole.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not TA4_Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		TA4_Cable:after_dig_tube(pos, oldnode)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "techage:ta4_cable_wall_entry",
	recipe = {
		{"", "techage:ta4_power_cableS", ""},
		{"", "basic_materials:concrete_block", ""},
		{"", "",""},
	},
})
