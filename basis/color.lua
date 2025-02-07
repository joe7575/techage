--[[

	TechAge
	=======

	Copyright (C) 2020-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Color library

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S
local COLORED = minetest.get_modpath("unifieddyes") and minetest.global_exists("unifieddyes")

local color = {}

color.COLOR64 = {
	"#000000",
	"#005500",
	"#000055",
	"#005555",
	"#0000AA",
	"#0055AA",
	"#0000FF",
	"#0055FF",
	"#550000",
	"#555500",
	"#550055",
	"#555555",
	"#5500AA",
	"#5555AA",
	"#5500FF",
	"#5555FF",
	"#AA0000",
	"#AA5500",
	"#AA0055",
	"#AA5555",
	"#AA00AA",
	"#AA55AA",
	"#AA00FF",
	"#AA55FF",
	"#FF0000",
	"#FF5500",
	"#FF0055",
	"#FF5555",
	"#FF00AA",
	"#FF55AA",
	"#FF00FF",
	"#FF55FF",
	"#55AA00",
	"#55FF00",
	"#55AA55",
	"#55FF55",
	"#55AAAA",
	"#55FFAA",
	"#55AAFF",
	"#55FFFF",
	"#AAAA00",
	"#AAFF00",
	"#AAAA55",
	"#AAFF55",
	"#AAAAAA",
	"#AAFFAA",
	"#AAAAFF",
	"#AAFFFF",
	"#FFAA00",
	"#FFFF00",
	"#FFAA55",
	"#FFFF55",
	"#FFAAAA",
	"#FFFFAA",
	"#FFAAFF",
	"#FFFFFF",
	"#000000",
	"#232323",
	"#464646",
	"#696969",
	"#8C8C8C",
	"#AFAFAF",
	"#D2D2D2",
	"#F5F5F5",
  }
  
local function move_item(item, pos, inv, digger)
  if not (digger and digger:is_player()) then return end
	local creative = minetest.is_creative_enabled(digger:get_player_name())
	if inv:room_for_item("main", item)
	  and (not creative or not inv:contains_item("main", item, true)) then
		inv:add_item("main", item)
	elseif not creative then
		minetest.item_drop(ItemStack(item), digger, pos)
	end
	minetest.remove_node(pos)
end

function color.on_dig(pos, node, digger)
	if not digger then return end
	local playername = digger:get_player_name()
	if minetest.is_protected(pos, playername) then
		return
	end

	local oldparam2 = minetest.get_node(pos).param2
	local def = minetest.registered_items[node.name]
	local inv = digger:get_inventory()
	move_item(node.name, pos, inv, digger)
end
  

minetest.register_chatcommand("ta_color", {
	description = minetest.formspec_escape(
			"Output the color palette and the numbers for Lua/Beduino color commands"),

	func = function(name, param)
		local tbl = {}
		if COLORED then
			tbl[1] = "size[14,7]"
			tbl[2] = "background[0,0;14,7;unifieddyes_palette_extended.png]"
			for i = 0, 10 do
				local y = i * 0.64
				tbl[#tbl + 1] = "label[0," .. y .. ";" .. (i * 24 +  0) .. "]"
				tbl[#tbl + 1] = "label[7," .. y .. ";" .. (i * 24 + 12) .. "]"
			end
		else
			tbl[1] = "size[10,7.5]"
			tbl[2] = "background[0,0;10,7.5;techage_palette256.png]"
			for i = 0, 13 do
				local y = i * 0.5
				tbl[#tbl + 1] = "label[0," .. y .. ";" .. (i * 18 + 0) .. "]"
				tbl[#tbl + 1] = "label[5," .. y .. ";" .. (i * 18 + 9) .. "]"
			end
		end
		minetest.show_formspec(name, ";techage:color_form", table.concat(tbl, ""))
		return true
    end
})

minetest.register_chatcommand("ta_color64", {
	description = minetest.formspec_escape(
			"Output the color palette and the numbers for Techage displays"),

	func = function(name, param)
		local tbl = {}
		tbl[1] = "size[8,8]"
		tbl[2] = "background[0,0;8,8;techage_palette64.png]"
		for i = 0, 7 do
			local y = i + 0.2
			tbl[#tbl + 1] = "label[0.2," .. y .. ";" .. (i * 8 + 0) .. "]"
			tbl[#tbl + 1] = "label[4.2," .. y .. ";" .. (i * 8 + 4) .. "]"
		end
		minetest.show_formspec(name, ";techage:color_form", table.concat(tbl, ""))
		return true
    end
})

-- Register callback
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "techage:color_form" then
        return false
    end
    return true
end)



techage.color = color
