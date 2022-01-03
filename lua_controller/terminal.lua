--[[

	Techage
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	terminal.lua:

]]--

local HELP = [[#### TA4 Lua Controller Terminal ####

Send commands to your Controller
and output text messages from your
Controller to the Terminal.

Commands can have up to 80 characters.
Local commands:
- clear    = clear screen
- help     = this message
- pub      = switch to public use
- priv      = switch to private use
Global commands:
- send <num> on/off  = send on/off event
- msg <num> <text>    = send a text message

For more help:
https://github.com/joe7575/techage/wiki

]]

local function formspec1()
	return "size[6,4]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"field[0.5,1;5,1;number;TA4 Lua Controller number:;]" ..
	"button_exit[1.5,2.5;2,1;exit;Save]"
end

local function formspec2(meta)
	local output = meta:get_string("output")
	output = minetest.formspec_escape(output)
	output = output:gsub("\n", ",")
	return "size[9,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[table,field;font=mono]"..
	"table[0.1,0.1;8.6,6.6;output;"..output..";200]"..
	"field[0.5,7.6;6,1;cmnd;Enter command;]" ..
	"field_close_on_enter[cmnd;false]"..
	"button[6.7,7.3;2,1;ok;Enter]"
end

local function output(pos, text)
	local meta = minetest.get_meta(pos)
	text = meta:get_string("output") .. "\n" .. (text or "")
	text = text:sub(-500,-1)
	meta:set_string("output", text)
	meta:set_string("formspec", formspec2(meta))

end

local function command(pos, cmnd, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if cmnd then
		cmnd = cmnd:sub(1,80)

		if cmnd == "clear" then
			meta:set_string("output", "")
			meta:set_string("formspec", formspec2(meta))
		elseif cmnd == "help" then
			local meta = minetest.get_meta(pos)
			meta:set_string("output", HELP)
			meta:set_string("formspec", formspec2(meta))
		elseif cmnd == "pub" and owner == player then
			meta:set_int("public", 1)
			--output(pos, player..":$ "..cmnd)
			output(pos, "> "..cmnd)
			output(pos, "Switched to public use!")
		elseif cmnd == "priv" and owner == player then
			meta:set_int("public", 0)
			--output(pos, player..":$ "..cmnd)
			output(pos, "> "..cmnd)
			output(pos, "Switched to private use!")
		elseif meta:get_int("public") == 1 or owner == player then
			-- send <num> on/off
			local num, topic = cmnd:match('^send%s+([0-9]+)%s+([onff]+)$')
			if num and topic then
				local own_number = meta:get_string("own_number")
				if techage.lua_ctlr.not_protected(owner, num) then
					--output(pos, player..":$ send "..num.." "..topic)
					output(pos, "> send "..num.." "..topic)
					techage.send_single(own_number, num, topic, nil)
					return
				end
			end
			-- msg <num> <text>
			local num, text = cmnd:match('^msg%s+([0-9]+)%s+(.+)$')
			if num and text then
				local own_number = meta:get_string("own_number")
				if techage.lua_ctlr.not_protected(owner, num) then
					--output(pos, player..":$ msg "..num.." "..text)
					output(pos, "> msg "..num.." "..text)
					techage.send_single(own_number, num, "msg", text)
					return
				end
			end
			local number = meta:get_string("number")
			local own_number = meta:get_string("own_number")
			if techage.lua_ctlr.not_protected(owner, number) then
				--output(pos, player..":$ "..cmnd)
				output(pos, "> "..cmnd)
				techage.send_single(own_number, number, "term", cmnd)
			end
		end
	end
end

minetest.register_node("techage:ta4_terminal", {
	description = "TA4 Lua Controller Terminal",
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
		meta:set_string("own_number", number)
		meta:set_string("formspec", formspec1())
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", "TA4 Lua Controller Terminal "..number..": not connected")
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = minetest.get_meta(pos)
		if fields.number and fields.number ~= "" then
			local owner = meta:get_string("owner")
			if techage.check_numbers(fields.number, owner) then
				meta:set_string("number", fields.number)
				local own_number = meta:get_string("own_number")
				meta:set_string("infotext", "TA4 Lua Controller Terminal "..own_number..": connected with "..fields.number)
				meta:set_string("formspec", formspec2(meta))
			end
		elseif (fields.key_enter == "true" or fields.ok == "Enter") and fields.cmnd ~= "" then
			command(pos, fields.cmnd, player:get_player_name())
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
		elseif topic == "msg" then
			output(pos, tostring(payload.src)..": "..tostring(payload.text))
			return true
		end
	end,
})

techage.lua_ctlr.register_function("get_term", {
	cmnd = function(self)
		return techage.lua_ctlr.get_command(self.meta.number)
	end,
	help = ' $get_term()  --> text string or nil\n'..
		' Read an entered string (command) from the Terminal.\n'..
		' example: s = $get_term()\n'..
		" The Terminal has to be connected to the controller."
})

techage.lua_ctlr.register_action("put_term", {
	cmnd = function(self, num, text)
		text = tostring(text or "")
		if techage.lua_ctlr.not_protected(self.meta.owner, num) then
			techage.send_single(self.meta.number, num, "term", text)
		end
	end,
	help = " $put_term(num, text)\n"..
		' Send a text line to the terminal with number "num".\n'..
		' example: $put_term("0123", "Hello "..name)'
})

techage.lua_ctlr.register_function("get_msg", {
	cmnd = function(self, raw)
		local msg = techage.lua_ctlr.get_msg(self.meta.number)
		if msg then
			local data = msg.data
			if not raw then
				data = tostring(data or "")
			end
			return msg.src, data
		end
	end,
	help = ' $get_msg([raw])  --> number and any value or nil\n'..
		' If the optional `raw` parameter is not set or false,\n'..
		' the second return value is guaranteed to be a string.\n'..
		' Read a received messages. Number is the node\n'..
		' number of the sender.\n'..
		' example: num,msg = $get_msg().'
})

techage.lua_ctlr.register_action("send_msg", {
	cmnd = function(self, num, data)
		if techage.lua_ctlr.not_protected(self.meta.owner, num) then
			techage.send_single(self.meta.number, num, "msg", data)
		end
	end,
	help = " $send_msg(num, data)\n"..
		' Send a message to the controller with number "num".\n'..
		' example: $send_msg("0123", "test")'
})
