--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Count techage commands player related

]]--

local PlayerName
local PlayerPoints = {}
local LastPlayerPoints = {}
local S = techage.S

local MAX_POINTS = tonumber(minetest.settings:get("techage_command_limit")) or 1200

function techage.counting_start(player_name)
	PlayerName = player_name
	PlayerPoints[PlayerName] = PlayerPoints[PlayerName] or 0
end

function techage.counting_stop()
	PlayerName = nil
end

function techage.counting_hit()
	if PlayerName then
		PlayerPoints[PlayerName] = PlayerPoints[PlayerName] + 1
	end
end

function techage.counting_add(player_name, points)
	PlayerPoints[player_name] = (PlayerPoints[player_name] or 0) + points
end

local function output()
	for name, val in pairs(PlayerPoints) do
		if val > MAX_POINTS then
			local obj = minetest.get_player_by_name(name)
			if obj then
				minetest.chat_send_player(name,
					S("[techage] The limit for 'number of commands per minute' has been exceeded.") ..
					" " .. string.format(MAX_POINTS .. " " .. S("is allowed. Current value is") .. " " .. val));
				minetest.log("action", "[techage] " .. name ..
					" exceeds the limit for commands per minute. value = " .. val)
				local factor = 100 / (obj:get_armor_groups().fleshy or 100)
				obj:punch(obj, 1.0, {full_punch_interval=1.0, damage_groups = {fleshy=factor * 5}})
			end
		end
	end
	LastPlayerPoints = table.copy(PlayerPoints)
	PlayerPoints = {}
	minetest.after(60, output)
end

minetest.after(60, output)


minetest.register_chatcommand("ta_limit", {
	description = "Get your current techage command limit value",
    func = function(name)
		local num = LastPlayerPoints[name] or 0
		return true, S("Your current value is") .. " " .. num .. " " .. S("per minute") .. ". " ..
			MAX_POINTS .. " " .. S("is allowed")
    end
})
