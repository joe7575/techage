--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Hammer to convert stone into gravel
	
]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local function handler(player_name, node, itemstack, digparams)
	local pos = techage.dug_node[player_name]
	if not pos then return end

	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end

	if minetest.get_item_group(node.name, "stone") > 0 then
		node.name = "default:gravel"
		minetest.swap_node(pos, node)
	end
end

minetest.register_tool("techage:hammer_bronze", {
	description = I("Bronze Hammer (converts stone into gravel)"),
	inventory_image = "techage_tool_hammer_bronze.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=5.00, [2]=2.0, [3]=1.0}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		minetest.after(0.05, handler, user:get_player_name(), node)
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_tool("techage:hammer_steel", {
	description = I("Steel Hammer (converts stone into gravel)"),
	inventory_image = "techage_tool_hammer_steel.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		minetest.after(0.05, handler, user:get_player_name(), node)
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_tool("techage:hammer_mese", {
	description = I("Mese Hammer (converts stone into gravel)"),
	inventory_image = "techage_tool_hammer_mese.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.4, [2]=1.2, [3]=0.60}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		minetest.after(0.05, handler, user:get_player_name(), node)
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_tool("techage:hammer_diamond", {
	description = I("Diamond Hammer (converts stone into gravel)"),
	inventory_image = "techage_tool_hammer_diamond.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		minetest.after(0.05, handler, user:get_player_name(), node)
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_craft({
	output = "techage:hammer_bronze",
	recipe = {
		{"default:bronze_ingot", "group:stick", "default:bronze_ingot"},
		{"default:bronze_ingot", "group:stick", "default:bronze_ingot"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "techage:hammer_steel",
	recipe = {
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "techage:hammer_mese",
	recipe = {
		{"default:mese_crystal", "group:stick", "default:mese_crystal"},
		{"default:mese_crystal", "group:stick", "default:mese_crystal"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "techage:hammer_diamond",
	recipe = {
		{"default:diamond", "group:stick", "default:diamond"},
		{"default:diamond", "group:stick", "default:diamond"},
		{"", "group:stick", ""},
	}
})
