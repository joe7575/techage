--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Keep only one formspec active per player

]]--

local P2S = minetest.pos_to_string

local ActiveFormspecs = {}
local ActivePlayer = {}


function techage.is_activeformspec(pos)
	return ActiveFormspecs[P2S(pos)]
end

function techage.set_activeformspec(pos, player)
	local name = player and player:get_player_name()
	if name then
		if ActivePlayer[name] then
			ActiveFormspecs[ActivePlayer[name]] = nil
		end
		ActivePlayer[name] = P2S(pos)
		ActiveFormspecs[P2S(pos)] = true
	end
end

function techage.reset_activeformspec(pos, player)
	local name = player and player:get_player_name()
	if name then
		if ActivePlayer[name] then
			ActiveFormspecs[ActivePlayer[name]] = nil
			ActivePlayer[name] = nil
		end
	end
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if ActivePlayer[name] then
		ActiveFormspecs[ActivePlayer[name]] = nil
		ActivePlayer[name] = nil
	end
end)
