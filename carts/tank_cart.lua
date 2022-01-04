--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Tank Cart

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local Pipe = techage.LiquidPipe
local MP = minetest.get_modpath("minecart")

local liquid = networks.liquid
local CAPACITY = 100

local function on_rightclick(pos, node, clicker)
	if clicker and clicker:is_player() then
		if M(pos):get_int("userID") == 0 then
			minecart.show_formspec(pos, clicker)
		else
			local nvm = techage.get_nvm(pos)
			techage.set_activeformspec(pos, clicker)
			M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
			minetest.get_node_timer(pos):start(2)
		end
	end
end

local function node_timer(pos, elapsed)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
		return true
	end
	return false
end

local function peek_liquid(pos)
	local nvm = techage.get_nvm(pos)
	return liquid.srv_peek(nvm)
end

local function take_liquid(pos, indir, name, amount)
	local nvm = techage.get_nvm(pos)
	amount, name = liquid.srv_take(nvm, name, amount)
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
	end
	return amount, name
end

local function put_liquid(pos, indir, name, amount)
	-- check if it is not powder
	local ndef = minetest.registered_craftitems[name] or {}
	if not ndef.groups or ndef.groups.powder ~= 1 then
		local nvm = techage.get_nvm(pos)
		local leftover = liquid.srv_put(nvm, name, amount, CAPACITY)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
		end
		return leftover
	end
	return amount
end

local function untake_liquid(pos, indir, name, amount)
	local nvm = techage.get_nvm(pos)
	local leftover = liquid.srv_put(nvm, name, amount, CAPACITY)
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
	end
	return leftover
end

minetest.register_node("techage:tank_cart", {
	description = S("TA Tank Cart"),
	tiles = {
		-- up, down, right, left, back, front
			"techage_tank_cart_top.png",
			"techage_tank_cart_bottom.png",
			"techage_tank_cart_side.png",
			"techage_tank_cart_side.png",
			"techage_tank_cart_front.png",
			"techage_tank_cart_front.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16,  7/16, -3/16, 3/16, 8/16, 3/16},
			{-7/16,  3/16, -7/16, 7/16, 7/16, 7/16},
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

	after_place_node = function(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = nvm.liquid or {}
		M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
		-- Delete the network between pump and cart
		Pipe:after_dig_node(pos)
		Pipe:after_place_node(pos)
	end,

	set_cargo = function(pos, data)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = data
	end,

	get_cargo = function(pos)
		local nvm = techage.get_nvm(pos)
		local data = nvm.liquid
		nvm.liquid = {}
		return data
	end,

	has_cargo = function(pos)
		return not techage.liquid.is_empty(pos)
	end,

	on_timer = node_timer,
	on_rightclick = on_rightclick,
})

techage.register_node({"techage:tank_cart"}, techage.liquid.recv_message)

liquid.register_nodes({"techage:tank_cart"},
	Pipe, "tank", {"U"}, {
		capa = CAPACITY,
		peek = peek_liquid,
		put = put_liquid,
		take = take_liquid,
		untake = untake_liquid,
	}
)

minecart.register_cart_entity("techage:tank_cart_entity", "techage:tank_cart", "tank", {
	initial_properties = {
		physical = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "wielditem",
		textures = {"techage:tank_cart"},
		visual_size = {x=0.66, y=0.66, z=0.66},
		static_save = false,
	},
	only_dig_if_empty  = 1,
})

minetest.register_craft({
	output = "techage:tank_cart",
	recipe = {
			{"default:junglewood", "techage:ta3_tank", "default:junglewood"},
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		},
})
