--[[

	Tube Library
	============

	Copyright (C) 2017 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	legacy_nodes.lua:
	
	Tubelib support for chests and furnace
	
]]--

local OwnerCache = {
}

-- Check if the chest is in the protected area of the owner
local function is_owner(pos, meta)		
	local owner = meta:get_string("owner")
	local key = minetest.hash_node_position(pos)
	-- If successfull, store info in cache
	if OwnerCache[key] ~= owner then
		if not minetest.is_protected(pos, owner) then
			OwnerCache[key] = owner
		end
	end
	return OwnerCache[key] == owner
end
		

techage.register_node({"default:chest", "default:chest_open"}, {
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

techage.register_node({"default:chest_locked", "default:chest_locked_open"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if is_owner(pos, meta) then
			local inv = meta:get_inventory()
			return techage.get_items(pos, inv, "main", num)
		end
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

techage.register_node({"default:furnace", "default:furnace_active"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "dst", num)
	end,
	on_push_item = function(pos, side, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		minetest.get_node_timer(pos):start(1.0)
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			return techage.put_items(inv, "fuel", stack)
		else
			return techage.put_items(inv, "src", stack)
		end
	end,
	on_unpull_item = function(pos, side, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "dst", stack)
	end,
})	
