--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Liquid Pipe Wall Entry

]]--

local S = techage.S

local Pipe = techage.LiquidPipe

minetest.register_node("techage:ta3_pipe_wall_entry", {
	description = S("TA3 Pipe Wall Entry"),
	tiles = {
		-- up, down, right, left, back, front
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png^techage_appl_hole_pipe.png",
		"basic_materials_concrete_block.png^techage_appl_hole_pipe.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "techage:ta3_pipe_wall_entry",
	recipe = {
		{"", "techage:ta3_pipeS", ""},
		{"", "basic_materials:concrete_block", ""},
		{"", "",""},
	},
})
