--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Industrial Furnace Firebox

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local firebox = techage.firebox
local fuel = techage.fuel
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CYCLE_TIME = 2
local EFFICIENCY = 2 -- burn cycles
local CATEGORY = 3

local function has_fuel(pos, mem)
	return mem.burn_cycles > 0 or (mem.liquid and mem.liquid.amount and mem.liquid.amount > 0)
end

local function stop_firebox(pos, mem)
	mem.running = false
	firebox.swap_node(pos, "techage:furnace_firebox")
	minetest.get_node_timer(pos):stop()
	M(pos):set_string("formspec", fuel.formspec(mem))
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	if mem.running then
		fuel.formspec_update(pos, mem)
		mem.burn_cycles = (mem.burn_cycles or 0) - 1
		if mem.burn_cycles <= 0 then
			if mem.liquid.amount > 0 then
				mem.liquid.amount = mem.liquid.amount - 1
				mem.burn_cycles = fuel.burntime(mem.liquid.name) * EFFICIENCY / CYCLE_TIME
				mem.burn_cycles_total = mem.burn_cycles
			else
				mem.liquid.name = nil
				stop_firebox(pos, mem)
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
		firebox.swap_node(pos, "techage:furnace_firebox_on")
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		M(pos):set_string("formspec", fuel.formspec(mem))
	end
end

local function booster_cmnd(pos, cmnd)
	return techage.transfer(
		pos, 
		"L",  -- outdir
		cmnd,  -- topic
		nil,  -- payload
		nil,  -- network
		{"techage:ta3_booster", "techage:ta3_booster_on"})
end

local _liquid = {
	capa = fuel.CAPACITY,
	fuel_cat = fuel.BT_OIL,
	peek = liquid.srv_peek,
	put = function(pos, indir, name, amount)
		if fuel.valid_fuel(name, fuel.BT_OIL) then
			return liquid.srv_put(pos, indir, name, amount)
		end
		return amount
	end,
	take = liquid.srv_take,
}

local _networks = {
	pipe = {
		sides = techage.networks.AllSides, -- Pipe connection sides
		ntype = "tank",
	},
}

minetest.register_node("techage:furnace_firebox", {
	description = S("TA3 Furnace Oil Burner"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_firehole.png^techage_frame_ta3.png",
	},
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = node_timer,
	can_dig = fuel.can_dig,
	allow_metadata_inventory_take = fuel.allow_metadata_inventory_take,
	allow_metadata_inventory_put = fuel.allow_metadata_inventory_put,
	on_metadata_inventory_put = fuel.on_metadata_inventory_put,
	on_receive_fields = fuel.on_receive_fields,
	on_rightclick = fuel.on_rightclick,
	liquid = _liquid,
	networks = _networks,
	
	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		techage.add_node(pos, "techage:furnace_firebox")
		mem.running = false
		mem.burn_cycles = 0
		mem.liquid = {}
		mem.liquid.amount =  0
		local meta = M(pos)
		meta:set_string("formspec", fuel.formspec(mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
	end,
})

minetest.register_node("techage:furnace_firebox_on", {
	description = S("TA3 Furnace Oil Burner"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		{
			image = "techage_concrete4.png^techage_appl_firehole4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	paramtype2 = "facedir",
	light_source = 8,
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	drop = "techage:furnace_firebox",
	
	on_timer = node_timer,
	can_dig = fuel.can_dig,
	allow_metadata_inventory_put = fuel.allow_metadata_inventory_put,
	allow_metadata_inventory_take = fuel.allow_metadata_inventory_take,
	on_receive_fields = fuel.on_receive_fields,
	on_rightclick = fuel.on_rightclick,
	liquid = _liquid,
	networks = _networks,
	
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local mem = tubelib2.get_mem(pos)
		mem.liquid = mem.liquid or {}
		mem.liquid.amount = mem.liquid.amount or 0
		start_firebox(pos, mem)
		fuel.on_metadata_inventory_put(pos, listname, index, stack, player)
	end,
})

minetest.register_craft({
	output = "techage:furnace_firebox",
	recipe = {
		{'techage:basalt_stone', 'techage:basalt_stone', 'techage:basalt_stone'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'techage:basalt_stone', 'techage:basalt_stone', 'techage:basalt_stone'},
	},
})

techage.register_node({"techage:furnace_firebox", "techage:furnace_firebox_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "state" then
			if mem.running then
				return "running"
			else
				return "stopped"
			end
		elseif topic == "fuel" then
			return mem.liquid and mem.liquid.amount and mem.liquid.amount
		else
			return "unsupported"
		end
	end,
	-- called from furnace_top
	on_transfer = function(pos, in_dir, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "fuel" then
			return has_fuel(pos, mem) and booster_cmnd(pos, "power")
		elseif topic == "running" then
			return mem.running and booster_cmnd(pos, "power")
		elseif topic == "start" then
			start_firebox(pos, mem)
			booster_cmnd(pos, "start")
		elseif topic == "stop" then
			stop_firebox(pos, mem)
			booster_cmnd(pos, "stop")
		end
	end
})	

Pipe:add_secondary_node_names({"techage:furnace_firebox", "techage:furnace_firebox_on"})


minetest.register_lbm({
	label = "[techage] Furnace firebox",
	name = "techage:furnace",
	nodenames = {"techage:furnace_firebox_on"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
})

