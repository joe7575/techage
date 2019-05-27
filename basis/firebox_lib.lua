--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Firebox basic functions

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

techage.firebox = {}

local BURN_TIME_FACTOR = 1

techage.firebox.Burntime = {
	["techage:charcoal"] = true, -- will be replaced by burntime
	["default:coal_lump"] = true,
	["default:coalblock"] = true,
	["techage:oil_source"] = true
}

local function determine_burntimes()
	for k,_ in pairs(techage.firebox.Burntime)do
		local fuel,_ = minetest.get_craft_result({method = "fuel", width = 1, items = {k}})
		techage.firebox.Burntime[k] = fuel.time * BURN_TIME_FACTOR
	end
end	
minetest.after(1, determine_burntimes)

function techage.firebox.formspec(mem)
	local fuel_percent = 0
	if mem.running then
		fuel_percent = ((mem.burn_cycles or 1) * 100) / (mem.burn_cycles_total or 1)
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

function techage.firebox.can_dig(pos, player)
	local mem = tubelib2.get_mem(pos)
	local inv = M(pos):get_inventory()
	return inv:is_empty("fuel") and not mem.running
end

function techage.firebox.allow_metadata_inventory(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if techage.firebox.Burntime[stack:get_name()] then
		return stack:get_count()
	end
	return 0
end

function techage.firebox.on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	if fields.update then
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("formspec", techage.firebox.formspec(mem))
	end
end

function techage.firebox.on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", techage.firebox.formspec(mem))
end

function techage.firebox.swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

function techage.firebox.get_fuel(pos)
	local inv = M(pos):get_inventory()
	local items = inv:get_stack("fuel", 1)
	if items:get_count() > 0 then
		local taken = items:take_item(1)
		inv:set_stack("fuel", 1, items)
		return taken
	end
end

