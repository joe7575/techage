--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Heat Exchanger3 (top part)

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.LiquidPipe

local function orientate_node(pos, name)
	local node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
	if node.name == name then
		local param2 = node.param2
		node = minetest.get_node(pos)
		node.param2 = param2
		minetest.swap_node(pos, node)
	else
		minetest.remove_node(pos)
		return true
	end
end

local function after_place_node(pos)
	if orientate_node(pos, "techage:heatexchanger2") then
		return true
	end
	Pipe:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Pipe:after_dig_node(pos)
end

local function cooler_cmnd(pos, topic, payload)
	return techage.transfer(pos, "R", topic, payload, Pipe,
		{"techage:ta4_collider_cooler"})
end

local function inlet_cmnd(pos, topic, payload)
	return techage.transfer(pos, "L", topic, payload, Pipe,
		{"techage:ta4_pipe_inlet", "techage:ta4_collider_pipe_inlet"})
end

minetest.register_node("techage:heatexchanger3", {
	description = S("TA4 Heat Exchanger 3"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_hole_ta4.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_ribsT.png",
		"techage_filling_ta4.png^techage_frameT_ta4.png^techage_appl_ribsT.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	networks = {
		pipe2 = {},
	},
	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:heatexchanger3"})

-- command interface, used by heatexchanger2
techage.register_node({"techage:heatexchanger3"}, {
	on_transfer = function(pos, indir, topic, payload)
		if topic == "cooler" then
			return cooler_cmnd(pos, topic, payload)
		else
			return inlet_cmnd(pos, topic, payload)
		end
	end,
})

minetest.register_craft({
	output = "techage:heatexchanger3",
	recipe = {
		{"default:tin_ingot", "dye:blue", "default:steel_ingot"},
		{"techage:ta4_pipeS", "basic_materials:gear_steel", "techage:ta4_pipeS"},
		{"", "techage:baborium_ingot", ""},
	},
})

techage.orientate_node = orientate_node
