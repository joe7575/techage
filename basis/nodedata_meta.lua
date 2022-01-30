--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Storage backend for node related data as node metadata

]]--

-- for lazy programmers
local M = minetest.get_meta

local storage = techage.storage

local MP = minetest.get_modpath("techage")
local serialize, deserialize = dofile(MP .. "/basis/marshal.lua")

-------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------
local api = {}

function api.get_mapblock_data(key)
	return {}
end

function api.store_mapblock_data(key, mapblock_data)
	for key, item in pairs(mapblock_data) do
		if key ~= "in_use" then
			local pos = item and item._POS_
			if pos then
				item._POS_ = nil
				local data = serialize(item)
				local meta = M(pos)
				meta:set_string("ta_data", data)
				meta:mark_as_private("ta_data")
			end
		end
	end
end

function api.get_node_data(pos)
	local tbl = {}
	local s = M(pos):get_string("ta_data")

	if s ~= "" then
		tbl = deserialize(s) or {}
	end
	tbl._POS_ = table.copy(pos)

	return tbl
end

-- Meta data can't be written reliable at shutdown,
-- so we have to store/restore the data differently.
function api.freeze_at_shutdown(data)
	-- We use the minetest serialize function, because marshal.encode
        -- generates a binary string, which can't be stored in storage.
	storage:set_string("shutdown_nodedata", minetest.serialize(data))
end

function api.restore_at_startup()
	local s = storage:get_string("shutdown_nodedata")
	if s ~= "" then
		return minetest.deserialize(s) or {}
	end
	return {}
end

return api
