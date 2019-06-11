--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Industrial Furnace Firebox

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local firebox = techage.firebox

local CYCLE_TIME = 2

local function has_fuel(pos, mem)
	return mem.burn_cycles > 0 or firebox.has_fuel(pos) 
end

local function stop_firebox(pos, mem)
	mem.running = false
	firebox.swap_node(pos, "techage:furnace_firebox")
	minetest.get_node_timer(pos):stop()
	M(pos):set_string("formspec", firebox.formspec(mem))
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		mem.burn_cycles = (mem.burn_cycles or 0) - 1
		if mem.burn_cycles <= 0 then
			local taken = firebox.get_fuel(pos) 
			if taken then
				mem.burn_cycles = firebox.Burntime[taken:get_name()] / CYCLE_TIME
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
		M(pos):set_string("formspec", firebox.formspec(mem))
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
	description = I("TA3 Furnace Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_hole_biogas.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_firehole.png^techage_frame_ta3.png",
	},
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = node_timer,
	can_dig = firebox.can_dig,
	allow_metadata_inventory_put = firebox.allow_metadata_inventory,
	allow_metadata_inventory_take = firebox.allow_metadata_inventory,
	on_receive_fields = firebox.on_receive_fields,
	on_rightclick = firebox.on_rightclick,
	
	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		mem.running = false
		mem.burn_cycles = 0
		local meta = M(pos)
		meta:set_string("formspec", firebox.formspec(mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
	end,
})

minetest.register_node("techage:furnace_firebox_on", {
	description = I("TA3 Furnace Firebox"),
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
	can_dig = firebox.can_dig,
	allow_metadata_inventory_put = firebox.allow_metadata_inventory,
	allow_metadata_inventory_take = firebox.allow_metadata_inventory,
	on_receive_fields = firebox.on_receive_fields,
	on_rightclick = firebox.on_rightclick,
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
			return techage.put_items(inv, "fuel", stack)
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "fuel", stack)
	end,
	on_recv_message = function(pos, topic, payload)
		if topic == "state" then
			local meta = minetest.get_meta(pos)
			return techage.get_inv_state(meta, "fuel")
		else
			return "unsupported"
		end
	end,
	-- called from furnace_top
	on_transfer = function(pos, in_dir, topic, payload)
		--print("on_transfer", topic, payload)
		if topic == "fuel" then
			local mem = tubelib2.get_mem(pos)
			return has_fuel(pos, mem) and booster_cmnd(pos, "power")
		elseif topic == "start" then
			local mem = tubelib2.get_mem(pos)
			start_firebox(pos, mem)
			booster_cmnd(pos, "start")
		elseif topic == "stop" then
			local mem = tubelib2.get_mem(pos)
			stop_firebox(pos, mem)
			booster_cmnd(pos, "stop")
		end
	end
})	

minetest.register_lbm({
	label = "[techage] Furnace firebox",
	name = "techage:furnace",
	nodenames = {"techage:furnace_firebox_on"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
})

techage.register_help_page(I("TA3 Furnace Firebox"), 
I([[Part of the TA3 Industrial Furnace.
Faster and more powerful 
than the standard furnace.]]), "techage:furnace_firebox")
