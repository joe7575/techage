--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Storage backend for node number mapping via sqlite database

]]--

-- for lazy programmers
local M = minetest.get_meta

local storage = techage.storage

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

local db = sqlite3.open(WP.."/techage_numbers.sqlite")
local ROW = sqlite3.ROW

-- Prevent use of this db instance.
if sqlite3 then sqlite3 = nil end

db:exec[[
  CREATE TABLE numbers(id INTEGER PRIMARY KEY, number INTEGER, x INTEGER, y INTEGER, z INTEGER);
  CREATE UNIQUE INDEX idx ON numbers(number);
]]

local set = db:prepare("INSERT or REPLACE INTO numbers VALUES(NULL, ?, ?, ?, ?);")
local get = db:prepare("SELECT * FROM numbers WHERE number=?;")

local function set_block(number, pos)
	set:reset()
	set:bind(1, number)
	set:bind(2, pos.x)
	set:bind(3, pos.y)
	set:bind(4, pos.z)
	set:step()
	return true
end

local function get_block(number)
	get:reset()
	get:bind(1, number)
	if get:step() == ROW then
		return {x = get:get_value(2), y = get:get_value(3), z = get:get_value(4)}
	end
end

local function del_block(number)
	db:exec("DELETE FROM numbers WHERE number="..number..";")
end

-------------------------------------------------------------------
-- Migration from mod storage
-------------------------------------------------------------------
local Version = storage:get_int("Version") or 0
local NextNumber = 0

if Version == 0 then
	Version = 4
end
if Version == 3 then
	Version = 4
	NextNumber = storage:get_int("NextNumber")
	for i = 1, NextNumber do
		local number = tostring(i)
		if storage:contains(number) then
			local pos = minetest.string_to_pos(storage:get_string(number))
			set_block(number, pos)
			storage:set_string(number, "")
		end
	end
elseif Version == 4 then
	NextNumber = storage:get_int("NextNumber")
else
	error("[] Invalid version number for 'number to pos mapping' table!")
end


-------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------
local api = {}

function api.get_nodepos(number)
	return get_block(number)
end

function api.set_nodepos(number, pos)
	set_block(number, pos)
end

function api.add_nodepos(pos)
	local num = tostring(NextNumber)
	NextNumber = NextNumber + 1
	storage:set_int("NextNumber", NextNumber)
	set_block(num, pos)
	return num
end

function api.del_nodepos(number)
	del_block(number)
end

-- delete invalid entries
function api.delete_invalid_entries(node_def)
	minetest.log("info", "[TechAge] Data maintenance started")
	for id, num, x, y, z in db:urows('SELECT * FROM numbers') do
		local pos = {x = x, y = y, z = z}
		local name = techage.get_node_lvm(pos).name
		if not node_def[name] then
			del_block(num)
		end
	end
	minetest.log("info", "[TechAge] Data maintenance finished")
end

return api
