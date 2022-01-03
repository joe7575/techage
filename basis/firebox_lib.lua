--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Firebox basic functions

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

techage.firebox = {}

techage.firebox.Burntime = {
	["techage:charcoal"] = true, -- will be replaced by burntime
	["default:coal_lump"] = true,
	["default:coalblock"] = true,
	["techage:oil_source"] = true,
	["techage:gas"] = true,
	["techage:gasoline"] = true,
	["techage:naphtha"] = true,
	["techage:fueloil"] = true,
}

techage.firebox.ValidOilFuels = {
	["techage:gasoline"] = 1, -- category
	["techage:naphtha"] = 2,
	["techage:fueloil"] = 3,
	["techage:oil_source"] = 4,
}


local function determine_burntimes()
	for k,_ in pairs(techage.firebox.Burntime)do
		local fuel,_ = minetest.get_craft_result({method = "fuel", width = 1, items = {k}})
		techage.firebox.Burntime[k] = fuel.time
	end
end
minetest.after(1, determine_burntimes)

function techage.firebox.formspec(nvm)
	local fuel_percent = 0
	if nvm.running then
		fuel_percent = ((nvm.burn_cycles or 1) * 100) / (nvm.burn_cycles_total or 1)
	end
	return "size[8,6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;7.8,0.5;#c6e8ff]"..
		"label[3,-0.1;"..minetest.colorize( "#000000", S("Firebox")).."]"..
		"list[current_name;fuel;3,1;1,1;]"..
		"image[4,1;1,1;default_furnace_fire_bg.png^[lowpart:"..
		fuel_percent..":default_furnace_fire_fg.png]"..
		"list[current_player;main;0,2.3;8,4;]"..
		"listring[current_name;fuel]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 2.3)
end

function techage.firebox.can_dig(pos, player)
	local inv = M(pos):get_inventory()
	return inv:is_empty("fuel")
end

function techage.firebox.allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if techage.firebox.Burntime[stack:get_name()] then
		return stack:get_count()
	end
	return 0
end

function techage.firebox.allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

function techage.firebox.on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", techage.firebox.formspec(nvm))
end

function techage.firebox.swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
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

function techage.firebox.has_fuel(pos)
	local inv = M(pos):get_inventory()
	local items = inv:get_stack("fuel", 1)
	return items:get_count() > 0
end

function techage.firebox.is_free_position(pos, player_name)
	local pos2 = techage.get_pos(pos, 'F')
	if minetest.is_protected(pos2, player_name) then
		minetest.chat_send_player(player_name, S("[TA] Area is protected!"))
		return false
	end
	local node = techage.get_node_lvm(pos2)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef or not ndef.buildable_to then
		minetest.chat_send_player(player_name, S("[TA] Not enough space!"))
		return false
	end
	return true
end

function techage.firebox.set_firehole(pos, on)
	local param2 = techage.get_node_lvm(pos).param2
	local pos2 = techage.get_pos(pos, 'F')
	if on == true then
		minetest.swap_node(pos2, {name="techage:coalfirehole_on", param2 = param2})
	elseif on == false then
		minetest.swap_node(pos2, {name="techage:coalfirehole", param2 = param2})
	else
		local node = techage.get_node_lvm(pos2)
		if node.name == "techage:coalfirehole" or node.name == "techage:coalfirehole_on" then
			minetest.swap_node(pos2, {name="air"})
		end
	end
end
