--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Tube support for digtron and protector chests

]]--


-- for lazy programmers
local M = minetest.get_meta

local CacheForFuelNodeNames = {}

local function is_fuel(stack)
	local name = stack:get_name()
	if CacheForFuelNodeNames[name] then
		return true
	end
	if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
		CacheForFuelNodeNames[name] = true
	end
	return CacheForFuelNodeNames[name]
end

------------------------------------------------------------------------------
-- digtron
------------------------------------------------------------------------------

techage.register_node({"digtron:inventory"}, {
	on_inv_request = function(pos, in_dir, access_type)
		local meta = minetest.get_meta(pos)
		return meta:get_inventory(), "main"
	end,
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "main", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
})

techage.register_node({"digtron:fuelstore"}, {
	on_inv_request = function(pos, in_dir, access_type)
		local meta = minetest.get_meta(pos)
		return meta:get_inventory(), "fuel"
	end,
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "fuel", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "fuel", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "fuel", stack)
	end,
})

techage.register_node({"digtron:combined_storage"}, {
	on_inv_request = function(pos, in_dir, access_type)
		local meta = minetest.get_meta(pos)
		return meta:get_inventory(), "main"
	end,
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "main", num)
	end,
	on_push_item = function(pos, side, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		minetest.get_node_timer(pos):start(1.0)
		if is_fuel(stack) then
			return techage.put_items(inv, "fuel", stack)
		else
			return techage.put_items(inv, "main", stack)
		end
	end,
	on_unpull_item = function(pos, side, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
})

------------------------------------------------------------------------------
-- protector
------------------------------------------------------------------------------

techage.register_node({"protector:chest"}, {
	on_inv_request = function(pos, in_dir, access_type)
		local meta = minetest.get_meta(pos)
		return meta:get_inventory(), "main"
	end,
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "main", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
})
