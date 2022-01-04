--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Storage backend for node number mapping via mod storage

]]--

local backend = {}
local storage = techage.storage

-- legacy method
local function deserialize(s)
	local tbl = {}
	for line in s:gmatch("[^;]+") do
		local num, spos = unpack(string.split(line, "="))
		tbl[num] = minetest.string_to_pos(spos)
	end
	return tbl
end


local Version = minetest.deserialize(storage:get_string("Version")) or 3
local NextNumber = 0

if Version == 1 then
	Version = 3
	local tbl = minetest.deserialize(storage:get_string("Number2Pos")) or {}
	NextNumber = minetest.deserialize(storage:get_string("NextNumber")) or 1
	for num, pos in pairs(tbl) do
		storage:set_string(num, minetest.pos_to_string(pos))
	end
	storage:set_string("Number2Pos", "")
elseif Version == 2 then
	Version = 3
	NextNumber = minetest.deserialize(storage:get_string("NextNumber")) or 1
	local tbl = deserialize(storage:get_string("Number2Pos"))
	for num, pos in pairs(tbl) do
		storage:set_string(num, minetest.pos_to_string(pos))
	end
	storage:set_string("Number2Pos", "")
else
	Version = 3
	NextNumber = storage:get_int("NextNumber")
end

storage:set_int("NextNumber", NextNumber)
storage:set_int("Version", Version)


-------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------
function backend.get_nodepos(number)
	return minetest.string_to_pos(storage:get_string(number))
end

function backend.set_nodepos(number, pos)
	storage:set_string(number, minetest.pos_to_string(pos))
end

function backend.add_nodepos(pos)
	local num = tostring(NextNumber)
	NextNumber = NextNumber + 1
	storage:set_int("NextNumber", NextNumber)
	storage:set_string(num, minetest.pos_to_string(pos))
	return num
end

function backend.del_nodepos(number)
	storage:set_string(number, "")
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
			else
				minetest.get_meta(pos):set_string("node_number", number)
			end
		end
	end
	minetest.log("info", "[TechAge] Data maintenance finished")
end

return backend
