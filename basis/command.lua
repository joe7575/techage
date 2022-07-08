--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Basis functions for inter-node communication

]]--

--- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
--local P = minetest.string_to_pos
--local M = minetest.get_meta

local NodeInfoCache = {}
local NumbersToBeRecycled = {}
local MP = minetest.get_modpath("techage")
local techage_use_sqlite = minetest.settings:get_bool('techage_use_sqlite', false)

-- Localize functions to avoid table lookups (better performance)
local string_split = string.split
local NodeDef = techage.NodeDef
local Tube = techage.Tube
local is_cart_available = minecart.is_nodecart_available
local techage_counting_hit = techage.counting_hit
local tubelib2_side_to_dir = tubelib2.side_to_dir

-------------------------------------------------------------------
-- Database
-------------------------------------------------------------------
local backend
if techage_use_sqlite then
    backend = dofile(MP .. "/basis/numbers_sqlite.lua")
else
    backend = dofile(MP .. "/basis/numbers_storage.lua")
end

local function update_nodeinfo(number)
	local pos = backend.get_nodepos(number)
	if pos then
		NodeInfoCache[number] = {pos = pos, name = techage.get_node_lvm(pos).name}
		return NodeInfoCache[number]
	end
end

local function delete_nodeinfo_entry(number)
	if number and NodeInfoCache[number] then
		number = next(NodeInfoCache, number)
		if number then
			NodeInfoCache[number] = nil
		end
	else
		number = next(NodeInfoCache, nil)
	end
	return number
end

-- Keep the cache size small by deleting entries randomly
local function keep_small(number)
	number = delete_nodeinfo_entry(number)
	minetest.after(10, keep_small, number)
end

keep_small()

minetest.after(2, backend.delete_invalid_entries, NodeDef)

-------------------------------------------------------------------
-- Local helper functions
-------------------------------------------------------------------
local function in_list(list, x)
	for _, v in ipairs(list) do
		if v == x then return true end
	end
	return false
end

-- Determine position related node number for addressing purposes
local function get_number(pos, new)
	local meta = minetest.get_meta(pos)
	if meta:contains("node_number") then
		return meta:get_string("node_number")
	end
	-- generate new number
	if new then
		local num = backend.add_nodepos(pos)
		meta:set_string("node_number", num)
		return num
	end
end

local function not_protected(pos, placer_name, clicker_name)
	local meta = minetest.get_meta(pos)
	if meta then
		if placer_name and not minetest.is_protected(pos, placer_name) then
			if clicker_name == nil or placer_name == clicker_name then
				return true
			end
			if not minetest.is_protected(pos, clicker_name) then
				return true
			end
		end
	end
	return false
end

local function register_lbm(name, nodenames)
	minetest.register_lbm({
		label = "[TechAge] Node update",
		name = name.."update",
		nodenames = nodenames,
		run_at_every_load = true,
		action = function(pos, node)
			if NodeDef[node.name] and NodeDef[node.name].on_node_load then
				NodeDef[node.name].on_node_load(pos, node)
			end
		end
	})
end

local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}

local function side_to_dir(side, param2)
	return tubelib2_side_to_dir(side, param2)
end

techage.side_to_outdir = side_to_dir

function techage.side_to_indir(side, param2)
	return tubelib2.Turn180Deg[side_to_dir(side, param2)]
end

local function get_next_node(pos, out_dir)
	local res, npos, node = Tube:compatible_node(pos, out_dir)
	local in_dir = tubelib2.Turn180Deg[out_dir]
	return res, npos, in_dir, node.name
end

local function get_dest_node(pos, out_dir)
	local spos, in_dir = Tube:get_connected_node_pos(pos, out_dir)
	local _,node = Tube:get_node(spos)
	return spos, in_dir, node.name
end

local function item_handling_node(name)
	local node_def = name and NodeDef[name]
	if node_def then
		return node_def.on_pull_item or node_def.on_push_item or node_def.is_pusher
	end
end

local function is_air_like(name)
	local ndef = minetest.registered_nodes[name]
	if ndef and ndef.buildable_to then
		return true
	end
	return false
end

techage.SystemTime = 0
minetest.register_globalstep(function(dtime)
	techage.SystemTime = techage.SystemTime + dtime
end)

-- used by TA1 hammer: dug_node[player_name] = pos
techage.dug_node = {}
minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger then return end
	-- store pos for tools without own 'register_on_dignode'
	techage.dug_node[digger:get_player_name()] = pos
end)

-------------------------------------------------------------------
-- API helper functions
-------------------------------------------------------------------

-- Function returns { pos, name } for the node referenced by number
function techage.get_node_info(dest_num)
	return NodeInfoCache[dest_num] or update_nodeinfo(dest_num)
end

-- Function returns the node number from the given position or
-- nil, if no node number for this position is assigned.
function techage.get_node_number(pos)
	return get_number(pos)
end

function techage.get_pos(pos, side)
	local node = techage.get_node_lvm(pos)
	local dir = nil
	if node.name ~= "air" and node.name ~= "ignore" then
		dir = side_to_dir(side, node.param2)
	end
	return tubelib2.get_pos(pos, dir)
end

-- Function is used for available nodes with lost numbers, only.
function techage.get_new_number(pos, name)
	-- store position
	return get_number(pos, true)
end

-- extract ident and value from strings like "ident=value"
function techage.ident_value(s)
    local ident, value = unpack(string.split(s, "=", true, 1))
	return (ident or ""):trim(), (value or ""):trim()
end

-------------------------------------------------------------------
-- Node construction/destruction functions
-------------------------------------------------------------------

-- Add node to the techage lists.
-- Function determines and returns the node position number,
-- needed for message communication.
-- If TA2 node, return '-' instead of a real number, because
-- TA2 nodes should not support number based commands.
function techage.add_node(pos, name, is_ta2)
	if item_handling_node(name) then
		Tube:after_place_node(pos)
	end
	if is_ta2 then
		return "-"
	end
	local key = minetest.hash_node_position(pos)
	local num = NumbersToBeRecycled[key]
	if num then
		backend.set_nodepos(num, pos)
		NumbersToBeRecycled[key] = nil
		return num
	end
	return get_number(pos, true)
end

-- Function removes the node from the techage lists.
function techage.remove_node(pos, oldnode, oldmetadata)
	local number = oldmetadata and oldmetadata.fields and (oldmetadata.fields.node_number or oldmetadata.fields.number)
	number = number or get_number(pos)
	if number and tonumber(number) then
		local key = minetest.hash_node_position(pos)
		NumbersToBeRecycled[key] = number
		NodeInfoCache[number] = nil
	end
	if oldnode and item_handling_node(oldnode.name) then
		Tube:after_dig_node(pos)
	end
end

-- Repairs the node number after it was erased by `backend.delete_invalid_entries`
function techage.repair_number(pos)
	local number = techage.get_node_number(pos)
	if number then
		backend.set_nodepos(number, pos)
	end
end

-- Like techage.add_node, but use the old number again
function techage.unpack_node(pos, name, number)
	if item_handling_node(name) then
		Tube:after_place_node(pos)
	end
	local key = minetest.hash_node_position(pos)
	NumbersToBeRecycled[key] = nil
	if number then
		backend.set_nodepos(number, pos)
	end
end

-- Like techage.remove_node but don't store the number for this position
function techage.pack_node(pos, oldnode, number)
	if number then
		NodeInfoCache[number] = nil
	end
	if oldnode and item_handling_node(oldnode.name) then
		Tube:after_dig_node(pos)
	end
end


-------------------------------------------------------------------
-- Node register function
-------------------------------------------------------------------

-- Register node for techage communication
-- Call this function only at load time!
-- Param names: List of node names like {"techage:pusher_off", "techage:pusher_on"}
-- Param node_definition: A table according to:
--    {
--        on_inv_request = func(pos, in_dir, access_type)
--        on_pull_item = func(pos, in_dir, num, (opt.) item_name),
--        on_push_item = func(pos, in_dir, item),
--        on_unpull_item = func(pos, in_dir, item),
--        on_recv_message = func(pos, src, topic, payload),
--        on_node_load = func(pos),  -- LBM function
--        on_transfer = func(pos, in_dir, topic, payload),
--    }
function techage.register_node(names, node_definition)
	-- store facedir table for all known node names
	for _,n in ipairs(names) do
		NodeDef[n] = node_definition
	end
	if node_definition.on_pull_item or node_definition.on_push_item or
			node_definition.is_pusher then
		Tube:add_secondary_node_names(names)

		for _,n in ipairs(names) do
			techage.KnownNodes[n] = true
		end
	end
	-- register LBM
	if node_definition.on_node_load then
		register_lbm(names[1], names)
	end
end

-------------------------------------------------------------------
-- Send message functions
-------------------------------------------------------------------

function techage.not_protected(number, placer_name, clicker_name)
	local ninfo = NodeInfoCache[number] or update_nodeinfo(number)
	if ninfo and ninfo.pos then
		return not_protected(ninfo.pos, placer_name, clicker_name)
	end
	return false
end

-- Check the given list of numbers.
-- Returns true if number(s) is/are valid, point to real nodes and
-- and the nodes are not protected for the given player_name.
function techage.check_numbers(numbers, placer_name)
	if numbers then
		for _,num in ipairs(string_split(numbers, " ")) do
			if not techage.not_protected(num, placer_name, nil) then
				return false
			end
		end
		return true
	end
	return false
end

function techage.send_multi(src, numbers, topic, payload)
	--print("send_multi", src, numbers, topic)
	for _,num in ipairs(string_split(numbers, " ")) do
		local ninfo = NodeInfoCache[num] or update_nodeinfo(num)
		if ninfo and ninfo.name and ninfo.pos then
			local ndef = NodeDef[ninfo.name]
			if ndef and ndef.on_recv_message then
				techage_counting_hit()
				ndef.on_recv_message(ninfo.pos, src, topic, payload)
			end
		end
	end
end

function techage.send_single(src, number, topic, payload)
	--print("send_single", src, number, topic)
	local ninfo = NodeInfoCache[number] or update_nodeinfo(number)
	if ninfo and ninfo.name and ninfo.pos then
		local ndef = NodeDef[ninfo.name]
		if ndef and ndef.on_recv_message then
			techage_counting_hit()
			return ndef.on_recv_message(ninfo.pos, src, topic, payload)
		end
	end
	return false
end

-- The destination node location is either:
-- A) a destination position, specified by pos
-- B) a neighbor position, specified by caller pos/outdir, or pos/side
-- C) a tubelib2 network connection, specified by caller pos/outdir, or pos/side
-- outdir is one of: 1..6
-- side is one of: "B", "R", "F", "L", "D", "U"
-- network is a tuebelib2 network instance
-- opt: nodenames is a table of valid the callee node names
function techage.transfer(pos, outdir, topic, payload, network, nodenames)
	-- determine out-dir
	if outdir and type(outdir) == "string" then
		local param2 = techage.get_node_lvm(pos).param2
		outdir = side_to_dir(outdir, param2)
	end
	-- determine destination pos
	local dpos, indir
	if network then
		dpos, indir = network:get_connected_node_pos(pos, outdir)
	else
		dpos, indir = tubelib2.get_pos(pos, outdir), outdir
	end
	-- check node name
	local name = techage.get_node_lvm(dpos).name
	if nodenames and not in_list(nodenames, name) then
		return false
	end
	-- call "on_transfer"
	local ndef = NodeDef[name]
	if ndef and ndef.on_transfer then
		return ndef.on_transfer(dpos, indir, topic, payload)
	end
	return false
end

-------------------------------------------------------------------
-- Beduino functions (see "bep-005_ta_cmnd.md")
-------------------------------------------------------------------
function techage.beduino_send_cmnd(src, number, topic, payload)
	--print("beduino_send_cmnd", src, number, topic)
	local ninfo = NodeInfoCache[number] or update_nodeinfo(number)
	if ninfo and ninfo.name and ninfo.pos then
		local ndef = NodeDef[ninfo.name]
		if ndef and ndef.on_beduino_receive_cmnd then
			return ndef.on_beduino_receive_cmnd(ninfo.pos, src, topic, payload or {})
		end
	end
	return 1, ""
end

function techage.beduino_request_data(src, number, topic, payload)
	--print("beduino_request_data", src, number, topic)
	local ninfo = NodeInfoCache[number] or update_nodeinfo(number)
	if ninfo and ninfo.name and ninfo.pos then
		local ndef = NodeDef[ninfo.name]
		if ndef and ndef.on_beduino_request_data then
			return ndef.on_beduino_request_data(ninfo.pos, src, topic, payload or {})
		end
	end
	return 1, ""
end

-------------------------------------------------------------------
-- Client side Push/Pull item functions
-------------------------------------------------------------------

function techage.get_inv_access(pos, out_dir, access_type)
	local npos, in_dir, name = get_dest_node(pos, out_dir)
	if npos and NodeDef[name] and NodeDef[name].on_inv_request then
		return NodeDef[name].on_inv_request(npos, in_dir, access_type)
	end
end

function techage.pull_items(pos, out_dir, num, item_name)
	local npos, in_dir, name = get_dest_node(pos, out_dir)
	if npos and NodeDef[name] and NodeDef[name].on_pull_item then
		return NodeDef[name].on_pull_item(npos, in_dir, num, item_name)
	end
end

function techage.push_items(pos, out_dir, stack, idx)
	local npos, in_dir, name = get_dest_node(pos, out_dir)
	if npos and NodeDef[name] and NodeDef[name].on_push_item then
		return NodeDef[name].on_push_item(npos, in_dir, stack, idx)
	elseif is_air_like(name) or is_cart_available(npos) then
		minetest.add_item(npos, stack)
		return true
	end
	return false
end

-- Check for recursion and too long distances
local start_pos
function techage.safe_push_items(pos, out_dir, stack, idx)
	local mem = techage.get_mem(pos)
	if not mem.pushing then
		if not start_pos then
			start_pos = pos
			mem.pushing = true
			local res = techage.push_items(pos, out_dir, stack, idx)
			mem.pushing = nil
			start_pos = nil
			return res
		else
			local npos, in_dir, name = get_dest_node(pos, out_dir)
			if vector.distance(start_pos, npos) < (Tube.max_tube_length or 100) then
				mem.pushing = true
				local res = techage.push_items(pos, out_dir, stack, idx)
				mem.pushing = nil
				return res
			end
		end
	end
	return false
end

function techage.unpull_items(pos, out_dir, stack)
	local npos, in_dir, name = get_dest_node(pos, out_dir)
	if npos and NodeDef[name] and NodeDef[name].on_unpull_item then
		return NodeDef[name].on_unpull_item(npos, in_dir, stack)
	end
	return false
end

-------------------------------------------------------------------
-- Client side Push/Pull item functions for hopper like nodes
-- (nodes with no tube support)
-------------------------------------------------------------------

function techage.neighbour_pull_items(pos, out_dir, num)
	local res, npos, in_dir, name = get_next_node(pos, out_dir)
	if res and NodeDef[name] and NodeDef[name].on_pull_item then
		return NodeDef[name].on_pull_item(npos, in_dir, num)
	end
end

function techage.neighbour_push_items(pos, out_dir, stack)
	local res, npos, in_dir, name = get_next_node(pos, out_dir)
	if res and NodeDef[name] and NodeDef[name].on_push_item then
		return NodeDef[name].on_push_item(npos, in_dir, stack)
	elseif name == "air" then
		minetest.add_item(npos, stack)
		return true
	end
	return false
end

function techage.neighbour_unpull_items(pos, out_dir, stack)
	local res, npos, in_dir, name = get_next_node(pos, out_dir)
	if res and NodeDef[name] and NodeDef[name].on_unpull_item then
		return NodeDef[name].on_unpull_item(npos, in_dir, stack)
	end
	return false
end

-------------------------------------------------------------------
-- Server side helper functions
-------------------------------------------------------------------

-- Get the given number of items from the inv. The position within the list
-- is incremented each time so that different item stacks will be considered.
-- Returns nil if ItemList is empty.
function techage.get_items(pos, inv, listname, num)
	if inv:is_empty(listname) then
		return nil
	end
	local size = inv:get_size(listname)
	local mem = techage.get_mem(pos)
	mem.ta_startpos = mem.ta_startpos or 0
	for idx = mem.ta_startpos, mem.ta_startpos+size do
		idx = (idx % size) + 1
		local items = inv:get_stack(listname, idx)
		if items:get_count() > 0 then
			local taken = items:take_item(num)
			inv:set_stack(listname, idx, items)
			mem.ta_startpos = idx
			return taken
		end
	end
	return nil
end

-- Put the given stack into the given ItemList.
-- Function returns false if ItemList is full.
function techage.put_items(inv, listname, item, idx)
	if idx and inv and idx <= inv:get_size(listname) then
		local stack = inv:get_stack(listname, idx)
		if stack:item_fits(item) then
			stack:add_item(item)
			inv:set_stack(listname, idx, stack)
			return true
		end
	else
		if inv and inv:room_for_item(listname, item) then
			inv:add_item(listname, item)
			return true
		end
	end
	return false
end

-- Return "full", "loaded", or "empty" depending
-- on the inventory load.
-- Full is returned, when no empty stack is available.
function techage.get_inv_state(inv, listname)
	local state
    if inv:is_empty(listname) then
        state = "empty"
    else
        local list = inv:get_list(listname)
        state = "full"
        for _, item in ipairs(list) do
            if item:is_empty() then
                return "loaded"
            end
        end
    end
    return state
end

-- Beduino variant
function techage.get_inv_state_num(inv, listname)
	local state
    if inv:is_empty(listname) then
        state = 0
    else
        local list = inv:get_list(listname)
        state = 2
        for _, item in ipairs(list) do
            if item:is_empty() then
                return 1
            end
        end
    end
    return state
end

minetest.register_chatcommand("ta_send", {
	description = minetest.formspec_escape(
			"Send a techage command to the block with the number given: /ta_send <number> <command> [<data>]"),
    func = function(name, param)
		local num, cmnd, payload = param:match('^([0-9]+)%s+(%w+)%s*(.*)$')

		if num and cmnd then
			if techage.not_protected(num, name) then
				local resp = techage.send_single("0", num, cmnd, payload)
				if type(resp) == "string" then
					return true, resp
				else
					return true, dump(resp)
				end
			else
				return false, "Destination block is protected"
			end
		end
		return false, "Syntax: /ta_send <number> <command> [<data>]"
    end
})

minetest.register_chatcommand("expoints", {
    privs = {
       server = true
    },
    func = function(name, param)
		local player_name, points = param:match("^(%S+)%s*(%d*)$")
		if player_name then
			local player = minetest.get_player_by_name(player_name)
			if player then
				if points and points ~= "" then
					if techage.set_expoints(player, tonumber(points)) then
						return true, "The player "..player_name.." now has "..points.." experience points."
					end
				else
					points = techage.get_expoints(player)
					return true, "The player "..player_name.." has "..points.." experience points."
				end
			else
				return false, "Unknown player "..player_name
			end
		end
		return false, "Syntax error!  Syntax:  /expoints <name> [<points>]"
    end
})

minetest.register_chatcommand("my_expoints", {
    func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local points = techage.get_expoints(player)
			if points then
				return true, "You have "..points.." experience points."
			end
		end
    end
})
