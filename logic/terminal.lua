--[[

	Terminal
	========

	Copyright (C) 2018-2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	terminal.lua:
	
]]--

local M = minetest.get_meta
local S = techage.S

local HELP_TA3 = S("#### TA3 Terminal ####@n"..
"@n"..
"Send commands to your machines@n"..
"and output text messages from your@n"..
"machines to the Terminal.@n"..
"@n"..
"Command syntax:@n"..
"  cmd <num> <cmnd>@n"..
"@n"..
"example: cmd 181 on@n"..
"<num> is the number of the node to which the command is sent@n"..
"'on' is the command to turn machines/nodes on@n"..
"Further commands can be retrieved by clicking on@n"..
"machines/nodes with the Techage Info Tool.@n"..
"@n"..
"Local commands:@n"..
"- clear    = clear screen@n"..
"- help     = this message@n"..
"- pub      = switch to public use@n"..
"- priv      = switch to private use@n"..
"To program a user button with a command:@n"..
"  set <button-num> <button-text> <command>@n"..
"e.g. 'set 1 ON cmd 123 on'@n")

local CMNDS_TA3 = S("Syntax error, try help")

--local function formspec1()
--	return "size[6,4]"..
--	default.gui_bg..
--	default.gui_bg_img..
--	default.gui_slots..
--	"field[0.5,1;5,1;number;Techage Controller number:;]" ..
--	"button_exit[1.5,2.5;2,1;exit;Save]"
--end

local function get_string(meta, num, default)
	local s = meta:get_string("bttn_text"..num)
	if not s or s == "" then
		return default
	end
	return s
end

local function formspec2(meta)
	local output = meta:get_string("output")
	local command = meta:get_string("command")
	output = minetest.formspec_escape(output)
	output = output:gsub("\n", ",")
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
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"button[0,0;3.3,1;bttn1;"..bttn_text1.."]button[3.3,0;3.3,1;bttn2;"..bttn_text2.."]button[6.6,0;3.3,1;bttn3;"..bttn_text3.."]"..
	"button[0,0.8;3.3,1;bttn4;"..bttn_text4.."]button[3.3,0.8;3.3,1;bttn5;"..bttn_text5.."]button[6.6,0.8;3.3,1;bttn6;"..bttn_text6.."]"..
	"button[0,1.6;3.3,1;bttn7;"..bttn_text7.."]button[3.3,1.6;3.3,1;bttn8;"..bttn_text8.."]button[6.6,1.6;3.3,1;bttn9;"..bttn_text9.."]"..
	"table[0,2.5;9.8,4.7;output;"..output..";200]"..
	"field[0.4,7.7;7.6,1;cmnd;;"..command.."]" ..
	"field_close_on_enter[cmnd;false]"..
	"button[7.9,7.4;2,1;ok;"..S("Enter").."]"
end

local function output(pos, text)
	local meta = minetest.get_meta(pos)
	text = meta:get_string("output") .. "\n" .. (text or "")
	text = text:sub(-500,-1)
	meta:set_string("output", text)
	meta:set_string("formspec", formspec2(meta))
end

local function get_line_text(pos, num)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("output") or ""
	local lines = string.split(text, "\n", true)
	local line = lines[num] or ""
	return line:gsub("^[%s$]*(.-)%s*$", "%1")
end


local function command(pos, command, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner") or ""
	if command then
		command = command:sub(1,80)
		command = string.trim(command)
		
		if command == "clear" then
			meta:set_string("output", "")
			meta:set_string("formspec", formspec2(meta))
		elseif command == "help" then
			local meta = minetest.get_meta(pos)
			meta:set_string("output", HELP_TA3)
			meta:set_string("formspec", formspec2(meta))
		elseif command == "pub" and owner == player then
			meta:set_int("public", 1)
			output(pos, player..":$ "..command)
			output(pos, S("Switched to public use!"))
		elseif command == "priv" and owner == player then
			meta:set_int("public", 0)
			output(pos, player..":$ "..command)
			output(pos, S("Switched to private use!"))
		elseif meta:get_int("public") == 1 or owner == player or 
				minetest.check_player_privs(player, "server") then
			output(pos, "$ "..command)
			local own_num = meta:get_string("node_number")
			local num, cmnd, payload = command:match('^cmd%s+([0-9]+)%s+(%w+)%s*(.*)$')
			if num and cmnd then
				if techage.not_protected(num, owner, owner) then
					local resp = techage.send_single(own_num, num, cmnd, payload)
					if type(resp) == "string" then
						output(pos, resp)
					else
						output(pos, dump(resp))
					end
				end
				return
			end
			num, cmnd = command:match('^turn%s+([0-9]+)%s+([onf]+)$')
			if num and (cmnd == "on" or cmnd == "off") then
				if techage.not_protected(num, owner, owner) then
					local resp = techage.send_single(own_num, num, cmnd)
					output(pos, dump(resp))
				end
				return
			end
			local bttn_num, label, cmnd = command:match('^set%s+([1-9])%s+(%w+)%s+(.+)$')
			if bttn_num and label and cmnd then
				meta:set_string("bttn_text"..bttn_num, label)
				meta:set_string("bttn_cmnd"..bttn_num, cmnd)
				meta:set_string("formspec", formspec2(meta))
				return
			end
			
			local cmnd, payload = command:match('^pipe%s+(%w+)%s*(.*)$')
			if cmnd then
				if not minetest.check_player_privs(player, "server") then
					output(pos, "server privs missing")
					return
				end
				local resp = techage.transfer(
					pos, 
					"B",  -- outdir
					cmnd,  -- topic
					payload,  -- payload
					techage.BiogasPipe,  -- network
					nil)  -- valid nodes
				output(pos, dump(resp))
				return
			end
			
			if command ~= "" then
				output(pos, CMNDS_TA3)
			end
		end
	end
end	

local function send_cmnd(pos, meta, num)
	local cmnd = meta:get_string("bttn_cmnd"..num)
	local owner = meta:get_string("owner") or ""
	command(pos, cmnd, owner)
end

local function register_terminal(num, tiles, node_box, selection_box)
	minetest.register_node("techage:terminal"..num, {
		description = S("TA3 Terminal"),
		tiles = tiles,
		drawtype = "nodebox",
		node_box = node_box,
		selection_box = selection_box,
		
		after_place_node = function(pos, placer)
			local number = techage.add_node(pos, minetest.get_node(pos).name)
			local meta = minetest.get_meta(pos)
			meta:set_string("node_number", number)
			meta:set_string("command", S("commands like: help"))
			meta:set_string("formspec", formspec2(meta))
			meta:set_string("owner", placer:get_player_name())
		end,

		on_receive_fields = function(pos, formname, fields, player)
			local meta = minetest.get_meta(pos)
			local evt = minetest.explode_table_event(fields.output)
			if evt.type == "DCL" then
				local s = get_line_text(pos, evt.row)
				meta:set_string("command", s)
				meta:set_string("formspec", formspec2(meta))
			elseif (fields.key_enter == "true" or fields.ok) and fields.cmnd ~= "" then
				command(pos, fields.cmnd, player:get_player_name())
				meta:set_string("command", "")
				meta:set_string("formspec", formspec2(meta))
			elseif fields.bttn1 then send_cmnd(pos, meta, 1)
			elseif fields.bttn2 then send_cmnd(pos, meta, 2)
			elseif fields.bttn3 then send_cmnd(pos, meta, 3)
			elseif fields.bttn4 then send_cmnd(pos, meta, 4)
			elseif fields.bttn5 then send_cmnd(pos, meta, 5)
			elseif fields.bttn6 then send_cmnd(pos, meta, 6)
			elseif fields.bttn7 then send_cmnd(pos, meta, 7)
			elseif fields.bttn8 then send_cmnd(pos, meta, 8)
			elseif fields.bttn9 then send_cmnd(pos, meta, 9)
			end
		end,
		
		after_dig_node = function(pos)
			techage.remove_node(pos)
			tubelib2.del_mem(pos)
		end,
		
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {choppy=2, cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_metal_defaults(),
	})
end

register_terminal("1", {
		-- up, down, right, left, back, front
		'techage_terminal1_top.png',
		'techage_terminal1_bottom.png',
		'techage_terminal1_side.png',
		'techage_terminal1_side.png',
		'techage_terminal1_bottom.png',
		"techage_terminal1_front.png",
	},
	{
		type = "fixed",
		fixed = {
			{-12/32, -16/32,  -8/32,  12/32, -14/32, 12/32},
			{-12/32, -14/32,  12/32,  12/32,   6/32, 14/32},
		},
	})

--minetest.register_craft({
--	output = "techage:terminal",
--	recipe = {
--		{"", "smartline:display", ""},
--		{"", "", ""},
--		{"dye:black", "tubelib:wlanchip", "default:copper_ingot"},
--	},
--})

register_terminal("2", {
		-- up, down, right, left, back, front
		'techage_terminal2_top.png',
		'techage_terminal2_side.png',
		'techage_terminal2_side.png^[transformFX',
		'techage_terminal2_side.png',
		'techage_terminal2_back.png',
		"techage_terminal2_front.png",
	},
	{
		type = "fixed",
		fixed = {
			{-12/32, -16/32, -16/32,  12/32, -14/32, 16/32},
			{-12/32, -14/32,  -3/32,  12/32,   6/32, 16/32},
			{-10/32, -12/32,  14/32,  10/32,   4/32, 18/32},
			{-12/32,   4/32,  -4/32,  12/32,   6/32, 16/32},
			{-12/32, -16/32,  -4/32, -10/32,   6/32, 16/32},
			{ 10/32, -16/32,  -4/32,  12/32,   6/32, 16/32},
			{-12/32, -14/32,  -4/32,  12/32, -12/32, 16/32},
		},
	},
	{
		type = "fixed",
		fixed = {
			{-12/32, -16/32, -4/32,  12/32, 6/32, 16/32},
		},
	})

minetest.register_craft({
	output = "techage:terminal2",
	recipe = {
		{"", "", ""},
		{"techage:basalt_glass_thin", "techage:vacuum_tube", "default:copper_ingot"},
		{"dye:grey", "default:steel_ingot", "techage:usmium_nuggets"},
	},
})

techage.register_node({"techage:terminal1", "techage:terminal2"}, {
	on_recv_message = function(pos, src, topic, payload)
		output(pos, "src="..src..", cmd="..dump(topic)..", data="..dump(payload))
		return true
	end,
	on_node_load = function(pos)
		local meta = M(pos)
		local number = meta:get_string("number") or ""
		if number ~= "" then
			meta:set_string("node_number", number)
			meta:set_string("number", nil)
		end
	end,
})

--sl_controller.register_function("get_term", {
--	cmnd = function(self)
--		return sl_controller.get_command(self.meta.number)
--	end,
--	help = ' $get_term()  --> text string or nil\n'..
--		' Read an entered string (command) from the Terminal.\n'..
--		' example: s = $get_term()\n'..
--		" The Terminal has to be connected to the controller."
--})

--sl_controller.register_action("put_term", {
--	cmnd = function(self, num, text)
--		text = tostring(text or "")
--		tubelib.send_message(num, self.meta.owner, nil, "term", text)
--	end,
--	help = " $put_term(num, text)\n"..
--		' Send a text line to the terminal with number "num".\n'..
--		' example: $put_term("0123", "Hello "..name)'
--})

--sl_controller.register_function("get_msg", {
--	cmnd = function(self)
--		local msg = sl_controller.get_msg(self.meta.number)
--		if msg then
--			return msg.src, msg.text
--		end
--	end,
--	help = ' $get_msg()  --> number and text string or nil\n'..
--		' Read a received messages. Number is the node\n'..
--		' number of the sender.\n'..
--		' example: num,msg = $get_msg().'
--})

--sl_controller.register_action("send_msg", {
--	cmnd = function(self, num, text)
--		local msg = {src = self.meta.number, text = tostring(text or "")}
--		tubelib.send_message(num, self.meta.owner, nil, "msg", msg)
--	end,
--	help = " $send_msg(num, text)\n"..
--		' Send a message to the controller with number "num".\n'..
--		' example: $send_msg("0123", "test")'
--})

