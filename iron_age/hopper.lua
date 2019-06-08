--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Simple TA1 Hopper
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local function scan_for_objects(pos, inv)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local lua_entity = object:get_luaentity()
		if not object:is_player() and lua_entity and lua_entity.name == "__builtin:item" then
			if lua_entity.itemstring ~= "" then
				local stack = ItemStack(lua_entity.itemstring)
				if inv:room_for_item("main", stack) then
					inv:add_item("main", stack)
					object:remove()
				end
			end
		end
	end
end

local function pull_push_item(pos, meta)
	local items = techage.neighbour_pull_items(pos, 6, 1)
	if items then
		if techage.neighbour_push_items(pos, meta:get_int("push_dir"), items) then
			return true
		end
		-- place item back
		techage.neighbour_unpull_items(pos, 6, items)
	end
	return false
end


local function push_item(pos, inv, meta)
	if not inv:is_empty("main") then
		local stack = inv:get_stack("main", 1)
		local taken = stack:take_item(1)
		if techage.neighbour_push_items(pos, meta:get_int("push_dir"), taken) then
			inv:set_stack("main", 1, stack)
		end
	end
end

local function node_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv then
		if not pull_push_item(pos, meta) then
			scan_for_objects({x=pos.x, y=pos.y+1, z=pos.z}, inv)
			push_item(pos, inv, meta)
		end
	end
	return true
end

minetest.register_node("techage:hopper_ta1", {
	description = I("TA1 Hopper"),
	tiles = {
		-- up, down, right, left, back, front
		"default_cobble.png^techage_appl_hopper_top.png",
		"default_cobble.png^techage_appl_hopper.png",
		"default_cobble.png^techage_appl_hopper_right.png",
		"default_cobble.png^techage_appl_hopper.png",
		"default_cobble.png^techage_appl_hopper.png",
		"default_cobble.png^techage_appl_hopper.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  2/16, -8/16,  8/16, 8/16, -6/16},
			{-8/16,  2/16,  6/16,  8/16, 8/16,  8/16},
			{-8/16,  2/16, -8/16, -6/16, 8/16,  8/16},
			{ 6/16,  2/16, -8/16,  8/16, 8/16,  8/16},
			{-6/16,  0/16, -6/16,  6/16, 3/16,  6/16},
			{-5/16, -4/16, -5/16,  5/16, 0/16,  5/16},
			{ 0/16, -4/16, -3/16, 11/16, 2/16,  3/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16,  2/16, -8/16,  8/16, 8/16,  8/16},
			{-5/16, -4/16, -5/16,  5/16, 0/16,  5/16},
			{ 0/16, -4/16, -3/16, 11/16, 2/16,  3/16},
		},
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 1)
	end,
	
	after_place_node = function(pos, placer)
		techage.add_node(pos, "techage:hopper_ta1")
		local node = minetest.get_node(pos)
		M(pos):set_int("push_dir", techage.side_to_indir("L", node.param2))
		minetest.get_node_timer(pos):start(2)
	end,

	on_timer = node_timer,
		
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
	end,
	
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "techage:hopper_ta1",
	recipe = {
		{"default:stone", "", "default:stone"},
		{"default:stone", "default:gold_ingot",	"default:stone"},
		{"", "default:stone", ""},
	},
})

techage.register_node({"techage:hopper_ta1"}, {
	on_pull_item = nil,  		-- not needed
	on_unpull_item = nil,		-- not needed
	
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
})	

techage.register_help_page("TA1 Hopper", [[The Hopper collects dropped items 
and pushes them to the right side. 
Items are sucked up when they 
are dropped on top of the Hopper block.
But the Hopper can also pull items out of 
chests or furnace blocks, if it is placed below.]], "techage:hopper_ta1")