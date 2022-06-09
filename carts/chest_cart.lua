--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Chest Cart

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local MP = minetest.get_modpath("minecart")

local Tube = techage.Tube

local function on_rightclick(pos, node, clicker)
	if clicker and clicker:is_player() then
		if M(pos):get_int("userID") == 0 then
			minecart.show_formspec(pos, clicker)
		end
	end
end

local function formspec()
	return "size[8,6]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;3,0;2,2;]"..
	"list[current_player;main;0,2.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local owner = M(pos):get_string("owner")
	if owner ~= "" and owner ~= player:get_player_name() then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	local owner = M(pos):get_string("owner")
	if owner ~= "" and owner ~= player:get_player_name() then
		return 0
	end
	return stack:get_count()
end

minetest.register_node("techage:chest_cart", {
	description = S("TA Chest Cart"),
	tiles = {
		-- up, down, right, left, back, front
			"techage_chest_cart_top.png",
			"techage_chest_cart_bottom.png",
			"techage_chest_cart_side.png",
			"techage_chest_cart_side.png",
			"techage_chest_cart_front.png",
			"techage_chest_cart_front.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16,  3/16, -7/16, 7/16, 8/16, 7/16},
			{-8/16, -8/16, -8/16, 8/16, 3/16, 8/16},
		},
	},
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, crumbly = 2, choppy = 2},
	node_placement_prediction = "",
	diggable = false,

	on_place = minecart.on_nodecart_place,
	on_punch = minecart.on_nodecart_punch,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_rightclick = on_rightclick,

	after_place_node = function(pos, placer)
		local inv = M(pos):get_inventory()
		inv:set_size('main', 4)
		if placer and placer:is_player() then
			minecart.show_formspec(pos, placer)
		else
			M(pos):set_string("formspec", formspec())
		end
	end,

	set_cargo = function(pos, data)
		local inv = M(pos):get_inventory()
		for idx, stack in ipairs(data) do
			inv:set_stack("main", idx, stack)
		end
	end,

	get_cargo = function(pos)
		local inv = M(pos):get_inventory()
		local data = {}
		for idx = 1, 4 do
			local stack = inv:get_stack("main", idx)
			data[idx] = {name = stack:get_name(), count = stack:get_count()}
		end
		return data
	end,

	has_cargo = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		return not inv:is_empty("main")
	end
})

minecart.register_cart_entity("techage:chest_cart_entity", "techage:chest_cart", "chest", {
	initial_properties = {
		physical = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "wielditem",
		textures = {"techage:chest_cart"},
		visual_size = {x=0.66, y=0.66, z=0.66},
		static_save = false,
	},
})

techage.register_node({"techage:chest_cart"}, {
	on_pull_item = function(pos, in_dir, num, item_name)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "main", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "main", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 131 then  -- Chest State
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return 0, {techage.get_inv_state_num(inv, "main")}
		else
			return 2, ""
		end
	end,
})

Tube:set_valid_sides("techage:chest_cart", {"L", "R", "F", "B"})

minetest.register_craft({
	output = "techage:chest_cart",
	recipe = {
			{"default:junglewood", "default:chest_locked", "default:junglewood"},
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		},
})
