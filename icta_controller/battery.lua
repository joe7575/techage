--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller - Battery

]]--

 -- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local BATTERY_CAPACITY = 10000000

local function calc_percent(content)
	local val = (BATTERY_CAPACITY - math.min(content or 0, BATTERY_CAPACITY))
	return 100 - math.floor((val * 100.0 / BATTERY_CAPACITY))
end

local function on_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local number = meta:get_string("node_number")
	local percent = calc_percent(meta:get_int("content"))
	meta:set_string("infotext", S("Battery").." "..number..": "..percent.." %")
	if percent == 0 then
		local node = minetest.get_node(pos)
		node.name = "techage:ta4_battery_empty"
		minetest.swap_node(pos, node)
		return false
	end
	return true
end

minetest.register_alias("techage:ta4_battery75", "techage:ta4_battery")
minetest.register_alias("techage:ta4_battery50", "techage:ta4_battery")
minetest.register_alias("techage:ta4_battery25", "techage:ta4_battery")

minetest.register_node("techage:ta4_battery", {
	description = S("Battery"),
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

	after_place_node = function(pos, placer, itemstack)
		local content = BATTERY_CAPACITY
		if itemstack then
			local stack_meta = itemstack:get_meta()
			if stack_meta then
				-- This ensures that dug batteries of the old system are considered full.
				local string_content = stack_meta:get_string("content")
				if string_content ~= "" then
					-- Batteries dug in the new system are handled correctly.
					content = techage.in_range(stack_meta:get_int("content"), 0, BATTERY_CAPACITY)
				end
			end
		end
		M(pos):set_int("content", content)
		local number = techage.add_node(pos, "techage:ta4_battery")
		M(pos):set_string("node_number", number)
		on_timer(pos, 1)
		minetest.get_node_timer(pos):start(30)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	on_timer = on_timer,

	preserve_metadata = function(pos, oldnode, oldmetadata, drops)
		local content = M(pos):get_int("content")

		local meta = drops[1]:get_meta()
		meta:set_int("content", content)
		local percent = calc_percent(content)
		local text = S("Battery").." ("..percent.." %)"
		meta:set_string("description", text)
	end,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=1, cracky=1, crumbly=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

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
	use_texture_alpha = techage.CLIP,
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

techage.register_node({"techage:ta4_battery"}, {
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(30)
	end,

	on_recv_message = function(pos, src, topic, payload)
		if topic == "load" then
			local meta = minetest.get_meta(pos)
			return calc_percent(meta:get_int("content"))
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 134 then
			local meta = minetest.get_meta(pos)
			return 0, {calc_percent(meta:get_int("content"))}
		else
			return 2, ""
		end
	end,
})
