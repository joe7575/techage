--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Brilliant Meririum and tools (mod "wielded_light" needed)

]]--

local S = techage.S

minetest.register_craftitem("techage:meridium_ingot", {
	description = "Meridium Ingot",
	inventory_image = "techage_meridium_ingot.png",
})


minetest.register_tool("techage:pick_meridium", {
	description = S("Meridium Pickaxe"),
	inventory_image = "techage_meridiumpick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	light_source = 12,
})

minetest.register_tool("techage:shovel_meridium", {
	description = S("Meridium Shovel"),
	inventory_image = "techage_meridiumshovel.png",
	wield_image = "techage_meridiumshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=40, maxlevel=2},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
	light_source = 12,
})

minetest.register_tool("techage:axe_meridium", {
	description = S("Meridium Axe"),
	inventory_image = "techage_meridiumaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	light_source = 12,
})

minetest.register_tool("techage:sword_meridium", {
	description = S("Meridium Sword"),
	inventory_image = "techage_meridiumsword.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=6},
	},
	sound = {breaks = "default_tool_breaks"},
	light_source = 12,
})

minetest.register_craft({
	output = 'techage:pick_meridium',
	recipe = {
		{'techage:meridium_ingot', 'techage:meridium_ingot', 'techage:meridium_ingot'},
		{'', 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})

minetest.register_craft({
	output = 'techage:shovel_meridium',
	recipe = {
		{'techage:meridium_ingot'},
		{'group:stick'},
		{'group:stick'},
	}
})

minetest.register_craft({
	output = 'techage:axe_meridium',
	recipe = {
		{'techage:meridium_ingot', 'techage:meridium_ingot'},
		{'techage:meridium_ingot', 'group:stick'},
		{'', 'group:stick'},
	}
})

minetest.register_craft({
	output = 'techage:sword_meridium',
	recipe = {
		{'techage:meridium_ingot'},
		{'techage:meridium_ingot'},
		{'group:stick'},
	}
})

techage.ironage_register_recipe({
	output = "techage:meridium_ingot",
	recipe = {"default:steel_ingot", "default:mese_crystal_fragment"},
	heat = 4,
	time = 3,
})
