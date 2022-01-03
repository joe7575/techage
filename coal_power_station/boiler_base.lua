--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Coal Power Station Boiler Base

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.SteamPipe
local networks = techage.networks

local function after_place_node(pos)
	Pipe:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Pipe:after_dig_node(pos)
end

minetest.register_node("techage:coalboiler_base", {
	description = S("TA3 Boiler Base"),
	tiles = {"techage_coal_boiler_mesh_base.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_12.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -16/32, -13/32, 13/32, 16/32, 13/32},
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

Pipe:add_secondary_node_names({"techage:coalboiler_base"})

-- for logical communication
techage.register_node({"techage:coalboiler_base"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		return true
	end
})

minetest.register_craft({
	output = "techage:coalboiler_base",
	recipe = {
		{"default:stone", "", "default:stone"},
		{"techage:iron_ingot", "", "techage:iron_ingot"},
		{"default:stone", "default:stone", "default:stone"},
	},
})
