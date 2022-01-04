--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Storage backend for node related data via sqlite database

]]--

-- for lazy programmers
local M = minetest.get_meta

-------------------------------------------------------------------
-- Database
-------------------------------------------------------------------
local MN = minetest.get_current_modname()
local WP = minetest.get_worldpath()
local MAR_MAGIC = 0x8e

if not techage.IE then
	error("Please add 'secure.trusted_mods = techage' to minetest.conf!")
end

local sqlite3 = techage.IE.require("lsqlite3")
local marshal = techage.IE.require("marshal")

if not sqlite3 then
	error("Please install sqlite3 via 'luarocks install lsqlite3'")
end
if not marshal then
	error("Please install marshal via 'luarocks install lua-marshal'")
end

local db = sqlite3.open(WP.."/techage_nodedata.sqlite")
local ROW = sqlite3.ROW

-- Prevent use of this db instance.
if sqlite3 then sqlite3 = nil end

db:exec[[
  CREATE TABLE mapblocks(id INTEGER PRIMARY KEY, key INTEGER, data BLOB);
  CREATE UNIQUE INDEX idx ON mapblocks(key);
]]

local set = db:prepare("INSERT or REPLACE INTO mapblocks VALUES(NULL, ?, ?);")
local get = db:prepare("SELECT * FROM mapblocks WHERE key=?;")

local function set_block(key, data)
	set:reset()
	set:bind(1, key)
	set:bind_blob(2, data)
	set:step()
	return true
end

local function get_block(key)
	get:reset()
	get:bind(1, key)
	if get:step() == ROW then
		return get:get_value(2)
	end
end

-------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------
local api = {}

function api.store_mapblock_data(key, mapblock_data)
	-- deactivated due to weird server crashes without error logs
	--local s = marshal.encode(mapblock_data)
	local s = minetest.serialize(mapblock_data)
	return set_block(key, s)
end

function api.get_mapblock_data(key)
	local s = get_block(key)
	if s then
		if s:byte(1) == MAR_MAGIC then
			return marshal.decode(s)
		else
			return minetest.deserialize(s)
		end
	end
	api.store_mapblock_data(key, {})
	return {}
end

function api.get_node_data(pos)
	-- legacy data available?
	local s = M(pos):get_string("ta_data")
	if s ~= "" then
		M(pos):set_string("ta_data", "")
		if s:byte(1) == MAR_MAGIC then
			return marshal.decode(s)
		else
			return minetest.deserialize(s)
		end
	end
	return {}
end

function api.freeze_at_shutdown(data)
	for key, item in pairs(data) do
		api.store_mapblock_data(key, item)
	end
end

function api.restore_at_startup()
	-- nothing to restore
	return {}
end

return api
