--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Heat Exchanger1 (bottom part)
	- has a connection to storage and turbine (via pipes)
	- acts as a cable junction for Exchanger2
]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local Pipe = techage.LiquidPipe
local power = networks.power

local function turbine_cmnd(pos, topic, payload)
	return techage.transfer(pos, "R", topic, payload, Pipe,
		{"techage:ta4_turbine", "techage:ta4_turbine_on", "techage:ta4_collider_cooler"})
end

local function inlet_cmnd(pos, topic, payload)
	return techage.transfer(pos, "L", topic, payload, Pipe,
		{"techage:ta4_pipe_inlet", "techage:ta4_collider_pipe_inlet"})
end

minetest.register_node("techage:heatexchanger1", {
	description = S("TA4 Heat Exchanger 1"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_hole_ta4.png^techage_appl_arrow_white.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		Cable:after_place_node(pos)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		if tlib2 == Cable then
			power.update_network(pos, 0, tlib2, node)
		end
	end,
	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		pos.y = pos.y + 1
		return minetest.get_node(pos).name ~= "techage:heatexchanger2"
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
		Pipe:after_dig_node(pos)
	end,
	networks = {},
	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:heatexchanger1"})
Pipe:set_valid_sides("techage:heatexchanger1", {"R", "L"})

power.register_nodes({"techage:heatexchanger1"}, Cable, "junc", {"F", "B", "U"})

-- command interface
techage.register_node({"techage:heatexchanger1"}, {
	on_transfer = function(pos, indir, topic, payload)
		local nvm = techage.get_nvm(pos)
		-- used by heatexchanger2
		if topic == "diameter" or topic == "volume" or topic == "window" or topic == "detector" then
			return inlet_cmnd(pos, topic, payload)
		else
			return turbine_cmnd(pos, topic, payload)
		end
	end,
})

minetest.register_craft({
	output = "techage:heatexchanger1",
	recipe = {
		{"default:tin_ingot", "techage:electric_cableS", "default:steel_ingot"},
		{"techage:ta4_pipeS", "basic_materials:gear_steel", "techage:ta4_pipeS"},
		{"", "techage:baborium_ingot", ""},
	},
})
