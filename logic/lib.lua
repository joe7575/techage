--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Logic library

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string

techage.logic = {}

local Face2Dir = {[0]=
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0, z=-1},
	{x=-1, y=0,  z=0},
	{x=0,  y=-1, z=0},
	{x=0,  y=1,  z=0}
}

-- Determine the destination position based on the position,
-- the node param2, and a route table like : {0,0,3}
-- 0 = forward, 1 = right, 2 = backward, 3 = left
function techage.logic.dest_pos(pos, param2, route)
	local p2 = param2
	for _,dir in ipairs(route) do
		p2 = (param2 + dir) % 4
		pos = vector.add(pos, Face2Dir[p2])
	end
	return pos, p2
end

function techage.logic.swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return false
	end
	node.name = name
	minetest.swap_node(pos, node)
	return true
end

function techage.logic.after_place_node(pos, placer, name, descr)
	local meta = M(pos)
	local own_num = techage.add_node(pos, name)
	meta:set_string("node_number", own_num)
	meta:set_string("owner", placer:get_player_name())
	meta:set_string("infotext", descr.." -")
end

techage.recursion_guard = techage.recursion_guard or {}

function techage.logic.guarded_action(pos, cmnd, ...)
	if not cmnd then
		return
	end
	local arg = {...}
	local own_num = M(pos):get_string("node_number")
	if techage.recursion_guard[own_num] then
		minetest.log("warning", "[techage] Button recursion detected at node_number=".. own_num .. " pos=" .. P2S(pos))
		return -- recursion detected, do not execute
	end
	techage.recursion_guard[own_num] = true
	local result = cmnd(unpack(arg))
	techage.recursion_guard[own_num] = nil
	return result
end

function techage.logic.send_on(pos, meta, time)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	if time and time > 0 then
		minetest.get_node_timer(pos):start(time)
	end
	techage.send_multi(own_num, numbers, "on")
	return own_num == numbers
end

function techage.logic.send_cmnd(pos, ident, default, time)
	local meta = M(pos)
	local s = meta:contains(ident) and meta:get_string(ident) or default
	local command, payload = unpack(string.split(s, " ", false, 1))
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	if time and time > 0 then
		minetest.get_node_timer(pos):start(time)
	end
	if command and command ~= "" then
		techage.send_multi(own_num, numbers, command, payload)
	end
end

function techage.logic.send_off(pos, meta)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	techage.send_multi(own_num, numbers, "off")
end

function techage.logic.infotext(meta, descr, text)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	if numbers ~= "" then
		meta:set_string("infotext", descr.." "..own_num..": "..S("connected with").." "..numbers)
	elseif text then
		meta:set_string("infotext", descr.." "..own_num..": "..text)
	else
		meta:set_string("infotext", descr.." "..own_num)
	end
end

function techage.logic.set_numbers(pos, numbers, player_name, descr)
	if techage.check_numbers(numbers, player_name) then
		local meta = M(pos)
		meta:set_string("numbers", numbers)
		techage.logic.infotext(meta, descr)
		return true
	end
	return false
end
