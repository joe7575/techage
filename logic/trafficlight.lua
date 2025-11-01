--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Traffic Lights

]]--

local S = techage.S
local M = minetest.get_meta
local P2S = minetest.pos_to_string

local TITLE = S("TA4 Traffic Light")

local 
ConvertTo = {
	off =  {
		["techage:ta4_trafficlight1_red"]    = "techage:ta4_trafficlight1",
		["techage:ta4_trafficlight1_amber"]  = "techage:ta4_trafficlight1",
		["techage:ta4_trafficlight1_green"]  = "techage:ta4_trafficlight1",
		["techage:ta4_trafficlight1B_red"]   = "techage:ta4_trafficlight1B",
		["techage:ta4_trafficlight1B_amber"] = "techage:ta4_trafficlight1B",
		["techage:ta4_trafficlight1B_green"] = "techage:ta4_trafficlight1B",
		["techage:ta4_trafficlight2_red"]    = "techage:ta4_trafficlight2",
		["techage:ta4_trafficlight2_amber"]  = "techage:ta4_trafficlight2",
		["techage:ta4_trafficlight2_green"]  = "techage:ta4_trafficlight2",
		["techage:ta4_trafficlight2B_red"]   = "techage:ta4_trafficlight2B",
		["techage:ta4_trafficlight2B_amber"] = "techage:ta4_trafficlight2B",
		["techage:ta4_trafficlight2B_green"] = "techage:ta4_trafficlight2B",
	},
	green = {
		["techage:ta4_trafficlight1_red"]    = "techage:ta4_trafficlight1_green",
		["techage:ta4_trafficlight1_amber"]  = "techage:ta4_trafficlight1_green",
		["techage:ta4_trafficlight1"]        = "techage:ta4_trafficlight1_green",
		["techage:ta4_trafficlight1B_red"]   = "techage:ta4_trafficlight1B_green",
		["techage:ta4_trafficlight1B_amber"] = "techage:ta4_trafficlight1B_green",
		["techage:ta4_trafficlight1B"]       = "techage:ta4_trafficlight1B_green",
		["techage:ta4_trafficlight2_red"]    = "techage:ta4_trafficlight2_green",
		["techage:ta4_trafficlight2_amber"]  = "techage:ta4_trafficlight2_green",
		["techage:ta4_trafficlight2"]        = "techage:ta4_trafficlight2_green",
		["techage:ta4_trafficlight2B_red"]   = "techage:ta4_trafficlight2B_green",
		["techage:ta4_trafficlight2B_amber"] = "techage:ta4_trafficlight2B_green",
		["techage:ta4_trafficlight2B"]       = "techage:ta4_trafficlight2B_green",
	},
	amber = {
		["techage:ta4_trafficlight1_red"]    = "techage:ta4_trafficlight1_amber",
		["techage:ta4_trafficlight1_green"]  = "techage:ta4_trafficlight1_amber",
		["techage:ta4_trafficlight1"]        = "techage:ta4_trafficlight1_amber",
		["techage:ta4_trafficlight1B_red"]   = "techage:ta4_trafficlight1B_amber",
		["techage:ta4_trafficlight1B_green"] = "techage:ta4_trafficlight1B_amber",
		["techage:ta4_trafficlight1B"]       = "techage:ta4_trafficlight1B_amber",
		["techage:ta4_trafficlight2_red"]    = "techage:ta4_trafficlight2_amber",
		["techage:ta4_trafficlight2_green"]  = "techage:ta4_trafficlight2_amber",
		["techage:ta4_trafficlight2"]        = "techage:ta4_trafficlight2_amber",
		["techage:ta4_trafficlight2B_red"]   = "techage:ta4_trafficlight2B_amber",
		["techage:ta4_trafficlight2B_green"] = "techage:ta4_trafficlight2B_amber",
		["techage:ta4_trafficlight2B"]       = "techage:ta4_trafficlight2B_amber",
	},
	red = {
		["techage:ta4_trafficlight1_amber"]  = "techage:ta4_trafficlight1_red",
		["techage:ta4_trafficlight1_green"]  = "techage:ta4_trafficlight1_red",
		["techage:ta4_trafficlight1"]        = "techage:ta4_trafficlight1_red",
		["techage:ta4_trafficlight1B_amber"] = "techage:ta4_trafficlight1B_red",
		["techage:ta4_trafficlight1B_green"] = "techage:ta4_trafficlight1B_red",
		["techage:ta4_trafficlight1B"]       = "techage:ta4_trafficlight1B_red",
		["techage:ta4_trafficlight2_amber"]  = "techage:ta4_trafficlight2_red",
		["techage:ta4_trafficlight2_green"]  = "techage:ta4_trafficlight2_red",
		["techage:ta4_trafficlight2"]        = "techage:ta4_trafficlight2_red",
		["techage:ta4_trafficlight2B_amber"] = "techage:ta4_trafficlight2B_red",
		["techage:ta4_trafficlight2B_green"] = "techage:ta4_trafficlight2B_red",
		["techage:ta4_trafficlight2B"]       = "techage:ta4_trafficlight2B_red",
	},
}

local SelectionBox = {
	type = "fixed",
	fixed = {-5/32, -15/32, 6/32, 5/32, 15/32, 24/32},
}


local function is_pole(pos)
	local node = minetest.get_node(pos)
	local dir = tubelib2.side_to_dir("B", node.param2)
	local pos2 = tubelib2.get_pos(pos, dir)
	local name = minetest.get_node(pos2).name
	return name == "techage:trafficlight_connector" or name == "techage:trafficlight_pole"
end

local function switch_on(pos, color)
	local node = techage.get_node_lvm(pos)
	if ConvertTo[color][node.name] then
		node.name = ConvertTo[color][node.name]
		M(pos):set_string("state", color)
		minetest.swap_node(pos, node)
	end
end

local function switch_off(pos)
	local node = techage.get_node_lvm(pos)
	if ConvertTo["off"][node.name] then
		node.name = ConvertTo["off"][node.name]
		M(pos):set_string("state", "off")
		minetest.swap_node(pos, node)
	end
end

local function on_rightclick(pos, node, clicker)
	if not minetest.is_protected(pos, clicker:get_player_name()) then
		local state = M(pos):get_string("state")
		if state == "off" then
			switch_on(pos, "green")
		else
			switch_off(pos)
		end
	end
end

local function after_dig_node(pos, oldnode, oldmetadata)
	techage.remove_node(pos, oldnode, oldmetadata)
end

minetest.register_node("techage:ta4_trafficlight1", {
	description = TITLE,
	tiles = {"techage_trafficlight1.png"},
	drawtype = "mesh",
	mesh = "techage_traffic_light.obj",
	selection_box = SelectionBox,

	after_place_node = function(pos, placer)
		local number
		if is_pole(pos) then
			local node =  minetest.get_node(pos)
			node.name = "techage:ta4_trafficlight1B"
			minetest.swap_node(pos, node)
			number = techage.add_node(pos, "techage:ta4_trafficlight1B")
		else
			number = techage.add_node(pos, "techage:ta4_trafficlight1")
		end
		local meta = M(pos)
		meta:set_string("state", "off")
		meta:set_string("infotext", TITLE .. " " .. number)
	end,
	
	on_rightclick = on_rightclick,
	after_dig_node = after_dig_node,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

for _,color in ipairs({"green", "amber", "red"}) do
	local tiles = {"techage_trafficlight1_" .. color .. '.png'}
	minetest.register_node("techage:ta4_trafficlight1_" .. color, {
		description = TITLE,
		tiles = tiles,
		drawtype = "mesh",
		mesh = "techage_traffic_light.obj",
		selection_box = SelectionBox,

		on_rightclick = on_rightclick,
		after_dig_node = after_dig_node,

		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		light_source = 10,
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {crumbly=0, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
		drop = "techage:ta4_trafficlight1",
	})
end

minetest.register_node("techage:ta4_trafficlight1B", {
	description = TITLE,
	tiles = {"techage_trafficlight1.png"},
	drawtype = "mesh",
	mesh = "techage_traffic_lightB.obj",
	selection_box = SelectionBox,

	on_rightclick = on_rightclick,
	after_dig_node = after_dig_node,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
	drop = "techage:ta4_trafficlight1",
})

for _,color in ipairs({"green", "amber", "red"}) do
	local tiles = {"techage_trafficlight1_" .. color .. '.png'}
	minetest.register_node("techage:ta4_trafficlight1B_" .. color, {
		description = TITLE,
		tiles = tiles,
		drawtype = "mesh",
		mesh = "techage_traffic_lightB.obj",
		selection_box = SelectionBox,
	
		on_rightclick = on_rightclick,
		after_dig_node = after_dig_node,

		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		light_source = 10,
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {crumbly=0, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
		drop = "techage:ta4_trafficlight1",
	})
end

minetest.register_node("techage:ta4_trafficlight2", {
	description = TITLE,
	tiles = {"techage_trafficlight2.png"},
	drawtype = "mesh",
	mesh = "techage_traffic_light.obj",
	selection_box = SelectionBox,

	after_place_node = function(pos, placer)
		local number
		if is_pole(pos) then
			local node =  minetest.get_node(pos)
			node.name = "techage:ta4_trafficlight2B"
			minetest.swap_node(pos, node)
			number = techage.add_node(pos, "techage:ta4_trafficlight2B")
		else
			number = techage.add_node(pos, "techage:ta4_trafficlight2")
		end
		local meta = M(pos)
		meta:set_string("state", "off")
		meta:set_string("infotext", TITLE .. " " .. number)
	end,
	
	on_rightclick = on_rightclick,
	after_dig_node = after_dig_node,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

for _,color in ipairs({"green", "amber", "red"}) do
	local tiles = {"techage_trafficlight2_" .. color .. '.png'}
	minetest.register_node("techage:ta4_trafficlight2_" .. color, {
		description = TITLE,
		tiles = tiles,
		drawtype = "mesh",
		mesh = "techage_traffic_light.obj",
		selection_box = SelectionBox,

		on_rightclick = on_rightclick,
		after_dig_node = after_dig_node,

		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		light_source = 10,
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {crumbly=0, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
		drop = "techage:ta4_trafficlight2",
	})
end

minetest.register_node("techage:ta4_trafficlight2B", {
	description = TITLE,
	tiles = {"techage_trafficlight2.png"},
	drawtype = "mesh",
	mesh = "techage_traffic_lightB.obj",
	selection_box = SelectionBox,

	on_rightclick = on_rightclick,
	after_dig_node = after_dig_node,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
	drop = "techage:ta4_trafficlight2",
})

for _,color in ipairs({"green", "amber", "red"}) do
	local tiles = {"techage_trafficlight2_" .. color .. '.png'}
	minetest.register_node("techage:ta4_trafficlight2B_" .. color, {
		description = TITLE,
		tiles = tiles,
		drawtype = "mesh",
		mesh = "techage_traffic_lightB.obj",
	selection_box = SelectionBox,

		on_rightclick = on_rightclick,
		after_dig_node = after_dig_node,

		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		light_source = 10,
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {crumbly=0, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
		drop = "techage:ta4_trafficlight2",
	})
end

minetest.register_craft({
	output = "techage:ta4_trafficlight1",
	recipe = {
		{"",  "dye:black", ""},
		{"", "techage:ta4_signaltower", ""},
		{"",  "default:steel_ingot", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_trafficlight2",
	recipe = {
		{"",  "dye:orange", ""},
		{"", "techage:ta4_signaltower", ""},
		{"",  "default:steel_ingot", ""},
	},
})

techage.register_node({
	"techage:ta4_trafficlight1",
	"techage:ta4_trafficlight1_green",
	"techage:ta4_trafficlight1_amber",
	"techage:ta4_trafficlight1_red",
	"techage:ta4_trafficlight2",
	"techage:ta4_trafficlight2_green",
	"techage:ta4_trafficlight2_amber",
	"techage:ta4_trafficlight2_red",
	"techage:ta4_trafficlight1B",
	"techage:ta4_trafficlight1B_green",
	"techage:ta4_trafficlight1B_amber",
	"techage:ta4_trafficlight1B_red",
	"techage:ta4_trafficlight2B",
	"techage:ta4_trafficlight2B_green",
	"techage:ta4_trafficlight2B_amber",
	"techage:ta4_trafficlight2B_red"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "green" then
			switch_on(pos, "green")
		elseif topic == "amber" then
			switch_on(pos, "amber")
		elseif topic == "red" then
			switch_on(pos, "red")
		elseif topic == "off" then
			switch_off(pos)
		elseif topic == "state" then
			local meta = minetest.get_meta(pos)
			return meta:get_string("state")
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 2 then
			local color = ({"green", "amber", "red"})[payload[1]]
			if color then
				switch_on(pos, color)
			else
				switch_off(pos)
			end
			return 0
		else
			return 2  -- unknown or invalid topic
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 130 then
			local meta = minetest.get_meta(pos)
			local color = ({off = 0, green = 1, amber = 2, red = 3})[meta:get_string("state")] or 1
			return 0, {color}
		else
			return 2, ""  -- unknown or invalid topic
		end
	end,
})

minetest.register_node("techage:trafficlight_pole", {
	description = S("TA4 Traffic Light Pole"),
	tiles = {
		"techage_trafficlight_pole.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed =         {{ -4/32, -16/32,  -4/32,   4/32, 16/32,   4/32}},
		connect_left =  {{-16/32, 0/32, -3/32,   3/32, 6/32, 3/32}},
		connect_right = {{ -3/32, 0/32, -3/32,  16/32, 6/32, 3/32}},
		connect_back =  {{ -3/32, 0/32, -3/32,   3/32, 6/32, 16/32}},
		connect_front = {{ -3/32, 0/32, -16/32,  3/32, 6/32, 3/32}},
	},
	connects_to = {
		"techage:trafficlight_arm",
		"techage:trafficlight_connector",
		"techage:ta4_trafficlight1",
		"techage:ta4_trafficlight1B",
		"techage:ta4_trafficlight1_red",
		"techage:ta4_trafficlight1_amber",
		"techage:ta4_trafficlight1_green",
		"techage:ta4_trafficlight1B_red",
		"techage:ta4_trafficlight1B_amber",
		"techage:ta4_trafficlight1B_green",
		"techage:ta4_trafficlight2",
		"techage:ta4_trafficlight2B",
		"techage:ta4_trafficlight2_red",
		"techage:ta4_trafficlight2_amber",
		"techage:ta4_trafficlight2_green",
		"techage:ta4_trafficlight2B_red",
		"techage:ta4_trafficlight2B_amber",
		"techage:ta4_trafficlight2B_green",
	},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:trafficlight_connector", {
	description = S("TA4 Traffic Light Connector"),
	tiles = {
		"techage_trafficlight_pole.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed =         {{ -4/32, -4/32,  -4/32,   4/32, 10/32,   4/32}},
		connect_left =  {{-16/32, 0/32, -3/32,   3/32, 6/32, 3/32}},
		connect_right = {{ -3/32, 0/32, -3/32,  16/32, 6/32, 3/32}},
		connect_back =  {{ -3/32, 0/32, -3/32,   3/32, 6/32, 16/32}},
		connect_front = {{ -3/32, 0/32, -16/32,  3/32, 6/32, 3/32}},
	},
	connects_to = {
		"techage:trafficlight_arm",
		"techage:trafficlight_connector",
		"techage:trafficlight_pole",
		"techage:ta4_trafficlight1",
		"techage:ta4_trafficlight1B",
		"techage:ta4_trafficlight1_red",
		"techage:ta4_trafficlight1_amber",
		"techage:ta4_trafficlight1_green",
		"techage:ta4_trafficlight1B_red",
		"techage:ta4_trafficlight1B_amber",
		"techage:ta4_trafficlight1B_green",
		"techage:ta4_trafficlight2",
		"techage:ta4_trafficlight2B",
		"techage:ta4_trafficlight2_red",
		"techage:ta4_trafficlight2_amber",
		"techage:ta4_trafficlight2_green",
		"techage:ta4_trafficlight2B_red",
		"techage:ta4_trafficlight2B_amber",
		"techage:ta4_trafficlight2B_green",
	},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:trafficlight_arm", {
	description = S("TA4 Traffic Light Arm"),
	tiles = {
		"techage_trafficlight_pole.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed =         {{ -3/32, 0/32, -16/32, 3/32, 6/32, 16/32}},
	},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_craft({
	output = "techage:trafficlight_pole",
	recipe = {
		{"", "basic_materials:steel_bar", ""},
		{"", "basic_materials:steel_bar", "dye:dark_grey"},
		{"", "basic_materials:steel_bar", ""},
	},
})

minetest.register_craft({
	output = "techage:trafficlight_arm",
	recipe = {
		{"", "dye:dark_grey", ""},
		{"basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techage:trafficlight_connector",
	recipe = {
		{"dye:dark_grey", "basic_materials:steel_bar", ""},
		{"basic_materials:steel_bar", "", ""},
		{"",  "", ""},
	},
})
