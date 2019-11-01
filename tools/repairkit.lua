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

local function power_data(power)
	local tbl = {}
	tbl[1] = S("Primary available")   ..": "..(power.prim_available or 0)
	tbl[2] = S("Secondary available") ..": "..(power.sec_available or 0)
	tbl[3] = S("Primary needed")      ..": "..(power.prim_needed or 0)
	tbl[4] = S("Secondary needed")    ..": "..(power.sec_needed or 0)
	tbl[5] = S("Number of nodes")     ..": "..(power.num_nodes or 0)
	tbl[6] = ""
	return table.concat(tbl, "\n")
end

local function read_state(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos and user then
		local time = math.floor(minetest.get_timeofday() * 24 * 6)
		local hours = math.floor(time / 6)
		local mins = (time % 6) * 10
		if mins < 10 then mins = "00" end
		minetest.chat_send_player(user:get_player_name(), S("Time")..": "..hours..":"..mins.."    ")
		local data = minetest.get_biome_data(pos)
		if data then
			local name = minetest.get_biome_name(data.biome)
			minetest.chat_send_player(user:get_player_name(), S("Biome")..": "..name..", "..S("Position temperature")..": "..math.floor(data.heat).."    ")
			if techage.OceanIdTbl[data.biome] then
				minetest.chat_send_player(user:get_player_name(), "Suitable for wind turbines")
			end
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
				local info = techage.send_single("0", number, "info", nil)
				if info and info ~= "" and info ~= "unsupported" then
					info = dump(info)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": Supported Commands:\n"..info.."    ")
				end
				local state = techage.send_single("0", number, "state", nil)
				if state and state ~= "" and state ~= "unsupported" then
					state = dump(state)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": state = "..state.."    ")
				end
				local fuel = techage.send_single("0", number, "fuel", nil)
				if fuel and fuel ~= "" and fuel ~= "unsupported" then
					fuel = dump(fuel)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": fuel = "..fuel.."    ")
				end
				local counter = techage.send_single("0", number, "counter", nil)
				if counter and counter ~= "" and counter ~= "unsupported" then
					counter = dump(counter)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": counter = "..counter.."    ")
				end
				local load = techage.send_single("0", number, "load", nil)
				if load and load ~= "" and load ~= "unsupported" then
					load = dump(load)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": load = "..load.." %    ")
				end
				local capa = techage.send_single("0", number, "capa", nil)
				if capa and capa ~= "" and capa ~= "unsupported" then
					capa = dump(capa)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": capa = "..capa.." %    ")
				end
				local owner = M(pos):get_string("owner") or ""
				if owner ~= "" then
					minetest.chat_send_player(user:get_player_name(), S("Node owner")..": "..owner.."    ")
				end
				minetest.chat_send_player(user:get_player_name(), S("Position")..": "..minetest.pos_to_string(pos).."    ")
				itemstack:add_wear(65636/200)
				return itemstack
			end
		elseif ndef and ndef.description then
			if ndef.is_power_available then
				techage.power.mark_nodes(user:get_player_name(), pos)
				local power = ndef.is_power_available(pos)
				if power then
					minetest.chat_send_player(user:get_player_name(), ndef.description..":\n"..power_data(power))
				end
			elseif ndef.techage_info then
				local info = ndef.techage_info(pos) or ""
				minetest.chat_send_player(user:get_player_name(), ndef.description..":\n"..info)
			end
			local owner = M(pos):get_string("owner") or ""
			if owner ~= "" then
				minetest.chat_send_player(user:get_player_name(), S("Node owner")..": "..owner.."    ")
			end
			minetest.chat_send_player(user:get_player_name(), S("Position")..": "..minetest.pos_to_string(pos).."    ")
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

