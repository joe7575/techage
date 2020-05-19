--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Node number management/storage based on SQLite

]]--

local MN = minetest.get_current_modname()
local WP = minetest.get_worldpath()
local IE = minetest.request_insecure_environment()

if not IE then
	error("Please add 'secure.trusted_mods = techage' to minetest.conf!")
end

local sqlite3 = IE.require("lsqlite3")
local marshal = IE.require("marshal")

if not sqlite3 then
	error("Please install sqlite3 via 'luarocks install lsqlite3'")
end
if not marshal then
	error("Please install marshal via 'luarocks install lua-marshal'")
end

local db = sqlite3.open(WP.."/techage_numbers.sqlite3")

-- Prevent use of this db instance.
if sqlite3 then sqlite3 = nil end

db:exec[[
  CREATE TABLE test2(id INTEGER PRIMARY KEY, number INTEGER, x INTEGER, y INTEGER, z INTEGER);
  CREATE INDEX idx ON test2(number);  
]]

local insert = db:prepare("INSERT INTO test2 VALUES(NULL, ?, ?, ?, ?);")
local query = db:prepare("SELECT * FROM test2 WHERE number=?")

local backend = {}
local storage = minetest.get_mod_storage()


local function set(number, pos)
	insert:reset()
	insert:bind(1, number)
	insert:bind(2, pos.x)
	insert:bind(3, pos.y)
	insert:bind(4, pos.z)
	insert:step()	
end

local function get(number)
	query:reset()
	query:bind(1, number)
	query:step()	
	local _, _, x, y, z, name = unpack(query:get_values())
	return {pos = {x = x, y = y, z = z}, name = name}
end

-------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------
function backend.get_nodepos(number)
	return minetest.string_to_pos(storage:get_string(number))
end	
	
function backend.set_nodepos(number, pos)
	storage:get_string(number, minetest.pos_to_string(pos))
end	
	
function backend.add_nodepos(pos)
	local num = tostring(NextNumber)
	NextNumber = NextNumber + 1
	storage:set_int("NextNumber", NextNumber)
	storage:get_string(num, minetest.pos_to_string(pos))
	return num
end	
	
function backend.del_nodepos(number)
	storage:get_string(number, "")
end	

-- delete invalid entries
function backend.delete_invalid_entries(node_def)
	minetest.log("info", "[TechAge] Data maintenance started")
	for i = 1, NextNumber do
		local number = tostring(i)
		if storage:contains(number) then
			local pos = backend.get_nodepos(number)
			local name = techage.get_node_lvm(pos).name
			if not node_def[name] then
				backend.del_nodepos(number)
			end
		end
	end
	minetest.log("info", "[TechAge] Data maintenance finished")
end	

return backend

