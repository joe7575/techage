--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Logic twofold signal lamp

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local OFF   = 0
local GREEN = 1
local AMBER = 2
local RED   = 3

local WRENCH_MENU = {
	{
		type = "ascii",
		name = "label1",
		label = S("Label") .. " 1",
		tooltip = S("Label for the lamp"),
		default = "1",
	},
	{
		type = "ascii",
		name = "label2",
		label = S("Label") .. " 2",
		tooltip = S("Label for the lamp"),
		default = "2",
	},
}

local function lamp_update(pos, objref)
	local meta = M(pos)
	pos = vector.round(pos)
	local nvm = techage.get_nvm(pos)
	nvm.lamp = nvm.lamp or {}
	local tbl = {" ", " ", meta:get_string("label1"), " ",  meta:get_string("label2")}
	local text = "<      " .. table.concat(tbl, "\n<      ")
	local texture = lcdlib.make_multiline_texture("default", text, 96, 96, 7, "top", "#000", 6)

	if nvm.lamp[1] == RED then
		texture = texture .. "^techage_smartline_signal_red2.png"
	elseif nvm.lamp[1] == GREEN then
		texture = texture .. "^techage_smartline_signal_green2.png"
	elseif nvm.lamp[1] == AMBER then
		texture = texture .. "^techage_smartline_signal_amber2.png"
	end

	if nvm.lamp[2] == RED then
		texture = texture .. "^techage_smartline_signal_red3.png"
	elseif nvm.lamp[2] == GREEN then
		texture = texture .. "^techage_smartline_signal_green3.png"
	elseif nvm.lamp[2] == AMBER then
		texture = texture .. "^techage_smartline_signal_amber3.png"
	end

	objref:set_properties({ textures = {texture}, visual_size = {x=1, y=1} })
end

local lcd_box = {-8/16, -4/16, 7.75/16, 8/16, 4/16, 8/16}

minetest.register_node("techage:ta4_signallamp_2x", {
	description = S("TA4 2x Signal Lamp"),
	inventory_image = 'techage_smartline_signal_2x.png^techage_smartline_signal_green2.png^techage_smartline_signal_amber3.png',
	tiles = {'techage_smartline_signal_2x.png'},
	drawtype = "nodebox",
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = lcd_box,
	},
	light_source = 6,

	display_entities = {
		["techage:display_entity"] = { depth = 0.48,
			on_display_update = lamp_update},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, "techage:ta4_signallamp_2x")
		local meta = minetest.get_meta(pos)
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA4 2x Signal Lamp") .. " " .. number)
		local nvm = techage.get_nvm(pos)
		nvm.lamp = {}
		lcdlib.update_entities(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	ta_after_formspec = function(pos, fields, playername)
		lcdlib.update_entities(pos)
	end,

	ta3_formspec = WRENCH_MENU,
	on_place = lcdlib.on_place,
	on_construct = lcdlib.on_construct,
	on_destruct = lcdlib.on_destruct,
	on_rotate = lcdlib.on_rotate,
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

techage.register_node({"techage:ta4_signallamp_2x"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		nvm.lamp = nvm.lamp or {}
		if topic == "green" then
			local num = math.min(tonumber(payload) or 0, 2)
			nvm.lamp[num] = GREEN
			lcdlib.update_entities(pos)
		elseif topic == "amber" then
			local num = math.min(tonumber(payload) or 0, 2)
			nvm.lamp[num] = AMBER
			lcdlib.update_entities(pos)
		elseif topic == "red" then
			local num = math.min(tonumber(payload) or 0, 2)
			nvm.lamp[num] = RED
			lcdlib.update_entities(pos)
		elseif topic == "off" then
			local num = math.min(tonumber(payload) or 0, 2)
			nvm.lamp[num] = OFF
			lcdlib.update_entities(pos)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		nvm.lamp = nvm.lamp or {}
		if topic == 3 then  -- Signal Lamp
			local num   = math.min(payload[1] or 1, 2)
			local color = math.min(payload[2] or 0, 3)
			nvm.lamp[num] = color
			lcdlib.update_entities(pos)
			return 0
		else
			return 2
		end
	end,
})

minetest.register_craft({
	output = "techage:ta4_signallamp_2x",
	recipe = {
		{"", "techage:aluminum", "dye:blue"},
		{"", "default:glass", "techage:ta4_wlanchip"},
		{"", "techage:ta4_leds", "techage:ta4_leds"},
	},
})
