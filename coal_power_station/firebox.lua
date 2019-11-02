--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Coal Power Station Firebox

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local firebox = techage.firebox
local oilburner = techage.oilburner
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CYCLE_TIME = 2
local BURN_CYCLE_FACTOR = 0.5

local function firehole(pos, on)
	local param2 = techage.get_node_lvm(pos).param2
	local pos2 = techage.get_pos(pos, 'F')
	if on == true then
		minetest.swap_node(pos2, {name="techage:coalfirehole_on", param2 = param2})
	elseif on == false then
		minetest.swap_node(pos2, {name="techage:coalfirehole", param2 = param2})
	else
		minetest.swap_node(pos2, {name="air"})
	end
end	

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		-- trigger generator and provide power ratio 0..1
		local ratio = techage.transfer(
			{x=pos.x, y=pos.y+2, z=pos.z}, 
			nil,  -- outdir
			"trigger",  -- topic
			(mem.power_level or 4)/4.0,  -- payload
			nil,  -- network
			{"techage:coalboiler_top"}  -- nodenames
		)
		ratio = math.max((ratio or 0.02), 0.02)
		mem.burn_cycles = (mem.burn_cycles or 0) - ratio
		if mem.burn_cycles <= 0 then
			local taken = firebox.get_fuel(pos) 
			if taken then
				mem.burn_cycles = (firebox.Burntime[taken:get_name()] or 1) / CYCLE_TIME * BURN_CYCLE_FACTOR
				mem.burn_cycles_total = mem.burn_cycles
			else
				mem.running = false
				firehole(pos, false)
				M(pos):set_string("formspec", firebox.formspec(mem))
				return false
			end
		end
		return true
	end
end

local function start_firebox(pos, mem)
	if not mem.running then
		mem.running = true
		node_timer(pos, 0)
		firehole(pos, true)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

minetest.register_node("techage:coalfirebox", {
	description = S("TA3 Power Station Firebox"),
	inventory_image = "techage_coal_boiler_inv.png",
	tiles = {"techage_coal_boiler_mesh_top.png"},
	drawtype = "mesh",
	mesh = "techage_boiler_large.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -16/32, -13/32, 13/32, 16/32, 13/32},
	},

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = node_timer,
	can_dig = firebox.can_dig,
	allow_metadata_inventory_put = firebox.allow_metadata_inventory_put,
	allow_metadata_inventory_take = firebox.allow_metadata_inventory_take,
	on_receive_fields = firebox.on_receive_fields,
	on_rightclick = firebox.on_rightclick,
	
	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		techage.add_node(pos, "techage:coalfirebox")
		mem.running = false
		mem.burn_cycles = 0
		mem.power_level = 4
		local meta = M(pos)
		meta:set_string("formspec", firebox.formspec(mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
		firehole(pos, false)
	end,

	on_destruct = function(pos)
		firehole(pos, nil)
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local mem = tubelib2.get_mem(pos)
		start_firebox(pos, mem)
		M(pos):set_string("formspec", firebox.formspec(mem))
	end,
})

minetest.register_node("techage:coalfirehole", {
	description = S("TA3 Coal Power Station Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png^techage_appl_firehole.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16,  6/16,  6/16, 6/16,  12/16},
		},
	},

	paramtype2 = "facedir",
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("techage:coalfirehole_on", {
	description = S("TA3 Coal Power Station Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		{
			image = "techage_coal_boiler4.png^[colorize:black:80^techage_appl_firehole4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16,  6/16,  6/16, 6/16,  12/16},
		},
	},
	paramtype2 = "facedir",
	light_source = 8,
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})

local function on_timer2(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		oilburner.formspec_update(pos, mem)
		-- trigger generator and provide power ratio 0..1
		local ratio = techage.transfer(
			{x=pos.x, y=pos.y+2, z=pos.z}, 
			nil,  -- outdir
			"trigger",  -- topic
			(mem.power_level or 4)/4.0,  -- payload
			nil,  -- network
			{"techage:coalboiler_top"}  -- nodenames
		)
		ratio = math.max((ratio or 0.02), 0.02)
		mem.burn_cycles = (mem.burn_cycles or 0) - ratio
		mem.liquid = mem.liquid or {}
		mem.liquid.amount = mem.liquid.amount or 0
		if mem.burn_cycles <= 0 then
			local taken = firebox.get_fuel(pos) 
			if mem.liquid.amount > 0 then
				mem.liquid.amount = mem.liquid.amount - 1
				mem.burn_cycles = oilburner.Oilburntime / CYCLE_TIME * BURN_CYCLE_FACTOR
				mem.burn_cycles_total = mem.burn_cycles
			else
				mem.running = false
				firehole(pos, false)
				M(pos):set_string("formspec", oilburner.formspec(mem))
				return false
			end
		end
		return true
	end
end

local function start_firebox2(pos, mem)
	print("start_firebox2", mem.running, mem.liquid and mem.liquid.amount)
	if not mem.running and mem.liquid.amount > 0 then
		mem.running = true
		on_timer2(pos, 0)
		firehole(pos, true)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

minetest.register_node("techage:oilfirebox", {
	description = S("TA3 Power Station Oil Firebox"),
	inventory_image = "techage_coal_boiler_inv.png",
	tiles = {"techage_coal_boiler_mesh_top.png"},
	drawtype = "mesh",
	mesh = "techage_boiler_large.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -16/32, -13/32, 13/32, 16/32, 13/32},
	},

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = on_timer2,
	can_dig = oilburner.can_dig,
	allow_metadata_inventory_put = oilburner.allow_metadata_inventory_put,
	allow_metadata_inventory_take = oilburner.allow_metadata_inventory_take,
	on_receive_fields = oilburner.on_receive_fields,
	on_rightclick = oilburner.on_rightclick,
	
	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		techage.add_node(pos, "techage:oilfirebox")
		mem.running = false
		mem.burn_cycles = 0
		mem.liquid = {}
		mem.liquid.amount =  0
		local meta = M(pos)
		meta:set_string("formspec", oilburner.formspec(mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
		firehole(pos, false)
	end,

	on_destruct = function(pos)
		firehole(pos, nil)
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local mem = tubelib2.get_mem(pos)
		mem.liquid = mem.liquid or {}
		mem.liquid.amount = mem.liquid.amount or 0
		start_firebox2(pos, mem)
		oilburner.on_metadata_inventory_put(pos, listname, index, stack, player)
	end,

	liquid = {
		capa = oilburner.CAPACITY,
		peek = liquid.srv_peek,
		put = function(pos, indir, name, amount)
			liquid.srv_put(pos, indir, name, amount)
			local mem = tubelib2.get_mem(pos)
			mem.liquid = mem.liquid or {}
			mem.liquid.amount = mem.liquid.amount or 0
			start_firebox2(pos, mem)
		end,
		take = liquid.srv_take,
	},
	networks = oilburner.networks,
})

Pipe:add_secondary_node_names({"techage:oilfirebox"})


techage.register_node({"techage:coalfirebox"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(inv, "fuel", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		if firebox.Burntime[stack:get_name()] then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local mem = tubelib2.get_mem(pos)
			start_firebox(pos, mem)
			return techage.put_items(inv, "fuel", stack)
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "fuel", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "state" then
			if mem.running then
				return "running"
			else
				return "stopped"
			end
		elseif topic == "fuel" then
			local inv = M(pos):get_inventory()
			local stack = inv:get_stack("fuel", 1)
			return stack:get_count()
		else
			return "unsupported"
		end
	end,
})


minetest.register_craft({
	output = "techage:coalfirebox",
	recipe = {
		{'default:stone', 'default:stone', 'default:stone'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:stone', 'default:stone', 'default:stone'},
	},
})

minetest.register_craft({
	output = "techage:oilfirebox",
	recipe = {
		{'', 'techage:coalfirebox', ''},
		{'', 'techage:ta3_barrel_empty', ''},
		{'', '', ''},
	},
})

minetest.register_lbm({
	label = "[techage] Power Station firebox",
	name = "techage:steam_engine",
	nodenames = {"techage:coalfirebox", "techage:oilfirebox"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
})


