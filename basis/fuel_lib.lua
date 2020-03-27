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
	return "container["..x..","..y.."]"..
		"box[0,0;1.05,2.1;#000000]"..
		"image[0.1,0.1;1,1;default_furnace_fire_bg.png^[lowpart:"..
		fuel_percent..":default_furnace_fire_fg.png]"..
		techage.item_image(0.1, 1.1, itemname)..
		"container_end[]"
end	

local function help(x, y)
	local tooltip = S("To add fuel punch\nthis block\nwith a fuel container")
	return "label["..x..","..y..";"..minetest.colorize("#000000", minetest.formspec_escape("[?]")).."]"..
		"tooltip["..x..","..y..";0.5,0.5;"..tooltip..";#0C3D32;#FFFFFF]"
end

function techage.fuel.formspec(nvm)
	local title = S("Fuel Menu")
	return "size[4,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;3.8,0.5;#c6e8ff]"..
		"label[1,-0.1;"..minetest.colorize("#000000", title).."]"..
		help(3.4, -0.1)..
		techage.fuel.fuel_container(1.5, 1, nvm)
end

function techage.fuel.can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local nvm = techage.get_nvm(pos)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	local inv = M(pos):get_inventory()
	return not inv or inv:is_empty("fuel") and nvm.liquid.amount == 0
end

function techage.fuel.on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", techage.fuel.formspec(nvm))
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

function techage.fuel.on_punch(pos, node, puncher, pointed_thing)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.blocking_time = mem.blocking_time or 0
	if mem.blocking_time > techage.SystemTime then
		return
	end
	
	local wielded_item = puncher:get_wielded_item():get_name()
	local item_count = puncher:get_wielded_item():get_count()
	local new_item = liquid.fill_on_punch(nvm, wielded_item, item_count, puncher) 
	if new_item then
		puncher:set_wielded_item(new_item)
		M(pos):set_string("formspec", techage.fuel.formspec(pos, nvm))
		mem.blocking_time = techage.SystemTime + BLOCKING_TIME
		return
	end
		
	local ldef = liquid.get_liquid_def(wielded_item)
	if ldef and ValidOilFuels[ldef.inv_item] then
		local new_item = liquid.empty_on_punch(pos, nvm, wielded_item, item_count)
		if new_item then
			puncher:set_wielded_item(new_item)
			M(pos):set_string("formspec", techage.fuel.formspec(pos, nvm))
			mem.blocking_time = techage.SystemTime + BLOCKING_TIME
		end
	end
end

function techage.fuel.get_fuel(nvm)
	if nvm.liquid and nvm.liquid.name and nvm.liquid.amount then
		if nvm.liquid.amount > 0 then
			nvm.liquid.amount = nvm.liquid.amount - 1
			return nvm.liquid.name
		end
		nvm.liquid.name = nil 
	end
	return nil
end

function techage.fuel.has_fuel(nvm)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	return nvm.liquid.amount > 0
end

function techage.fuel.get_fuel_amount(nvm)
	if nvm.liquid and nvm.liquid.amount then
		return nvm.liquid.amount
	end
	return 0
end