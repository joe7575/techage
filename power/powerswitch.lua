--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Power Switch  (large and small)

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power

local Param2ToDir = {
	[0] = 6,
	[1] = 5,
	[2] = 2,
	[3] = 4,
	[4] = 1,
	[5] = 3,
}

local function sign_in(pos, node)
	local dir = Param2ToDir[node.param2]
	local pos2 = tubelib2.get_pos(pos, dir)
	M(pos2):set_int("switch_sign_in", 1)
end

local function sign_off(pos, node)
	local dir = Param2ToDir[node.param2]
	local pos2 = tubelib2.get_pos(pos, dir)
	M(pos2):set_int("switch_sign_in", 0)
end

local function switch_on(pos, node, clicker, name)
	if clicker and minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
	local dir = Param2ToDir[node.param2]
	local pos2 = tubelib2.get_pos(pos, dir)

	techage.legacy_switches(pos2)
	power.turn_switch_on(pos2, Cable, "techage:powerswitch_box_off", "techage:powerswitch_box_on")
end

local function switch_off(pos, node, clicker, name)
	if clicker and minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
	minetest.get_node_timer(pos):stop()
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
	local dir = Param2ToDir[node.param2]
	local pos2 = tubelib2.get_pos(pos, dir)

	techage.legacy_switches(pos2)
	power.turn_switch_off(pos2, Cable, "techage:powerswitch_box_off", "techage:powerswitch_box_on")
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
		local meta = M(pos)
		local number = techage.add_node(pos, "techage:powerswitch")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA Power Switch").." "..number)
		local node = minetest.get_node(pos)
		switch_on(pos, node, placer, "techage:powerswitch_on")
		sign_in(pos, node)
	end,

	on_rightclick = function(pos, node, clicker)
		switch_on(pos, node, clicker, "techage:powerswitch_on")
	end,

	after_dig_node = sign_off,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
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
		switch_off(pos, node, clicker, "techage:powerswitch")
	end,

	after_dig_node = sign_off,
	drop = "techage:powerswitch",
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:powerswitchsmall", {
	description = S("TA Power Switch Small"),
	inventory_image = "techage_smart_button_inventory.png",
	tiles = {
		'techage_smart_button_off.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -5/32, -16/32, -5/32, 5/32, -15/32, 5/32},
			{ -2/16, -12/16, -2/16, 2/16,  -8/16, 2/16},
		},
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local number = techage.add_node(pos, "techage:powerswitchsmall")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA Power Switch Small").." "..number)
		local node = minetest.get_node(pos)
		switch_on(pos, node, placer, "techage:powerswitchsmall_on")
		sign_in(pos, node)
	end,

	on_rightclick = function(pos, node, clicker)
		switch_on(pos, node, clicker, "techage:powerswitchsmall_on")
	end,

	after_dig_node = sign_off,
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:powerswitchsmall_on", {
	description = S("TA Power Switch Small"),
	inventory_image = "techage_appl_switch_inv.png",
	tiles = {
		'techage_smart_button_on.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -5/32, -16/32, -5/32, 5/32, -15/32, 5/32},
			{ -2/16, -12/16, -2/16, 2/16,  -8/16, 2/16},
		},
	},

	on_rightclick = function(pos, node, clicker)
		switch_off(pos, node, clicker, "techage:powerswitchsmall")
	end,

	after_dig_node = sign_off,
	drop = "techage:powerswitchsmall",
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.register_node({"techage:powerswitch", "techage:powerswitch_on",
		"techage:powerswitchsmall", "techage:powerswitchsmall_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local node = techage.get_node_lvm(pos)
		if topic == "on" and node.name == "techage:powerswitch" then
			switch_on(pos, node, nil, "techage:powerswitch_on")
			return true
		elseif topic == "on" and node.name == "techage:powerswitchsmall" then
			switch_on(pos, node, nil, "techage:powerswitchsmall_on")
			return true
		elseif topic == "off" and node.name == "techage:powerswitch_on" then
			switch_off(pos, node, nil, "techage:powerswitch")
			return true
		elseif topic == "off" and node.name == "techage:powerswitchsmall_on" then
			switch_off(pos, node, nil, "techage:powerswitchsmall")
			return true
		elseif topic == "state" then
			if node.name == "techage:powerswitch_on" or
					node.name == "techage:powerswitchsmall_on" then
				return "on"
			end
			return "off"
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local node = techage.get_node_lvm(pos)
		if topic == 1 and payload[1] == 1 and node.name == "techage:powerswitch" then
			switch_on(pos, node, nil, "techage:powerswitch_on")
			return 0
		elseif topic == 1 and payload[1] == 1 and node.name == "techage:powerswitchsmall" then
			switch_on(pos, node, nil, "techage:powerswitchsmall_on")
			return 0
		elseif topic == 1 and payload[1] == 0 and node.name == "techage:powerswitch_on" then
			switch_off(pos, node, nil, "techage:powerswitch")
			return 0
		elseif topic == 1 and payload[1] == 0 and node.name == "techage:powerswitchsmall_on" then
			switch_off(pos, node, nil, "techage:powerswitchsmall")
			return 0
		else
			return 2
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local node = techage.get_node_lvm(pos)
		if topic == 142 then
			if node.name == "techage:powerswitch_on" or
					node.name == "techage:powerswitchsmall_on" then
				return 0, {1}
			end
			return 0, {0}
		else
			return 2, ""
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
	type = "shapeless",
	output = "techage:powerswitchsmall",
	recipe = {"techage:powerswitch"},
})
