--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Construction Guide

]]--



-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local S, NS = dofile(MP.."/intllib.lua")

local Recipes = {}
local ItemNames = {}
local RecipeList = {}
local PlanImages = {}
local NamesAsStr = ""

-- formspec images
local function plan(images)
	local tbl = {}
	if images == "none" then return "label[1,3;No plan available" end
	for y=1,#images do
		for x=1,#images[1] do
			local img = images[y][x] or false
			if img ~= false then
				local x_offs, y_offs = (x-1) * 1, (y-1) * 1 + 0.8
				tbl[#tbl+1] = "image["..x_offs..","..y_offs..";1,1;"..img..".png]"
			end
		end
	end
	return table.concat(tbl)
end	

local function formspec_help(idx)
	local bttn
	if ItemNames[idx] == "-" then
		bttn = ""
	elseif ItemNames[idx] == "plan" then
		bttn = "button[7.6,1;1,1;plan;"..S("Plan").."]"
	else
		bttn = "item_image[7.6,1;1,1;"..ItemNames[idx].."]"
	end
	return "size[9,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"item_image[7.6,0;1,1;techage:construction_board]"..
	bttn..
	"table[0.1,0;7,3;page;"..NamesAsStr..";"..idx.."]"..
	"textarea[0.3,3.7;9,6.2;help;"..S("Help")..":;"..Recipes[idx].."]"
end

local function formspec_plan(idx)
	return "size[9,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0,0;"..RecipeList[idx]..":]"..
	"button[8,0;1,0.8;back;<<]"..
	plan(PlanImages[idx])
end

local board_box = {
	type = "wallmounted",
	--wall_top = {-8/16, 15/32, -6/16, 8/16, 8/16, 6/16},
    --wall_bottom = {-8/16, 15/32, -6/16, 8/16, 8/16, 6/16},
    wall_side = {-16/32, -11/32, -16/32,   -15/32, 6/16, 8/16},
}

minetest.register_node("techage:construction_board", {
	description = S("TA Construction Board"),
	inventory_image = 'techage_constr_plan_inv.png',
	tiles = {"techage_constr_plan.png"},
	drawtype = "nodebox",
	node_box = board_box,
	selection_box = board_box,
	
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec_help(1))
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		print(dump(fields))
		local meta = minetest.get_meta(pos)
		local idx = meta:get_int("help_idx")
		idx = techage.range(idx, 1, #Recipes)
		if fields.plan then
			meta:set_string("formspec", formspec_plan(idx))
		elseif fields.back then
			meta:set_string("formspec", formspec_help(idx))
		elseif fields.page then
			local evt = minetest.explode_table_event(fields.page)
			if evt.type == "CHG" then
				local idx = tonumber(evt.row)
				idx = techage.range(idx, 1, #Recipes)
				meta:set_int("help_idx", idx)
				meta:set_string("formspec", formspec_help(idx))
			end
		end
	end,
	
	paramtype2 = "wallmounted",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:construction_board",
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"},
	},
})


function techage.register_help_page(name, text, item_name, images)
	RecipeList[#RecipeList+1] = name
	ItemNames[#ItemNames+1] = item_name or "plan"
	NamesAsStr = table.concat(RecipeList, ",    ") or ""
	Recipes[#Recipes+1] = text
	PlanImages[#PlanImages+1] = images or "none"
end

function techage.register_chap_page(name, text)
	RecipeList[#RecipeList+1] = name
	ItemNames[#ItemNames+1] = "-"
	NamesAsStr = table.concat(RecipeList, ",") or ""
	Recipes[#Recipes+1] = text
	PlanImages[#PlanImages+1] = "none"
end
