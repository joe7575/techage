--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Power line Protection
]]--

local M = minetest.get_meta
local S = techage.S

local RANGE = 8

local IsNodeUnderObservation = {}

-- Register all nodes, which should be protected by the "techage:power_pole"
function techage.register_powerline_node(name)
	IsNodeUnderObservation[name] = true
end

local function powerpole_found(pos, name, range)
	local pos1 = {x=pos.x-range, y=pos.y-range, z=pos.z-range}
	local pos2 = {x=pos.x+range, y=pos.y+range, z=pos.z+range}
	for _,npos in ipairs(minetest.find_nodes_in_area(pos1, pos2, {
				"techage:power_pole", "techage:power_pole_conn",
				"techage:power_pole2"})) do
		if minetest.get_meta(npos):get_string("owner") ~= name then
			return true
		end
	end
	return false
end

local function is_protected(pos, name, range)
	if minetest.check_player_privs(name, "powerline")
			or not powerpole_found(pos, name, range) then
		return false
	end
	return true
end

function techage.is_protected(pos, name)
	return is_protected(pos, name, RANGE+3)
end


local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
	local node = techage.get_node_lvm(pos)
	if IsNodeUnderObservation[node.name] and is_protected(pos, name, RANGE) then
        return true
    end
	return old_is_protected(pos, name)
end

minetest.register_privilege("powerline", {
	description = S("Allow to dig/place Techage power lines nearby power poles"),
	give_to_singleplayer = false,
	give_to_admin = true,
})

techage.register_powerline_node("techage:power_line")
techage.register_powerline_node("techage:power_lineS")
techage.register_powerline_node("techage:power_lineA")
techage.register_powerline_node("techage:power_pole3")
