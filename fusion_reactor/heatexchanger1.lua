--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Heat Exchanger1 (bottom part)
	- has a connection to storage and turbine (via pipes)
	- acts as a cable junction for Exchanger2
]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local Pipe2 = techage.LiquidPipe
local Pipe3 = techage.GasPipe
local power = networks.power
local liquid = networks.liquid
local control = networks.control

local function turbine_cmnd(pos, topic, payload)
	return techage.transfer(pos, "R", topic, payload, Pipe2,
		{"techage:ta5_turbine", "techage:ta5_turbine_on"})
end

-- Send to the magnets
local function control_cmnd(pos, topic)
	local outdir = networks.side_to_outdir(pos, "L")
	return control.request(pos, Pipe3, outdir, "tank", topic)
end

minetest.register_node("techage:ta5_heatexchanger1", {
	description = S("TA5 Heat Exchanger 1"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_hole_ta4.png^techage_appl_arrow_white.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_ta5_pipe2.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frameB_ta4.png^techage_appl_hole_electric.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		Cable:after_place_node(pos)
		Pipe2:after_place_node(pos)
		Pipe3:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		if tlib2 == Cable then
			power.update_network(pos, 0, Cable, node) -- junction!!!
		elseif tlib2 == Pipe2 then
			power.update_network(pos, outdir, Pipe2, node)
		else
			power.update_network(pos, outdir, Pipe3, node)
		end
	end,
	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		pos.y = pos.y + 1
		return minetest.get_node(pos).name ~= "techage:ta5_heatexchanger2"
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
		Pipe2:after_dig_node(pos)
		Pipe3:after_dig_node(pos)
	end,
	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta5_heatexchanger1"}, Pipe2, "tank", {"R"}, {})
liquid.register_nodes({"techage:ta5_heatexchanger1"}, Pipe3, "tank", {"L"}, {})
power.register_nodes({"techage:ta5_heatexchanger1"}, Cable, "junc", {"F", "B", "U"})

-- command interface
techage.register_node({"techage:ta5_heatexchanger1"}, {
	on_transfer = function(pos, indir, topic, payload)
		local nvm = techage.get_nvm(pos)
		-- used by heatexchanger2
		if topic == "test_gas_blue" then
			return control_cmnd(pos, topic)
		else
			return turbine_cmnd(pos, topic, payload)
		end
	end,
})

minetest.register_craft({
	output = "techage:ta5_heatexchanger1",
	recipe = {
		{"default:tin_ingot", "techage:electric_cableS", "default:steel_ingot"},
		{"techage:ta5_pipe1S", "basic_materials:gear_steel", "techage:ta4_pipeS"},
		{"", "techage:baborium_ingot", ""},
	},
})
