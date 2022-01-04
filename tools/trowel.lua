--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Trowel tool to hide/open cable/pipe/tube nodes

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local function replace_node(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local name = placer:get_player_name()
		if minetest.is_protected(pos, name) then
			return
		end
		local node = minetest.get_node(pos)
		local res = false
		if minetest.get_item_group(node.name, "techage_trowel") == 1 then
			res = networks.hide_node(pos, node, placer)
		elseif networks.hidden_name(pos) or M(pos):get_string("techage_hidden_nodename") ~= "" then
			res = networks.open_node(pos, node, placer)
		else
			minetest.chat_send_player(placer:get_player_name(), "Invalid/unsuported block!")
			return
		end
		if res then
			minetest.sound_play("default_dig_snappy", {
				pos = pos,
				gain = 1,
				max_hear_distance = 5})
		elseif placer and placer.get_player_name then
			minetest.chat_send_player(placer:get_player_name(), "Invalid fill material in inventory slot 1!")
		end
	end
end

minetest.register_tool("techage:trowel", {
	description = S("TechAge Trowel"),
	inventory_image = "techage_trowel.png",
	wield_image = "techage_trowel.png",
	use_texture_alpha = techage.CLIP,
	groups = {cracky=1},
	on_use = replace_node,
	on_place = replace_node,
	node_placement_prediction = "",
	stack_max = 1,
})


minetest.register_craft({
	output = "techage:trowel",
	recipe = {
		{"basic_materials:steel_bar", "basic_materials:steel_bar", ""},
		{"basic_materials:steel_bar", "default:stick", ""},
		{"", "", "default:stick"},
	},
})
