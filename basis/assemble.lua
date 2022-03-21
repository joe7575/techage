--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Assemble routines

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

techage.assemble = {}

local Face2Dir = {[0]=
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=0,  y=0, z=-1},
	{x=-1, y=0,  z=0},
	{x=0,  y=-1, z=0},
	{x=0,  y=1,  z=0}
}

-- Determine the destination position based on the base position,
-- param2, and a route table like : {0,3}
-- 0 = forward, 1 = right, 2 = backward, 3 = left
local function dest_pos(pos, param2, route, y_offs)
	local p2 = param2
	local pos1 = {x=pos.x, y=pos.y+y_offs, z=pos.z}
	for _,dir in ipairs(route) do
		p2 = (param2 + dir) % 4
		pos1 = vector.add(pos1, Face2Dir[p2])
	end
	return pos1, p2
end


-- timer based function
local function build(pos, param2, AssemblyPlan, idx)
	local item = AssemblyPlan[idx]
	if item ~= nil then
		local y, path, fd_offs, node_name = item[1], item[2], item[3], item[4]
		local pos1 = dest_pos(pos, param2, path, y)
		minetest.add_node(pos1, {name=node_name, param2=(param2 + fd_offs) % 4})
		minetest.after(0.5, build, pos, param2, AssemblyPlan, idx+1)
	else
		local nvm = techage.get_nvm(pos)
		nvm.assemble_locked = false
	end
end

-- timer based function
local function remove(pos, param2, AssemblyPlan, idx)
	local item = AssemblyPlan[idx]
	if item ~= nil then
		local y, path = item[1], item[2]
		local pos1 = dest_pos(pos, param2, path, y)
		minetest.remove_node(pos1)
		minetest.after(0.5, remove, pos, param2, AssemblyPlan, idx-1)
	else
		local nvm = techage.get_nvm(pos)
		nvm.assemble_locked = false
	end
end

local function check_space(pos, param2, AssemblyPlan, player_name)
	for _,item in ipairs(AssemblyPlan) do
		local y, path, node_name = item[1], item[2], item[4]
		local pos1 = dest_pos(pos, param2, path, y)
		if minetest.is_protected(pos1, player_name) then
			minetest.chat_send_player(player_name, S("[TA] Area is protected!"))
			return false
		end

		local node = techage.get_node_lvm(pos1)
		local ndef = minetest.registered_nodes[node.name]
		if not ndef or not ndef.buildable_to and node.name ~= node_name then
			minetest.chat_send_player(player_name, S("[TA] Not enough space!"))
			return false
		end
	end
	return true
end


-- Two important flags:
-- 1) nvm.assemble_locked is true while the object is being assembled/disassembled
-- 2) nvm.assemble_build is true if the object is assembled
function techage.assemble.build(pos, AssemblyPlan, player_name)
	-- check protection
	if minetest.is_protected(pos, player_name) then
		return
	end
	local nvm = techage.get_nvm(pos)
	if nvm.assemble_locked then
		return
	end
	local node = minetest.get_node(pos)
	if check_space(pos, node.param2, AssemblyPlan, player_name) then
		nvm.assemble_locked = true
		build(pos, node.param2, AssemblyPlan, 1)
		nvm.assemble_build = true
	end
end

function techage.assemble.remove(pos, AssemblyPlan, player_name)
	-- check protection
	if minetest.is_protected(pos, player_name) then
		return
	end
	local nvm = techage.get_nvm(pos)
	if nvm.assemble_locked then
		return
	end
	local node = minetest.get_node(pos)
	nvm.assemble_locked = true
	remove(pos, node.param2, AssemblyPlan, #AssemblyPlan)
	nvm.assemble_build = false
end

--------------------------------------------------------------------------------
-- Assembly functions based on nodes from node inventory
--------------------------------------------------------------------------------
local function play_sound(pos, sound)
	minetest.sound_play(sound, {
		pos = pos,
		gain = 1,
		max_hear_distance = 10,
	})
end

local function build_inv(pos, inv, param2, AssemblyPlan, player_name, idx)
	local item = AssemblyPlan[idx]
	if item ~= nil then
		local y, path, fd_offs, node_name = item[1], item[2], item[3], item[4]
		local pos1 = dest_pos(pos, param2, path, y)
		if not minetest.is_protected(pos1, player_name) then
			local node = minetest.get_node(pos1)
			if techage.is_air_like(node.name) then
				local stack = inv:remove_item("src", ItemStack(node_name))
				if stack:get_count() == 1 then
					minetest.add_node(pos1, {name=node_name, param2=(param2 + fd_offs) % 4})
					play_sound(pos, "default_place_node_hard")
					local ndef = minetest.registered_nodes[node_name]
					if ndef and ndef.after_place_node then
						local placer = minetest.get_player_by_name(player_name)
						ndef.after_place_node(pos1, placer, ItemStack(node_name))
					end
				end
			end
		end
		minetest.after(0.5, build_inv, pos, inv, param2, AssemblyPlan, player_name, idx + 1)
	else
		local nvm = techage.get_nvm(pos)
		nvm.assemble_locked = false
	end
end

local function remove_inv(pos, inv, param2, AssemblyPlan, player_name, idx)
	local item = AssemblyPlan[idx]
	if item ~= nil then
		local y, path, fd_offs, node_name = item[1], item[2], item[3], item[4]
		local pos1 = dest_pos(pos, param2, path, y)
		if not minetest.is_protected(pos1, player_name) then
			local stack = ItemStack(node_name)
			if inv:room_for_item("src", stack) then
				local node = minetest.get_node(pos1)
				if node.name == node_name then
					local meta = M(pos1):to_table()
					minetest.remove_node(pos1)
					inv:add_item("src", stack)
					play_sound(pos, "default_dig_cracky")
					local ndef = minetest.registered_nodes[node_name]
					if ndef and ndef.after_dig_node then
						local digger = minetest.get_player_by_name(player_name)
						ndef.after_dig_node(pos1, node, meta, digger)
					end
				end
			end
		end
		minetest.after(0.5, remove_inv, pos, inv, param2, AssemblyPlan, player_name, idx - 1)
	else
		local nvm = techage.get_nvm(pos)
		nvm.assemble_locked = false
	end
end

function techage.assemble.build_inv(pos, inv, AssemblyPlan, player_name)
	-- check protection
	if minetest.is_protected(pos, player_name) then
		return
	end
	local nvm = techage.get_nvm(pos)
	if nvm.assemble_locked then
		return
	end
	local node = minetest.get_node(pos)
	nvm.assemble_locked = true
	build_inv(pos, inv, node.param2, AssemblyPlan, player_name, 1)
end

function techage.assemble.remove_inv(pos, inv, AssemblyPlan, player_name)
	-- check protection
	if minetest.is_protected(pos, player_name) then
		return
	end
	local nvm = techage.get_nvm(pos)
	if nvm.assemble_locked then
		return
	end
	local node = minetest.get_node(pos)
	nvm.assemble_locked = true
	remove_inv(pos, inv, node.param2, AssemblyPlan, player_name, #AssemblyPlan)
end

function techage.assemble.count_items(AssemblyPlan)
	local t = {}
	for _, item in ipairs(AssemblyPlan) do
		local node_name = item[4]
		local ndef = minetest.registered_nodes[node_name]
		local name = ndef.description
		if not t[name] then
			t[name] = 1
		else
			t[name] = t[name] + 1
		end
	end
	return t
end

-- Determine the destination position based on the given route
-- param2, and a route table like : {0,3}
-- 0 = forward, 1 = right, 2 = backward, 3 = left
-- techage.assemble.get_pos(pos, param2, route, y_offs)
techage.assemble.get_pos = dest_pos
