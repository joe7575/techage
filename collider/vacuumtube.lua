--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Vacuum Tube as part of the Collider

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local VTube = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4},
	max_tube_length = 5,
	tube_type = "vtube",
	show_infotext = false,
	primary_node_names = {"techage:ta4_vtubeS", "techage:ta4_vtubeA"},
	secondary_node_names = {"techage:ta4_magnet"},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		minetest.swap_node(pos, {name = "techage:ta4_vtube"..tube_type, param2 = param2})
	end,
})

techage.VTube = VTube

minetest.register_node("techage:ta4_vtubeS", {
	description = S("TA4 Vacuum Tube"),
	drawtype = "nodebox",
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_tube.png^[transformR90",
		"techage_collider_tube.png^[transformR90",
		"techage_collider_tube.png",
		"techage_collider_tube.png",
		'techage_collider_tube_open.png',
		'techage_collider_tube_open.png',
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -6/16,  8/16,  8/16},
			{ 6/16, -8/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16,  6/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16, -6/16,  8/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not VTube:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		VTube:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_vtubeA", {
	description = S("TA4 Vacuum Tube"),
	drawtype = "nodebox",
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_tube.png^[transformR90",
		'techage_collider_tube.png^techage_collider_tube_open.png',
		"techage_collider_tube.png",
		"techage_collider_tube.png",
		"techage_collider_tube.png^[transformR90",
		'techage_collider_tube.png^techage_collider_tube_open.png',
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -6/16,  8/16,  8/16},
			{ 6/16, -8/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16,  6/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16,  6/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16, -6/16, -6/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		VTube:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 1, not_in_creative_inventory=1},
	drop = "techage:ta4_vtubeS",
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techage:ta4_vtubeS 4",
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'techage:aluminum', 'dye:blue', 'techage:aluminum'},
		{'', 'default:steel_ingot', ''},
	},
})
