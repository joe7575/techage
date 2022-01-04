--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Drive Axles for the Steam Engine

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local power = networks.power

local Axle = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 10,
	show_infotext = false,
	tube_type = "axle",
	primary_node_names = {"techage:axle", "techage:axle_on"},
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes, state)
		if state == "on" then
			minetest.swap_node(pos, {name = "techage:axle_on", param2 = param2})
		else
			minetest.swap_node(pos, {name = "techage:axle", param2 = param2})
		end
	end,
})

-- Use global callback instead of node related functions
Axle:register_on_tube_update2(function(pos, outdir, tlib2, node)
	power.update_network(pos, outdir, tlib2, node)
end)

minetest.register_node("techage:axle", {
	description = S("TA2 Drive Axle"),
	tiles = {
		"techage_axleR.png",
		"techage_axleR.png",
		"techage_axle.png",
		"techage_axle.png",
		"techage_axle_clutch.png",
		"techage_axle_clutch.png",
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

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16, -3/16, -4/8,  3/16, 3/16, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:axle_on", {
	description = S("TA2 Drive Axle"),
	tiles = {
		{
			image = "techage_axle4R.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			image = "techage_axle4R.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			image = "techage_axle4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			image = "techage_axle4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			image = "techage_axle_clutch4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		{
			image = "techage_axle_clutch4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
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

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16, -3/16, -4/8,  3/16, 3/16, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	diggable = false,
	groups = {not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:axle 3",
	recipe = {
		{"default:junglewood", "", "default:wood"},
		{"", "techage:iron_ingot", ""},
		{"default:wood", "", "default:junglewood"},
	},
})


techage.Axle = Axle
