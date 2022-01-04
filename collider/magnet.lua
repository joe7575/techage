--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Magnet as part of the Collider

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string

local PWR_NEEDED = 5
local CYCLE_TIME = 2
local CAPACITY = 10

local Cable = techage.ElectricCable
local Pipe = techage.LiquidPipe
local VTube = techage.VTube
local power = networks.power
local liquid = networks.liquid

minetest.register_node("techage:ta4_colliderblock", {
	description = S("TA4 Collider Steel Block"),
	tiles = {
		"default_steel_block.png",
	},
	paramtype2 = "facedir",
	groups = {cracky = 1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_detector_magnet", {
	description = S("TA4 Collider Detector Magnet"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_magnet.png^techage_collider_magnet_appl.png",
		"techage_collider_magnet.png^techage_collider_magnet_appl.png",
		"techage_collider_magnet.png",
		"techage_collider_magnet.png",
		"techage_collider_magnet.png^techage_collider_magnet_appl.png",
		"techage_collider_magnet.png^techage_collider_magnet_appl.png",
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {cracky = 1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_magnet", {
	description = S("TA4 Collider Magnet"),
	inventory_image = minetest.inventorycube(
		"techage_collider_magnet.png^techage_appl_hole_electric.png",
		"techage_collider_magnet.png^techage_appl_hole_pipe.png",
		"techage_collider_magnet.png^techage_collider_magnet_tube.png"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_magnet.png^techage_appl_hole_electric.png",
		"techage_collider_magnet.png",
		"techage_collider_magnet.png^techage_collider_magnet_tube.png",
		"techage_collider_magnet.png^techage_collider_magnet_tube.png",
		"techage_collider_magnet.png^techage_collider_magnet_appl.png^techage_appl_hole_pipe.png^techage_collider_magnet_sign.png",
		"techage_collider_magnet.png^techage_collider_magnet_appl.png^techage_appl_hole_pipe.png^techage_collider_magnet_sign.png",
	},
	drawtype = "nodebox",
	use_texture_alpha = techage.CLIP,
	node_box = {
		type = "fixed",
		fixed = {
			{-11/16, -11/16, -11/16,  11/16,  11/16,  -2/16},
			{-11/16, -11/16,   2/16,  11/16,  11/16,  11/16},
			{-11/16,   2/16, -11/16,  11/16,  11/16,  11/16},
			{-11/16, -11/16, -11/16,  11/16,  -2/16,  11/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-4/8, -4/8, -4/8, 4/8, 4/8, 4/8},
	},
	collision_box = {
		type = "fixed",
		fixed = {-11/16, -11/16, -11/16, 11/16, 11/16, 11/16},
	},
	wield_scale = {x = 0.8, y = 0.8, z = 0.8},
	paramtype2 = "facedir",
	groups = {cracky = 1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack)
		if pos.y > techage.collider_min_depth then
			minetest.remove_node(pos)
			minetest.add_item(pos, ItemStack("techage:ta4_magnet"))
			return
		end
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
		VTube:after_place_node(pos)
		M(pos):set_string("infotext", S("TA4 Collider Magnet") .. " #0")
	end,

	-- To be called by the detector
	on_cyclic_check = function(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = nvm.liquid or {}
		nvm.consumed = power.consume_power(pos, Cable, 6, PWR_NEEDED)
		if nvm.tube_damage then
			nvm.tube_damage = nil
			return -1
		elseif nvm.liquid.amount == CAPACITY and
				nvm.liquid.name == "techage:isobutane" and
				nvm.consumed == PWR_NEEDED then
			return 0
		end
		return -2
	end,

	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		if tlib2.tube_type == "vtube" then
			local nvm = techage.get_nvm(pos)
			nvm.tube_damage = true
		elseif tlib2.tube_type == "pipe2" then
			local nvm = techage.get_nvm(pos)
			nvm.liquid = nvm.liquid or {}
			nvm.liquid.amount = 0
		end
	end,

	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		VTube:after_dig_node(pos)
		techage.del_mem(pos)
	end,
})

power.register_nodes({"techage:ta4_magnet"}, Cable, "con", {"U"})
liquid.register_nodes({"techage:ta4_magnet"}, Pipe, "tank", {"F", "B"}, {
	capa = CAPACITY,
	peek = function(pos, indir)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_put(nvm, name, amount, CAPACITY)
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_take(nvm, name, amount)
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		liquid.srv_put(nvm, name, amount, CAPACITY)
	end,
})

VTube:add_secondary_node_names({"techage:ta4_magnet"})
VTube:set_valid_sides("techage:ta4_magnet", {"R", "L"})

local function send_to_next(pos, in_dir, topic, payload)
	return techage.transfer(pos, in_dir, topic, payload, VTube,
		{"techage:ta4_magnet", "techage:ta4_collider_tube_inlet"})
end

--[[
Commands
--------

distance  : Check distance between all magnets.
            Returns pos of next magnet or the number of the defect magnet.
enumerate : Give each magnet a unique number (1...n)
pos       : Read the position
test      : Test all magnet attributs.
            Returns true or false, err
]]--
techage.register_node({"techage:ta4_magnet"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "distance" then
			local pos2 = send_to_next(pos, in_dir, topic, payload)
			if type(pos2) == "table" then
				local dist = math.abs(pos.x - pos2.x) + math.abs(pos.z - pos2.z)
				if pos.y == pos2.y and dist == VTube.max_tube_length + 1 then
					return pos
				end
				return nvm.number or 0
			else
				return pos2
			end
		elseif topic == "enumerate" and payload then
			payload = tonumber(payload) or 1
			nvm.number = payload
			M(pos):set_string("infotext", S("TA4 Collider Magnet") .. " #" .. payload)
			return send_to_next(pos, in_dir, topic, payload + 1)
		elseif topic == "pos" then
			if payload and tonumber(payload) == nvm.number then
				nvm.tube_damage = nil
				return pos
			else
				return send_to_next(pos, in_dir, topic, payload)
			end
		elseif topic == "test" then
			if payload and tonumber(payload) == nvm.number then
				if not nvm.liquid or not nvm.liquid.amount or nvm.liquid.amount < CAPACITY then
					return false, "no gas"
				elseif nvm.liquid.name ~= "techage:isobutane" then
					return false, "wrong gas"
				elseif nvm.consumed ~= PWR_NEEDED then
					return false, "no power"
				elseif nvm.tube_damage then
					nvm.tube_damage = nil
					return false, "no vacuum"
				end
				return true
			else
				return send_to_next(pos, in_dir, topic, payload)
			end
		end
	end,
})

minetest.register_node("techage:ta4_magnet_base", {
	description = S("TA4 Collider Magnet Base"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -8/16, -6/16, 6/16, 5/16, 6/16},
		},
	},
	paramtype2 = "facedir",
	groups = {cracky = 1},
	is_ground_content = false,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techage:ta4_colliderblock",
	recipe = {
		{'techage:aluminum', '', 'default:steel_ingot'},
		{'', '', ''},
		{'default:steel_ingot', '', 'techage:aluminum'},
	},
})


minetest.register_craft({
	output = "techage:ta4_detector_magnet 2",
	recipe = {
		{'default:steel_ingot', '', 'techage:aluminum'},
		{'dye:red', 'basic_materials:gold_wire', 'dye:brown'},
		{'techage:aluminum', '', 'default:steel_ingot'},
	},
})

minetest.register_craft({
	output = "techage:ta4_magnet",
	recipe = {
		{'techage:ta3_pipeS', '', 'techage:electric_cableS'},
		{'techage:ta4_round_ceramic', 'techage:ta4_detector_magnet', 'techage:ta4_round_ceramic'},
		{'', '', ''},
	},
})

minetest.register_craft({
	output = "techage:ta4_magnet_base 4",
	recipe = {
		{'techage:aluminum', 'default:steel_ingot', ''},
		{'techage:aluminum', 'default:steel_ingot', ''},
		{'techage:aluminum', 'default:steel_ingot', ''},
	},
})

minetest.register_lbm({
	label = "Repair Magnets",
	name = "techage:magnets",
	nodenames = {"techage:ta4_magnet", "techage:ta4_collider_pipe_inlet"},
	run_at_every_load = false,
	action = function(pos, node)
		local nvm = techage.get_nvm(pos)
		if nvm.liquid and nvm.liquid.name == "techage:hydrogen" then
			nvm.liquid.name = "techage:isobutane"
		end
	end,
})
