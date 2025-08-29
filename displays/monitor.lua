--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 CRT Monitor

]]--

local S = techage.S
local M = minetest.get_meta

local MENU = {
	{
		type = "dropdown",
		choices = "16x8,20x10,24x12,28x14,32x16,36x18,40x20",
		name = "resolution",
		label = S("Resolution"),
		tooltip = S("Select resolution of the monitor in characters x lines"),
		default = "8",
		values = {8,10,12,14,16,18,20},
	},
	{
		type = "dropdown",
		choices = "green,amber,yellow,white",
		name = "color",
		label = S("Color"),
		tooltip = S("Select color of the screen text"),
		default = "#2DD204",
		values = {"#2DD204","#F8C800","#DFD700","#CCCCCC"},
	},
}

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
	mem.ticks = mem.ticks or 0
	if mem.ticks > 0 then
		lcdlib.update_entities(pos)
		mem.ticks = mem.ticks - 1
	end
	return true
end

minetest.register_node("techage:ta3_monitor", {
	description = S("TA3 CRT Monitor"),
	tiles = {-- up, down, right, left, back, front
		'techage_monitor_top.png',
		'techage_monitor_top.png',
		'techage_monitor_side.png^[transformFX',
		'techage_monitor_side.png',
		'techage_monitor_back.png',
		'techage_monitor_front.png',
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -15/32,  16/32, 16/32,  8/32},
			{-10/32, -10/32,   8/32,  10/32, 10/32, 12/32},
		},
	},
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	light_source = 8,
	ta3_formspec = MENU,
	ta_after_formspec = function(pos, fields, playername)
		if fields.save then
			lcdlib.update_entities(pos)
			local resolution = M(pos):get_int("resolution")
			local cycle_time = resolution * resolution / 64
			print("cycle_time =", cycle_time)
			minetest.get_node_timer(pos):start(cycle_time)
		end
	end,

	display_entities = {
		["techage:monitor_entity"] = { 
			depth = -0.48,
			yoffs = 0.025,
			size = {x=0.90, y=0.90},
			on_display_update = update
		},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, "techage:ta3_monitor")
		local meta = M(pos)
		meta:set_string("number", number)
		meta:set_int("resolution", 8)
		meta:set_string("color", "#33FF00")
		meta:set_string("infotext", S("TA3 CRT Monitor no:") .. " " .. number)
		local nvm = techage.get_nvm(pos)
		nvm.text = {"My", "Techage","TA3", "CRT Monitor", "No: " .. number}
		lcdlib.update_entities(pos)
		minetest.get_node_timer(pos):start(1)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	on_timer = on_timer,
	on_destruct = lcdlib.on_destruct,
	on_rotate = lcdlib.on_rotate,
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = "techage:ta3_monitor",
	recipe = {
		{"", "", ""},
		{"techage:basalt_glass_thin", "dye:green", ""},
		{"techage:vacuum_tube", "default:copper_ingot", "techage:vacuum_tube"},
	},
})

local function add_line(pos, payload, cycle_time)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	local num_rows = M(pos):get_int("resolution") or 8
	nvm.text = nvm.text or {}
	mem.ticks = mem.ticks or 0
	local str = tostring(payload) or "oops"

	if mem.ticks == 0 then
		mem.ticks = cycle_time
	end

	while #nvm.text >= num_rows do
		table.remove(nvm.text, 1)
	end
	table.insert(nvm.text, str)
end

local function write_row(pos, payload, cycle_time, beduino)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	local num_rows = M(pos):get_int("resolution") or 8
	local str, row

	nvm.text = nvm.text or {}
	mem.ticks = mem.ticks or 0

	if beduino or type(payload) == "string" then
		-- split string into row and text on the first blank
		words = string.split(payload, " ", false, 1, false)
		row = tonumber(words[1] or "1") or 1
		str = words[2] or "oops"
	else
		str = tostring(payload.get("str")) or "oops"
		row = tonumber(payload.get("row")) or 1
	end

	if mem.ticks == 0 then
		mem.ticks = cycle_time
	end

	if row < 1 then row = 1 end
	if row > num_rows then row = num_rows end

	while #nvm.text < row do
		table.insert(nvm.text, "")
	end
	nvm.text[row] = str
end

local function clear_screen(pos, cycle_time)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.ticks = mem.ticks or 0

	if mem.ticks == 0 then
		mem.ticks = cycle_time
	end

	nvm.text = {}
end

techage.register_node({"techage:ta3_monitor"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "add" then  -- add one line and scroll if necessary
			add_line(pos, payload, 1)
		elseif topic == "set" then  -- overwrite the given row
			write_row(pos, payload, 1)
		elseif topic == "clear" then  -- clear the screen
			clear_screen(pos, 1)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 67 then  -- add one line and scroll if necessary
			add_line(pos, payload, 1)
		elseif topic == 68 then  -- overwrite the given row
			write_row(pos, payload, 1, true)
		elseif topic == 17 then  -- clear the screen
			clear_screen(pos, 1)
		else
			return 2
		end
		return 0
	end,
	on_node_load = function(pos)
		lcdlib.update_entities(pos)
	end,
})

lcdlib.register_display_entity("techage:monitor_entity")
