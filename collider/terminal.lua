--[[

	Techage
	=======

	Copyright (C) 2020-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Terminal

]]--

local M = minetest.get_meta
local S = techage.S

local STR_LEN = 80
local HELP = [[#### TA4 Terminal ####

Send commands to the connected machine
and output text messages from the
machine.

Commands can have up to 80 characters.
Local commands:
- clear          = clear screen
- help           = this message
- pub            = switch to public use
- priv           = switch to private use
- connect <num>  = connect the machine

All other commands are machine dependent.
]]

local function get_string(meta, num, default)
	local s = meta:get_string("bttn_text"..num)
	if not s or s == "" then
		return default
	end
	return s
end

local function formspec2(mem)
	mem.command = mem.command or ""
	mem.output = mem.output or ""
	local output = minetest.formspec_escape(mem.output)
	output = output:gsub("\n", ",")
	local command = minetest.formspec_escape(mem.command)
	local bttn_text1 = get_string(meta, 1, "User1")
	local bttn_text2 = get_string(meta, 2, "User2")
	local bttn_text3 = get_string(meta, 3, "User3")
	local bttn_text4 = get_string(meta, 4, "User4")
	local bttn_text5 = get_string(meta, 5, "User5")
	local bttn_text6 = get_string(meta, 6, "User6")
	local bttn_text7 = get_string(meta, 7, "User7")
	local bttn_text8 = get_string(meta, 8, "User8")
	local bttn_text9 = get_string(meta, 9, "User9")
	return "size[10,8]"..
		"style_type[table,field;font=mono]"..
		"button[0,0;3.3,1;bttn1;"..bttn_text1.."]button[3.3,0;3.3,1;bttn2;"..bttn_text2.."]button[6.6,0;3.3,1;bttn3;"..bttn_text3.."]"..
		"button[0,0.8;3.3,1;bttn4;"..bttn_text4.."]button[3.3,0.8;3.3,1;bttn5;"..bttn_text5.."]button[6.6,0.8;3.3,1;bttn6;"..bttn_text6.."]"..
		"button[0,1.6;3.3,1;bttn7;"..bttn_text7.."]button[3.3,1.6;3.3,1;bttn8;"..bttn_text8.."]button[6.6,1.6;3.3,1;bttn9;"..bttn_text9.."]"..
		"table[0,2.5;9.8,4.7;output;"..output..";200]"..
		"field[0.4,7.7;7.6,1;cmnd;;"..mem.command.."]" ..
		"field_close_on_enter[cmnd;false]"..
		"button[7.9,7.4;2,1;enter;"..S("Enter").."]"
end

local function output(pos, text)
	local mem = techage.get_mem(pos)
	mem.output = mem.output .. "\n" .. (text or "")
	mem.output = mem.output:sub(-500,-1)
	M(pos):set_string("formspec", formspec2(mem))
end

local function command(pos, mem, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if mem.command == "clear" then
		mem.output = ""
		mem.command = ""
		meta:set_string("formspec", formspec2(mem))
	elseif mem.command == "" then
		output(pos, ">")
		mem.command = ""
		meta:set_string("formspec", formspec2(mem))
	elseif mem.command == "help" then
		local meta = minetest.get_meta(pos)
		mem.output = HELP
		mem.command = ""
		meta:set_string("formspec", formspec2(mem))
	elseif mem.command == "pub" and owner == player then
		meta:set_int("public", 1)
		output(pos, "> "..mem.command)
		mem.command = ""
		output(pos, "Switched to public use!")
	elseif mem.command == "priv" and owner == player then
		meta:set_int("public", 0)
		output(pos, "> "..mem.command)
		mem.command = ""
		output(pos, "Switched to private use!")
	elseif meta:get_int("public") == 1 or owner == player then
		if mem.command == "clear" then
			mem.output =
			mem.command = ""
			meta:set_string("formspec", formspec2(mem))
		end
	end
end

minetest.register_node("techage:ta4_terminal", {
	description = "TA4 Collider Terminal",
	tiles = {
		-- up, down, right, left, back, front
		'techage_terminal1_top.png',
		'techage_terminal1_bottom.png',
		'techage_terminal1_side.png',
		'techage_terminal1_side.png',
		'techage_terminal1_bottom.png',
		"techage_terminal1_front.png",
	},
	drawtype = "nodebox",
	node_box = 	{
		type = "fixed",
		fixed = {
			{-12/32, -16/32,  -8/32,  12/32, -14/32, 12/32},
			{-12/32, -14/32,  12/32,  12/32,   6/32, 14/32},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-12/32, -16/32,  -8/32,  12/32, -14/32, 12/32},
			{-12/32, -14/32,  12/32,  12/32,   6/32, 14/32},
		},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, minetest.get_node(pos).name)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec1())
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA4 Collider Terminal") .. ": " .. S("not connected")
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = minetest.get_meta(pos)
		local mem = techage.get_mem(pos)
		if fields.number and fields.number ~= "" then
			local owner = meta:get_string("owner")
			if techage.check_numbers(fields.number, owner) then
				local own_number = meta:get_string("own_number")
				if techage.send_single(own_number, fields.number, "connect") == true then
					meta:set_string("number", fields.number)
					meta:set_string("infotext", S("TA4 Collider Terminal") .. ": " .. S("connected with") .. " " .. fields.number)
					meta:set_string("formspec", formspec2(mem))
				end
			end
		elseif (fields.enter or fields.key_enter_field) and fields.cmnd then
			mem.command = string.sub(fields.cmnd, 1, STR_LEN)
			command(pos, mem, player:get_player_name())
		elseif fields.key_up then
			mem.command = pdp13.historybuffer_priv(pos)
			meta:set_string("formspec", formspec2(mem))
		elseif fields.key_down then
			mem.command = pdp13.historybuffer_next(pos)
			meta:set_string("formspec", formspec2(mem))
		end
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techage:ta4_terminal",
	recipe = {
		{"", "techage:ta4_display", ""},
		{"dye:black", "techage:ta4_wlanchip", "default:copper_ingot"},
		{"", "techage:aluminum", ""},
	},
})

techage.register_node({"techage:ta4_terminal"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "term" then
			output(pos, payload)
			return true
		elseif topic == "clear" then
			local mem = techage.get_mem(pos)
			mem.output = ""
			mem.command = ""
			M(pos):set_string("formspec", formspec2(mem))
			return true
		end
	end,
})
