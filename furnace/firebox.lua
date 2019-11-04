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
local oilburner = techage.oilburner
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CYCLE_TIME = 2

local function has_fuel(pos, mem)
	return mem.burn_cycles > 0 or (mem.liquid and mem.liquid.amount and mem.liquid.amount > 0)
end

local function stop_firebox(pos, mem)
	mem.running = false
	firebox.swap_node(pos, "techage:furnace_firebox")
	minetest.get_node_timer(pos):stop()
	M(pos):set_string("formspec", oilburner.formspec(mem))
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	if mem.running then
		oilburner.formspec_update(pos, mem)
		mem.burn_cycles = (mem.burn_cycles or 0) - 1
		if mem.burn_cycles <= 0 then
			if mem.liquid.amount > 0 then
				mem.liquid.amount = mem.liquid.amount - 1
				mem.burn_cycles = (oilburner.Oilburntime or 1) / CYCLE_TIME
				mem.burn_cycles_total = mem.burn_cycles
			else
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
		M(pos):set_string("formspec", oilburner.formspec(mem))
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
	can_dig = oilburner.can_dig,
	allow_metadata_inventory_put = oilburner.allow_metadata_inventory_put,
	allow_metadata_inventory_take = oilburner.allow_metadata_inventory_take,
	on_receive_fields = oilburner.on_receive_fields,
	on_rightclick = oilburner.on_rightclick,
	
	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		techage.add_node(pos, "techage:furnace_firebox")
		mem.running = false
		mem.burn_cycles = 0
		mem.liquid = {}
		mem.liquid.amount =  0
		local meta = M(pos)
		meta:set_string("formspec", oilburner.formspec(mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local mem = tubelib2.get_mem(pos)
		mem.liquid = mem.liquid or {}
		mem.liquid.amount = mem.liquid.amount or 0
		oilburner.on_metadata_inventory_put(pos, listname, index, stack, player)
	end,

	liquid = {
		capa = oilburner.CAPACITY,
		peek = liquid.srv_peek,
		put = liquid.srv_put,
		take = liquid.srv_take,
	},
	networks = oilburner.networks,
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
	can_dig = oilburner.can_dig,
	allow_metadata_inventory_put = oilburner.allow_metadata_inventory_put,
	allow_metadata_inventory_take = oilburner.allow_metadata_inventory_take,
	on_receive_fields = oilburner.on_receive_fields,
	on_rightclick = oilburner.on_rightclick,
	
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local mem = tubelib2.get_mem(pos)
		mem.liquid = mem.liquid or {}
		mem.liquid.amount = mem.liquid.amount or 0
		start_firebox(pos, mem)
		oilburner.on_metadata_inventory_put(pos, listname, index, stack, player)
	end,

	liquid = {
		capa = oilburner.CAPACITY,
		peek = liquid.srv_peek,
		put = liquid.srv_put,
		take = liquid.srv_take,
	},
	networks = oilburner.networks,
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

