--[[

	TechAge
	=======

	Copyright (C) 2017-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Number programmer

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local function join_to_string(tbl)
	local t = {}
	for key,_ in pairs(tbl) do
		t[#t + 1] = key
	end
	return table.concat(t, " ")
end

local function reset_programmer(itemstack, user, pointed_thing)
	user:get_meta():set_string("techage_prog_numbers", nil)
	minetest.chat_send_player(user:get_player_name(), S("[TechAge Programmer] programmer reset"))
	return itemstack
end

local function read_number(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos then
		local number = techage.get_node_number(pos)
		if number then
			local numbers = minetest.deserialize(user:get_meta():get_string("techage_prog_numbers")) or {}
			techage.add_to_set(numbers, number)
			user:get_meta():set_string("techage_prog_numbers", minetest.serialize(numbers))
			minetest.chat_send_player(user:get_player_name(), S("[TechAge Programmer] number").." "..number.." read")
		else
			minetest.chat_send_player(user:get_player_name(), S("[TechAge Programmer] Unknown node on").." "..minetest.pos_to_string(pos))
		end
	else
		return reset_programmer(itemstack, user, pointed_thing)
	end
	return itemstack
end

local function program_numbers(itemstack, placer, pointed_thing)
	local pos = pointed_thing.under
	if pos then
		local meta = M(pos)
		local numbers = minetest.deserialize(placer:get_meta():get_string("techage_prog_numbers")) or {}
		placer:get_meta():set_string("techage_prog_numbers", nil)
		local player_name = placer:get_player_name()
		if meta and meta:get_string("owner") ~= player_name then
			minetest.chat_send_player(player_name, S("[TechAge Programmer] foreign or unknown node!"))
			return itemstack
		end
		local text = table.concat(numbers, " ")
		local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
		if ndef and ndef.techage_set_numbers then
			local res = ndef.techage_set_numbers(pos, text, player_name)
			if res == true then
				minetest.chat_send_player(player_name, S("[TechAge Programmer] node programmed!"))
			else
				minetest.chat_send_player(player_name, S("[TechAge Programmer] Error: invalid numbers!"))
			end
		else
			minetest.chat_send_player(player_name, S("[TechAge Programmer] Error: programmer not supported!"))
		end
		return itemstack
	else
		return reset_programmer(itemstack, placer, pointed_thing)
	end
end

minetest.register_craftitem("techage:programmer", {
	description = S("TechAge Programmer (right = read number, left = write numbers)"),
	inventory_image = "techage_programmer.png",
	stack_max = 1,
	wield_image = "techage_programmer_wield.png",
	groups = {cracky=1, book=1},
	-- left mouse button = program
	on_use = program_numbers,
	on_secondary_use = reset_programmer,
	-- right mouse button = read
	on_place = read_number,
})

minetest.register_craft({
	output = "techage:programmer",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "techage:ta4_wlanchip", ""},
		{"", "dye:red", ""},
	},
})
