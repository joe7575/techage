--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Tubes in TA4 design based on tubelib2

]]--

local Tube = techage.Tube
local S = techage.S

minetest.register_node("techage:ta4_tubeS", {
	description = S("TA4 Tube"),
	tiles = { -- Top, base, right, left, front, back
		"techage_tubeta4_tube.png^[transformR90",
		"techage_tubeta4_tube.png^[transformR90",
		"techage_tubeta4_tube.png",
		"techage_tubeta4_tube.png",
		"techage_tube_hole.png",
		"techage_tube_hole.png",
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

	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-2/8, -2/8, -4/8,  2/8, 2/8, 4/8},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = { -1/4, -1/4, -1/2,  1/4, 1/4, 1/2 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -1/4, -1/4, -1/2,  1/4, 1/4, 1/2 },
	},
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy=2, cracky=3},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta4_tubeA", {
	description = S("TA4 Tube"),
	tiles = { -- Top, base, right, left, front, back
		"techage_tubeta4_knee2.png",
		"techage_tubeta4_hole2.png^[transformR180",
		"techage_tubeta4_knee.png^[transformR270",
		"techage_tubeta4_knee.png",
		"techage_tubeta4_knee2.png",
		"techage_tubeta4_hole2.png",
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-2/8, -4/8, -2/8,  2/8, 2/8,  2/8},
			{-2/8, -2/8, -4/8,  2/8, 2/8, -2/8},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = { -1/4, -1/2, -1/2,  1/4, 1/4, 1/4 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -1/4, -1/2, -1/2,  1/4, 1/4, 1/4 },
	},
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy=2, cracky=3, not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta4_tubeS",
})

minetest.register_craft({
	output = "techage:ta4_tubeS 6",
	recipe = {
		{"dye:blue", "", "basic_materials:plastic_sheet"},
		{"", "basic_materials:plastic_sheet", ""},
		{"basic_materials:plastic_sheet", "", "techage:aluminum"},
	},
})

techage.TA4tubes = {
	["techage:ta4_tubeS"] = true,
	["techage:ta4_tubeA"] = true,
}
