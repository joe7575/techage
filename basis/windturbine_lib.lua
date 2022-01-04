--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Wind turbine helper function

]]--

local S = techage.S
local P = minetest.string_to_pos
local M = minetest.get_meta

local function chat_message(player_name, msg)
	if player_name then
		minetest.chat_send_player(player_name, S("[TA4 Wind Turbine]").." "..msg)
	end
	return false, msg
end

-- num_turbines is the mx number of valid wind turbines. In the case of a tool
-- it should be 0, in case of the rotor: 1
function techage.valid_place_for_windturbine(pos, player_name, num_turbines)
	local pos1, pos2, num

	-- Check if occean (only for tool)
	if num_turbines == 0 and pos.y ~= 1 then
		return chat_message(player_name, S("This is not the surface of the ocean!"))
	end
	local node = minetest.get_node(pos)
	if num_turbines == 0 and node.name ~= "default:water_source" then
		return chat_message(player_name, S("This is no ocean water!"))
	end
	local data = minetest.get_biome_data({x=pos.x, y=-2, z=pos.z})
	if data then
		local name = minetest.get_biome_name(data.biome)
		if not string.find(name, "ocean") then
			return chat_message(player_name, S("This is a").." "..name.." "..S("biome and no ocean!"))
		end
	end
	-- check the space over ocean
	pos1 = {x=pos.x-20, y=2, z=pos.z-20}
	pos2 = {x=pos.x+20, y=22, z=pos.z+20}
	num = #minetest.find_nodes_in_area(pos1, pos2, {"air", "ignore"})
	if num < (41 * 41 * 21 * 0.9) then
		techage.mark_region(player_name, pos1, pos2, "")
		return chat_message(player_name,
				S("Here is not enough wind\n(A free air space of 41x41x21 m is necessary)!"))
	end
	-- Check for water surface (occean)
	pos1 = {x=pos.x-20, y=1, z=pos.z-20}
	pos2 = {x=pos.x+20, y=1, z=pos.z+20}
	num = #minetest.find_nodes_in_area(pos1, pos2,
			{"default:water_source", "default:water_flowing", "ignore"})

	if num < (41*41 * 0.8) then
		techage.mark_region(player_name, pos1, pos2, "")
		return chat_message(player_name, S("Here is not enough water (41x41 m)!"))
	end
	-- Check for next wind turbine
	pos1 = {x=pos.x-13, y=2, z=pos.z-13}
	pos2 = {x=pos.x+13, y=22, z=pos.z+13}

	num = #minetest.find_nodes_in_area(pos1, pos2, {"techage:ta4_wind_turbine"})
	if num > num_turbines then
		techage.mark_region(player_name, pos1, pos2, "")
		return chat_message(player_name, S("The next wind turbines is too close!"))
	end

	if num_turbines == 0 then
		chat_message(player_name,  minetest.pos_to_string(pos).." "..
				S("is a suitable place for a wind turbine!"))
	end
	return true, "ok"
end
