--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	distributor.lua:
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local N = minetest.get_node

local function formspec()
	return "size[10.5,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;2,4;]"..
	"list[current_player;main;1.25,4.5;8,4;]"..
	"listring[context;src]"..
	"listring[current_player;main]"
end


-- move items to the output slots
local function keep_running(pos, elapsed)
	local meta = M(pos)
	local inv = meta:get_inventory()
	local name, num
	
	for i = 1,10 do
		--local list = inv:get_list("src")
		for i = 1,8 do
			--local stack = list[i]
			local stack = inv:get_stack("src", i)
			if stack:get_count() > 0 then 
				local taken = inv:remove_item("src", stack)
				num = taken:get_count()
				inv:add_item("src", taken)
				break
			end
		end
	end
	return true
end

local function after_place_node(pos, placer)
	local meta = M(pos)
	local inv = meta:get_inventory()
	inv:set_size('src', 8)
	inv:add_item("src", ItemStack("wool:blue"))
	inv:add_item("src", ItemStack("wool:red"))
	inv:add_item("src", ItemStack("wool:green"))
	meta:set_string("formspec", formspec())
	
	minetest.get_node_timer(pos):start(0.1)
end

minetest.register_node("techage:perf_test", {
	description = "perf_test",
	tiles = {"techage_filling_ta2.png"},

	after_place_node = after_place_node,
	
	on_timer = keep_running,
	
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
})


minetest.register_lbm({
	label = "[TechAge] Node update",
	name = "techage:perf_test",
	nodenames = {"techage:perf_test"},
	run_at_every_load = true,
	action = function(pos, node)
		after_place_node(pos)
	end
})
