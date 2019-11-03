--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Oil burner lib

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

techage.oilburner = {}

local CAPACITY = 50

techage.oilburner.CAPACITY = CAPACITY
techage.oilburner.Oilburntime = 50

minetest.after(1, function()
	local fuel,_ = minetest.get_craft_result({method = "fuel", width = 1, items = {"techage:oil_source"}})
	techage.oilburner.Oilburntime = fuel.time
end)

techage.oilburner.liquid = {
	capa = CAPACITY,
	peek = liquid.srv_peek,
	put = liquid.srv_put,
	take = liquid.srv_take,
}

techage.oilburner.networks = {
	pipe = {
		sides = techage.networks.AllSides, -- Pipe connection sides
		ntype = "tank",
	},
}

local function formspec_oil(x, y, mem)
	local itemname = ""
	if mem.liquid and mem.liquid.amount and mem.liquid.amount > 0  then
		itemname = "techage:oil_source "..mem.liquid.amount
	end
	local fuel_percent = 0
	if mem.running then
		fuel_percent = ((mem.burn_cycles or 1) * 100) / (mem.burn_cycles_total or 1)
	end
	return "container["..x..","..y.."]"..
		"background[0,0;3,1.05;techage_form_grey.png]"..
		"list[context;fuel;0,0;1,1;]"..
		techage.item_image(1, 0, itemname)..
		"image[2,0;1,1;default_furnace_fire_bg.png^[lowpart:"..
		fuel_percent..":default_furnace_fire_fg.png]"..
		"container_end[]"
end	

techage.oilburner.formspec_oil = formspec_oil


function techage.oilburner.formspec(mem)
	local update = ((mem.countdown or 0) > 0 and mem.countdown) or S("Update")
	return "size[8,5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	formspec_oil(1, 0, mem)..
	"button[5,0;2,1;update;"..update.."]"..
	"list[current_player;main;0,1.3;8,4;]"
end

local function fill_container(pos, inv, mem)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	local empty_container = inv:get_stack("fuel", 1):get_name()
	local full_container = liquid.get_full_container(empty_container, "techage:oil_source")
	local ldef = liquid.get_liquid_def(full_container)
	if ldef and mem.liquid.amount - ldef.size >= 0 then 
		inv:remove_item("fuel", ItemStack(empty_container))
		inv:add_item("fuel", ItemStack(full_container))
		mem.liquid.amount = mem.liquid.amount - ldef.size
	end
end

local function empty_container(pos, inv, mem)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	local stack = inv:get_stack("fuel", 1)
	if stack:get_count() == 1 then
		local ldef = liquid.get_liquid_def(stack:get_name())
		if ldef and ldef.inv_item == "techage:oil_source" then
			if mem.liquid.amount + ldef.size <= CAPACITY then 
				inv:remove_item("fuel", stack)
				inv:add_item("fuel", ItemStack(ldef.container))
				mem.liquid.amount = mem.liquid.amount + ldef.size
				mem.liquid.name = "techage:oil_source"
			end
		end
	end
end

local function move_item(pos, stack)
	local mem = tubelib2.get_mem(pos)
	local inv = M(pos):get_inventory()
	if liquid.is_container_empty(stack:get_name()) then
		fill_container(pos, inv, mem)
	else
		empty_container(pos, inv, mem)
	end
	M(pos):set_string("formspec", techage.oilburner.formspec(mem))
end

function techage.oilburner.move_item(pos, stack, formspec)
	local mem = tubelib2.get_mem(pos)
	local inv = M(pos):get_inventory()
	if liquid.is_container_empty(stack:get_name()) then
		fill_container(pos, inv, mem)
	else
		empty_container(pos, inv, mem)
	end
	M(pos):set_string("formspec", formspec(pos, mem))
end

function techage.oilburner.allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return 1
end

function techage.oilburner.allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

function techage.oilburner.on_metadata_inventory_put(pos, listname, index, stack, player)
	minetest.after(0.5, move_item, pos, stack)
end

function techage.oilburner.can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	local inv = M(pos):get_inventory()
	return inv:is_empty("fuel") and mem.liquid.amount == 0
end

function techage.oilburner.on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	mem.countdown = 10
	M(pos):set_string("formspec", techage.oilburner.formspec(mem))
end

function techage.oilburner.on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	mem.countdown = 10
	M(pos):set_string("formspec", techage.oilburner.formspec(mem))
end

function techage.oilburner.formspec_update(pos, mem)
	if mem.countdown and mem.countdown > 0 then
		mem.countdown = mem.countdown - 1
		M(pos):set_string("formspec", techage.oilburner.formspec(mem))
	end
end
