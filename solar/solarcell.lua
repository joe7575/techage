--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Solar Module and Carriers

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local PWR_PERF = 3

local Cable = techage.TA4_Cable
local power = networks.power
local control = networks.control

local function temperature(pos)
	local data = minetest.get_biome_data(pos)
	if data then
		return math.floor(data.heat) or 0
	end
	return 0
end

-- return the required param2 for solar modules
local function get_param2(pos, side)
	local dir = networks.side_to_outdir(pos, side)
	return (dir + 1) % 4
end

-- do we have enough light?
local function light(pos)
	if minetest.get_node(pos).name ~= "air" then return false end
	local light = minetest.get_node_light(pos) or 0
	return light >= (15 - 1)
end

-- check if solar module is available and has the correct orientation
local function is_solar_module(base_pos, pos, side)
	local pos1 = techage.get_pos(pos, side)
	if pos1 then
		local node = techage.get_node_lvm(pos1)
		if node and node.name == "techage:ta4_solar_module" and
						light({x = pos1.x, y = pos1.y + 1, z = pos1.z}) then
			if side == "L" and node.param2 == M(base_pos):get_int("left_param2") then
				return true
			elseif side == "R" and node.param2 == M(base_pos):get_int("right_param2") then
				return true
			end
		end
	end
	return false
end

-- provide the available power, which is temperature dependent
local function on_getpower1(pos)
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	if is_solar_module(pos, pos1, "L") and is_solar_module(pos, pos1, "R") then
		return PWR_PERF * M(pos):get_int("temperature") / 100.0
	end
	return 0
end

local function on_getpower2(pos)
	local pos1 = {x = pos.x, y = pos.y+1, z = pos.z}
	if is_solar_module(pos, pos1, "L") and is_solar_module(pos, pos1, "R") then
		return PWR_PERF * M(pos):get_int("temperature") / 100.0
	end
	return 0
end

local function after_place_node(pos)
	M(pos):set_int("temperature", temperature(pos))
	M(pos):set_int("left_param2", get_param2(pos, "L"))
	M(pos):set_int("right_param2", get_param2(pos, "R"))
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node)
	power.update_network(pos, 0, tlib2, node)
end

minetest.register_node("techage:ta4_solar_module", {
	description = S("TA4 Solar Module"),
	inventory_image = "techage_solar_module_top.png",
	tiles = {
		-- up, down, right, left, back, front
		"techage_solar_module_top.png",
		"techage_solar_module_bottom.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, 7/16, -1/2,  1/2, 8/16, 16/16},
		},
	},
	techage_info = function(pos)
		local power = 0
		local pos1 = {x = pos.x, y = pos.y + 1, z = pos.z}
		if light(pos1) then
			power = PWR_PERF * temperature(pos) / 200.0
		end
		local light = minetest.get_node_light(pos1).." / " ..15
		return S("power").." = "..power..", "..S("light").." = "..light
	end,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:ta4_solar_carrier", {
	description = S("TA4 Solar Carrier Module"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten^techage_appl_ta4_cable.png",
		"techage_concrete.png^[brighten^techage_appl_ta4_cable.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/8, -8/16, -1/2,  3/8, -6/16, 1/2},
			{-1/8, -6/16, -1/2,  1/8,  6/16, 1/2},
			{-3/8,  5/16, -1/2,  3/8,  7/16, 1/2},
		},
	},
	after_place_node = function(pos)
		M(pos):set_int("temperature", temperature(pos))
		M(pos):set_int("left_param2", get_param2(pos, "L"))
		M(pos):set_int("right_param2", get_param2(pos, "R"))
	end,

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:ta4_solar_carrierB", {
	description = S("TA4 Solar Carrier Module B"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^[brighten^techage_appl_ta4_cable.png",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten^techage_appl_ta4_cable.png",
		"techage_concrete.png^[brighten^techage_appl_ta4_cable.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/8, -8/16, -1/2,  3/8, -6/16, 1/2},
			{-1/8, -6/16, -1/2,  1/8,  8/16, 1/2},
		},
	},
	after_place_node = function(pos)
		M(pos):set_int("temperature", temperature(pos))
		M(pos):set_int("left_param2", get_param2(pos, "L"))
		M(pos):set_int("right_param2", get_param2(pos, "R"))
		Cable:after_place_node(pos)
	end,

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:ta4_solar_carrierT", {
	description = S("TA4 Solar Carrier Module T"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
		"techage_concrete.png^[brighten",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -8/16, -1/2,  1/8,  6/16, 1/2},
			{-3/8,  5/16, -1/2,  3/8,  7/16, 1/2},
		},
	},

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

power.register_nodes({"techage:ta4_solar_carrier", "techage:ta4_solar_carrierB"}, Cable, "junc", {"F", "B"})

control.register_nodes({"techage:ta4_solar_carrier"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "power" then
				return on_getpower1(pos)
			end
		end,
	}
)

control.register_nodes({"techage:ta4_solar_carrierB"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "power" then
				return on_getpower2(pos)
			end
		end,
	}
)

minetest.register_craft({
	output = "techage:ta4_solar_module",
	recipe = {
		{"techage:ta4_silicon_wafer", "techage:ta4_silicon_wafer", "techage:ta4_silicon_wafer"},
		{"default:copper_ingot", "default:tin_ingot", "default:copper_ingot"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_solar_carrierB 2",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "techage:ta4_power_cableS", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "techage:ta4_solar_carrierT 2",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
		{"", "techage:ta4_power_cableS", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_solar_carrier",
	recipe = {
		{"", "techage:ta4_solar_carrierT", ""},
		{"", "techage:ta4_solar_carrierB", ""},
		{"", "", ""},
	},
})
