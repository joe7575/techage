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

local CYCLE_TIME = 2
local BURN_CYCLES = 10


local Fuels = {
	["techage:charcoal"] = true,
	["default:coal_lump"] = true,
	["default:coalblock"] = true,
}

local function formspec(mem)
	local fuel_percent = 0
	if mem.running then
		fuel_percent = (mem.burn_cycles * 100) / BURN_CYCLES
	end
	return "size[8,6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[current_name;fuel;1,0.5;1,1;]"..
		"image[3,0.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
		fuel_percent..":default_furnace_fire_fg.png]"..
		"button[5,0.5;1.8,1;update;"..I("Update").."]"..
		"list[current_player;main;0,2;8,4;]"..
		"listring[current_name;fuel]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 2)
end

local function can_dig(pos, player)
	local inv = M(pos):get_inventory()
	return inv:is_empty("fuel")
end

local function allow_metadata_inventory(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if Fuels[stack:get_name()] then
		return stack:get_count()
	end
	return 0
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	if fields.update then
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("formspec", formspec(mem))
	end
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(mem))
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function get_fuel(pos)
	local inv = M(pos):get_inventory()
	local items = inv:get_stack("fuel", 1)
	if items:get_count() > 0 then
		local taken = items:take_item(1)
		inv:set_stack("fuel", 1, items)
		return taken
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		local trd = TRD({x=pos.x, y=pos.y+2, z=pos.z})
		if trd and trd.trigger_boiler then
			trd.trigger_boiler({x=pos.x, y=pos.y+2, z=pos.z})
		end
		mem.burn_cycles = (mem.burn_cycles or 0) - 1
		if mem.burn_cycles <= 0 then
			if get_fuel(pos) then
				mem.burn_cycles = BURN_CYCLES
			else
				mem.running = false
				swap_node(pos, "techage:firebox")
				M(pos):set_string("formspec", formspec(mem))
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
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory,
	allow_metadata_inventory_take = allow_metadata_inventory,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	
	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		mem.running = false
		mem.burn_cycles = 0
		local meta = M(pos)
		meta:set_string("formspec", formspec(mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
	end,

	on_metadata_inventory_put = function(pos)
		local mem = tubelib2.init_mem(pos)
		mem.running = true
		-- activate the formspec fire temporarily
		mem.burn_cycles = BURN_CYCLES
		M(pos):set_string("formspec", formspec(mem))
		mem.burn_cycles = 0
		swap_node(pos, "techage:firebox_on")
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
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory,
	allow_metadata_inventory_take = allow_metadata_inventory,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
})

