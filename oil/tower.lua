--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Oil Tower

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

minetest.register_node("techage:oiltower1", {
	description = S("TA3 Derrick"),
	tiles = {
		"techage_oil_tower1.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -7/16,  8/16,  8/16},
			{ 7/16, -8/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16, -7/16,  8/16},
			{-8/16,  7/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16,  8/16, -7/16},
			{-8/16, -8/16,  7/16,  8/16,  8/16,  8/16},
		},
	},
	drop = "",
	diggable = false,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
})

minetest.register_node("techage:oiltower2", {
	description = S("TA3 Derrick"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_oil_tower_top.png^[transformR180",
		"techage_oil_tower_top.png^[transformR180",
		"techage_oil_tower2.png^[transformFX",
		"techage_oil_tower2.png",
		"techage_oil_tower2.png",
		"techage_oil_tower2.png^[transformFX",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -7/16,  8/16,  4/16},
			{ 3/16, -8/16, -8/16,  4/16,  8/16,  4/16},
			{-8/16, -8/16, -8/16,  4/16, -7/16,  4/16},
			{-8/16,  7/16, -8/16,  4/16,  8/16,  4/16},
			{-8/16, -8/16, -8/16,  4/16,  8/16, -7/16},
			{-8/16, -8/16,  3/16,  4/16,  8/16,  4/16},
		},
	},
	drop = "",
	diggable = false,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
})

minetest.register_node("techage:oiltower3", {
	description = S("TA3 Derrick"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_oil_tower_top.png^[transformR180",
		"techage_oil_tower_top.png^[transformR180",
		"techage_oil_tower3.png^[transformFX",
		"techage_oil_tower3.png",
		"techage_oil_tower3.png",
		"techage_oil_tower3.png^[transformFX",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -7/16,  8/16,  0/16},
			{-1/16, -8/16, -8/16,  0/16,  8/16,  0/16},
			{-8/16, -8/16, -8/16,  0/16, -7/16,  0/16},
			{-8/16,  7/16, -8/16,  0/16,  8/16,  0/16},
			{-8/16, -8/16, -8/16,  0/16,  8/16, -7/16},
			{-8/16, -8/16, -1/16,  0/16,  8/16,  0/16},
		},
	},
	drop = "",
	diggable = false,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
})

minetest.register_node("techage:oiltower4", {
	description = S("TA3 Derrick"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_oil_tower_top.png^[transformR180",
		"techage_oil_tower_top.png^[transformR180",
		"techage_oil_tower4.png^[transformFX",
		"techage_oil_tower4.png",
		"techage_oil_tower4.png",
		"techage_oil_tower4.png^[transformFX",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -7/16,  8/16, -4/16},
			{-5/16, -8/16, -8/16, -4/16,  8/16, -4/16},
			{-8/16, -8/16, -8/16, -4/16, -7/16, -4/16},
			{-8/16,  7/16, -8/16, -4/16,  8/16, -4/16},
			{-8/16, -8/16, -8/16, -4/16,  8/16, -7/16},
			{-8/16, -8/16, -5/16, -4/16,  8/16, -4/16},
		},
	},
	drop = "",
	diggable = false,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
})

minetest.register_node("techage:oiltower5", {
	description = S("TA4 Derrick"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_oil_tower1.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, 7/16, 8/16, 8/16, 8/16},
		},
	},
	drop = "",
	diggable = false,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
})

minetest.register_node("techage:oil_drillbit", {
	description = S("TA3 Drill Pipe"),
	drawtype = "plantlike",
	tiles = {"techage_oil_drillbit.png"},
	inventory_image = "techage_oil_drillbit_inv.png",
	wield_image = "techage_oil_drillbit_inv.png",
	visual_scale = 1,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	groups = {cracky = 1},
	is_ground_content = false,
})

minetest.register_node("techage:oil_drillbit2", {
	description = S("TA3 Drill Pipe"),
	drawtype = "plantlike",
	tiles = {"techage_oil_drillbit.png"},
	inventory_image = "techage_oil_drillbit_inv.png",
	wield_image = "techage_oil_drillbit_inv.png",
	visual_scale = 1,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	drop = "",
	diggable = false,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
})

local AssemblyPlan = {
	-- y-offs, path, facedir-offs, name

	-- level 0
	{ 0, {0,1}, 0, "techage:oiltower1"},
	{ 0, {0,3}, 0, "techage:oiltower1"},
	{ 0, {2,1}, 0, "techage:oiltower1"},
	{ 0, {2,3}, 0, "techage:oiltower1"},
	-- level 1
	{ 1, {0,1}, 0, "techage:oiltower1"},
	{ 1, {0,3}, 0, "techage:oiltower1"},
	{ 1, {2,1}, 0, "techage:oiltower1"},
	{ 1, {2,3}, 0, "techage:oiltower1"},
	{ 1, {0}, 2, "techage:oiltower5"},
	{ 1, {1}, 3, "techage:oiltower5"},
	{ 1, {2}, 0, "techage:oiltower5"},
	{ 1, {3}, 1, "techage:oiltower5"},
	-- level 2
	{ 2, {0,1}, 0, "techage:oiltower2"},
	{ 2, {0,3}, 3, "techage:oiltower2"},
	{ 2, {2,1}, 1, "techage:oiltower2"},
	{ 2, {2,3}, 2, "techage:oiltower2"},
	{ 2, {0}, 2, "techage:oiltower5"},
	{ 2, {1}, 3, "techage:oiltower5"},
	{ 2, {2}, 0, "techage:oiltower5"},
	{ 2, {3}, 1, "techage:oiltower5"},
	-- level 3
	{ 3, {0,1}, 0, "techage:oiltower3"},
	{ 3, {0,3}, 3, "techage:oiltower3"},
	{ 3, {2,1}, 1, "techage:oiltower3"},
	{ 3, {2,3}, 2, "techage:oiltower3"},
	{ 3, {0}, 2, "techage:oiltower5"},
	{ 3, {1}, 3, "techage:oiltower5"},
	{ 3, {2}, 0, "techage:oiltower5"},
	{ 3, {3}, 1, "techage:oiltower5"},
	-- level 4
	{ 4, {0,1}, 0, "techage:oiltower4"},
	{ 4, {0,3}, 3, "techage:oiltower4"},
	{ 4, {2,1}, 1, "techage:oiltower4"},
	{ 4, {2,3}, 2, "techage:oiltower4"},
	{ 4, {0}, 2, "techage:oiltower5"},
	{ 4, {1}, 3, "techage:oiltower5"},
	{ 4, {2}, 0, "techage:oiltower5"},
	{ 4, {3}, 1, "techage:oiltower5"},
	-- level 5
	{ 5, {0}, 2, "techage:oiltower5"},
	{ 5, {1}, 3, "techage:oiltower5"},
	{ 5, {2}, 0, "techage:oiltower5"},
	{ 5, {3}, 1, "techage:oiltower5"},
	-- level 6
	{ 6, {0}, 2, "techage:oiltower5"},
	{ 6, {1}, 3, "techage:oiltower5"},
	{ 6, {2}, 0, "techage:oiltower5"},
	{ 6, {3}, 1, "techage:oiltower5"},
	-- level 7
	{ 7, {}, 0, "techage:oiltower1"},
	-- drill bits
	{ 1, {},  0, "techage:oil_drillbit2"},
	{ 2, {},  0, "techage:oil_drillbit2"},
	{ 3, {},  0, "techage:oil_drillbit2"},
	{ 4, {},  0, "techage:oil_drillbit2"},
	{ 5, {},  0, "techage:oil_drillbit2"},
	{ 6, {},  0, "techage:oil_drillbit2"},
}

minetest.register_craft({
	output = "techage:oil_drillbit 12",
	recipe = {
		{"", "default:steel_ingot", "default:obsidian_shard"},
		{"", "default:steel_ingot", ""},
		{"default:obsidian_shard", "default:steel_ingot", ""},
	},
})

techage.oiltower = {}

-- Two important flags:
-- 1) mem.assemble_locked is true while the tower is being assembled/disassembled
-- 2) mem.assemble_build is true if the tower is assembled
function techage.oiltower.build(pos, player_name)
	minetest.chat_send_player(player_name, S("[TA] Derrick is being built!"))
	techage.assemble.build(pos, AssemblyPlan, player_name)
end

function techage.oiltower.remove(pos, player_name)
	minetest.chat_send_player(player_name, S("[TA] Derrick is being removed!"))
	techage.assemble.remove(pos, AssemblyPlan, player_name)
end
