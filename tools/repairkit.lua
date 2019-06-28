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
	if pos and user then
		local number = techage.get_node_number(pos)
		if number then
			local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
			if ndef and ndef.description then
				local state = techage.send_single(number, "state", nil)
				if state and state ~= "" and state ~= "unsupported" then
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": state = "..state.."    ")
				end
				local fuel = techage.send_single(number, "fuel", nil)
				if fuel and fuel ~= "" and fuel ~= "unsupported" then
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": fuel = "..fuel.."    ")
				end
				local counter = techage.send_single(number, "counter", nil)
				if counter and counter ~= "" and counter ~= "unsupported" then
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": counter = "..counter.."    ")
				end
				local load = techage.send_single(number, "load", nil)
				if load and load ~= "" and load ~= "unsupported" then
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": load = "..load.." %    ")
				end
				itemstack:add_wear(65636/200)
				return itemstack
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
	stack_max = 1,
})


minetest.register_tool("techage:end_wrench", {
	description = "TechAge End Wrench (use = read status, place = cmd: on/off)",
	inventory_image = "techage_end_wrench.png",
	wield_image = "techage_end_wrench.png",
	groups = {cracky=1, book=1},
	on_use = read_state,
	on_place = read_state,
	node_placement_prediction = "",
	stack_max = 1,
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
	output = "techage:end_wrench",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"", "techage:iron_ingot", ""},
		{"default:steel_ingot", "", ""},
	},
})
