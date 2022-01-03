--[[

	Iron Age
	========

	Copyright (C) 2018 Joachim Stolberg
    Based on mods/default/tools.lua

	AGPL v3
	See LICENSE.txt for more information

]]--



local function tools()
	minetest.override_item("default:pick_bronze", {
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level=1,
			groupcaps={
				cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
			},
			damage_groups = {fleshy=4},
		},
	})
	minetest.override_item("default:pick_steel", {
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level=1,
			groupcaps={
				cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=30, maxlevel=2},
			},
			damage_groups = {fleshy=4},
		},
	})

	minetest.override_item("default:shovel_bronze", {
		tool_capabilities = {
			full_punch_interval = 1.1,
			max_drop_level=1,
			groupcaps={
				crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2},
			},
			damage_groups = {fleshy=3},
		},
	})
	minetest.override_item("default:shovel_steel", {
		tool_capabilities = {
			full_punch_interval = 1.1,
			max_drop_level=1,
			groupcaps={
				crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=40, maxlevel=2},
			},
			damage_groups = {fleshy=3},
		},
	})

	minetest.override_item("default:axe_bronze", {
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level=1,
			groupcaps={
				choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=20, maxlevel=2},
			},
			damage_groups = {fleshy=4},
		},
	})
	minetest.override_item("default:axe_steel", {
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level=1,
			groupcaps={
				choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=30, maxlevel=2},
			},
			damage_groups = {fleshy=4},
		},
	})

	minetest.override_item("default:sword_bronze", {
		tool_capabilities = {
			full_punch_interval = 0.8,
			max_drop_level=1,
			groupcaps={
				snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=30, maxlevel=2},
			},
			damage_groups = {fleshy=6},
		},
	})
	minetest.override_item("default:sword_steel", {
		tool_capabilities = {
			full_punch_interval = 0.8,
			max_drop_level=1,
			groupcaps={
				snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=40, maxlevel=2},
			},
			damage_groups = {fleshy=6},
		},
	})
end

minetest.after(1, tools)
