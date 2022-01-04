--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Item Source Block
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 30

local function formspec()
	return "size[8,7.2]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[context;main;3.5,0.8;1,1;]"..
		"list[current_player;main;0,3.5;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	return stack:get_count()
end

minetest.register_node("techage:itemsource", {
	description = "Techage Item Source",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_outp.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_nodedetector.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_nodedetector.png^techage_frame_ta3.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local node = minetest.get_node(pos)
		meta:set_int("push_dir", techage.side_to_outdir("R", node.param2))
		local inv = meta:get_inventory()
		inv:set_size('main', 1)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		meta:set_string("infotext", "Techage Item Source")
		meta:set_string("formspec", formspec())
	end,

	on_timer = function(pos, elapsed)
		local meta = M(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack('main', 1)
		if stack:get_count() > 0 then
			local push_dir = meta:get_int("push_dir")
			if techage.push_items(pos, push_dir, stack) then
				local cnt = meta:get_int("counter") + stack:get_count()
				meta:set_int("counter", cnt)
				meta:set_string("infotext", "Techage Item Source: "..cnt)
			end
		end
		return true
	end,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	is_ground_content = false,
	drop = "",
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_glass_defaults(),
})

techage.register_node({"techage:itemsource"}, {
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})
