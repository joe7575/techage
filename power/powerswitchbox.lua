--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Power Switch Box
]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = techage.get_node_lvm
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power

local node_box = {
	type = "fixed",
	fixed = {
		{ -1/4, -1/4, -2/4,  1/4, 1/4, 2/4},
	},
}

function techage.legacy_switches(pos)
	local meta = M(pos)
	local node = N(pos)

	if node.name == "techage:powerswitch_box" then
		if meta:get_int("netw_param2") == 0 then
			node.name = "techage:powerswitch_box_off"
		else
			node.name = "techage:powerswitch_box_on"
		end
		minetest.swap_node(pos, node)
	elseif meta:get_string("netw_name") == "techage:powerswitch_box" then
		if meta:get_int("netw_param2") == 0 then
			meta:set_string("netw_name", "techage:powerswitch_box_off")
		else
			meta:set_string("netw_name", "techage:powerswitch_box_on")
		end
	end

	if meta:contains("tl2_param2_copy") then
		meta:set_string("netw_param2_copy", meta:get_string("tl2_param2_copy"))
		meta:set_string("tl2_param2_copy", "")
	end
end


-- The on-switch is a "primary node" like cables
minetest.register_node("techage:powerswitch_box_on", {
	description = S("TA Power Switch Box"),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = node_box,
	tiles = {
		"techage_electric_switch.png^[transformR90",
		"techage_electric_switch.png^[transformR90",
		"techage_electric_switch.png",
		"techage_electric_switch.png",
		"techage_electric_junction.png",
		"techage_electric_junction.png",
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	on_rightclick = function(pos, node, clicker)
		techage.legacy_switches(pos)
		if M(pos):get_int("switch_sign_in") ~= 1 then
			if power.turn_switch_off(pos, Cable, "techage:powerswitch_box_off", "techage:powerswitch_box_on") then
				minetest.sound_play("doors_glass_door_open", {
					pos = pos,
					gain = 1,
					max_hear_distance = 5})
			end
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy=2, cracky=2, crumbly=2, techage_trowel = 1},
	sounds = default.node_sound_defaults(),
})

-- The off-switch is a "secondary node" without connection sides
minetest.register_node("techage:powerswitch_box_off", {
	description = S("TA Power Switch Box"),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = node_box,
	tiles = {
		"techage_electric_switch_off.png^[transformR90",
		"techage_electric_switch_off.png^[transformR90",
		"techage_electric_switch_off.png",
		"techage_electric_switch_off.png",
		"techage_electric_junction.png",
		"techage_electric_junction.png",
	},
	on_rightclick = function(pos, node, clicker)
		techage.legacy_switches(pos)
		if M(pos):get_int("switch_sign_in") ~= 1 then
			if power.turn_switch_on(pos, Cable, "techage:powerswitch_box_off", "techage:powerswitch_box_on") then
				minetest.sound_play("doors_glass_door_open", {
					pos = pos,
					gain = 1,
					max_hear_distance = 5})
			end
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_node(pos)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	drop = "techage:powerswitch_box_on",
	groups = {choppy=2, cracky=2, crumbly=2, techage_trowel = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
})

power.register_nodes({"techage:powerswitch_box_off"}, Cable, "con", {})

minetest.register_craft({
	output = "techage:powerswitch_box_on",
	recipe = {
		{"", "basic_materials:plastic_sheet", ""},
		{"techage:electric_cableS", "basic_materials:copper_wire", "techage:electric_cableS"},
		{"", "basic_materials:plastic_sheet", ""},
	},
})
