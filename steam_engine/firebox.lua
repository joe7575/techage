--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Steam Engine Firebox

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local firebox = techage.firebox

local CYCLE_TIME = 2


local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		local trd = TRD({x=pos.x, y=pos.y+2, z=pos.z})
		if trd and trd.trigger_boiler then
			trd.trigger_boiler({x=pos.x, y=pos.y+2, z=pos.z})
		end
		mem.burn_cycles = (mem.burn_cycles or 0) - 1
		if mem.burn_cycles <= 0 then
			local taken = firebox.get_fuel(pos) 
			if taken then
				mem.burn_cycles = firebox.Burntime[taken:get_name()] / CYCLE_TIME
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
	description = I("TA2 Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_firebox.png^techage_frame_ta2.png",
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
	description = I("TA2 Firebox"),
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
