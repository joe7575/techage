--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Mono Displays

]]--

local S = techage.S
local M = minetest.get_meta
local color = techage.color
local DESCR = S("TA4 Display II")
local MENUL = {
	{
		type = "dropdown",
		choices = "16x8,20x10,24x12,28x14,32x16,36x18,40x20",
		name = "resolution",
		label = S("Resolution"),
		tooltip = S("Select resolution of the display in characters x lines"),
		default = "14",
		values = {8,10,12,14,16,18,20},
	},
	{
		type = "numbers",
		name = "colorno",
		label = S("Text color"),
		tooltip = S("Select color of the screen text (0..63)\nSee chat command '/ta_color64'"),
		default = "63",
	},
	{
		type = "numbers",
		name = "background",
		label = S("Background color"),
		tooltip = S("Select color of the display background (0..63)\nSee chat command '/ta_color64'"),
		default = "0",
	},
}

local MENUS = {
	{
		type = "numbers",
		name = "background",
		label = S("Background color"),
		tooltip = S("Select color of the display background (0..63)\nSee chat command '/ta_color64'"),
		default = "0",
	},
}

local function range(value, min, max)
	value = math.min(value, max)
	value = math.max(value, min)
	return value
end

local function update(pos, objref)
	pos = vector.round(pos)
	local nvm = techage.get_nvm(pos)
--	local t = core.get_us_time()
	lcdlib.on_mono_display_update(pos, objref, nvm.text or {})
--	t = core.get_us_time() - t
--	print("time =", t)
end

local function on_timer(pos)
	local mem = techage.get_mem(pos)
	if mem.update then
		lcdlib.update_entities(pos)
		mem.update = false
	end
	return true
end

local function register_display(name, description, inventory_image, tiles, node_box, display_entities)
	minetest.register_node(name, {
		description = description,
		inventory_image = inventory_image,
		tiles = tiles,
		drawtype = "nodebox",
		paramtype2 = "color4dir",
		palette = "techage_palette64.png",
		node_box = node_box,
		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		sunlight_propagates = true,
		light_source = 8,
		ta3_formspec = display_entities and MENUL or MENUS,
		ta_after_formspec = function(pos, fields, playername)
			if fields.save then
				-- Check if the colorno and background are in the range 0..63
				M(pos):set_int("colorno", range(M(pos):get_int("colorno"), 0, 63))
				M(pos):set_int("background", range(M(pos):get_int("background"), 0, 63))
				-- Set the background color of the display
				local background = M(pos):get_int("background")
				local node = minetest.get_node(pos)
				node.param2 = (node.param2 % 4) + background * 4
				minetest.swap_node(pos, node)
				-- Set the text color of the display
				local colorno = M(pos):get_int("colorno")
				M(pos):set_string("color", color.COLOR64[colorno + 1])
				lcdlib.update_entities(pos)
				-- Set the update time of the display
				local resolution = M(pos):get_int("resolution")
				local cycle_time = resolution * resolution / 64
				minetest.get_node_timer(pos):stop()
				minetest.get_node_timer(pos):start(cycle_time)
			end
		end,

		display_entities = display_entities,

		after_place_node = function(pos, placer)
			local node = minetest.get_node(pos)
			local ndef = minetest.registered_nodes[node.name]
			local meta = M(pos)
			if ndef.display_entities then
				local number = techage.add_node(pos, node.name)
				meta:set_string("number", number)
				meta:set_string("infotext", DESCR .. " " .. number)
				local nvm = techage.get_nvm(pos)
				nvm.text = {"My Techage", "TA4 Display II", "No: "..number}
				meta:set_int("resolution", 14)
				meta:set_string("color", "#F5F5F5")
				meta:set_int("colorno", 63)
				lcdlib.update_entities(pos)
			end
			meta:set_int("background", 4)
			node.param2 = (node.param2 % 4) + 4 * 4
			minetest.swap_node(pos, node)
			minetest.get_node_timer(pos):start(3)
		end,

		after_dig_node = function(pos, oldnode, oldmetadata)
			techage.remove_node(pos, oldnode, oldmetadata)
			techage.del_mem(pos)
		end,

		on_timer = on_timer,
		on_destruct = lcdlib.on_destruct,
		on_rotate = lcdlib.on_rotate,
		on_dig = color.on_dig,
		groups = {cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
	})
end

register_display(
	"techage:ta4_display2",
	DESCR,
	'techage_display2_inventory.png',
	{-- up, down, right, left, back, front
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_front.png',
	},
	{
		type = "fixed",
		fixed = {
			{-16/32, -16/32, 14/32, 16/32, 16/32, 16/32},
		},
	},
	{
		["techage:display2_entity"] = {
			depth = 0.43,
			yoffs = 0.000,
			size = {x=0.94, y=0.94},
			on_display_update = update
		},
	}
)

register_display(
	"techage:ta4_displayXXL",
	S("TA4 Display II XXL inside"),
	'techage_display2_inventory.png^techage_displayXXL_inventory.png',
	{-- up, down, right, left, back, front
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_front2.png',
	},
	{
		type = "fixed",
		fixed = {
			{-16/32, -16/32, 10/32, 16/32, 16/32, 16/32},
		},
	},
	{
		["techage:monitor_entity"] = {
			depth = 0.3,
			size = {x=2.8, y=2.8},
			on_display_update = update
		},
	}
)

register_display(
	"techage:ta4_displayXXL2",
	S("TA4 Display II XXL outside"),
	'techage_display2_inventory.png^techage_displayXXL_inventory.png',
	{-- up, down, right, left, back, front
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_side.png',
		'techage_display2_front2.png',
	},
	{
		type = "fixed",
		fixed = {
			{-16/32, -16/32, 10/32, 16/32, 16/32, 16/32},
		},
	},
	nil
)

minetest.register_craft({
	output = "techage:ta4_display2",
	recipe = {
		{"", "", ""},
		{"techage:basalt_glass_thin", "dye:black", "techage:ta4_leds"},
		{"default:copper_ingot", "techage:ta4_wlanchip", "basic_materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output = "techage:ta4_displayXXL2",
	recipe = {
		{"", "", ""},
		{"techage:basalt_glass_thin", "dye:black", "techage:ta4_leds"},
		{"default:copper_ingot", "", "basic_materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output = "techage:ta4_displayXXL",
	recipe = {
		{"", "", ""},
		{"techage:ta4_leds", "dye:black", "techage:basalt_glass_thin"},
		{"default:copper_ingot", "techage:ta4_wlanchip", "basic_materials:plastic_sheet"},
	},
})

local function add_line(pos, payload)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	local num_rows = M(pos):get_int("resolution") or 8
	nvm.text = nvm.text or {}
	local str = tostring(payload) or "oops"
	mem.update = true
	while #nvm.text >= num_rows do
		table.remove(nvm.text, 1)
	end
	table.insert(nvm.text, str)
end

local function write_row(pos, payload, beduino)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	local num_rows = M(pos):get_int("resolution") or 8
	local str, row
	nvm.text = nvm.text or {}

	if beduino or type(payload) == "string" then
		-- split string into row and text on the first blank
		words = string.split(payload, " ", false, 1, false)
		row = tonumber(words[1] or "1") or 1
		str = words[2] or "oops"
	else
		str = tostring(payload.get("str")) or "oops"
		row = tonumber(payload.get("row")) or 1
	end
	mem.update = true
	if row < 1 then row = 1 end
	if row > num_rows then row = num_rows end

	while #nvm.text < row do
		table.insert(nvm.text, "")
	end
	nvm.text[row] = str
end

local function clear_screen(pos)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.update = true
	nvm.text = {}
end

techage.register_node({"techage:ta4_display2", "techage:ta4_displayXXL"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "add" then  -- add one line and scroll if necessary
			add_line(pos, payload)
		elseif topic == "set" then  -- overwrite the given row
			write_row(pos, payload)
		elseif topic == "clear" then  -- clear the screen
			clear_screen(pos)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 67 then  -- add one line and scroll if necessary
			add_line(pos, payload)
		elseif topic == 68 then  -- overwrite the given row
			write_row(pos, payload, true)
		elseif topic == 17 then  -- clear the screen
			clear_screen(pos)
		else
			return 2
		end
		return 0
	end,
	on_node_load = function(pos)
		lcdlib.update_entities(pos)
	end,
})

lcdlib.register_display_entity("techage:display2_entity")
