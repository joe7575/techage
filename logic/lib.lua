--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Logic library
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

techage.logic = {}

function techage.logic.swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

function techage.logic.after_place_node(pos, placer, name, descr)
	local meta = M(pos)
	local own_num = techage.add_node(pos, name)
	meta:set_string("node_number", own_num)
	meta:set_string("owner", placer:get_player_name())
	meta:set_string("infotext", descr.." -")
end

function techage.logic.send_on(pos, meta, time)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	if time and time > 0 then
		minetest.get_node_timer(pos):start(time)
	end
	techage.send_multi(numbers, "on", own_num)
end

function techage.logic.send_off(pos, meta)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	techage.send_multi(numbers, "off", own_num)
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