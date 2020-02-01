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
local BLOCKING_TIME = 0.3 -- 300ms

techage.fuel.CAPACITY = CAPACITY

-- fuel burning categories (better than...)
techage.fuel.BT_BITUMEN = 4
techage.fuel.BT_OIL     = 3
techage.fuel.BT_FUELOIL = 2
techage.fuel.BT_NAPHTHA = 1


function techage.fuel.fuel_container(x, y, nvm)
	local itemname = ""
	if nvm.liquid and nvm.liquid.name and nvm.liquid.amount and nvm.liquid.amount > 0  then
		itemname = nvm.liquid.name.." "..nvm.liquid.amount
	end
	local fuel_percent = 0
	if nvm.running then
		fuel_percent = ((nvm.burn_cycles or 1) * 100) / (nvm.burn_cycles_total or 1)
	end
	local tooltip = S("To add fuel punch\nthis block\nwith a fuel container")
	return "container["..x..","..y.."]"..
		"box[0,0;1.05,2.1;#000000]"..
		"tooltip[0,0;1.1,1.1;"..tooltip..";#0C3D32;#FFFFFF]"..
		"image[0.1,0.1;1,1;default_furnace_fire_bg.png^[lowpart:"..
		fuel_percent..":default_furnace_fire_fg.png]"..
		techage.item_image(0.1, 1.1, itemname)..
		"container_end[]"
end	

function techage.fuel.formspec(nvm)
	local title = S("Fuel Menu")
	return "size[4,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;3.8,0.5;#c6e8ff]"..
		"label[1,-0.1;"..minetest.colorize("#000000", title).."]"..
		techage.fuel.fuel_container(1.5, 1, nvm)
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

function techage.fuel.on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
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

-- check if the given empty container can be replaced by a full
-- container and added to the players inventory
local function fill(nvm, empty_container, item_count, puncher)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	local full_container = liquid.get_full_container(empty_container, nvm.liquid.name)
	if empty_container and full_container then
		local item = ItemStack(full_container) -- to be added
		local ldef = liquid.get_liquid_def(full_container)
		if ldef and nvm.liquid.amount - ldef.size >= 0 then 
			if item_count > 1 then -- can't be simply replaced?
				-- check for extra free space
				local inv = puncher:get_inventory()
				if inv:room_for_item("main", item) then
					-- add full container and return
					-- the empty once - 1
					inv:add_item("main", item)	
					item = {name = empty_container, count = item_count - 1}
				else
					return -- no free space
				end
			end
			nvm.liquid.amount = nvm.liquid.amount - ldef.size
			if nvm.liquid.amount == 0 then 
				nvm.liquid.name = nil 
			end
			return item -- to be added to the players inv.
		end
	end
end

local function empty(nvm, full_container)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	local ldef = liquid.get_liquid_def(full_container)
	if ldef and ValidOilFuels[ldef.inv_item] then
		if not nvm.liquid.name or ldef.inv_item == nvm.liquid.name then
			if nvm.liquid.amount + ldef.size <= CAPACITY then 
				nvm.liquid.amount = nvm.liquid.amount + ldef.size
				nvm.liquid.name = ldef.inv_item
				return ItemStack(ldef.container)
			end
		end
	end
end

function techage.fuel.on_punch(pos, node, puncher, pointed_thing)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.blocking_time = mem.blocking_time or 0
	if mem.blocking_time > techage.SystemTime then
		return
	end
	
	local wielded_item = puncher:get_wielded_item():get_name()
	local item_count = puncher:get_wielded_item():get_count()
	local new_item = fill(nvm, wielded_item, item_count, puncher) 
			or empty(nvm, wielded_item)
	if new_item then
		puncher:set_wielded_item(ItemStack(new_item))
		M(pos):set_string("formspec", techage.fuel.formspec(pos, nvm))
		mem.blocking_time = techage.SystemTime + BLOCKING_TIME
		return
	end
end
