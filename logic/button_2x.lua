--[[

	TechAge
	=======

	Copyright (C) 2017-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Logic twofold button

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local function get_button_num(pos, clicker, pointed_thing)
	-- use the node behind the button to get better results
	if clicker and pointed_thing then
		local offs = vector.subtract(pointed_thing.under, pointed_thing.above)
		pointed_thing.under = vector.add(pointed_thing.under, offs)
		pointed_thing.above = vector.add(pointed_thing.above, offs)
		local pos1 = minetest.pointed_thing_to_face_pos(clicker, pointed_thing)
		local y = pos1.y - pos.y

		if y > 0.03 then
			return 1
		elseif y < -0.03 then
			return 2
		end
	end
end

local WRENCH_MENU = {
	{
		type = "dropdown",
		choices = "button,switch",
		name = "type",
		label = S("Type"),
		tooltip = S("Momentary button or on/off switch"),
		default = "1",
	},
	{
		type = "ascii",
		name = "label1",
		label = S("Label") .. " 1",
		tooltip = S("Label for the button"),
		default = "1",
	},
	{
		type = "numbers",
		name = "dest_number1",
		label = S("Number") .. " 1",
		tooltip = S("Destination block number"),
		default = "",
	},
	{
		type = "ascii",
		name = "command1",
		label = S("Command") .. " 1",
		tooltip = S("Command to be sent (ignored for switches)"),
		default = "1",
	},
	{
		type = "ascii",
		name = "label2",
		label = S("Label") .. " 2",
		tooltip = S("Label for the button"),
		default = "1",
	},
	{
		type = "numbers",
		name = "dest_number2",
		label = S("Number") .. " 2",
		tooltip = S("Destination block number"),
		default = "",
	},
	{
		type = "ascii",
		name = "command2",
		label = S("Command") .. " 2",
		tooltip = S("Command to be sent (ignored for switches)"),
		default = "2",
	},
	{
		type = "dropdown",
		choices = "private,protected,public",
		name = "access",
		label = S("Access"),
		tooltip = S("Button protection"),
		default = "8",
	},
}

local function send_cmnd(pos, num, cmd)
	local meta = M(pos)
	local own_num = meta:get_string("node_number")
	local dest = meta:get_string("dest_number" .. num)
	local command, payload = cmd, nil
	if not cmd then
		local s = meta:get_string("command" .. num)
		command, payload = unpack(string.split(s, " ", false, 1))
	end
	local owner = meta:get_string("owner")
	if techage.check_numbers(dest, owner) then
		techage.send_multi(own_num, dest, command, payload)
	end
end

local function button_update(pos, objref)
	local meta = M(pos)
	pos = vector.round(pos)
	local nvm = techage.get_nvm(pos)
	nvm.button = nvm.button or {}
	local tbl = {" ", " ", meta:get_string("label1"), " ",  meta:get_string("label2")}
	local text = "<      " .. table.concat(tbl, "\n<      ")
	local texture = lcdlib.make_multiline_texture("default", text, 96, 96, 7, "top", "#000", 6)

	if nvm.button[1] then
		texture = texture .. "^techage_smartline_button_4x_on2.png"
	end
	if nvm.button[2] then
		texture = texture .. "^techage_smartline_button_4x_on3.png"
	end
	objref:set_properties({ textures = {texture}, visual_size = {x=1, y=1} })
end

local function switch_off(pos, num)
	local nvm = techage.get_nvm(pos)
	nvm.button = nvm.button or {}
	nvm.button[num] = nil
	lcdlib.update_entities(pos)
end

local function switch_on(pos, num)
	local nvm = techage.get_nvm(pos)
	nvm.button = nvm.button or {}
	nvm.button[num] = true
	lcdlib.update_entities(pos)
end

local lcd_box = {-8/16, -4/16, 7.75/16, 8/16, 4/16, 8/16}

local function can_access(pos, player)
	local meta = M(pos)
	local playername = player:get_player_name()
	local access = meta:get_string("access")
	local owner = meta:get_string("owner")
	local protected = minetest.is_protected(pos, playername)

	if access == "private" and playername ~= owner then
		return false
	elseif access == "protected" and protected then
		return false
	end
	return true
end

minetest.register_node("techage:ta4_button_2x", {
	description = S("TA4 2x Button"),
	inventory_image = 'techage_smartline_button_2x.png',
	tiles = {'techage_smartline_button_2x.png'},
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
			on_display_update = button_update},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, "techage:ta4_button_2x")
		local meta = minetest.get_meta(pos)
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", "TA4 2x Button " .. number)
		meta:set_string("type", "button")
		meta:set_string("label1", "B1")
		meta:set_string("label2", "B2")
		lcdlib.update_entities(pos)
	end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker and clicker:is_player() then
			-- Check access settings
			if not can_access(pos, clicker) then
				return
			end

			local num = get_button_num(pos, clicker, pointed_thing)
			if num then
				local typ = M(pos):get_string("type")
				if typ == "switch" then
					local nvm = techage.get_nvm(pos)
					nvm.button = nvm.button or {}
					if nvm.button[num] then
						switch_off(pos, num)
						send_cmnd(pos, num, "off")
					else
						switch_on(pos, num)
						send_cmnd(pos, num, "on")
					end
				else
					switch_on(pos, num)
					send_cmnd(pos, num)
					minetest.after(0.5, switch_off, pos, num)
				end
				minetest.sound_play("techage_button", {
					pos = pos,
					gain = 0.5,
					max_hear_distance = 5,
				})
			end
		end
	end,

	ta_after_formspec = function(pos, fields, playername)
		lcdlib.update_entities(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
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

minetest.register_craft({
	output = "techage:ta4_button_2x",
	recipe = {
		{"", "", ""},
		{"", "techage:ta4_button_off", "techage:ta4_button_off"},
		{"", "", ""},
	},
})
