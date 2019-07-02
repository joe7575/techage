--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Construction Guide

]]--

local S = techage.S

local Categories = {}  -- ordered list of chapters
local EntryOrders = {} -- ordered entry lists of categories
local HelpPages = {}   -- help data as key/value table
local formspec_context = {}

local DUMMY = {
	name = "unknown", 
	text = "unknown",
	item_name = "-", 
	images = "none"
}

-- formspec list of entries
local function entries_as_string(player_name)
	local category = formspec_context[player_name].category or Categories[1]
	local tbl = {}
	for _,cat in ipairs(Categories) do
		if cat == category and not formspec_context[player_name].close_tree then
			tbl[#tbl+1] = minetest.formspec_escape("V  "..HelpPages[cat][cat].name)
			for _,item in ipairs(EntryOrders[category]) do
				if item ~= cat then
					local name = item
					if HelpPages[category][item] then
						name = HelpPages[category][item].name
					end
					tbl[#tbl+1] = minetest.formspec_escape("    +- "..name)
				end
			end
		else
			tbl[#tbl+1] = minetest.formspec_escape(">  "..HelpPages[cat][cat].name)
		end
	end
	formspec_context[player_name].list_len = #tbl
	return table.concat(tbl, ",") or ""
end

-- Translate given index into a HelpPage category and key
local function get_ref(player_name)
	local category = formspec_context[player_name].category or Categories[1]
	local index = formspec_context[player_name].index or 1
	index = techage.range(index, 1, formspec_context[player_name].list_len or 1)

	local offs = 0
	for idx1,cat in ipairs(Categories) do
		if idx1 + offs == index then
			formspec_context[player_name].category = cat
			formspec_context[player_name].index = idx1
			return cat, cat  -- category
		end
		if cat == category and not formspec_context[player_name].close_tree then
			for idx2,item in ipairs(EntryOrders[category]) do
				if idx1 + idx2 - 1 == index then
					formspec_context[player_name].category = cat
					formspec_context[player_name].index = index
					return cat, item  -- no category
				end
			end
			offs = #EntryOrders[category] - 1
		end
	end
	-- return any entry by default
	formspec_context[player_name].category = Categories[1]
	return Categories[1], Categories[1]
end

-- formspec images
local function plan(images)
	local tbl = {}
	if images == "none" then return "label[1,3;"..S("No plan available") end
	for y=1,#images do
		for x=1,#images[1] do
			local img = images[y][x] or false
			if img ~= false then
				local x_offs, y_offs = (x-1) * 1, (y-1) * 1 + 0.8
				tbl[#tbl+1] = "image["..x_offs..","..y_offs..";1,1;"..img.."]"
			end
		end
	end
	return table.concat(tbl)
end	

local function formspec_help(player_name)
	local bttn
	local cat, key = get_ref(player_name)
	local hdef = HelpPages[cat][key] or DUMMY
	local index = formspec_context[player_name].index or 1
	local box = "box[7.5,0.9;1,1.1;#BBBBBB]"

	if hdef.item_name == "-" then
		bttn = ""
	elseif hdef.item_name == "plan" then
		bttn = "button[7.6,1;1,1;plan;"..S("Plan").."]"
	else
		bttn = box.."item_image[7.6,1;1,1;"..hdef.item_name.."]"
	end
	return "size[9,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"item_image[7.6,0;1,1;techage:construction_board]"..
	bttn..
	"table[0.1,0;7,4;page;"..entries_as_string(player_name)..";"..index.."]"..
	"textarea[0.3,4.7;9,5.3;help;"..S("Help")..":;"..hdef.text.."]"..
	"box[0,4.75;8.775,4.45;#000000]"
end

local function formspec_plan(player_name)
	local cat, key = get_ref(player_name)
	local hdef = HelpPages[cat][key] or DUMMY
	return "size[9,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0,0;"..hdef.name..":]"..
	"button[8,0;1,0.8;back;<<]"..
	plan(hdef.images)
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
		local player_name = placer:get_player_name()
		formspec_context[player_name] = formspec_context[player_name] or {}
		meta:set_string("formspec", formspec_help(player_name))
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			return
		end
		local meta = minetest.get_meta(pos)
		formspec_context[player_name] = formspec_context[player_name] or {}
		if fields.plan then
			meta:set_string("formspec", formspec_plan(player_name))
		elseif fields.back then
			meta:set_string("formspec", formspec_help(player_name))
		elseif fields.page then
			local evt = minetest.explode_table_event(fields.page)
			if evt.type == "CHG" then
				local idx = tonumber(evt.row)
				idx = techage.range(idx, 1, formspec_context[player_name].list_len or 1)
				-- unfold/close the tree
				if formspec_context[player_name].index == idx then
					formspec_context[player_name].close_tree = not formspec_context[player_name].close_tree
				end
				formspec_context[player_name].index = idx
				meta:set_string("formspec", formspec_help(player_name))
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


function techage.register_entry_page(category, entry, name, text, item_name, images)
	if HelpPages[category] then
		HelpPages[category][entry] = {
			name = name, 
			text = text,
			item_name = item_name or "plan", 
			images = images or "none"
		}
	else
		minetest.log("error", "[techage] help category '"..category.."' does not exist!")
	end
end


function techage.register_category_page(category, name, text, item_name, entry_order, images)
	Categories[#Categories + 1] = category
	HelpPages[category] = {}
	techage.register_entry_page(category, category, name, text, item_name, images or "none")
	
	table.insert(entry_order, 1, category)
	EntryOrders[category] = entry_order
end

function techage.register_help_page(name, text, item_name, images)
end

function techage.register_chap_page(name, text, item_name)
end
