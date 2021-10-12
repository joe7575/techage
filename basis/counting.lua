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

local function output()
	for name, val in pairs(PlayerPoints) do
		minetest.log("action", "[techage] " .. name .. " hat " .. val .. " Punkte")
	end
	PlayerPoints = {}
	minetest.after(60, output)
end

minetest.after(60, output)

