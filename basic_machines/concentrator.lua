--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Tube Concentrator

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Tube = techage.Tube

local size = 2/8
local Boxes = {
	{{-size, -size,  size, size, size, 0.5 }}, -- z+
	{{-size, -size, -size, 0.5,  size, size}}, -- x+
	{{-size, -size, -0.5,  size, size, size}}, -- z-
	{{-0.5,  -size, -size, size, size, size}}, -- x-
	{{-size, -0.5,  -size, size, size, size}}, -- y-
	{{-size, -size, -size, size, 0.5,  size}}, -- y+
}

local names = networks.register_junction("techage:concentrator", 2/8, Boxes, Tube, {
	description = S("Tube Concentrator"),
	tiles = {
		"techage_tube_junction.png^techage_appl_arrow2.png^[transformR270",
		"techage_tube_junction.png^techage_appl_arrow2.png^[transformR270",
		"techage_tube_junction.png^techage_tube_hole.png",
		"techage_tube_junction.png",
		"techage_tube_junction.png^techage_appl_arrow2.png^[transformR90",
		"techage_tube_junction.png^techage_appl_arrow2.png^[transformR270",
	},
	paramtype2 = "facedir", -- important!
	use_texture_alpha = techage.CLIP,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		local name = "techage:concentrator"..networks.junction_type(pos, Tube, "R", node.param2)
		minetest.swap_node(pos, {name = name, param2 = node.param2})
		M(pos):set_int("push_dir", techage.side_to_outdir("R", node.param2))
		Tube:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		local name = "techage:concentrator"..networks.junction_type(pos, Tube, "R", node.param2)
		minetest.swap_node(pos, {name = name, param2 = node.param2})
	end,
	ta_rotate_node = function(pos, node, new_param2)
		Tube:after_dig_node(pos)
		minetest.swap_node(pos, {name = node.name, param2 = new_param2})
		Tube:after_place_node(pos)
		M(pos):set_int("push_dir", techage.side_to_outdir("R", new_param2))
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_node(pos)
	end,
}, 27)

for _, name in ipairs(names) do
	Tube:set_valid_sides(name, {"B", "R", "F", "L", "D", "U"})
end

techage.register_node(names, {
	on_push_item = function(pos, in_dir, stack)
		local push_dir = M(pos):get_int("push_dir")
		return techage.safe_push_items(pos, push_dir, stack)
	end,
	is_pusher = true,  -- is a pulling/pushing node
})

names = networks.register_junction("techage:ta4_concentrator", 2/8, Boxes, Tube, {
	description = S("TA4 Tube Concentrator"),
	tiles = {
		"techage_tubeta4_junction.png^techage_appl_arrow2.png^[transformR270",
		"techage_tubeta4_junction.png^techage_appl_arrow2.png^[transformR270",
		"techage_tubeta4_junction.png^techage_tube_hole.png",
		"techage_tubeta4_junction.png",
		"techage_tubeta4_junction.png^techage_appl_arrow2.png^[transformR90",
		"techage_tubeta4_junction.png^techage_appl_arrow2.png^[transformR270",
	},
	paramtype2 = "facedir", -- important!
	use_texture_alpha = techage.CLIP,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_defaults(),

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		local name = "techage:ta4_concentrator"..networks.junction_type(pos, Tube, "R", node.param2)
		minetest.swap_node(pos, {name = name, param2 = node.param2})
		M(pos):set_int("push_dir", techage.side_to_outdir("R", node.param2))
		Tube:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir1, tlib2, node)
		local name = "techage:ta4_concentrator"..networks.junction_type(pos, Tube, "R", node.param2)
		minetest.swap_node(pos, {name = name, param2 = node.param2})
	end,
	ta_rotate_node = function(pos, node, new_param2)
		Tube:after_dig_node(pos)
		minetest.swap_node(pos, {name = node.name, param2 = new_param2})
		Tube:after_place_node(pos)
		M(pos):set_int("push_dir", techage.side_to_outdir("R", new_param2))
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Tube:after_dig_node(pos)
	end,
}, 27)

for _, name in ipairs(names) do
	Tube:set_valid_sides(name, {"B", "R", "F", "L", "D", "U"})
end

techage.register_node(names, {
	on_push_item = function(pos, in_dir, stack)
		local push_dir = M(pos):get_int("push_dir")
		return techage.safe_push_items(pos, push_dir, stack)
	end,
	is_pusher = true,  -- is a pulling/pushing node
})


minetest.register_craft({
	output = "techage:concentrator27",
	recipe = {
		{"", "techage:tubeS", ""},
		{"techage:tubeS", "", "techage:tubeS"},
		{"", "techage:tubeS", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_concentrator27",
	recipe = {
		{"", "techage:ta4_tubeS", ""},
		{"techage:ta4_tubeS", "", "techage:ta4_tubeS"},
		{"", "techage:ta4_tubeS", ""},
	},
})
