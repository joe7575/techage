--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Liquid Filler

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local liquid = techage.liquid
local CYCLE_TIME = 2

local function formspec(pos)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;7.8,0.5;#c6e8ff]"..
		"label[3,-0.1;"..minetest.colorize( "#000000", S("Liquid Filler")).."]"..
		"list[context;src;0,0.8;3,3;]"..
		"image[3.5,1.8;1,1;techage_form_arrow_bg.png^[transformR270]"..
		"list[context;dst;5,0.8;3,3;]"..
		"list[current_player;main;0,4.2;8,3;]"..
		"listring[current_player;main]"..
		"listring[context;src]" ..
		"listring[current_player;main]"..
		"listring[context;dst]" ..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.2)

end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = M(pos):get_inventory()
	return inv:is_empty("src") and inv:is_empty("dst")
end

local function on_rightclick(pos, node, clicker)
	local inv = M(pos):get_inventory()
	if not inv:is_empty("src") then
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

local function node_timer(pos, elapsed)
	local inv = M(pos):get_inventory()
	if not inv:is_empty("src") then
		local taken = techage.get_items(pos, inv, "src", 1)
		if liquid.is_container_empty(taken:get_name()) then
			liquid.fill_container({x = pos.x, y = pos.y+1, z = pos.z}, inv, taken:get_name())
		else
			liquid.empty_container({x = pos.x, y = pos.y-1, z = pos.z}, inv, taken:get_name())
		end
	end
	return true
end

minetest.register_node("techage:filler", {
	description = S("TA Liquid Filler"),
	tiles = {
		-- up, down, right, left, back, front
	"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_tube.png",
	"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_tube.png",
	"techage_filling_ta3.png^techage_frame_small_ta3.png^techage_appl_outp.png",
	"techage_filling_ta3.png^techage_frame_small_ta3.png^techage_appl_inp.png",
	"techage_filling_ta3.png^techage_appl_liquid_hopper.png^techage_frame_ta3.png",
	"techage_filling_ta3.png^techage_appl_liquid_hopper.png^techage_frame_ta3.png",
	},

	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/2, -3/8, -3/8,   1/2, 3/8, 3/8},  -- box
			{ -2/8,  3/8, -2/8,   2/8,  4/8, 2/8}, -- top
			{ -2/8, -4/8, -2/8,   2/8, -3/8, 2/8}, -- bottom
		},
	},

	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('src', 9)
		inv:set_size('dst', 9)
	end,

	after_place_node = function(pos, placer)
		M(pos):set_string("formspec", formspec(pos))
	end,

	on_rightclick = on_rightclick,
	on_timer = node_timer,
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,

	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = techage.CLIP,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, choppy=2},
	sounds = default.node_sound_defaults(),
})

techage.register_node({"techage:filler"}, {
	on_pull_item = function(pos, in_dir, num)
		local inv = M(pos):get_inventory()
		return techage.get_items(pos, inv, "dst", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local inv = M(pos):get_inventory()
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		return techage.put_items(inv, "src", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local inv = M(pos):get_inventory()
		return techage.put_items(inv, "dst", stack)
	end,
})


minetest.register_craft({
	output = "techage:filler",
	recipe = {
		{"default:steel_ingot", "group:wood", "default:steel_ingot"},
		{"techage:tubeS", "", "techage:tubeS"},
		{"default:steel_ingot", "group:wood", "default:steel_ingot"},
	},
})
