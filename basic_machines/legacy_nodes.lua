--[[

	Tube Library
	============

	Copyright (C) 2017 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	legacy_nodes.lua:
	
	Tubelib support for chests and furnace
	
]]--

techage.register_node("default:chest", {"default:chest_open"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(inv, "main", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_item(inv, "main", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_item(inv, "main", stack)
	end,
})	

techage.register_node("default:furnace", {"default:furnace_active"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(inv, "dst", num)
	end,
	on_push_item = function(pos, side, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		minetest.get_node_timer(pos):start(1.0)
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			return techage.put_item(inv, "fuel", stack)
		else
			return techage.put_item(meta, "src", stack)
		end
	end,
	on_unpull_item = function(pos, side, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_item(meta, "dst", stack)
	end,
})	
