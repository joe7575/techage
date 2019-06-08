--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Basis functions for inter-node communication

]]--

--- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta


------------------------------------------------------------------
-- Data base storage
-------------------------------------------------------------------
local storage = minetest.get_mod_storage()
local NextNumber = minetest.deserialize(storage:get_string("NextNumber")) or 1
local Version = minetest.deserialize(storage:get_string("Version")) or 1
local Number2Pos = minetest.deserialize(storage:get_string("Number2Pos")) or {}

local function update_mod_storage()
	minetest.log("action", "[TechAge] Store data...")
	storage:set_string("NextNumber", minetest.serialize(NextNumber))
	storage:set_string("Version", minetest.serialize(Version))
	storage:set_string("Number2Pos", minetest.serialize(Number2Pos))
	-- store data each hour
	minetest.after(60*59, update_mod_storage)
	minetest.log("action", "[TechAge] Data stored")
end

minetest.register_on_shutdown(function()
	update_mod_storage()
end)

-- store data after one hour
minetest.after(60*59, update_mod_storage)

-- Key2Number will be generated at runtine
local Key2Number = {} 

-------------------------------------------------------------------
-- Local helper functions
-------------------------------------------------------------------

local function in_list(list, x)
	for _, v in ipairs(list) do
		if v == x then return true end
	end
	return false
end

-- Localize functions to avoid table lookups (better performance).
local string_split = string.split
local NodeDef = techage.NodeDef
local Tube = techage.Tube

-- Determine position related node number for addressing purposes
local function get_number(pos)
	local key = minetest.hash_node_position(pos)
	if not Key2Number[key] then
		Key2Number[key] = NextNumber
		NextNumber = NextNumber + 1
	end
	return string.format("%u", Key2Number[key])
end

local function generate_Key2Number()
	local key
	for num,item in pairs(Number2Pos) do
		key = minetest.hash_node_position(item.pos)
		Key2Number[key] = num
	end
end

local function not_protected(pos, placer_name, clicker_name)
	local meta = minetest.get_meta(pos)
	if meta then
		local cached_name = meta:get_string("techage_cached_name")
		if placer_name and (placer_name == cached_name or not minetest.is_protected(pos, placer_name)) then
			meta:set_string("techage_cached_name", placer_name)
			if clicker_name == nil or not minetest.is_protected(pos, clicker_name) then
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
				NodeDef[node.name].on_node_load(pos)
			end
		end
	})
end


local DirToSide = {"B", "R", "F", "L", "D", "U"}

local function dir_to_side(dir, param2)
	if dir < 5 then
		dir = (((dir - 1) - (param2 % 4)) % 4) + 1
	end
	return DirToSide[dir]
end

local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}

local function side_to_dir(side, param2)
	local dir = SideToDir[side]
	if dir < 5 then
		dir = (((dir - 1) + (param2 % 4)) % 4) + 1
	end
	return dir
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

-------------------------------------------------------------------
-- API helper functions
-------------------------------------------------------------------
	
-- Check the given list of numbers.
-- Returns true if number(s) is/are valid and point to real nodes.
function techage.check_numbers(numbers)
	if numbers then
		for _,num in ipairs(string_split(numbers, " ")) do
			if Number2Pos[num] == nil then
				return false
			end
		end
		return true
	end
	return false
end	

-- Function returns { pos, name } for the node on the given position number.
function techage.get_node_info(dest_num)
	if Number2Pos[dest_num] then
		return Number2Pos[dest_num]
	end
	return nil
end	

-- Function returns the node number from the given position or
-- nil, if no node number for this position is assigned.
function techage.get_node_number(pos)
	local key = minetest.hash_node_position(pos)
	local num = Key2Number[key]
	if num then
		num = string.format("%u", num)
		if Number2Pos[num] and Number2Pos[num].name then
			return num
		end
	end
	return nil
end	

-- Function is used for available nodes with lost numbers, only.
function techage.get_new_number(pos, name)
	-- store position 
	local number = get_number(pos)
	Number2Pos[number] = {
		pos = pos, 
		name = name,
	}
	return number
end

-------------------------------------------------------------------
-- Node construction/destruction functions
-------------------------------------------------------------------
	
-- Add node to the techage lists.
-- Function determines and returns the node position number,
-- needed for message communication.
function techage.add_node(pos, name)
	if item_handling_node(name) then
		Tube:after_place_node(pos)
	end
	-- store position 
	local number = get_number(pos)
	Number2Pos[number] = {
		pos = pos, 
		name = name,
	}
	return number
end

-- Function removes the node from the techage lists.
function techage.remove_node(pos)
	local number = get_number(pos)
	local name
	if Number2Pos[number] then
		name = Number2Pos[number].name
		Number2Pos[number] = {
			pos = pos, 
			name = nil,
			time = minetest.get_day_count() -- used for reservation timeout
		}
	end
	if item_handling_node(name) then
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
--        on_pull_item = func(pos, in_dir, num),
--        on_push_item = func(pos, in_dir, item),
--        on_unpull_item = func(pos, in_dir, item),
--        on_recv_message = func(pos, topic, payload),
--        on_node_load = func(pos),  -- LBM function
--        on_node_repair = func(pos),  -- repair defect (feature!) nodes
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

function techage.send_multi(numbers, placer_name, clicker_name, topic, payload)
	for _,num in ipairs(string_split(numbers, " ")) do
		if Number2Pos[num] and Number2Pos[num].name then
			local data = Number2Pos[num]
			if not_protected(data.pos, placer_name, clicker_name) then
				if NodeDef[data.name] and NodeDef[data.name].on_recv_message then
					NodeDef[data.name].on_recv_message(data.pos, topic, payload)
				end
			end
		end
	end
end		

function techage.send_single(number, topic, payload)
	if Number2Pos[number] and Number2Pos[number].name then
		local data = Number2Pos[number]
		if NodeDef[data.name] and NodeDef[data.name].on_recv_message then
			return NodeDef[data.name].on_recv_message(data.pos, topic, payload)
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
		local param2 = Tube:get_node_lvm(pos).param2
		outdir = side_to_dir(outdir, param2)
	end
	-- determine destination pos
	local dpos, indir
	if network then
		dpos, indir = network:get_connected_node_pos(pos, outdir)
	else
		dpos, indir = tubelib2.get_pos(pos, outdir)
	end
	-- check node name
	local name = Tube:get_node_lvm(dpos).name
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

-- for defect nodes
function techage.repair_node(pos)
	local node = minetest.get_node(pos)
	if NodeDef[node.name] and NodeDef[node.name].on_node_repair then
		return NodeDef[node.name].on_node_repair(pos)
	end
	return false
end

-------------------------------------------------------------------
-- Client side Push/Pull item functions
-------------------------------------------------------------------

function techage.pull_items(pos, out_dir, num)
	local npos, in_dir, name = get_dest_node(pos, out_dir)
	if npos and NodeDef[name] and NodeDef[name].on_pull_item then
		return NodeDef[name].on_pull_item(npos, in_dir, num)
	end
end

function techage.push_items(pos, out_dir, stack)
	local npos, in_dir, name = get_dest_node(pos, out_dir)
	if npos and NodeDef[name] and NodeDef[name].on_push_item then
		return NodeDef[name].on_push_item(npos, in_dir, stack)	
	elseif name == "air" then
		minetest.add_item(npos, stack)
		return true 
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
-- is random so that different item stacks will be considered.
-- Returns nil if ItemList is empty.
function techage.get_items(inv, listname, num)
	if inv:is_empty(listname) then
		return nil
	end
	local size = inv:get_size(listname)
	local startpos = math.random(1, size)
	for idx = startpos, startpos+size do
		idx = (idx % size) + 1
		local items = inv:get_stack(listname, idx)
		if items:get_count() > 0 then
			local taken = items:take_item(num)
			inv:set_stack(listname, idx, items)
			return taken
		end
	end
	return nil
end

-- Put the given stack into the given ItemList.
-- Function returns false if ItemList is full.
function techage.put_items(inv, listname, stack)
	if inv and inv.room_for_item and inv:room_for_item(listname, stack) then
		inv:add_item(listname, stack)
		return true
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


-------------------------------------------------------------------------------
-- Data Maintenance
-------------------------------------------------------------------------------
local function data_maintenance()
	minetest.log("info", "[TechAge] Data maintenance started")
	-- Remove old unused positions
	local Tbl = table.copy(Number2Pos)
	Number2Pos = {}
	local day_cnt = minetest.get_day_count()
	for num,item in pairs(Tbl) do
		if item.name then
			Number2Pos[num] = item
		-- data not older than 5 real days
		elseif item.time and (item.time + (72*5)) > day_cnt then
			Number2Pos[num] = item
		else
			minetest.log("info", "Position deleted", num)
		end
	end
	minetest.log("info", "[TechAge] Data maintenance finished")
end	
	
generate_Key2Number()

-- maintain data after 5 seconds
-- (minetest.get_day_count() will not be valid at start time)
minetest.after(5, data_maintenance)


