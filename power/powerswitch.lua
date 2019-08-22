--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Power Station Generator

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S


local Cable = techage.ElectricCable
local power_cut = techage.power.power_cut
local after_rotate_node = techage.power.after_rotate_node

local Param2ToDir = {
	[0] = 6,
	[1] = 5,
	[2] = 2,
	[3] = 4,
	[4] = 1,
	[5] = 3,
}

local function switch_on(pos, node, clicker)
	if clicker and minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	node.name = "techage:powerswitch_on"
	minetest.swap_node(pos, node)
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
	local dir = Param2ToDir[node.param2]
	power_cut(pos, dir, Cable, false)
end

local function switch_off(pos, node, clicker)
	if clicker and minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	node.name = "techage:powerswitch"
	minetest.swap_node(pos, node)
	minetest.get_node_timer(pos):stop()
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
	local dir = Param2ToDir[node.param2]
	power_cut(pos, dir, Cable, true)
end


minetest.register_node("techage:powerswitch", {
	description = S("TA Power Switch"),
	inventory_image = "techage_appl_switch_inv.png",
	tiles = {
		'techage_appl_switch_off.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/4, -8/16, -1/4,  1/4, -7/16, 1/4},
			{ -1/6, -12/16, -1/6,  1/6, -8/16, 1/6},
		},
	},
	
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:powerswitch")
		meta:set_string("number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA Power Switch").." "..number)
	end,

	on_rightclick = function(pos, node, clicker)
		switch_on(pos, node, clicker)
	end,

	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:powerswitch_on", {
	description = S("TA Power Switch"),
	inventory_image = "techage_appl_switch_inv.png",
	tiles = {
		'techage_appl_switch_on.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/4, -8/16, -1/4,  1/4, -7/16, 1/4},
			{ -1/6, -12/16, -1/6,  1/6, -8/16, 1/6},
		},
	},
	
	on_rightclick = function(pos, node, clicker)
		switch_off(pos, node, clicker)
	end,

	drop = "techage:powerswitch",
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local function get_conn_dirs(pos, node)
	local tbl = {[0]=
		{2,4}, {1,3}, {2,4}, {1,3},
		{2,4}, {5,6}, {2,4}, {5,6},
		{2,4}, {5,6}, {2,4}, {5,6},
		{5,6}, {1,3}, {5,6}, {1,3},
		{5,6}, {1,3}, {5,6}, {1,3},
		{2,4}, {1,3}, {2,4}, {1,3},
	}
	return tbl[node.param2]
end

local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	return minetest.rotate_and_place(itemstack, placer, pointed_thing)
end

local function on_rotate(pos, node, user, mode, new_param2)
	if minetest.is_protected(pos, user:get_player_name()) then
		return false
	end
	node.param2 = techage.rotate_wallmounted(node.param2)
	minetest.swap_node(pos, node)
	after_rotate_node(pos, Cable)
	return true
end

minetest.register_node("techage:powerswitch_box", {
	description = S("TA Power Switch Box"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_switch.png',
		'techage_electric_switch.png',
		'techage_electric_junction.png',
		'techage_electric_junction.png',
		'techage_electric_switch.png',
		'techage_electric_switch.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -2/4, -1/4, -1/4,  2/4, 1/4, 1/4},
		},
	},
	
	on_place = on_place,
	on_rotate = on_rotate,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, techage_trowel = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:powerswitch_box"}, {
		power_network = Cable,
		conn_sides = get_conn_dirs,
})

techage.register_node({"techage:powerswitch", "techage:powerswitch_on"}, {
	on_recv_message = function(pos, topic, payload)
		local mem = tubelib2.get_mem(pos)
		local node = minetest.get_node(pos)
		if topic == "on" and node.name == "techage:powerswitch" then
			switch_on(pos, node)
			return true
		elseif topic == "off" and node.name == "techage:powerswitch_on" then
			switch_off(pos, node)
			return true
		elseif topic == "state" then
			if node.name == "techage:powerswitch_on" then
				return "on"
			end
			return "off"
		else
			return "unsupported"
		end
	end,
})	

minetest.register_craft({
	output = "techage:powerswitch 2",
	recipe = {
		{"", "", ""},
		{"dye:yellow", "dye:red", "dye:yellow"},
		{"basic_materials:plastic_sheet", "basic_materials:copper_wire", "basic_materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output = "techage:powerswitch_box",
	recipe = {
		{"", "basic_materials:plastic_sheet", ""},
		{"techage:electric_cableS", "basic_materials:copper_wire", "techage:electric_cableS"},
		{"", "basic_materials:plastic_sheet", ""},
	},
})
