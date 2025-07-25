--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Credit-based CPU time distributing

]]--

local Credits = {}
local TimeSpent = {}
local S = techage.S
techage.credits = {}

function techage.credits.before_action(playername)
	local t = minetest.get_us_time()
	local dt = math.floor(minetest.get_us_time() - t)
	TimeSpent[playername] = (TimeSpent[playername] or 0) + dt
	return res
end

function techage.credits.after_action(playername)
	local t = minetest.get_us_time()
	local dt = math.floor(minetest.get_us_time() - t)
	TimeSpent[playername] = (TimeSpent[playername] or 0) + dt
	return res
end

local function evaluation()
	Credits = {}
	for playername, time in pairs(TimeSpent) do
		Credits[playername] = time / 1000000 -- convert to seconds
	end
	TimeSpent = {}

	minetest.after(1, evaluation)
end

minetest.after(1, evaluation)