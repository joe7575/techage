--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Valve

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local function switch_node(pos, node)
	if node.name == "techage:ta3_valve_open" then
		node.name = "techage:ta3_valve_closed"
		--node.name = "default:dirt"
		minetest.swap_node(pos, node)
		local number = M(pos):get_string("node_number")
		M(pos):set_string("infotext", S("TA3 Valve closed")..": "..number)
		Pipe:after_dig_tube(pos, {name = "techage:ta3_valve_open", param2 = node.param2})
	elseif node.name == "techage:ta3_valve_closed" then
		node.name = "techage:ta3_valve_open"
		minetest.swap_node(pos, node)	
		local number = M(pos):get_string("node_number")
		M(pos):set_string("infotext", S("TA3 Valve open")..": "..number)
		Pipe:after_place_tube(pos)
	end
	minetest.sound_play("techage_valve", {
		pos = pos, 
		gain = 1,
		max_hear_distance = 10})
end

local function on_rightclick(pos, node, clicker)
	if not minetest.is_protected(pos, clicker:get_player_name()) then
		switch_node(pos, node)
	end
end

--local function node_timer(pos, elapsed)
--	if techage.is_activeformspec(pos) then
--		local nvm = techage.get_nvm(pos)
--		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
--		return true
--	end	
--	return false
--end

--local function can_dig(pos, player)
--	if minetest.is_protected(pos, player:get_player_name()) then
--		return false
--	end
--	return liquid.is_empty(pos)
--end

--local function take_liquid(pos, indir, name, amount)
--	amount, name = liquid.srv_take(pos, indir, name, amount)
--	if techage.is_activeformspec(pos) then
--		local nvm = techage.get_nvm(pos)
--		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
--	end
--	return amount, name
--end
	
--local function put_liquid(pos, indir, name, amount)
--	-- check if it is not powder
--	local ndef = minetest.registered_craftitems[name] or {}
--	if not ndef.groups or ndef.groups.powder ~= 1 then
--		local leftover = liquid.srv_put(pos, indir, name, amount)
--		if techage.is_activeformspec(pos) then
--			local nvm = techage.get_nvm(pos)
--			M(pos):set_string("formspec", liquid.formspec(pos, nvm))
--		end
--		return leftover
--	end
--	return amount
--end

minetest.register_node("techage:ta3_valve_open", {
	description = S("TA Valve"),
	tiles = {
		"techage_gaspipe.png^techage_gaspipe_valve_open.png^[transformR90",
		"techage_gaspipe.png^techage_gaspipe_valve_open.png^[transformR90",
		"techage_gaspipe.png^techage_gaspipe_valve_open.png",
		"techage_gaspipe.png^techage_gaspipe_valve_open.png",
		"techage_gaspipe_valve_hole.png",
		"techage_gaspipe_valve_hole.png",
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local number = techage.add_node(pos, "techage:ta3_valve_closed")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA3 Valve open")..": "..number)
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	
	on_rightclick = on_rightclick,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8,  -1/8,  -4/8,   1/8,  1/8,  4/8},
			{-3/16, -3/16, -3/16,  3/16, 3/16, 3/16},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta3_valve_closed", {
	description = S("TA Valve"),
	tiles = {
		"techage_gaspipe.png^techage_gaspipe_valve_closed.png^[transformR90",
		"techage_gaspipe.png^techage_gaspipe_valve_closed.png^[transformR90",
		"techage_gaspipe.png^techage_gaspipe_valve_closed.png",
		"techage_gaspipe.png^techage_gaspipe_valve_closed.png",
		"techage_gaspipe_valve_hole.png",
		"techage_gaspipe_valve_hole.png",
	},
	
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,
	
	on_rightclick = on_rightclick,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8,  -1/8,  -4/8,   1/8,  1/8,  4/8},
			{-3/16, -3/16, -3/16,  3/16, 3/16, 3/16},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 2, cracky = 2, snappy = 2, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta3_valve_open",
})

techage.register_node({"techage:ta3_valve_closed", "techage:ta3_valve_open"}, {
	on_recv_message = function(pos, src, topic, payload)
		local node = techage.get_node_lvm(pos)
		if topic == "on" and node.name == "techage:ta3_valve_closed" then
			switch_node(pos, node)
			return true
		elseif topic == "off" and node.name == "techage:ta3_valve_open" then
			switch_node(pos, node)
			return true
		elseif topic == "state" then
			if node.name == "techage:ta3_valve_open" then
				return "on"
			end
			return "off"
		else
			return "unsupported"
		end
	end,
})	

minetest.register_craft({
	output = "techage:ta3_valve_open",
	recipe = {
		{"", "dye:black", ""},
		{"techage:ta3_pipeS", "basic_materials:steel_bar", "techage:ta3_pipeS"},
		{"", "techage:vacuum_tube", ""},
	},
})
