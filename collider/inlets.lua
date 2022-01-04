--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Tube/Pipe Inputs/Outputs as part of the Collider

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local PWR_NEEDED = 15
local CYCLE_TIME = 2
local GAS_CAPA = 20
local AIR_CAPA = 1000

local VTube = techage.VTube
local Pipe = techage.LiquidPipe
local Cable = techage.ElectricCable
local power = networks.power
local liquid = networks.liquid

--------------------------------------------------------------------------------
-- Tube Input
--------------------------------------------------------------------------------
minetest.register_node("techage:ta4_collider_tube_inlet", {
	description = S("TA4 Collider Tube Input"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png^techage_collider_tube_open.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-4/8, -4/8, -4/8, -1/8,  4/8,  4/8},
			{ 1/8, -4/8, -4/8,  4/8,  4/8,  4/8},
			{-4/8,  1/8, -4/8,  4/8,  4/8,  4/8},
			{-4/8, -4/8, -4/8,  4/8, -1/8,  4/8},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-4/8, -4/8, -4/8, 4/8, 4/8, 4/8},
	},
	paramtype2 = "facedir",
	groups = {cracky = 1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack)
		VTube:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode)
		VTube:after_dig_node(pos)
		techage.del_mem(pos)
	end,
})

VTube:add_secondary_node_names({"techage:ta4_collider_tube_inlet"})
VTube:set_valid_sides("techage:ta4_collider_tube_inlet", {"F"})

-- Called from the detector via tube ring
techage.register_node({"techage:ta4_collider_tube_inlet"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "distance" then
			return pos
		elseif topic == "enumerate" and payload then
			return payload - 1
		elseif topic == "check" then
			local nvm = techage.get_nvm(pos)
			nvm.check_received = true
			return true
		end
	end,
})

-- Used by the detector to check the tube connection
function techage.tube_inlet_command(pos, command, payload)
	if command == "distance" then
		local pos2 = techage.transfer(pos, "F", command, payload, VTube, {"techage:ta4_magnet"})
		if type(pos2) == "table" then
			local dist = math.abs(pos.x - pos2.x) + math.abs(pos.z - pos2.z)
			if pos.y == pos2.y and dist == VTube.max_tube_length + 1 then
				return true
			end
			return 0
		else
			return pos2
		end
	end
	return techage.transfer(pos, "F", command, payload, VTube, {"techage:ta4_magnet"})
end

minetest.register_craft({
	output = "techage:ta4_collider_tube_inlet",
	recipe = {
		{'', '', ''},
		{'techage:ta4_vtubeS', 'techage:ta4_colliderblock', ''},
		{'', '', ''},
	},
})

--------------------------------------------------------------------------------
-- Pipe Input (gas)
--------------------------------------------------------------------------------
minetest.register_node("techage:ta4_collider_pipe_inlet", {
	description = S("TA4 Collider Pipe Input"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png^techage_appl_hole_pipe.png",
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
		local nvm = techage.get_nvm(pos)
		Pipe:after_place_node(pos)
		nvm.liquid = {}
	end,

	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		techage.del_mem(pos)
	end,
})

liquid.register_nodes({"techage:ta4_collider_pipe_inlet"}, Pipe, "tank", {"F"}, {
	capa = GAS_CAPA,
	peek = function(pos, indir)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_put(nvm, name, amount, GAS_CAPA)
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_take(nvm, name, amount)
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		liquid.srv_put(nvm, name, amount, GAS_CAPA)
	end,
})

techage.register_node({"techage:ta4_collider_pipe_inlet"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		-- called from heatexchanger
		if topic == "detector" then
			local nvm = techage.get_nvm(pos)
			nvm.detector_received = true
			return true
		end
	end,
})

-- Used by the detector to check for gas pressure
function techage.gas_inlet_check(pos, node, meta, nvm)
	nvm.liquid = nvm.liquid or {}
	if nvm.liquid.amount == GAS_CAPA and nvm.liquid.name == "techage:isobutane" then
		return true
	end
	return false, "no gas"
end

-- Used by the detector to check for cooler connection
function techage.cooler_check(pos, node, meta, nvm)
	if nvm.detector_received then
		nvm.detector_received = nil
		return true
	end
	return false, "Cooler defect"
end

minetest.register_craft({
	output = "techage:ta4_collider_pipe_inlet",
	recipe = {
		{'', '', ''},
		{'techage:ta3_pipeS', 'techage:ta4_colliderblock', ''},
		{'', '', ''},
	},
})


--------------------------------------------------------------------------------
-- Pipe Output (air)
--------------------------------------------------------------------------------
local function init_air(nvm)
	nvm.liquid = {
		amount = AIR_CAPA,
		name = "air",
	}
	return nvm.liquid
end

minetest.register_node("techage:ta4_collider_pipe_outlet", {
	description = S("TA4 Collider Pipe Output"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png^techage_appl_hole_pipe.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
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
		local nvm = techage.get_nvm(pos)
		init_air(nvm)
		Pipe:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		techage.del_mem(pos)
	end,
})

liquid.register_nodes({"techage:ta4_collider_pipe_outlet"}, Pipe, "tank", {"U"}, {
	capa = AIR_CAPA,
	peek = function(pos, indir)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_put(nvm, name, amount, AIR_CAPA)
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_take(nvm, name, amount)
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		liquid.srv_put(nvm, name, amount, AIR_CAPA)
	end,
})

-- Used by the detector to check the vacuum
function techage.air_outlet_check(pos, node, meta, nvm)
	nvm.liquid = nvm.liquid or {}
	if nvm.liquid.amount == 0 then
		return true
	end
	return false, "no vacuum"
end

function techage.air_outlet_reset(pos)
	local nvm = techage.get_nvm(pos)
	init_air(nvm)
end

minetest.register_craft({
	output = "techage:ta4_collider_pipe_outlet",
	recipe = {
		{'', 'techage:ta3_pipeS', ''},
		{'', 'techage:ta4_colliderblock', ''},
		{'', '', ''},
	},
})

--------------------------------------------------------------------------------
-- Cable Input (power)
--------------------------------------------------------------------------------
minetest.register_node("techage:ta4_collider_cable_inlet", {
	description = S("TA4 Collider Cable Input"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png^techage_appl_hole_electric.png",
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
		Cable:after_place_node(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		nvm.consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		return true
	end,

	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
})

-- Used by the detector to check for power
function techage.power_inlet_check(pos, node, meta, nvm)
	if nvm.consumed == PWR_NEEDED then
		return true
	end
	return false, "no power"
end

power.register_nodes({"techage:ta4_collider_cable_inlet"}, Cable, "con", {"F"})

techage.register_node({"techage:ta4_collider_cable_inlet"}, {
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})

minetest.register_craft({
	output = "techage:ta4_collider_cable_inlet",
	recipe = {
		{'', '', ''},
		{'techage:electric_cableS', 'techage:ta4_colliderblock', ''},
		{'', '', ''},
	},
})
