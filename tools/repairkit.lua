--[[

	TexchAge
	========

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	repairkit.lua:
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

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
		local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
		if number then
			if ndef and ndef.description then
				local info = techage.send_single(number, "info", nil)
				if info and info ~= "" and info ~= "unsupported" then
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": Supported Commands:\n"..info.."    ")
				end
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
				local power = techage.send_single(number, "power", nil)
				if power and power ~= "" and power ~= "unsupported" then
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": power = "..power.." %    ")
				end
				itemstack:add_wear(65636/200)
				return itemstack
			end
		elseif ndef and ndef.description then
			if ndef.is_power_available then
				local power = ndef.is_power_available(pos)
				local text = "\nGenerators = "..power.prim_available.."\nAkkus = "..power.sec_available.."\nMachines = "..power.prim_needed.."\n"
				minetest.chat_send_player(user:get_player_name(), ndef.description..": power = "..text)
			end
			itemstack:add_wear(65636/200)
			return itemstack
		end
	end
end

minetest.register_tool("techage:repairkit", {
	description = S("TechAge Repair Kit"),
	inventory_image = "techage_repairkit.png",
	wield_image = "techage_repairkit.png^[transformR270",
	groups = {cracky=1, book=1},
	on_use = read_state,
	node_placement_prediction = "",
	stack_max = 1,
})


minetest.register_tool("techage:end_wrench", {
	description = S("TechAge End Wrench (use = read status, place = cmd: on/off)"),
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

techage.register_entry_page("ta", "end_wrench",
	S("TechAge End Wrench"), 
	S("The End Wrench is a tool to read any kind od status information from a node with command inderface.@n"..
		"- use (left mouse button) = read status@n".. 
		"- place (right mouse button) = send command: on/off"), 
	"techage:end_wrench")

