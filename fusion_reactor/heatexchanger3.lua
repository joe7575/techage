--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Heat Exchanger3 (top part)

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe2 = techage.LiquidPipe
local Pipe3 = techage.GasPipe
local liquid = networks.liquid
local control = networks.control

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
	if orientate_node(pos, "techage:ta5_heatexchanger2") then
		return true
	end
	Pipe2:after_place_node(pos)
	Pipe3:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Pipe2:after_dig_node(pos)
	Pipe3:after_dig_node(pos)
end

local function turbine_cmnd(pos, topic, payload)
	return techage.transfer(pos, "R", topic, payload, Pipe2,
		{"techage:ta5_turbine", "techage:ta5_turbine_on"})
end

-- Send to the magnets
local function control_cmnd(pos, topic)
	local outdir = networks.side_to_outdir(pos, "L")
	return control.request(pos, Pipe3, outdir, "tank", topic)
end

minetest.register_node("techage:ta5_heatexchanger3", {
	description = S("TA5 Heat Exchanger 3"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_hole_ta4.png",
		"techage_filling_ta4.png^techage_frameT_ta5.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frameT_ta5.png^techage_appl_hole_ta5_pipe1.png",
		"techage_filling_ta4.png^techage_frameT_ta5.png^techage_appl_ribsT.png",
		"techage_filling_ta4.png^techage_frameT_ta5.png^techage_appl_ribsT.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta5_heatexchanger3"}, Pipe2, "tank", {"R"}, {})
liquid.register_nodes({"techage:ta5_heatexchanger3"}, Pipe3, "tank", {"L"}, {})

-- command interface, used by heatexchanger2
techage.register_node({"techage:ta5_heatexchanger3"}, {
	on_transfer = function(pos, indir, topic, payload)
		if topic == "turbine" then
			return turbine_cmnd(pos, topic, payload)
		else
			return control_cmnd(pos, topic)
		end
	end,
})

minetest.register_craft({
	output = "techage:ta5_heatexchanger3",
	recipe = {
		{"default:tin_ingot", "dye:red", "default:steel_ingot"},
		{"techage:ta5_pipe2S", "basic_materials:gear_steel", "techage:ta4_pipeS"},
		{"", "techage:baborium_ingot", ""},
	},
})

techage.orientate_node = orientate_node
