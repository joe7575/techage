--[[

	TexchAge
	========

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	repairkit.lua:
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

--local function destroy_node(itemstack, placer, pointed_thing)
--	if pointed_thing.type == "node" then
--		local pos = pointed_thing.under
--		if not minetest.is_protected(pos, placer:get_player_name()) then
--			local mem = tubelib2.get_mem(pos)
--			mem.techage_aging = 999999
--		end
--	end
--end

--local function repair_node(itemstack, user, pointed_thing)
--	local pos = pointed_thing.under
--	if pos then
--		if techage.repair_node(pos) then
--			minetest.chat_send_player(user:get_player_name(), "[TechAge] Node repaired")
--			itemstack:add_wear(13108)
--			return itemstack
--		end
--	end
--	return 
--end

local function read_state(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos then
		local number = techage.get_node_number(pos)
		if number then
			local state = techage.send_single(number, "state", nil)
			local counter = techage.send_single(number, "counter", nil)
			if state and counter then
				if type(counter) ~= "number" then counter = "unknown" end
				minetest.chat_send_player(user:get_player_name(), "[TechAge] state ="..state..", counter = "..counter)
			end
		end
	end
end

minetest.register_tool("techage:repairkit", {
	description = "TechAge Repair Kit",
	inventory_image = "techage_repairkit.png",
	wield_image = "techage_repairkit.png^[transformR270",
	groups = {cracky=1, book=1},
	on_use = read_state,
	node_placement_prediction = "",
})


minetest.register_node("techage:end_wrench", {
	description = "TechAge End Wrench (use = read status, place = destroy)",
	inventory_image = "techage_end_wrench.png",
	wield_image = "techage_end_wrench.png",
	groups = {cracky=1, book=1},
	on_use = read_state,
	on_place = read_state,
	node_placement_prediction = "",
})

minetest.register_craft({
	output = "techage:repairkit",
	recipe = {
		{"", "basic_materials:gear_steel", ""},
		{"", "techage:end_wrench", ""},
		{"", "basic_materials:oil_extract", ""},
	},
})

minetest.register_craft({
	output = "techage:end_wrench 4",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"", "default:tin_ingot", ""},
		{"default:steel_ingot", "", ""},
	},
})
