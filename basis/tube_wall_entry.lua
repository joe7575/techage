--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Tube wall entry

]]--

local S = techage.S

local Tube = techage.Tube

minetest.register_node("techage:tube_wall_entry", {
	description = S("Tube Wall Entry"),
	tiles = {
		-- up, down, right, left, back, front
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png^techage_tube_hole.png",
		"basic_materials_concrete_block.png^techage_tube_hole.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Tube:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "techage:tube_wall_entry",
	recipe = {
		{"", "techage:tubeS", ""},
		{"", "basic_materials:concrete_block", ""},
		{"", "",""},
	},
})
