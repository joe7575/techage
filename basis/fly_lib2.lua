--[[

	TechAge
	=======

	Copyright (C) 2020-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Block fly/move library II

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S
local fly1 = techage.flylib

local flylib2 = {}
local MAX_SPEED = 8

local DelayedJobs = {}

local function call_after(func, ...)
	DelayedJobs[#DelayedJobs + 1] = {func = func, args = {...}}
end
	
local function run_delayed_jobs()
	for idx = 1, #DelayedJobs do
		local job = DelayedJobs[idx]
		job.func(unpack(job.args))
	end
	DelayedJobs = {}
end

local function slots(slot)
	return function(slot, i)
		if slot == 0 then  
			i = i + 1
			if i <= 16 then
				return i, i  -- variabel, result
			end
		else
			i = i + 1
			if i == 1 then
				return slot,slot
			end
		end
	end, tonumber(slot), 0  -- param, start value
end

local function destinations(nvm, dest_pos, slot)
	if slot == 0 then
		local tbl = {dest_pos}
		-- Calculate dest-pos for all nodes
		local base_pos = nvm.lNodes[1].base_pos
		for idx = 2,16 do
			if  nvm.lNodes[idx] then
				tbl[idx] = vector.add(vector.subtract(nvm.lNodes[idx].base_pos, base_pos), dest_pos)
			end
		end
		return tbl
	end
	return {[slot] = dest_pos}
end

local function distance(v)
	return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end


local function remove_node(pos, node)
	if minecart.is_cart(node.name) then
		return minecart.remove_cart(pos)
	else
		local metadata = M(pos):to_table()
		minetest.remove_node(pos)
		return metadata
	end
end

local function place_node(dest_pos, node, metadata)
	local name = techage.get_node_lvm(dest_pos).name
	local ndef = minetest.registered_nodes[name]

	if minecart.is_cart(node.name) then
		minecart.place_and_start_cart(dest_pos, {name = node.name, param2 = node.param2}, metadata)
		return true
	elseif ndef.buildable_to then
		minetest.set_node(dest_pos, {name = node.name, param2 = node.param2})
		local meta = M(dest_pos)
		meta:from_table(metadata or {})
		return true
	end
end

local function get_node_from_inventory(inv, idx)
	local stack = inv:get_stack("main", idx)
	local param2 = stack:get_meta():get_int("param2")
	inv:set_stack("main", idx, nil)
	return {name = stack:get_name(), param2 = param2}
end

-- Move node from 'curr_pos' to 'dest_pos'
-- * pos is the controller block position
-- * max_speed is the maximum speed
-- * height is move block height as value between 0 and 1 and used to calculate the offset
--   for the attached object (player).
-- * yoffset is an additional offset for non-player objects
-- * idx is the node related movecontroller inventory slot (optional)
local function move_node(pos, curr_pos, dest_pos, max_speed, height, yoffset, idx)
	local dir = fly1.determine_dir(curr_pos, dest_pos)
	local obj, is_cart = fly1.node_to_entity(pos, curr_pos, dest_pos, idx)

	if obj then
		if is_cart then
			fly1.attach_objects(curr_pos, 0, obj, yoffset, {x = 0, y = -0.4, z = 0})
		else
			local offs = {x=0, y=height or 1, z=0}
			fly1.attach_objects(curr_pos, offs, obj, yoffset)
			if dir.y == 0 then
				if (dir.x ~= 0 and dir.z == 0) or (dir.x == 0 and dir.z ~= 0) then
					fly1.attach_objects(curr_pos, dir, obj, yoffset)
				end
			end
		end
		local self = obj:get_luaentity()
		self.path_idx = 2
		self.lmove = {vector.subtract(dest_pos, curr_pos)}
		self.max_speed = max_speed
		self.yoffs = yoffset
		self.idx = idx
		fly1.move_entity(obj, dest_pos, dir)
		return true
	else
		return false
	end
end

-- Place node to start position, if necessary
local function correct_node(pos, idx, node, dest_pos)
	local cnode = techage.get_node_lvm(node.curr_pos)
	local inv = M(pos):get_inventory()
	if inv:get_stack("main", idx):get_count() == 1 then
		local ndef = minetest.registered_nodes[cnode.name]
		if ndef.buildable_to then
			local inode = get_node_from_inventory(inv, idx)
			return place_node(node.curr_pos, inode)
		else
			local inode = get_node_from_inventory(inv, idx)
			minetest.swap_node(node.curr_pos, inode)
			call_after(minetest.set_node, node.curr_pos, {name = cnode.name, param2 = cnode.param2})
			return true
		end
	end
	if cnode.name == node.name then 
		return true
	end
	local dest_name = techage.get_node_lvm(dest_pos).name
	if dest_name == node.name then 
		local metadata = remove_node(dest_pos, node)
		return place_node(node.curr_pos, node, metadata)
	end
	return false
end

local function is_simple_node(node)
	if not minecart.is_rail(pos, node.name) then
		local ndef = minetest.registered_nodes[node.name]
		return node.name ~= "air" and techage.can_dig_node(node.name, ndef) or minecart.is_cart(node.name)
	end
end

function flylib2.get_pos(payload)
	if payload then
		local x,y,z = unpack(string.split(payload, ",", false, 2))
		if z then
			x = tonumber(x) or 0
			y = tonumber(y) or 0
			z = tonumber(z) or 0
			return {x = x, y = y, z = z}
		end
	end
end

function flylib2.get_node_base_positions(lNodes)
	local tbl = {}
	for idx, item in ipairs(lNodes) do
		tbl[idx] = item.base_pos
	end
	return tbl
end

function flylib2.get_nodes(pos_list)
	local tbl = {}
	for idx,pos in ipairs(pos_list) do
		local node = techage.get_node_lvm(pos)
		if is_simple_node(node) then
			tbl[idx] = {base_pos = pos, curr_pos = pos, name = node.name, param2 = node.param2}
		else
			tbl[idx] = {base_pos = pos, curr_pos = pos, name = "techage:invalid_node", param2 = 0}
		end
	end
	return tbl
end

function flylib2.valid_distance(nvm, destpos, slot, max_dist)
	slot = slot > 0 and slot or 1
	local basepos = nvm.lNodes[slot] and nvm.lNodes[slot].base_pos
	if basepos and destpos then
		local v = vector.subtract(destpos, basepos)
		return distance(v) <= max_dist
	end
	return false
end

-- pos  = movecontroller position
-- slot = inventory slot index (1..16) or 0 for all slots
function flylib2.reset_nodes(pos, nvm, slot)
	local meta = M(pos)
	if nvm.running then return false end
	local max_speed = meta:contains("max_speed") and meta:get_float("max_speed") or MAX_SPEED
	local height = techage.in_range(meta:contains("height") and meta:get_float("height") or 1, 0, 1) -- platform height
	local yoffs = meta:get_float("offset") -- for non-player objects

	for idx in slots(slot) do
		nvm.lNodes =  nvm.lNodes or {}
		local node = nvm.lNodes[idx]
		if node and node.curr_pos and node.curr_pos ~= node.base_pos then
			if correct_node(pos, idx, node, node.base_pos) then
				move_node(pos, node.curr_pos, node.base_pos, max_speed, height, yoffs, idx)
				node.curr_pos = node.base_pos
			end
		end
	end
	run_delayed_jobs()
	return true
end

-- pos  = movecontroller position
-- slot = inventory slot index (1..16) or 0 for all slots
function flylib2.move_nodes(pos, nvm, dest_pos, slot)
	local meta = M(pos)
	if nvm.running then return false end
	local max_speed = meta:contains("max_speed") and meta:get_float("max_speed") or MAX_SPEED
	local height = techage.in_range(meta:contains("height") and meta:get_float("height") or 1, 0, 1) -- platform height
	local yoffs = meta:get_float("offset") -- for non-player objects
	local dests = destinations(nvm, dest_pos, slot)

	for idx in slots(slot) do
		local node = nvm.lNodes[idx]
		local dest_pos = dests[idx]
		if node and node.curr_pos and node.curr_pos ~= dest_pos then
			if correct_node(pos, idx, node, dest_pos) then
				move_node(pos, node.curr_pos, dest_pos, max_speed, height, yoffs, idx)
				node.curr_pos = dest_pos
			end
		end
	end
	run_delayed_jobs()
	return true
end

minetest.register_craftitem("techage:invalid_node", {
	description = S("Invalid node"),
	inventory_image = "techage_invalid_node.png",
	groups = {not_in_creative_inventory = 1},
})

techage.flylib2 = flylib2
