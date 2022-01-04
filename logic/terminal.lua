--[[

	Terminal
	========

	Copyright (C) 2018-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	terminal.lua:

]]--

local M = minetest.get_meta
local S = techage.S

local HELP_TA3 = [[        #### TA3 Terminal ####
Send commands to machines and output the results.
Local commands:
- Clear screen with 'clear'
- Output this message with 'help'
- Switch to public use of buttons with 'pub'
- Switch to private use of buttons with 'priv'
- Program a user button with
   'set <button-num> <button-text> <command>'
   Example: 'set 1 ON cmd 1234 on'
- send a command with 'cmd <num> <cmnd>'
   Example: 'cmd 1234 on']]

local HELP_TA4 = [[        #### TA4 Terminal ####
Send commands to machines and output the results.
Local commands:
- Clear screen with 'clear'
- Output this message with 'help'
- Switch to public use of buttons with 'pub'
- Switch to private use of buttons with 'priv'
- Program a user button with
   'set <button-num> <button-text> <command>'
   Example: 'set 1 ON cmd 1234 on'
- send a command with 'cmd <num> <cmnd>'
   Example: 'cmd 1234 on'
- Connect to a machine with 'connect <num>'
If connected, compact commands like 'status'
are possible.]]

local SYNTAX_ERR = S("Syntax error, try help")

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
	return "size[10,8.5]"..
	--"style_type[table,field;font=mono]"..
	"button[0,-0.2;3.3,1;bttn1;"..bttn_text1.."]button[3.3,-0.2;3.3,1;bttn2;"..bttn_text2.."]button[6.6,-0.2;3.3,1;bttn3;"..bttn_text3.."]"..
	"button[0,0.6;3.3,1;bttn4;"..bttn_text4.."]button[3.3,0.6;3.3,1;bttn5;"..bttn_text5.."]button[6.6,0.6;3.3,1;bttn6;"..bttn_text6.."]"..
	"button[0,1.4;3.3,1;bttn7;"..bttn_text7.."]button[3.3,1.4;3.3,1;bttn8;"..bttn_text8.."]button[6.6,1.4;3.3,1;bttn9;"..bttn_text9.."]"..
	"table[0,2.3;9.8,5.6;output;"..output..";200]"..
	"field[0.4,8.2;7.6,1;cmnd;;"..command.."]" ..
	"field_close_on_enter[cmnd;false]"..
	"button[7.9,7.9;2,1;ok;"..S("Enter").."]"
end

local function output(pos, text)
	local meta = minetest.get_meta(pos)
	text = meta:get_string("output") .. "\n" .. (text or "")
	text = text:sub(-1000,-1)
	meta:set_string("output", text)
	meta:set_string("formspec", formspec2(meta))
end

local function append(pos, text)
	local meta = minetest.get_meta(pos)
	text = meta:get_string("output") .. (text or "")
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

local function server_debug(pos, command, player)
	local cmnd, payload = command:match('^pipe%s+([%w_]+)%s*(.*)$')
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
			techage.LiquidPipe,  -- network
			nil)  -- valid nodes
		output(pos, dump(resp))
		return true
	end

	cmnd, payload = command:match('^axle%s+([%w_]+)%s*(.*)$')
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
			techage.TA1Axle,  -- network
			nil)  -- valid nodes
		output(pos, dump(resp))
		return true
	end

	cmnd, payload = command:match('^vtube%s+([%w_]+)%s*(.*)$')
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
			techage.VTube,  -- network
			nil)  -- valid nodes
		output(pos, dump(resp))
		return true
	end
end

local function command(pos, command, player, is_ta4)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner") or ""

	command = command:sub(1,80)
	command = string.trim(command)
	local cmnd, data = command:match('^(%w+)%s*(.*)$')

	if cmnd == "clear" then
		meta:set_string("output", "")
		meta:set_string("formspec", formspec2(meta))
	elseif cmnd == "" then
		output(pos, "$")
	elseif cmnd == "help" then
		if is_ta4 then
			output(pos, HELP_TA4)
		else
			output(pos, HELP_TA3)
		end
	elseif cmnd == "pub" then
		meta:set_int("public", 1)
		output(pos, "$ "..command)
		output(pos, "Switched to public buttons!")
	elseif cmnd == "priv" then
		meta:set_int("public", 0)
		output(pos, "$ "..command)
		output(pos, "Switched to private buttons!")
	elseif cmnd == "connect" and data then
		output(pos, "$ "..command)
		if techage.not_protected(data, owner, owner) then
			local own_num = meta:get_string("node_number")
			local resp = techage.send_single(own_num, data, cmnd)
			if resp then
				meta:set_string("connected_to", data)
				output(pos, "Connected.")
			else
				meta:set_string("connected_to", "")
				output(pos, "Not connected!")
			end
		else
			output(pos, "Protection error!")
		end
	else
		output(pos, "$ "..command)
		local own_num = meta:get_string("node_number")
		local connected_to = meta:contains("connected_to") and meta:get_string("connected_to")
		local bttn_num, label, num, cmnd, payload

		num, cmnd, payload = command:match('^cmd%s+([0-9]+)%s+(%w+)%s*(.*)$')
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

		bttn_num, label, cmnd = command:match('^set%s+([1-9])%s+([%w_]+)%s+(.+)$')
		if bttn_num and label and cmnd then
			meta:set_string("bttn_text"..bttn_num, label)
			meta:set_string("bttn_cmnd"..bttn_num, cmnd)
			meta:set_string("formspec", formspec2(meta))
			return
		end

		if server_debug(pos, command, player) then
			return
		end

		if connected_to then
			local cmnd, payload = command:match('^(%w+)%s*(.*)$')
			if cmnd then
				local resp = techage.send_single(own_num, connected_to, cmnd, payload)
				if resp ~= true then
					if type(resp) == "string" then
						output(pos, resp)
					else
						output(pos, dump(resp))
					end
				end
				return
			end
		end

		if command ~= "" then
			output(pos, SYNTAX_ERR)
		end
	end
end

local function send_cmnd(pos, meta, num)
	local cmnd = meta:get_string("bttn_cmnd"..num)
	local owner = meta:get_string("owner") or ""
	command(pos, cmnd, owner)
end

local function register_terminal(name, description, tiles, node_box, selection_box)
	minetest.register_node("techage:"..name, {
		description = description,
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
			meta:set_string("infotext", description .. " " .. number)
		end,

		on_receive_fields = function(pos, formname, fields, player)
			local meta = minetest.get_meta(pos)
			local public = meta:get_int("public") == 1
			local protected = minetest.is_protected(pos, player:get_player_name())

			if not protected then
				local evt = minetest.explode_table_event(fields.output)
				if evt.type == "DCL" then
					local s = get_line_text(pos, evt.row)
					meta:set_string("command", s)
					meta:set_string("formspec", formspec2(meta))
					return
				elseif (fields.ok or fields.key_enter_field) and fields.cmnd then
					local is_ta4 = string.find(description, "TA4")
					command(pos, fields.cmnd, player:get_player_name(), is_ta4)
					techage.historybuffer_add(pos, fields.cmnd)
					meta:set_string("command", "")
					meta:set_string("formspec", formspec2(meta))
					return
				elseif fields.key_up then
					meta:set_string("command", techage.historybuffer_priv(pos))
					meta:set_string("formspec", formspec2(meta))
					return
				elseif fields.key_down then
					meta:set_string("command", techage.historybuffer_next(pos))
					meta:set_string("formspec", formspec2(meta))
					return
				end
			end
			if public or not protected then
				if fields.bttn1 then send_cmnd(pos, meta, 1)
				elseif fields.bttn2 then send_cmnd(pos, meta, 2)
				elseif fields.bttn3 then send_cmnd(pos, meta, 3)
				elseif fields.bttn4 then send_cmnd(pos, meta, 4)
				elseif fields.bttn5 then send_cmnd(pos, meta, 5)
				elseif fields.bttn6 then send_cmnd(pos, meta, 6)
				elseif fields.bttn7 then send_cmnd(pos, meta, 7)
				elseif fields.bttn8 then send_cmnd(pos, meta, 8)
				elseif fields.bttn9 then send_cmnd(pos, meta, 9)
				end
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
end

register_terminal("terminal2", S("TA3 Terminal"), {
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
	}
)

register_terminal("terminal3", S("TA4 Terminal"), {
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
	},
	{
		type = "fixed",
		fixed = {
			{-12/32, -16/32,  -8/32,  12/32, -14/32, 12/32},
			{-12/32, -14/32,  12/32,  12/32,   6/32, 14/32},
		},
	}
)

minetest.register_craft({
	output = "techage:terminal2",
	recipe = {
		{"", "", ""},
		{"techage:basalt_glass_thin", "techage:vacuum_tube", "default:copper_ingot"},
		{"dye:grey", "default:steel_ingot", "techage:usmium_nuggets"},
	},
})

minetest.register_craft({
	output = "techage:terminal3",
	recipe = {
		{"techage:basalt_glass_thin", "", ""},
		{"techage:ta4_leds", "", ""},
		{"techage:aluminum", "techage:ta4_wlanchip", "techage:ta4_ramchip"},
	},
})

techage.register_node({"techage:terminal2"}, {
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

techage.register_node({"techage:terminal3"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "text" then
			output(pos, payload)
		elseif topic == "append" then
			append(pos, payload)
		else
			output(pos, "src="..src..", cmd="..dump(topic)..", data="..dump(payload))
		end
		return true
	end,
})
