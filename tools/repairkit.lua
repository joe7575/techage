--[[

	TechAge
	=======

	Copyright (C) 2017-2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	repairkit.lua:
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Nodes2Convert = {
	["techage:detector_off"] = "techage:ta3_detector_off",
	["techage:detector_on"] = "techage:ta3_detector_on",
	["techage:repeater"] = "techage:ta3_repeater",
	["techage:button_off"] = "techage:ta3_button_off",
	["techage:button_on"] = "techage:ta3_button_on",
}

local function read_state(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos and user then
		local data = minetest.get_biome_data(pos)
		if data then
			minetest.chat_send_player(user:get_player_name(), S("Biome")..": "..data.biome..", "..S("Position temperature")..": "..math.floor(data.heat).."    ")
		end
		local number = techage.get_node_number(pos)
		local node = minetest.get_node(pos)
		if Nodes2Convert[node.name] then
			if minetest.is_protected(pos, user:get_player_name()) then
				return
			end
			node.name = Nodes2Convert[node.name]
			minetest.swap_node(pos, node)
			return
		end
		local ndef = minetest.registered_nodes[node.name]
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
				if power and power.prim_available then
					local text = "\nGenerators: "..power.prim_available.." ku\nAkkus: "..power.sec_available.." ku\nMachines: "..power.prim_needed.." ku\nNum Nodes: "..power.num_nodes.."\n"
					minetest.chat_send_player(user:get_player_name(), ndef.description..":"..text)
				end
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
	description = S("TechAge Info Tool (use = read status info)"),
	inventory_image = "techage_end_wrench.png",
	wield_image = "techage_end_wrench.png",
	groups = {cracky=1, book=1},
	on_use = read_state,
	on_place = read_state,
	node_placement_prediction = "",
	stack_max = 1,
})

--minetest.register_craft({
--	output = "techage:repairkit",
--	recipe = {
--		{"", "basic_materials:gear_steel", ""},
--		{"", "techage:end_wrench", ""},
--		{"", "basic_materials:oil_extract", ""},
--	},
--})

minetest.register_craft({
	output = "techage:end_wrench",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"", "techage:iron_ingot", ""},
		{"default:steel_ingot", "", ""},
	},
})

techage.register_entry_page("ta", "end_wrench",
	S("TechAge Info Tool"), 
	S("The TechAge Info Tool is a tool to read any kind of status information from nodes providing a command interface.@n"..
		"Click on the node to read the status"), 
	"techage:end_wrench")

