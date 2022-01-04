--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Configured inventory lib
	Assuming the inventory has the name "conf"

]]--

-- for lazy programmers
local M = minetest.get_meta

local inv_lib = {}

function inv_lib.preassigned_stacks(pos, xsize, ysize)
	local inv = M(pos):get_inventory()
	local tbl = {}
	for idx = 1, xsize * ysize do
		local item_name = inv:get_stack("conf", idx):get_name()
		if item_name ~= "" then
			local x = (idx - 1) % xsize
			local y = math.floor((idx - 1) / xsize)
			tbl[#tbl+1] = "item_image["..x..","..y..";1,1;"..item_name.."]"
		end
	end
	return table.concat(tbl, "")
end

function inv_lib.item_filter(pos, size)
	local inv = M(pos):get_inventory()
	local filter = {}
	for idx = 1, size do
		local item_name = inv:get_stack("conf", idx):get_name()
		if item_name == "" then item_name = "unconfigured" end
		if not filter[item_name] then
			filter[item_name] = {}
		end
		table.insert(filter[item_name], idx)
	end
	return filter
end

function inv_lib.allow_conf_inv_put(pos, listname, index, stack, player)
	local inv = M(pos):get_inventory()
	local list = inv:get_list(listname)

	if list[index]:get_count() == 0 then
		stack:set_count(1)
		inv:set_stack(listname, index, stack)
		return 0
	end
	return 0
end

function inv_lib.allow_conf_inv_take(pos, listname, index, stack, player)
	local inv = M(pos):get_inventory()
	inv:set_stack(listname, index, nil)
	return 0
end

function inv_lib.allow_conf_inv_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local stack = inv:get_stack(to_list, to_index)

	if stack:get_count() == 0 then
		return 1
	else
		return 0
	end
end

function inv_lib.put_items(pos, inv, listname, item, stacks, idx)
	for _, i in ipairs(stacks or {}) do
		if not idx or idx == i then
			local stack = inv:get_stack(listname, i)
			if stack:item_fits(item) then
				stack:add_item(item)
				inv:set_stack(listname, i, stack)
				return true
			end
		end
	end
	return false
end

function inv_lib.take_item(pos, inv, listname, num, stacks)
	local mem = techage.get_mem(pos)
	mem.ta_startpos = mem.ta_startpos or 1
	local size = #(stacks or {})
	for i = 1, size do
		local idx = stacks[((i + mem.ta_startpos) % size) + 1]
		local stack = inv:get_stack(listname, idx)
		local taken = stack:take_item(num)
		if taken:get_count() > 0 then
			inv:set_stack(listname, idx, stack)
			mem.ta_startpos = mem.ta_startpos + i
			return taken
		end
	end
end


return inv_lib
