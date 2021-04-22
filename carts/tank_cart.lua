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
local liquid = techage.liquid
local MP = minetest.get_modpath("minecart")

local CAPACITY = 100

local function on_rightclick(pos, node, clicker)
	if clicker and clicker:is_player() then
		if M(pos):get_int("userID") == 0 then
			minecart.show_formspec(pos, clicker)
		else
			local nvm = techage.get_nvm(pos)
			techage.set_activeformspec(pos, clicker)
			M(pos):set_string("formspec", liquid.formspec(pos, nvm))
			minetest.get_node_timer(pos):start(2)
		end
	end
end

local function node_timer(pos, elapsed)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
		return true
	end	
	return false
end

local function take_liquid(pos, indir, name, amount)
	amount, name = liquid.srv_take(pos, indir, name, amount)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
	end
	return amount, name
end
	
local function untake_liquid(pos, indir, name, amount)
	local leftover = liquid.srv_put(pos, indir, name, amount)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", liquid.formspec(pos, nvm))
	end
	return leftover
end

local function put_liquid(pos, indir, name, amount)
	-- check if it is not powder
	local ndef = minetest.registered_craftitems[name] or {}
	if not ndef.groups or ndef.groups.powder ~= 1 then
		local leftover = liquid.srv_put(pos, indir, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", liquid.formspec(pos, nvm))
		end
		return leftover
	end
	return amount
end

local networks_def = {
	pipe2 = {
		sides = {U = 1}, -- Pipe connection side
		ntype = "tank",
	},
}

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
		return not liquid.is_empty(pos)
	end,
	
	on_timer = node_timer,
	
	liquid = {
		capa = CAPACITY,
		peek = liquid.srv_peek,
		put = put_liquid,
		take = take_liquid,
		untake = untake_liquid,
	},
	networks = networks_def,
	on_rightclick = on_rightclick,
})

techage.register_node({"techage:tank_cart"}, liquid.recv_message)	

Pipe:add_secondary_node_names({"techage:tank_cart"})


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
