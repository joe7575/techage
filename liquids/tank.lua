--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3/TA4 Tank, Oil Tank

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CAPACITY = 1000

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", liquid.formspec(pos, nvm))
	minetest.get_node_timer(pos):start(2)
end

local function node_timer(pos, elapsed)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
		return true
	end	
	return false
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	return liquid.is_empty(pos)
end

local function take_liquid(pos, indir, name, amount)
	amount, name = liquid.srv_take(pos, indir, name, amount)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
	end
	return amount, name
end
	
local function put_liquid(pos, indir, name, amount)
	-- check if it is not powder
	local ndef = minetest.registered_craftitems[name] or {}
	if not ndef.groups or ndef.groups.powder ~= 1 then
		local leftover = liquid.srv_put(pos, indir, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", liquid.formspec(pos, nvm))
		end
		return leftover
	end
	return amount
end

local function untake_liquid(pos, indir, name, amount)
	local leftover = liquid.srv_put(pos, indir, name, amount)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
	end
	return leftover
end

local networks_def = {
	pipe2 = {
		sides = techage.networks.AllSides, -- Pipe connection sides
		ntype = "tank",
	},
}

minetest.register_node("techage:ta3_tank", {
	description = S("TA3 Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local number = techage.add_node(pos, "techage:ta3_tank")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", liquid.formspec(pos, nvm))
		meta:set_string("infotext", S("TA3 Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	on_timer = node_timer,
	on_punch = liquid.on_punch,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,
	liquid = {
		capa = CAPACITY,
		peek = liquid.srv_peek,
		put = put_liquid,
		take = take_liquid,
		untake = untake_liquid,
	},
	networks = networks_def,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:oiltank", {
	description = S("Oil Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_metal.png^techage_framexl_ta3_top.png",
		"techage_filling_metal.png^techage_framexl_ta3_top.png",
		"techage_filling_metal.png^techage_framexl_ta3.png^techage_appl_explosive.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-6/8, -4/8, -6/8, 6/8, 6/8, 6/8},
	},
	selection_box = {
		type = "fixed",
		fixed = {-6/8, -4/8, -6/8, 6/8, 6/8, 6/8},
	},
	collision_box = {
		type = "fixed",
		fixed = {-6/8, -4/8, -6/8, 6/8, 6/8, 6/8},
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local number = techage.add_node(pos, "techage:oiltank")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", liquid.formspec(pos, nvm))
		meta:set_string("infotext", S("Oil Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	on_timer = node_timer,
	on_punch = liquid.on_punch,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,
	liquid = {
		capa = CAPACITY * 4,
		peek = liquid.srv_peek,
		put = put_liquid,
		take = take_liquid,
		untake = untake_liquid,
	},
	networks = networks_def,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_tank", {
	description = S("TA4 Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local number = techage.add_node(pos, "techage:ta4_tank")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", liquid.formspec(pos, nvm))
		meta:set_string("infotext", S("TA4 Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	on_timer = node_timer,
	on_punch = liquid.on_punch,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,
	liquid = {
		capa = CAPACITY * 2,
		peek = liquid.srv_peek,
		put = put_liquid,
		take = take_liquid,
		untake = untake_liquid,
	},
	networks = networks_def,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

techage.register_node({"techage:ta3_tank", "techage:ta4_tank", "techage:oiltank"}, liquid.recv_message)	

Pipe:add_secondary_node_names({"techage:ta3_tank", "techage:ta4_tank", "techage:oiltank"})

minetest.register_craft({
	output = "techage:ta3_tank 2",
	recipe = {
		{"techage:iron_ingot", "techage:ta3_barrel_empty", "group:wood"},
		{"group:wood", "techage:ta3_barrel_empty", "techage:ta3_pipeS"},
		{"group:wood", "techage:ta3_barrel_empty", "techage:iron_ingot"},
	},
})

minetest.register_craft({
	output = "techage:oiltank",
	recipe = {
		{"", "", ""},
		{"techage:ta3_tank", "techage:iron_ingot", ""},
		{"techage:iron_ingot", "techage:ta3_tank", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_tank",
	recipe = {
		{"default:tin_ingot", "dye:blue", "default:steel_ingot"},
		{"", "techage:ta3_tank", ""},
		{"", "", ""},
	},
})

minetest.register_lbm({
	label = "Repair Tanks",
	name = "techage:tank",
	nodenames = {"techage:ta3_tank", "techage:oiltank", "techage:ta4_tank"},
	run_at_every_load = true,
	action = function(pos, node)
		local mem = tubelib2.get_mem(pos)
		if mem.liquid and mem.liquid.amount then
			local nvm = techage.get_nvm(pos)
			nvm.liquid = nvm.liquid or {}
			nvm.liquid.amount = mem.liquid.amount
			nvm.liquid.name = mem.liquid.name
			--tubelib2.del_mem(pos)
		end
	end,
})