--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Steam Engine Firebox

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local firebox = techage.firebox

local CYCLE_TIME = 2
local BURN_CYCLE_FACTOR = 0.8

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	--print("firebox burn_cycles = "..(mem.burn_cycles or 0))
	if mem.running then
		local power = techage.transfer(
			{x=pos.x, y=pos.y+2, z=pos.z}, 
			nil,  -- outdir
			"trigger",  -- topic
			nil,  -- payload
			nil,  -- network
			{"techage:boiler2"}  -- nodenames
		)
		mem.burn_cycles = (mem.burn_cycles or 0) - math.max((power or 0.1), 0.1)
		if mem.burn_cycles <= 0 then
			local taken = firebox.get_fuel(pos) 
			if taken then
				mem.burn_cycles = firebox.Burntime[taken:get_name()] / CYCLE_TIME * BURN_CYCLE_FACTOR
				mem.burn_cycles_total = mem.burn_cycles
			else
				mem.running = false
				firebox.swap_node(pos, "techage:firebox")
				M(pos):set_string("formspec", firebox.formspec(mem))
				return false
			end
		end
		return true
	end
end

minetest.register_node("techage:firebox", {
	description = S("TA2 Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_firebox.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_appl_firehole.png^techage_frame_ta2.png",
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

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local mem = tubelib2.init_mem(pos)
		mem.running = true
		-- activate the formspec fire temporarily
		mem.burn_cycles = firebox.Burntime[stack:get_name()] / CYCLE_TIME
		mem.burn_cycles_total = mem.burn_cycles
		M(pos):set_string("formspec", firebox.formspec(mem))
		mem.burn_cycles = 0
		firebox.swap_node(pos, "techage:firebox_on")
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})

minetest.register_node("techage:firebox_on", {
	description = S("TA2 Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		"techage_firebox.png^techage_frame_ta2.png",
		{
			image = "techage_firebox4.png^techage_appl_firehole4.png^techage_frame4_ta2.png",
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
	groups = {cracky=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	drop = "techage:firebox",
	
	on_timer = node_timer,
	can_dig = firebox.can_dig,
	allow_metadata_inventory_put = firebox.allow_metadata_inventory,
	allow_metadata_inventory_take = firebox.allow_metadata_inventory,
	on_receive_fields = firebox.on_receive_fields,
	on_rightclick = firebox.on_rightclick,
})

minetest.register_craft({
	output = "techage:firebox",
	recipe = {
		{'group:stone', 'group:stone', 'group:stone'},
		{'techage:iron_ingot', '', 'techage:iron_ingot'},
		{'group:stone', 'group:stone', 'group:stone'},
	},
})

techage.register_node({"techage:firebox", "techage:firebox_on"}, {
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if firebox.Burntime[stack:get_name()] then
			if inv:room_for_item("fuel", stack) then
				inv:add_item("fuel", stack)
				minetest.get_node_timer(pos):start(CYCLE_TIME)
				return true
			end
		end
		return false
	end,
})	

minetest.register_lbm({
	label = "[techage] Steam engine firebox",
	name = "techage:steam_engine",
	nodenames = {"techage:firebox_on"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		local mem = tubelib2.get_mem(pos)
		mem.power_level = nil
	end
})


