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

local NUM_NODES_PER_MIN = 100
local NvmStore = {}
local MemStore = {}
local NumNodes = 0
local StoredNodes = 0

local function set_metadata(hash, tbl)
	local pos = minetest.get_position_from_hash(hash)
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

local function storage_loop()
	local cnt = 0
	while true do
		NumNodes = 0
		StoredNodes = 0
		for hash,tbl in pairs(NvmStore) do
			NumNodes = NumNodes + 1
			if tbl.__used__ then
				tbl.__used__ = nil
				set_metadata(hash, tbl)
				StoredNodes = StoredNodes + 1
				cnt = cnt + 1
				if cnt > NUM_NODES_PER_MIN then
					cnt = 0
					coroutine.yield()
				end
			else
				-- remove from memory if node is unloaded
				local pos = minetest.get_position_from_hash(hash)
				if minetest.get_node(pos).name == "ignore" then
					NvmStore[hash] = nil
					MemStore[hash] = nil
				end
			end
		end
		coroutine.yield()
	end
end

local co = coroutine.create(storage_loop)
		
		
local function cyclic_task()
	local t = minetest.get_us_time()
	coroutine.resume(co)
	t = minetest.get_us_time() - t
	print("[TA NVM Storage] duration="..t.."us, total="..NumNodes..", stored="..StoredNodes)
	-- run every minutes
	minetest.after(60, cyclic_task)
end

minetest.register_on_shutdown(function()
	NumNodes = 0
	StoredNodes = 0
	local t = minetest.get_us_time()
	for k,v in pairs(NvmStore) do
		NumNodes = NumNodes + 1
		if v.__used__ then
			v.__used__ = nil
			set_metadata(k, v)
			StoredNodes = StoredNodes + 1
		end
	end
	t = minetest.get_us_time() - t
	print("[TA NVM Storage] duration="..t.."us, total="..NumNodes..", stored="..StoredNodes)
end)

minetest.after(60, cyclic_task)


-- To get the volatile node data as table
function techage.get_mem(pos, will_change)
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
	NvmStore[hash].__used__ = true
	return NvmStore[hash]
end

-- To be called when a node is removed
function techage.del_mem(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("ta_data", "")
	local hash = minetest.hash_node_position(pos)
	NvmStore[hash] = nil
	MemStore[hash] = nil
end
