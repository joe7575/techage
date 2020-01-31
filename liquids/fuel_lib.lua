--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Oil fuel burning lib

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local LQD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).liquid end
local Pipe = techage.LiquidPipe
local liquid = techage.liquid
local ValidOilFuels = techage.firebox.ValidOilFuels
local Burntime = techage.firebox.Burntime

techage.fuel = {}

local CAPACITY = 50

techage.fuel.CAPACITY = CAPACITY

-- fuel burning categories (better than...)
techage.fuel.BT_BITUMEN = 4
techage.fuel.BT_OIL     = 3
techage.fuel.BT_FUELOIL = 2
techage.fuel.BT_NAPHTHA = 1


local function formspec_fuel(x, y, nvm)
	local itemname = ""
	if nvm.liquid and nvm.liquid.name and nvm.liquid.amount and nvm.liquid.amount > 0  then
		itemname = nvm.liquid.name.." "..nvm.liquid.amount
	end
	local fuel_percent = 0
	if nvm.running then
		fuel_percent = ((nvm.burn_cycles or 1) * 100) / (nvm.burn_cycles_total or 1)
	end
	return "container["..x..","..y.."]"..
		"background[0,0;3,1.05;techage_form_grey.png]"..
		"list[context;fuel;0,0;1,1;]"..
		techage.item_image(1, 0, itemname)..
		"image[2,0;1,1;default_furnace_fire_bg.png^[lowpart:"..
		fuel_percent..":default_furnace_fire_fg.png]"..
		"container_end[]"
end	

techage.fuel.formspec_fuel = formspec_fuel


function techage.fuel.formspec(nvm)
	local update = ((nvm.countdown or 0) > 0 and nvm.countdown) or S("Update")
	return "size[8,5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	formspec_fuel(1, 0, nvm)..
	"button[5,0;2,1;update;"..update.."]"..
	"list[current_player;main;0,1.3;8,4;]"
end

local function fill_container(pos, inv, nvm)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	local empty_container = inv:get_stack("fuel", 1):get_name()
	local full_container = liquid.get_full_container(empty_container, nvm.liquid.name)
	if empty_container and full_container then
		local ldef = liquid.get_liquid_def(full_container)
		if ldef and nvm.liquid.amount - ldef.size >= 0 then 
			inv:remove_item("fuel", ItemStack(empty_container))
			inv:add_item("fuel", ItemStack(full_container))
			nvm.liquid.amount = nvm.liquid.amount - ldef.size
			if nvm.liquid.amount == 0 then 
				nvm.liquid.name = nil 
			end
		end
	end
end

local function empty_container(pos, inv, nvm)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	local stack = inv:get_stack("fuel", 1)
	if stack:get_count() == 1 then
		local ldef = liquid.get_liquid_def(stack:get_name())
		if ldef and ValidOilFuels[ldef.inv_item] then
			if not nvm.liquid.name or ldef.inv_item == nvm.liquid.name then
				if nvm.liquid.amount + ldef.size <= CAPACITY then 
					inv:remove_item("fuel", stack)
					inv:add_item("fuel", ItemStack(ldef.container))
					nvm.liquid.amount = nvm.liquid.amount + ldef.size
					nvm.liquid.name = ldef.inv_item
				end
			end
		end
	end
end

local function move_item(pos, stack)
	local nvm = techage.get_nvm(pos)
	local inv = M(pos):get_inventory()
	if liquid.is_container_empty(stack:get_name()) then
		fill_container(pos, inv, nvm)
	else
		empty_container(pos, inv, nvm)
	end
	M(pos):set_string("formspec", techage.fuel.formspec(nvm))
end

function techage.fuel.move_item(pos, stack, formspec)
	local nvm = techage.get_nvm(pos)
	local inv = M(pos):get_inventory()
	if liquid.is_container_empty(stack:get_name()) then
		fill_container(pos, inv, nvm)
	else
		empty_container(pos, inv, nvm)
	end
	M(pos):set_string("formspec", formspec(pos, nvm))
end

function techage.fuel.allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if liquid.is_container_empty(stack:get_name()) then
		return 1
	end
	local category = LQD(pos).fuel_cat
	local ldef = liquid.get_liquid_def(stack:get_name())
	if ldef and ValidOilFuels[ldef.inv_item] and ValidOilFuels[ldef.inv_item] <= category then
		return 1
	end
	return 0
end

function techage.fuel.allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

function techage.fuel.on_metadata_inventory_put(pos, listname, index, stack, player)
	minetest.after(0.5, move_item, pos, stack)
end

function techage.fuel.can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local nvm = techage.get_nvm(pos)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	local inv = M(pos):get_inventory()
	return inv:is_empty("fuel") and nvm.liquid.amount == 0
end

function techage.fuel.on_rightclick(pos)
	local nvm = techage.get_nvm(pos)
	nvm.countdown = 10
	M(pos):set_string("formspec", techage.fuel.formspec(nvm))
end

function techage.fuel.on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	nvm.countdown = 10
	M(pos):set_string("formspec", techage.fuel.formspec(nvm))
end

function techage.fuel.formspec_update(pos, nvm)
	if nvm.countdown and nvm.countdown > 0 then
		nvm.countdown = nvm.countdown - 1
		M(pos):set_string("formspec", techage.fuel.formspec(nvm))
	end
end

-- name is the fuel item name
function techage.fuel.burntime(name)
	if ValidOilFuels[name] then
		return Burntime[name] or 0.01 -- not zero !
	end
	return 0.01 -- not zero !
end

function techage.fuel.valid_fuel(name, category)
	return ValidOilFuels[name] and ValidOilFuels[name] <= category
end
