--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Valve

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

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
		local number = techage.add_node(pos, "techage:ta3_valve_closed")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA3 Valve")..": "..number)
		return false
	end,
	on_rightclick = function(pos, node, clicker)
		if minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end
		if liquid.turn_valve_off(pos, Pipe, "techage:ta3_valve_closed", "techage:ta3_valve_open") then
			minetest.sound_play("techage_valve", {
				pos = pos,
				gain = 1,
				max_hear_distance = 10})
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_tube(pos, oldnode, oldmetadata)
	end,

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
	use_texture_alpha = techage.CLIP,
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

	on_rightclick = function(pos, node, clicker)
		if minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end
		if liquid.turn_valve_on(pos, Pipe, "techage:ta3_valve_closed", "techage:ta3_valve_open") then
			minetest.sound_play("techage_valve", {
				pos = pos,
				gain = 1,
				max_hear_distance = 10})
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

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
	use_texture_alpha = techage.CLIP,
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
			liquid.turn_valve_on(pos, Pipe, "techage:ta3_valve_closed", "techage:ta3_valve_open")
			return true
		elseif topic == "off" and node.name == "techage:ta3_valve_open" then
			liquid.turn_valve_off(pos, Pipe, "techage:ta3_valve_closed", "techage:ta3_valve_open")
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
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local node = techage.get_node_lvm(pos)
		if topic == 1 and payload[1] == 1 and node.name == "techage:ta3_valve_closed" then
			liquid.turn_valve_on(pos, Pipe, "techage:ta3_valve_closed", "techage:ta3_valve_open")
			return 0
		elseif topic == 1 and payload[1] == 0 and node.name == "techage:ta3_valve_open" then
			liquid.turn_valve_off(pos, Pipe, "techage:ta3_valve_closed", "techage:ta3_valve_open")
			return 0
		else
			return 2, ""
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local node = techage.get_node_lvm(pos)
		if topic == 142 then -- State
			if node.name == "techage:ta3_valve_open" then
				return 0, {1}
			end
			return 0, {0}
		else
			return 2, ""
		end
	end,
})

liquid.register_nodes({"techage:ta3_valve_closed"}, Pipe, "special", {}, {})

minetest.register_craft({
	output = "techage:ta3_valve_open",
	recipe = {
		{"", "dye:black", ""},
		{"techage:ta3_pipeS", "basic_materials:steel_bar", "techage:ta3_pipeS"},
		{"", "techage:vacuum_tube", ""},
	},
})
