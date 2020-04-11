--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	ICTA Controller - Display

]]--
 
local NUM_ROWS = 5 
local RADIUS = 6
local Param2ToFacedir = {[0] = 0, 0, 3, 1, 2, 0}
 
lcdlib.register_display_entity("techage:display_entity")
lcdlib.register_display_entity("techage:display_entityXL")

local function display_update(pos, objref) 
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("text") or ""
	text = string.gsub(text, "|", " \n")
	local texture = lcdlib.make_multiline_texture(
		"default", text,
		70, 70, NUM_ROWS, "top", "#000")
	objref:set_properties({ textures = {texture},
							visual_size = {x=0.94, y=0.94} })
end

local function display_updateXL(pos, objref) 
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("text") or ""
	text = string.gsub(text, "|", " \n")
	local texture = lcdlib.make_multiline_texture(
		"default", text,
		126, 70, NUM_ROWS, "top", "#000")
	objref:set_properties({ textures = {texture},
							visual_size = {x=0.94*1.9, y=0.94} })
end

local function on_timer(pos)
	local node = minetest.get_node(pos) 
	-- check if display is loaded and a player in front of the display
	if node.name == "techage:ta4_display" or node.name == "techage:ta4_displayXL" then 
		local dir = minetest.facedir_to_dir(Param2ToFacedir[node.param2 % 6])
		local pos2 = vector.add(pos, vector.multiply(dir, RADIUS))
		for _, obj in pairs(minetest.get_objects_inside_radius(pos2, RADIUS)) do
			if obj:is_player() then
				lcdlib.update_entities(pos)
				break
			end
		end
	end
	return false
end

local lcd_box = {
	type = "wallmounted",
	wall_top = {-8/16, 15/32, -8/16, 8/16, 8/16, 8/16}
}

minetest.register_node("techage:ta4_display", {
	description = "TA4 Display",
	inventory_image = 'techage_display_inventory.png',
	tiles = {"techage_display.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	node_box = lcd_box,
	selection_box = lcd_box,
	light_source = 6,
	
	display_entities = {
		["techage:display_entity"] = { depth = 0.42,
			on_display_update = display_update},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, "techage:ta4_display")
		local meta = minetest.get_meta(pos)
		meta:set_string("number", number)
		meta:set_string("text", "My\nTechage\nTA4\nDisplay\nNo: "..number)
		meta:set_int("startscreen", 1)
		lcdlib.update_entities(pos)
	end,

	after_dig_node = function(pos)
		techage.remove_node(pos)
	end,

	on_timer = on_timer,
	on_place = lcdlib.on_place,
	on_construct = lcdlib.on_construct,
	on_destruct = lcdlib.on_destruct,
	on_rotate = lcdlib.on_rotate,
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

local lcd_boxXL = {
	type = "fixed",
	fixed = {-0.9, -8/16, -8/16, 0.9, -15/32, 8/16}
}

minetest.register_node("techage:ta4_displayXL", {
	description = "TA4 Display XL",
	inventory_image = 'techage_display_inventoryXL.png',
	tiles = {"techage_displayXL.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	node_box = lcd_boxXL,
	selection_box = lcd_boxXL,
	light_source = 6,
	
	display_entities = {
		["techage:display_entityXL"] = { depth = 0.42,
			on_display_update = display_updateXL},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, "techage:ta4_displayXL")
		local meta = minetest.get_meta(pos)
		meta:set_string("number", number)
		meta:set_string("text", "My\nTechage\nTA4\nDisplay\nNo: "..number)
		meta:set_int("startscreen", 1)
		lcdlib.update_entities(pos)
	end,

	after_dig_node = function(pos)
		techage.remove_node(pos)
	end,

	on_timer = on_timer,
	on_place = lcdlib.on_place,
	on_construct = lcdlib.on_construct,
	on_destruct = lcdlib.on_destruct,
	on_rotate = lcdlib.on_rotate,
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})


minetest.register_craft({
	output = "techage:ta4_display",
	recipe = {
		{"", "", ""},
		{"techage:basalt_glass_thin", "dye:green", "techage:ta4_wlanchip"},
		{"", "default:copper_ingot", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_displayXL",
	recipe = {
		{"techage:ta4_display", "techage:ta4_display"},
		{"", ""},
	},
})

local function add_line(meta, payload)
	local text = meta:get_string("text")
	local rows
	if meta:get_int("startscreen") == 1 then
		rows = {}
		meta:set_int("startscreen", 0)
	else
		rows = string.split(text, "|")
	end
	while #rows >= NUM_ROWS do
		table.remove(rows, 1)
	end
	table.insert(rows, payload)
	text = table.concat(rows, "|")
	meta:set_string("text", text)
end

local function write_row(meta, payload)
	local text = meta:get_string("text")
	if type(payload) == "table" then
		local row = tonumber(payload.row) or 0
		if row > NUM_ROWS then row = NUM_ROWS end
		local str = payload.str or "oops"
		if row == 0 then
			meta:set_string("infotext", str)
			return 
		end
		local rows
		if meta:get_int("startscreen") == 1 then
			rows = {}
			meta:set_int("startscreen", 0)
		else
			rows = string.split(text, "|")
		end
		if #rows < NUM_ROWS then
			for i = #rows, NUM_ROWS do
				table.insert(rows, " ")
			end
		end
		rows[row] = str
		text = table.concat(rows, "|")
		meta:set_string("text", text)
	end
end

techage.register_node({"techage:ta4_display"}, {
	on_recv_message = function(pos, src, topic, payload)
		local timer = minetest.get_node_timer(pos)
		if topic == "add" then  -- add one line and scroll if necessary
			local meta = minetest.get_meta(pos)
			add_line(meta, payload)
			if not timer:is_started() then
				timer:start(1)
			end
		elseif topic == "set" then  -- overwrite the given row
			local meta = minetest.get_meta(pos)
			write_row(meta, payload)
			if not timer:is_started() then
				timer:start(1)
			end
		elseif topic == "clear" then  -- clear the screen
			local meta = minetest.get_meta(pos)
			meta:set_string("text", "")
			if not timer:is_started() then
				timer:start(1)
			end
		end
	end,
})		

techage.register_node({"techage:ta4_displayXL"}, {
	on_recv_message = function(pos, src, topic, payload)
		local timer = minetest.get_node_timer(pos)
		if topic == "add" then  -- add one line and scroll if necessary
			local meta = minetest.get_meta(pos)
			add_line(meta, payload)
			if not timer:is_started() then
				timer:start(2)
			end
		elseif topic == "set" then  -- overwrite the given row
			local meta = minetest.get_meta(pos)
			write_row(meta, payload)
			if not timer:is_started() then
				timer:start(2)
			end
		elseif topic == "clear" then  -- clear the screen
			local meta = minetest.get_meta(pos)
			meta:set_string("text", "")
			if not timer:is_started() then
				timer:start(2)
			end
		end
	end,
})		
