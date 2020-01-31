--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Memory storage system for volatile and non-volatile memory.
	Non-volatile memory is stored from time to time and at shutdown
	as node metadata. Volatile memory is lost at every shutdown.

]]--

local S = function(pos) if pos then return minetest.pos_to_string(pos) end end

-- Node data will be stored every NUM_SLOTS * CYCLE_TIME seconds
local NUM_SLOTS = 50
local CYCLE_TIME = 30
local NvmStore = {}
local MemStore = {}
local NumNodes = 0
local StoredNodes = 0
local NextNum = 0
local Timeslot = 0
local FNAME = minetest.get_worldpath()..DIR_DELIM.."techage_metadata.txt"

local function read_file()
    local f = io.open(FNAME, "r")
	if f ~= nil then 
		local s = f:read("*all")
		io.close(f)
		return minetest.deserialize(s) or {}
	end
	return {}
end

local function write_file(tbl)
	local s = minetest.serialize(tbl)
	local f = io.open(FNAME, "w")
	f:write(s)
	f:close()
end

NvmStore = read_file()

minetest.register_on_shutdown(function()
	write_file(NvmStore)
end)


local function set_metadata(hash, tbl)
	local pos = minetest.get_position_from_hash(hash)
	tbl.USED = nil
	local data = minetest.serialize(tbl)
	local meta = minetest.get_meta(pos)
	meta:set_string("ta_data", data)
	meta:mark_as_private("ta_data")
end

local function get_metadata(hash)
	local pos = minetest.get_position_from_hash(hash)
	local meta = minetest.get_meta(pos)
	local s = meta:get_string("ta_data")
	if s ~= "" then
		return minetest.deserialize(s)
	end
end

local function nvm_storage()
	local ToBeDeleted = {}
	for hash,tbl in pairs(NvmStore) do
		NumNodes = NumNodes + 1
		if tbl.USED then
			if not tbl.SLOT then
				tbl.SLOT = NextNum % NUM_SLOTS
				NextNum = NextNum + 1
			end
			if tbl.SLOT == Timeslot then
				set_metadata(hash, tbl)
				StoredNodes = StoredNodes + 1
			end
		else
			ToBeDeleted[#ToBeDeleted+1] = hash
		end
	end
	for _,hash in ipairs(ToBeDeleted) do
		NvmStore[hash] = nil
	end
	return #ToBeDeleted
end

local function cyclic_task()
	local t = minetest.get_us_time()
	Timeslot = (Timeslot + 1) % NUM_SLOTS
	NumNodes = 0
	StoredNodes = 0
	local deleted = nvm_storage()
	t = minetest.get_us_time() - t
	print("[TA NVM Storage] duration="..t.."us, total="..NumNodes..", stored="..StoredNodes..", deleted="..deleted)
	minetest.after(CYCLE_TIME, cyclic_task)
end

minetest.after(CYCLE_TIME, cyclic_task)



-- To get the volatile node data as table
function techage.get_mem(pos)
	local hash = minetest.hash_node_position(pos)
	if not MemStore[hash] then
		MemStore[hash] = {}
	end
	return MemStore[hash]
end

-- To get the nonvolatile node data as table
function techage.get_nvm(pos)
	local hash = minetest.hash_node_position(pos)
	if not NvmStore[hash] then
		NvmStore[hash] = get_metadata(hash) or {}
	end
	NvmStore[hash].USED = true
	return NvmStore[hash]
end

function techage.peek_nvm(pos)
	local hash = minetest.hash_node_position(pos)
	return NvmStore[hash] or {}
end

-- To be called when a node is removed
function techage.del_mem(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("ta_data", "")
	local hash = minetest.hash_node_position(pos)
	NvmStore[hash] = nil
	MemStore[hash] = nil
end
