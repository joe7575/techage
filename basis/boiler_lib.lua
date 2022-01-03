--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Boiler common functions

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local HEAT_STEP = 10
local MAX_WATER = 10
local BLOCKING_TIME = 0.3 -- 300ms

techage.boiler = {}

local IsWater = {
	["bucket:bucket_river_water"] = true,
	["bucket:bucket_water"] = true,
}

local IsBucket = {
	["bucket:bucket_empty"] = true,
}

local function node_description(name)
	name = string.split(name, " ")[1]
	local ndef = minetest.registered_nodes[name] or minetest.registered_items[name] or minetest.registered_craftitems[name]
	if ndef and ndef.description then
		return minetest.formspec_escape(ndef.description)
	end
	return ""
end

local function item_image(x, y, itemname)
	return "box["..x..","..y..";0.85,0.9;#808080]"..
		"item_image["..x..","..y..";1,1;"..itemname.."]"
end

function techage.boiler.formspec(pos, nvm)
	local title = S("Water Boiler")
	local temp = nvm.temperature or 20
	local ratio = nvm.power_ratio or 0
	local tooltip = S("To add water punch\nthe boiler\nwith a water bucket")
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;4.8,0.5;#c6e8ff]"..
		"label[1.5,-0.1;"..minetest.colorize("#000000", title).."]"..
		item_image(1, 1.5, "default:water_source "..(nvm.num_water or 0))..
		"tooltip[1,1.5;1,1;"..tooltip..";#0C3D32;#FFFFFF]"..
		"image[3,1.0;1,2;techage_form_temp_bg.png^[lowpart:"..
		temp..":techage_form_temp_fg.png]"..
		"tooltip[3,1;1,2;"..S("water temperature")..";#0C3D32;#FFFFFF]"
end

function techage.boiler.water_temperature(pos, nvm)
	nvm.temperature = nvm.temperature or 20
	nvm.num_water = nvm.num_water or 0
	nvm.water_level = nvm.water_level or 0
	if nvm.fire_trigger then
		nvm.temperature = math.min(nvm.temperature + HEAT_STEP, 100)
	else
		nvm.temperature = math.max(nvm.temperature - HEAT_STEP, 20)
	end
	nvm.fire_trigger = false

	if nvm.water_level == 0 then
		if nvm.num_water > 0 then
			nvm.num_water = nvm.num_water - 1
			nvm.water_level = 100
		else
			nvm.temperature = 20
		end
	end
	return nvm.temperature
end

function techage.boiler.on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", techage.boiler.formspec(pos, nvm))
end

function techage.boiler.can_dig(pos, player)
	local nvm = techage.get_nvm(pos)
	nvm.num_water = nvm.num_water or 0
	return nvm.num_water == 0
end

local function space_in_inventory(wielded_item, item_count, puncher)
	-- check if holding more than 1 empty container
	if item_count > 1 then
		local inv = puncher:get_inventory()
		local item = ItemStack({name=wielded_item, count = item_count - 1})
		if inv:room_for_item("main", item) then
			inv:add_item("main", item)
			return true
		end
		return false
	end
	return true
end

function techage.boiler.on_punch(pos, node, puncher, pointed_thing)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.blocking_time = mem.blocking_time or 0
	if mem.blocking_time > techage.SystemTime then
		return
	end

	nvm.num_water = nvm.num_water or 0
	local wielded_item = puncher:get_wielded_item():get_name()
	local item_count = puncher:get_wielded_item():get_count()
	if IsWater[wielded_item] and nvm.num_water < MAX_WATER then
		mem.blocking_time = techage.SystemTime + BLOCKING_TIME
		nvm.num_water = nvm.num_water + 1
		puncher:set_wielded_item(ItemStack("bucket:bucket_empty"))
		M(pos):set_string("formspec", techage.boiler.formspec(pos, nvm))
	elseif IsBucket[wielded_item] and nvm.num_water > 0 then
		if item_count > 1 then
			local inv = puncher:get_inventory()
			local item = ItemStack("bucket:bucket_water")
			if inv:room_for_item("main", item) then
				inv:add_item("main", item)
				puncher:set_wielded_item({name=wielded_item, count = item_count - 1})
				mem.blocking_time = techage.SystemTime + BLOCKING_TIME
				nvm.num_water = nvm.num_water - 1
			end
		else
			mem.blocking_time = techage.SystemTime + BLOCKING_TIME
			nvm.num_water = nvm.num_water - 1
			puncher:set_wielded_item(ItemStack("bucket:bucket_water"))
		end
		M(pos):set_string("formspec", techage.boiler.formspec(pos, nvm))
	end
end
