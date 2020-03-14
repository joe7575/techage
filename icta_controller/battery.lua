--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	ICTA Controller - Battery

]]--

 -- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic
local BATTERY_CAPACITY = 10000000

local function calc_percent(content)
	local val = (BATTERY_CAPACITY - math.min(content or 0, BATTERY_CAPACITY))
	return 100 - math.floor((val * 100.0 / BATTERY_CAPACITY))
end

local function on_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local percent = calc_percent(meta:get_int("content"))
	meta:set_string("infotext", S("Battery").." ("..percent.."%)")
	if percent == 0 then
		local node = minetest.get_node(pos)
		node.name = "techage:ta4_battery_empty"
		minetest.swap_node(pos, node)
		return false
	end
	return true
end

local function register_battery(ext, percent, nici)
	minetest.register_node("techage:ta4_battery"..ext, {
		description = S("Battery").." "..ext,
		inventory_image = 'techage_battery_inventory.png',
		wield_image = 'techage_battery_inventory.png',
		tiles = {
			-- up, down, right, left, back, front
			"techage_smartline.png",
			"techage_smartline.png",
			"techage_smartline.png",
			"techage_smartline.png",
			"techage_smartline.png",
			"techage_smartline.png^techage_battery_green.png",
		},

		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
			},
		},
		
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_int("content", BATTERY_CAPACITY * percent)
			local node = minetest.get_node(pos)
			node.name = "techage:ta4_battery"
			minetest.swap_node(pos, node)
			on_timer(pos, 1)
			minetest.get_node_timer(pos):start(30)
		end,
		
		on_timer = on_timer,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			local percent = calc_percent(tonumber(oldmetadata.fields.content))
			local stack
			if percent > 95 then
				stack = ItemStack("techage:ta4_battery")
			elseif percent > 75 then
				stack = ItemStack("techage:ta4_battery75")
			elseif percent > 50 then
				stack = ItemStack("techage:ta4_battery50")
			elseif percent > 25 then
				stack = ItemStack("techage:ta4_battery25")
			else
				return
			end
			local inv = minetest.get_inventory({type="player", name=digger:get_player_name()})
			inv:add_item("main", stack)
		end,

		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {choppy=1, cracky=1, crumbly=1, not_in_creative_inventory=nici},
		drop = "",
		is_ground_content = false,
		sounds = default.node_sound_stone_defaults(),
	})
end

register_battery("", 1.0, 0)
register_battery("75", 0.75, 1)
register_battery("50", 0.5, 1)
register_battery("25", 0.25, 1)

minetest.register_node("techage:ta4_battery_empty", {
	description = S("Battery"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_battery_red.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},
	
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_int("content", 0)
	end,
	
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=1, cracky=1, crumbly=1, not_in_creative_inventory=1},
	drop = "",
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})


if minetest.global_exists("moreores") then
	minetest.register_craft({
		output = "techage:ta4_battery 2",
		recipe = {
			{"", "moreores:silver_ingot", ""},
			{"", "default:copper_ingot", ""},
			{"", "moreores:silver_ingot", ""},
		}
	})
else
	minetest.register_craft({
		output = "techage:ta4_battery 2",
		recipe = {
			{"", "default:tin_ingot", ""},
			{"", "default:copper_ingot", ""},
			{"", "default:tin_ingot", ""},
		}
	})
end

techage.register_node({"techage:ta4_battery", "techage:ta4_battery25", 
		"techage:ta4_battery50", "techage:ta4_battery75"}, 
	{
		on_node_load = function(pos)
			minetest.get_node_timer(pos):start(30)
		end,
})
