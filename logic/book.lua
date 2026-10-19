--[[

	TechAge
	=======

	Copyright (C) 2024 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Book

	A placeable book (looking like a flat lying book) with a title and two text
	tabs: "Numbers" (filled by the TechAge programmer) and "Notes" (own notes).
	The save button is only shown to the owner. Title and content are preserved
	when the book is dug and placed again.

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local esc = minetest.formspec_escape

local MAX_TEXT_SIZE = 10000
local MAX_TITLE_SIZE = 80

local BookOpen = {}        -- player_name -> {pos = pos, tab = tab}

local function infotext_for(title)
	if title ~= nil and title ~= "" then
		return S("TA4 Book") .. ": " .. title
	end
	return S("TA4 Book")
end

local function book_description(title)
	if title ~= nil and title ~= "" then
		return title
	end
	return S("TA4 Book")
end

local function sanitize(s)
	s = s:sub(1, MAX_TEXT_SIZE)
	s = s:gsub("\r\n", "\n"):gsub("\r", "\n")
	s = s:gsub("[%z\1-\8\11-\31\127]", "") -- keep \t and \n
	return s
end

local function sanitize_title(s)
	s = s:sub(1, MAX_TITLE_SIZE)
	s = s:gsub("[\r\n]+", " ")
	s = s:gsub("[%z\1-\8\11-\31\127]", "")
	return s
end

local function formspec(meta, name, tab)
	local is_owner = (meta:get_string("owner") == name)
	local fs = "size[8,8]" ..
		"tabheader[0.5,0;book_tabs;" ..
			esc(S("Numbers")) .. "," .. esc(S("Notes")) .. ";" ..
			tostring(tab) .. ";false;false]" ..
		"field[0.5,1.0;7.0,0.8;title;" .. esc(S("Title:")) .. ";" ..
			esc(meta:get_string("title")) .. "]"
	if tab == 2 then
		fs = fs .. "textarea[0.5,1.9;7.0,4.9;notes;;" ..
			esc(meta:get_string("notes")) .. "]"
	else
		fs = fs .. "textarea[0.5,1.9;7.0,4.9;numbers;;" ..
			esc(meta:get_string("numbers")) .. "]"
	end
	if is_owner then
		fs = fs .. "button_exit[2.5,7.0;3,0.8;save;" .. esc(S("Save")) .. "]"
	else
		fs = fs .. "button_exit[2.5,7.0;3,0.8;close;" .. esc(S("Close")) .. "]"
	end
	return fs
end

local function show_book(pos, player, tab)
	local name = player:get_player_name()
	local meta = M(pos)
	if meta:get_string("owner") == "" then
		meta:set_string("owner", name)
	end
	tab = tab or 1
	BookOpen[name] = {pos = pos, tab = tab}
	minetest.show_formspec(name, "techage:ta4_book", formspec(meta, name, tab))
end

local function persist(meta, fields)
	if fields.title ~= nil then
		meta:set_string("title", sanitize_title(fields.title))
	end
	if fields.numbers ~= nil then
		meta:set_string("numbers", sanitize(fields.numbers))
	end
	if fields.notes ~= nil then
		meta:set_string("notes", sanitize(fields.notes))
	end
	meta:set_string("infotext", infotext_for(meta:get_string("title")))
end

-- Called by the TechAge programmer (left click).
-- Appends the collected numbers as a new line at the end of the "Numbers" tab.
local function techage_set_numbers(pos, numbers, player_name)
	if numbers == nil or numbers == "" then
		return false
	end
	local meta = M(pos)
	local text = meta:get_string("numbers")
	if text ~= "" then
		text = text .. "\n" .. numbers
	else
		text = numbers
	end
	meta:set_string("numbers", text:sub(1, MAX_TEXT_SIZE))
	return true
end

minetest.register_node("techage:ta4_book", {
	description = S("TA4 Book"),
	inventory_image = "default_book.png",
	wield_image = "techage_ta4_book.png",
	tiles = {
		-- up, down, right, left, back, front
		"techage_ta4_book.png",
		"techage_ta4_book.png^[transformFX",
		"techage_ta4_book_side.png^[transformR270",
		"techage_ta4_book_side.png^[transformR90",
		"techage_ta4_book_side.png^[transformFX",
		"techage_ta4_book_side.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.rotate_simple,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {-3/16, -8/16, -4/16, 3/16, -6/16, 4/16},
	},
	selection_box = {
		type = "fixed",
		fixed = {-3/16, -8/16, -4/16, 3/16, -6/16, 4/16},
	},
	groups = {choppy=2, cracky=2, crumbly=2, book=1, flammable=3},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		local title, numbers, notes = "", "", ""
		if itemstack then
			local imeta = itemstack:get_meta()
			title = imeta:get_string("title")
			numbers = imeta:get_string("numbers")
			notes = imeta:get_string("notes")
		end
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("title", title)
		meta:set_string("numbers", numbers)
		meta:set_string("notes", notes)
		meta:set_string("infotext", infotext_for(title))
	end,

	preserve_metadata = function(pos, oldnode, oldmetadata, drops)
		if drops[1] then
			local meta = M(pos)
			local title = meta:get_string("title")
			local imeta = drops[1]:get_meta()
			imeta:set_string("title", title)
			imeta:set_string("numbers", meta:get_string("numbers"))
			imeta:set_string("notes", meta:get_string("notes"))
			imeta:set_string("description", book_description(title))
		end
	end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker then
			show_book(pos, clicker)
		end
	end,

	techage_set_numbers = techage_set_numbers,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "techage:ta4_book" then
		return
	end
	local name = player:get_player_name()
	local info = BookOpen[name]
	if not info then
		return
	end
	local pos = info.pos
	if minetest.get_node(pos).name ~= "techage:ta4_book" then
		BookOpen[name] = nil
		return
	end

	local meta = M(pos)
	local owner = meta:get_string("owner")

	if fields.quit then
		BookOpen[name] = nil
	end

	-- only the owner may modify the book; persist on save or tab switch
	if owner == name and (fields.save or fields.book_tabs) then
		persist(meta, fields)
	end

	if fields.book_tabs then
		show_book(pos, player, tonumber(fields.book_tabs) or 1)
		return
	end

	if fields.save then
		meta:set_string("infotext", infotext_for(meta:get_string("title")))
		return
	end
end)

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta4_book",
	recipe = {"default:book", "techage:ta4_wlanchip"},
})
