--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Winch for TA2 gravity-based energy storage

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local MIN_LOAD = 99  -- 1 stack
local MAX_ROPE_LEN = 10
local CYCLE_TIME = 2

local Axle = techage.Axle
local power = networks.power


local function chest_pos(pos)
	local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}  -- start pos
	local pos2 = {x = pos.x, y = pos.y - 1 - MAX_ROPE_LEN, z = pos.z}  -- end pos
	local _, pos3 = minetest.line_of_sight(pos1, pos2)
	return pos3 or pos2
end

local function chest_load(nvm, pos)
	local amount = 0
	local inv = minetest.get_inventory({type = "node", pos = pos})
	nvm.stored_items = {}
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		nvm.stored_items[i] = {name = stack:get_name(), count = stack:get_count()}
		amount = amount + stack:get_count()
	end
	return amount
end

local function chest_full(pos)
	local nvm = techage.get_nvm(pos)
	local pos1 = chest_pos(pos)
	local node = minetest.get_node(pos1)
	if node.name == "techage:ta2_weight_chest" then
		return chest_load(nvm, pos1) >= MIN_LOAD
	end
end

local function add_chest_entity(pos, nvm)
	local mem = techage.get_mem(pos)
	local length
	
	if not nvm.capa or nvm.capa == 0 then
		length = (nvm.length or MAX_ROPE_LEN) * (1 - (nvm.load or 0))
	else
		length = (nvm.length or MAX_ROPE_LEN) * (1 - (nvm.load or 0) / nvm.capa)
	end
	local y = pos.y - length - 1
	techage.renew_rope(pos, length, true)
	if mem.obj then
		mem.obj:remove()
	end
	mem.obj = minetest.add_entity({x = pos.x, y = y, z = pos.z}, "techage:ta2_weight_chest_entity")
end

-- Add chest node, remove chest entity instead
local function add_chest(pos)
	local mem = techage.get_mem(pos)
	local nvm = techage.get_nvm(pos)
	if mem.obj then
		mem.obj:remove()
		mem.obj = nil
	end
	if nvm.capa and nvm.capa >= MIN_LOAD then
		local pos1 = {x = pos.x, y = pos.y - (nvm.length or 1) - 1, z = pos.z}
		minetest.add_node(pos1, {name = "techage:ta2_weight_chest", param2 = 0})
		local ndef = minetest.registered_nodes["techage:ta2_weight_chest"]
		ndef.on_construct(pos1)
		ndef.after_place_node(pos1)
		local inv = minetest.get_inventory({type = "node", pos = pos1})
		for i, item in ipairs(nvm.stored_items or {}) do
			inv:set_stack("main", i, item)
		end
	end
	nvm.capa = 0
end

-- Remove chest node, add rope and chest entity instead
local function remove_chest(pos)
	local mem = techage.get_mem(pos)
	local nvm = techage.get_nvm(pos)
	local pos1 = chest_pos(pos)
	local mass = chest_load(nvm, pos1)
	if mass > 0 then
		nvm.length = pos.y - pos1.y - 1
		nvm.capa = mass * nvm.length / MAX_ROPE_LEN
		minetest.remove_node(pos1)
		mem.obj = minetest.add_entity(pos1, "techage:ta2_weight_chest_entity")
		techage.renew_rope(pos, nvm.length)
		return true
	end
end

minetest.register_node("techage:ta2_winch", {
	description = S("TA2 Winch"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_appl_arrow2.png^techage_frame_ta2.png^[transformR270",
		"techage_filling_ta2.png^techage_appl_arrow2.png^techage_frame_ta2.png^techage_appl_winch_hole.png^[transformR270",
		"techage_filling_ta2.png^techage_axle_gearbox.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_winch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_winch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_winch.png^techage_frame_ta2.png",
	},

	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		local outdir = networks.side_to_outdir(pos, "R")
		M(pos):set_int("outdir", outdir)
		Axle:after_place_node(pos, {outdir})
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		techage.renew_rope(pos, MAX_ROPE_LEN - 1)
	end,

	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		local outdir = M(pos):get_int("outdir")
		nvm.capa = nvm.capa or 1
		nvm.load = nvm.load or 0

		if not nvm.running and power.power_available(pos, Axle, outdir) and chest_full(pos) then
			remove_chest(pos)
			nvm.running = true
			power.start_storage_calc(pos, Axle, outdir)
		elseif nvm.running and nvm.load == 0 and not power.power_available(pos, Axle, outdir) then
			add_chest(pos)
			nvm.running = false
			power.start_storage_calc(pos, Axle, outdir)
		end

		if nvm.running then
			local val = power.get_storage_load(pos, Axle, outdir, nvm.capa) or 0
			if val > 0 then
				nvm.load = val
				add_chest_entity(pos, nvm)
			end
		end
		return true
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		add_chest(pos)
		techage.del_rope(pos)
		local outdir = tonumber(oldmetadata.fields.outdir or 0)
		power.start_storage_calc(pos, Axle, outdir)
		Axle:after_dig_node(pos, {outdir})
		techage.del_mem(pos)
	end,

	get_storage_data = function(pos, outdir, tlib2)
		local nvm = techage.get_nvm(pos)
		nvm.capa = nvm.capa or 1
		if nvm.running then
			return {level = (nvm.load or 0) / nvm.capa, capa = nvm.capa}
		end
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:ta2_winch"}, Axle, "sto", {"R"})

techage.register_node({"techage:ta2_winch"}, {
	on_node_load = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		local nvm = techage.get_nvm(pos)
		add_chest_entity(pos, nvm)
	end,
})

minetest.register_craft({
	output = "techage:ta2_winch",
	recipe = {
		{"farming:string", "farming:string", "farming:string"},
		{"farming:string", "techage:gearbox", "farming:string"},
		{"farming:string", "farming:string", "farming:string"},
	},
})
