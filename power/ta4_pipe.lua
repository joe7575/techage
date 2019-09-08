--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Biogas/Stream/oil pipes

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 100, 
	show_infotext = false,
	force_to_use_tubes = true,
	tube_type = "ta4_pipe",
	primary_node_names = {"techage:ta4_pipeS", "techage:ta4_pipeA"}, 
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		minetest.swap_node(pos, {name = "techage:ta4_pipe"..tube_type, param2 = param2})
	end,
})

Pipe:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	minetest.registered_nodes[node.name].after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
end)

techage.BiogasPipe = Pipe

minetest.register_node("techage:ta4_pipeS", {
	description = S("TA4 Pipe"),
	tiles = {
		"techage_gaspipe.png^[transformR90",
		"techage_gaspipe.png^[transformR90",
		"techage_gaspipe.png",
		"techage_gaspipe.png",
		"techage_gaspipe_hole2.png",
		"techage_gaspipe_hole2.png",
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode)
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -1/8, -4/8,  1/8, 1/8, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_pipeA", {
	description = S("TA4 Pipe"),
	tiles = {
		"techage_gaspipe_knee2.png",
		"techage_gaspipe_hole2.png^[transformR180",
		"techage_gaspipe_knee.png^[transformR270",
		"techage_gaspipe_knee.png",
		"techage_gaspipe_knee2.png",
		"techage_gaspipe_hole2.png",
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode)
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -4/8, -1/8, 1/8, 1/8,    1/8},
			{-2/8, -0.5, -2/8, 2/8, -13/32, 2/8},
			{-1/8, -1/8, -4/8, 1/8, 1/8,    -1/8},
			{-2/8, -2/8, -0.5, 2/8, 2/8,    -13/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta4_pipeS",
})


minetest.register_craft({
	output = "techage:ta4_pipeS 3",
	recipe = {
		{'', '', "default:steel_ingot"},
		{'dye:yellow', 'techage:meridium_ingot', ''},
		{"default:steel_ingot", '', ''},
	},
})

