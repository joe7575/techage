--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Library for shared inventories

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

techage.shared_inv = {}

local hyperloop = techage.hyperloop
local remote_pos = techage.hyperloop.remote_pos

local function copy_inventory_list(from_pos, to_pos, listname)
	local inv1 = minetest.get_inventory({type="node", pos=from_pos})
	local inv2 = minetest.get_inventory({type="node", pos=to_pos})
	inv2:set_list(listname, inv1:get_list(listname))
end

function techage.shared_inv.node_timer(pos, elapsed)
	local rmt_pos = remote_pos(pos)
	if techage.is_activeformspec(pos) then
		copy_inventory_list(rmt_pos, pos, "main")
		return true
	end
	return false
end

-- Synchronize the client inventory with the server one
function techage.shared_inv.before_inv_access(pos, listname)
	if hyperloop.is_client(pos) then
		local rmt_pos = remote_pos(pos)
		copy_inventory_list(rmt_pos, pos, listname)
		return true
	end
	return false
end

-- Synchronize the client inventory with the server one
function techage.shared_inv.after_inv_access(pos, listname)
	if hyperloop.is_client(pos) then
		local rmt_pos = remote_pos(pos)
		copy_inventory_list(pos, rmt_pos, listname)
		return true
	end
	return false
end

function techage.shared_inv.on_rightclick(pos, clicker, listname)
	if hyperloop.is_client(pos) then
		local rmt_pos = remote_pos(pos)
		copy_inventory_list(rmt_pos, pos, listname)
		techage.set_activeformspec(pos, clicker)
		minetest.get_node_timer(pos):start(2)
	end
end
