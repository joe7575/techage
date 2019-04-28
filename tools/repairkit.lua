--[[

	Tube Library
	============

	Copyright (C) 2017-2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	repairkit.lua:
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local function destroy_node(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		if not minetest.is_protected(pos, placer:get_player_name()) then
			M(pos):set_int("tubelib_aging", 999999)
		end
	end
end

local function repair_node(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos then
		if tubelib.repair_node(pos) then
			minetest.chat_send_player(user:get_player_name(), "[Tubelib] Node repaired")
			itemstack:take_item()
			return itemstack
		end
	end
	return 
end

local function read_state(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos then
		local number = tubelib.get_node_number(pos)
		if number then
			local state = tubelib.send_request(number, "state", nil)
			local counter = tubelib.send_request(number, "counter", nil)
			local aging = tubelib.send_request(number, "aging", nil)
			if state and counter and aging then
				if type(counter) ~= "number" then counter = "unknown" end
				minetest.chat_send_player(user:get_player_name(), "[Tubelib] state ="..state..", counter = "..counter..", aging = "..aging)
			end
		end
	end
end

minetest.register_craftitem("tubelib:repairkit", {
	description = "Tubelib Repair Kit",
	inventory_image = "tubelib_repairkit.png",
	wield_image = "tubelib_repairkit.png^[transformR270",
	groups = {cracky=1, book=1},
	on_use = repair_node,
	node_placement_prediction = "",
})


minetest.register_node("tubelib:end_wrench", {
	description = "Tubelib End Wrench (use = read status, place = destroy)",
	inventory_image = "tubelib_end_wrench.png",
	wield_image = "tubelib_end_wrench.png",
	groups = {cracky=1, book=1},
	on_use = read_state,
	on_place = destroy_node,
	node_placement_prediction = "",
})

minetest.register_craft({
	output = "tubelib:repairkit",
	recipe = {
		{"", "basic_materials:gear_steel", ""},
		{"", "tubelib:end_wrench", ""},
		{"", "basic_materials:oil_extract", ""},
	},
})

minetest.register_craft({
	output = "tubelib:end_wrench 4",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"", "default:tin_ingot", ""},
		{"default:steel_ingot", "", ""},
	},
})
