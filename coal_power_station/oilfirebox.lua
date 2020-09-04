--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Coal Power Station Firebox

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local firebox = techage.firebox
local fuel = techage.fuel
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CYCLE_TIME = 2
local BURN_CYCLE_FACTOR = 0.5

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local power = techage.transfer(
		{x=pos.x, y=pos.y+2, z=pos.z}, 
		nil,  -- outdir
		"trigger",  -- topic
		nil,  -- payload
		nil,  -- network
		{"techage:coalboiler_top"}  -- nodenames
	)
	nvm.burn_cycles = (nvm.burn_cycles or 0) - math.max((power or 0.02), 0.02)
	if nvm.burn_cycles <= 0 then
	local liq_name = fuel.get_fuel(nvm)
		if liq_name then
			nvm.burn_cycles = fuel.burntime(liq_name) / CYCLE_TIME * BURN_CYCLE_FACTOR
			nvm.burn_cycles_total = nvm.burn_cycles
		else
			nvm.running = false
			firebox.set_firehole(pos, false)
			M(pos):set_string("formspec", fuel.formspec(nvm))
			return false
		end
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", fuel.formspec(nvm))
	end
	return true
end

local function start_firebox(pos, nvm)
	if not nvm.running and fuel.has_fuel(nvm) then
		nvm.running = true
		node_timer(pos, 0)
		firebox.set_firehole(pos, true)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

minetest.register_node("techage:oilfirebox", {
	description = S("TA3 Power Station Oil Burner"),
	inventory_image = "techage_oil_boiler_inv.png",
	tiles = {"techage_coal_boiler_mesh_top.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_12.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -16/32, -13/32, 13/32, 16/32, 13/32},
	},

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = node_timer,
	can_dig = fuel.can_dig,
	on_rightclick = fuel.on_rightclick,
	on_receive_fields = fuel.on_receive_fields,
	
	after_place_node = function(pos, placer)
		if firebox.is_free_position(pos, placer:get_player_name()) then
			techage.add_node(pos, "techage:oilfirebox")
			local nvm = techage.get_nvm(pos)
			nvm.running = false
			nvm.burn_cycles = 0
			nvm.liquid = {}
			nvm.liquid.amount =  0
			local meta = M(pos)
			meta:set_string("formspec", fuel.formspec(nvm))
			local inv = meta:get_inventory()
			firebox.set_firehole(pos, false)
		else
			minetest.remove_node(pos)
			return true
		end
	end,
	
	on_destruct = function(pos)
		firebox.set_firehole(pos, nil)
	end,

	on_punch = function(pos, node, puncher, pointed_thing)
		local nvm = techage.get_nvm(pos)
		fuel.on_punch(pos, node, puncher, pointed_thing)
		if nvm.liquid and nvm.liquid.amount and nvm.liquid.amount > 0 then
			minetest.after(1, start_firebox, pos, nvm)
		end
	end,
	
	liquid = {
		capa = fuel.CAPACITY,
		fuel_cat = fuel.BT_BITUMEN,
		peek = liquid.srv_peek,
		put = function(pos, indir, name, amount)
			if fuel.valid_fuel(name, fuel.BT_BITUMEN) then
				local leftover = liquid.srv_put(pos, indir, name, amount)
				local nvm = techage.get_nvm(pos)
				nvm.liquid = nvm.liquid or {}
				nvm.liquid.amount = nvm.liquid.amount or 0
				start_firebox(pos, nvm)
				if techage.is_activeformspec(pos) then
					local nvm = techage.get_nvm(pos)
					M(pos):set_string("formspec", fuel.formspec(nvm))
				end
				return leftover
			end
			return amount
		end,
		take = function(pos, indir, name, amount)
			amount, name = liquid.srv_take(pos, indir, name, amount)
			if techage.is_activeformspec(pos) then
				local nvm = techage.get_nvm(pos)
				M(pos):set_string("formspec", fuel.formspec(nvm))
			end
			return amount, name
		end
	},
	networks = {
		pipe2 = {
			sides = techage.networks.AllSides, -- Pipe connection sides
			ntype = "tank",
		},
	},
})

Pipe:add_secondary_node_names({"techage:oilfirebox"})


techage.register_node({"techage:oilfirebox"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "state" then
			return nvm.running and "running" or "stopped"
		elseif topic == "fuel" then
			return techage.fuel.get_fuel_amount(nvm)
		else
			return "unsupported"
		end
	end,
})

minetest.register_craft({
	output = "techage:oilfirebox",
	recipe = {
		{'', 'techage:coalfirebox', ''},
		{'', 'techage:ta3_barrel_empty', ''},
		{'', '', ''},
	},
})


