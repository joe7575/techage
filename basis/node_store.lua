--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Data storage system for node related volatile and non-volatile data.
	Non-volatile data is stored from time to time and at shutdown.
	Volatile data is lost at every shutdown.

]]--

local NvmStore = {}  -- non-volatile data cache
local MemStore = {}  -- volatile data cache

local N = function(pos) print(minetest.pos_to_string(pos), minetest.get_node(pos).name) end

-------------------------------------------------------------------
-- Backend
-------------------------------------------------------------------
local MP = minetest.get_modpath("techage")
local techage_use_sqlite = minetest.settings:get_bool('techage_use_sqlite', false)
local backend

if techage_use_sqlite then
    backend = dofile(MP .. "/basis/nodedata_sqlite.lua")
else
    backend = dofile(MP .. "/basis/nodedata_meta.lua")
end

-- return keys for mapblock and inner-mapblock addressing based on the node position
local function get_keys(pos)
	local kx1, kx2 = math.floor(pos.x / 16) + 2048, pos.x % 16
	local ky1, ky2 = math.floor(pos.y / 16) + 2048, pos.y % 16
	local kz1, kz2 = math.floor(pos.z / 16) + 2048, pos.z % 16
	return kx1 * 4096 * 4096 + ky1 * 4096 + kz1, kx2 * 16 * 16 + ky2 * 16 + kz2
end

local function pos_from_key(key1, key2)

	local x1 = (math.floor(key1 / (4096 * 4096)) - 2048)  * 16
	local y1 = ((math.floor(key1 / 4096) % 4096) - 2048)  * 16
	local z1 = ((key1 % 4096) - 2048)  * 16
	local x2 = math.floor(key2 / (16 * 16))
	local y2 = math.floor(key2 / 16) % 16
	local z2 = key2 % 16

	return {x = x1 + x2, y = y1 + y2, z = z1 + z2}
end

local function debug(key1, item)
	--local pos1 = pos_from_key(key1, 0)
	--local pos2 = {x = pos1.x + 15, y = pos1.y + 15, z = pos1.z + 15}
	--techage.mark_region("mapblock", pos1, pos2, "singleplayer", 5)

	local cnt = 0
	for key2, tbl in pairs(item) do
		if key2 ~= "in_use" then
			cnt = cnt + 1
			--N(pos_from_key(key1, key2))
		end
	end
	print("mapblock", string.format("%09X", key1), cnt.." nodes")
end


-------------------------------------------------------------------
-- Storage scheduler
-------------------------------------------------------------------
local CYCLE_TIME = 600  -- store data every 10 min
local JobQueue = {}
local first = 0
local last = -1
local SystemTime = 0

local function push(key)
	last = last + 1
	JobQueue[last] = {key = key, time = SystemTime + CYCLE_TIME}
end

local function pop()
	if first > last then return end
	local item = JobQueue[first]
	if item.time <= SystemTime then
		JobQueue[first] = nil -- to allow garbage collection
		first = first + 1
		return item.key
	end
end

-- check every 100 msec if any data has to be stored
minetest.register_globalstep(function(dtime)
	SystemTime = SystemTime + dtime
	local key = pop()
	if key and NvmStore[key] then
		--debug(key, NvmStore[key])
		local t = minetest.get_us_time()
		if NvmStore[key].in_use then
			NvmStore[key].in_use = nil
			backend.store_mapblock_data(key, NvmStore[key])
			push(key)
		else
			NvmStore[key] = nil -- remove unused data from cache
		end
		t = minetest.get_us_time() - t
		if t > 20000 then
			minetest.log("warning", "[TA Storage] duration = "..(t/1000.0).." ms")
		end
	end
end)

-------------------------------------------------------------------
-- Store/Restore NVM data
-------------------------------------------------------------------
NvmStore = backend.restore_at_startup()

minetest.register_on_shutdown(function()
	backend.freeze_at_shutdown(NvmStore)
end)

-------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------
-- Returns volatile node data as table
function techage.get_mem(pos)
	local hash = minetest.hash_node_position(pos)
	if not MemStore[hash] then
		MemStore[hash] = {}
	end
	return MemStore[hash]
end

-- Returns non-volatile node data as table
function techage.get_nvm(pos)
	local key1, key2 = get_keys(pos)

	if not NvmStore[key1] then
		NvmStore[key1] = backend.get_mapblock_data(key1)
		push(key1)
	end

	local block = NvmStore[key1]
	block.in_use = true
	if not block[key2] then
		block[key2] = backend.get_node_data(pos)
	end
	return block[key2]
end

function techage.peek_nvm(pos)
	local key1, key2 = get_keys(pos)
	local block = NvmStore[key1] or {}
	return block[key2] or {}
end

-- To be called when a node is removed
function techage.del_mem(pos)
	local hash = minetest.hash_node_position(pos)
	MemStore[hash] = nil

	local key1, key2 = get_keys(pos)
	NvmStore[key1] = NvmStore[key1] or backend.get_mapblock_data(key1)
	NvmStore[key1][key2] = nil
	backend.store_mapblock_data(key1, NvmStore[key1])
end
