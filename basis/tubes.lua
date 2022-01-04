--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Tubes based on tubelib2

]]--

local S = techage.S


-- used for registered nodes
techage.KnownNodes = {
	["techage:tubeS"] = true,
	["techage:tubeA"] = true,
	["techage:ta4_tubeS"] = true,
	["techage:ta4_tubeA"] = true,
}


local Tube = tubelib2.Tube:new({
	                -- North, East, South, West, Down, Up
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 200,
	show_infotext = false,
	primary_node_names = {
		"techage:tubeS", "techage:tubeA",
		"techage:ta4_tubeS", "techage:ta4_tubeA",
		"techage:tube_wall_entry",
	},
	after_place_tube = function(pos, param2, tube_type, num_tubes, tbl)
		local name = minetest.get_node(pos).name
		if name == "techage:tubeS" or name == "techage:tubeA" then
			minetest.swap_node(pos, {name = "techage:tube"..tube_type, param2 = param2})
		elseif name == "techage:tube_wall_entry" then
			minetest.swap_node(pos, {name = "techage:tube_wall_entry", param2 = param2})
		else
			minetest.swap_node(pos, {name = "techage:ta4_tube"..tube_type, param2 = param2})
		end
	end,
})

techage.Tube = Tube

minetest.register_node("techage:tubeS", {
	description = S("TechAge Tube"),
	tiles = { -- Top, base, right, left, front, back
		"techage_tube_tube.png^[transformR90",
		"techage_tube_tube.png^[transformR90",
		"techage_tube_tube.png",
		"techage_tube_tube.png",
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

minetest.register_node("techage:tubeA", {
	description = S("TechAge Tube"),
	tiles = { -- Top, base, right, left, front, back
		"techage_tube_knee2.png",
		"techage_tube_hole2.png^[transformR180",
		"techage_tube_knee.png^[transformR270",
		"techage_tube_knee.png",
		"techage_tube_knee2.png",
		"techage_tube_hole2.png",
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
	drop = "techage:tubeS",
})

minetest.register_craft({
	output = "techage:tubeS 4",
	recipe = {
		{"default:steel_ingot", "", "group:wood"},
		{"", "group:wood", ""},
		{"group:wood", "", "default:tin_ingot"},
	},
})
