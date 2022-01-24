--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	pillar

]]--

local S = techage.S

minetest.register_node("techage:pillar", {
	description = S("TA4 Pillar"),
	tiles = {"techage_concrete.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_07.obj",
	selection_box = {
		type = "fixed",
		fixed = {-10/32, -16/32, -10/32, 10/32, 16/32, 10/32},
	},
	collision_box = {
		type = "fixed",
		fixed = {-4/32, -16/32, -4/32, 4/32, 16/32, 4/32},
	},
	climbable = true,
	walkable = true,
	paramtype = "light",
	backface_culling = true,
	groups = {cracky=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:pillar",
	recipe = {"basic_materials:concrete_block"},
})
