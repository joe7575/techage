--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Cooler as part of the Collider

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.LiquidPipe

minetest.register_node("techage:ta4_collider_cooler", {
	description = S("TA4 Collider Cooler"),
	tiles = {
		-- up, down, right, left, back, front
		{
			image = "techage_appl_cooler4.png^techage_frame4_ta4_top.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_appl_cooler4.png^techage_frame4_ta4_top.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_cooler.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_cooler.png",
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {cracky = 1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	networks = {
		pipe2 = {},
	},

	after_place_node = function(pos, placer, itemstack)
		Pipe:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		techage.del_mem(pos)
	end,
})

Pipe:add_secondary_node_names({"techage:ta4_collider_cooler"})
Pipe:set_valid_sides("techage:ta4_collider_cooler", {"R", "L"})

techage.register_node({"techage:ta4_collider_cooler"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "cooler" then
			return true
		else
			return false
		end
	end,
})

minetest.register_craft({
	output = "techage:ta4_collider_cooler",
	recipe = {
		{'', 'dye:blue', ''},
		{'', 'techage:cooler', ''},
		{'', 'techage:aluminum', ''},
	},
})
