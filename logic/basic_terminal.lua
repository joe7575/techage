--[[

	Basic Terminal
	==============

	Copyright (C) 2018-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	terminal.lua:

]]--

local M = minetest.get_meta
local S = techage.S
local SCREENSAVER_TIME = 60 * 5
local CYCLE_TIME = 0.1

local Functions = {}
local Actions = {}
local Buttons = {"Edit", "Save", "Renum", "Cancel", "Run", "Stop", "Continue", "List"}
local States = {"init", "edit", "stopped", "running", "error", "input_str", "input_num", "break"}
local ErrorStr = {
	[1] = "Node not found",
	[2] = "Command not supported",
	[3] = "Command failed",
	[4] = "Access denied",
	[5] = "Wrong response type",
	[6] = "Wrong number of parameters",
}

local InputField = "style_type[field;textcolor=#FFFFFF]" ..
	"field[1.5,0.8;7.4,0.7;input;;]" ..
	"field_close_on_enter[input;false]" ..
	"button[9,0.8;1.5,0.7;Enter;Enter]"

local WRENCH_MENU = {
	{
		type = "dropdown",
		choices = "all players,friends,me",
		name = "public",
		label = S("Access allowed for"),
		tooltip = S("Friends are players for whom this area is not protected"),
		default = "1",
		values = {1,2,0}
	},
	{
		type = "dropdown",
		choices = "terminal,basic",
		name = "opmode",
		label = S("Operational mode"),
		tooltip = S("Switch between TA3 terminal and BASIC computer"),
		default = "terminal",
	},
}

local function register_ext_function(name, param_types, return_type, func)
	Functions[nanobasic.add_function(name, param_types, return_type)] = func
end

local function register_action(states, key, func)
	for _,state in ipairs(states) do
		Actions[state] = Actions[state] or {}
		Actions[state][key] = func
	end
end

local function font_size(nvm)
	nvm.trm_text_size = nvm.trm_text_size or 0
	return nvm.trm_text_size >= 0 and "+" .. nvm.trm_text_size or tostring(nvm.trm_text_size)
end

local function fs_output_window(nvm, x, y, name, text)
	local font_size = font_size(nvm)
	local fs = {
		"container[", x, ",", y, "]",
		"box[0,0;12,7.5;#000000]",
		"style_type[textarea;font=mono;",
		"textcolor=#FFFFFF;border=false;",
		"font_size=", font_size, "]",
		"textarea[0,0;12,7.5;" .. name .. ";;", 
		minetest.formspec_escape(text), "]",
		"container_end[]"
	}
	return table.concat(fs, "")
end

local function fs_size_buttons(x, y)
	local fs = {
		"container[", x, ",", y, "]",
		"button[0.0,0;0.6,0.6;larger;+]",
		"button[0.6,0;0.6,0.6;smaller;-]",
		"container_end[]"
	}
	return table.concat(fs, "")
end

local function key_rows(keys)
	local t = {}
	for i = 1, #keys do
		local x = (i - 1) * 1.5
		if keys[i] ~= "" then
			t[#t+1] = "button[" .. x .. ",0;1.5,0.7;" .. keys[i] .. ";" .. keys[i] .. "]"
		else
			t[#t+1] = "button[" .. x .. ",0;1.5,0.7;;---]"
		end
	end
	return table.concat(t, "")
end

local function input_panel(nvm, x, y)
	local fs = {
		"container[", x, ",", y, "]",
		key_rows(nvm.bttns or Buttons),
		nvm.input or "",
		"container_end[]"
	}
	return table.concat(fs, "")
end

local function get_action(nvm, fields)
	local keys = {"Edit", "Save", "Renum", "Cancel", "Run", "Stop", "Continue", "List", "Enter", "smaller", "larger"}
	nvm.status = nvm.status or "init"
	if nvm.status == "" then
		nvm.status = "init"
	end
	--print("get_action", nvm.status, dump(fields))
	for _,key in ipairs(keys) do
		if fields[key] and Actions[nvm.status] and Actions[nvm.status][key] then
			return Actions[nvm.status][key]
		end
	end
	return function(pos, nvm, fields)
			return
		end
end

local function formspec(pos, text)
	local nvm = techage.get_nvm(pos)
	local name = nvm.status == "edit" and "code" or ""
	return "formspec_version[4]" ..
		"size[12.8,10.5]" ..
		"label[0.5,0.6;Mode: " .. (nvm.status or "") .. "]" ..
		fs_size_buttons(10.6, 0.1) ..
		techage.wrench_image(11.9, 0.15) ..
		fs_output_window(nvm, 0.4, 0.8, name, text or "") ..
		input_panel(nvm, 0.4, 8.6)
end

local function poweron_message(pos)
	local s = nanobasic.free_mem() or ""
	local ver = nanobasic.version()
	return "NanoBasic V" .. ver .. "\n" .. s .. "Ready.\n"
end

-- Lines have line numbers at the beginning, like: "10 PRINT "Hello World"
-- This function sorts the lines by the line numbers
local function sort_lines(pos, nvm, code)
	local lines = {}
	local keys = {}
	for line in code:gmatch("[^\r\n]+") do
		local num = tonumber(line:match("^%s*(%d+)"))
		if num then
			if lines[num] then
				nanobasic.print(pos, "Line number " .. num .. " is already used\n")
				return
			end
			lines[num] = line
			keys[#keys + 1] = num
		else
			nanobasic.print(pos, "Line number missing in line '" .. line .. "'\n")
			return
		end
	end
	
	table.sort(keys)
	
	local sorted = {}
	for i,num in ipairs(keys) do 
		sorted[i] = lines[num]
	end
	return table.concat(sorted, "\n")
end

local function replace_all_goto_refs(lines, new_nums)
	for num,line in pairs(lines) do
		local goto_num = line:match("GOTO%s+(%d+)")
		if goto_num then
			local new_num = new_nums[goto_num]
			if new_num then
				lines[num] = line:gsub("GOTO%s+%d+", "GOTO " .. new_num)
			end
		end
		goto_num = line:match("GOSUB%s+(%d+)")
		if goto_num then
			local new_num = new_nums[goto_num]
			if new_num then
				lines[num] = line:gsub("GOSUB%s+%d+", "GOSUB " .. new_num)
			end
		end
		goto_num = line:match("goto%s+(%d+)")
		if goto_num then
			local new_num = new_nums[goto_num]
			if new_num then
				lines[num] = line:gsub("goto%s+%d+", "goto " .. new_num)
			end
		end
		goto_num = line:match("gosub%s+(%d+)")
		if goto_num then
			local new_num = new_nums[goto_num]
			if new_num then
				lines[num] = line:gsub("gosub%s+%d+", "gosub " .. new_num)
			end
		end
	end
end

local function renumber_lines(pos, nvm, code)
	local lines = {}
	local new_nums = {}
	local num = 10
	for line in code:gmatch("[^\r\n]+") do
		local s = line:match("^%s*(%d+)")
		if s and tonumber(s) < num then
			lines[#lines + 1] = num .. line:sub(s:len() + 1)
			new_nums[s] = num
			num = num + 10
		else
			lines[#lines + 1] = line
			num = tonumber(s) + 10
		end
	end
	
	replace_all_goto_refs(lines, new_nums)
	return table.concat(lines, "\n")
end

minetest.register_node("techage:basic_terminal", {
	description = S("TA3 Terminal"),
	tiles = {-- up, down, right, left, back, front
		'techage_terminal2_top.png',
		'techage_terminal2_side.png',
		'techage_terminal2_side.png^[transformFX',
		'techage_terminal2_side.png',
		'techage_terminal2_back.png',
		"techage_terminal2_front.png",
	},
	drawtype = "nodebox",
	node_box = {
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
	selection_box = {
		type = "fixed",
		fixed = {
			{-12/32, -16/32, -4/32,  12/32, 6/32, 16/32},
		},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, minetest.get_node(pos).name)
		local nvm = techage.get_nvm(pos)
		local meta = M(pos)
		local text = poweron_message(pos)
		nvm.trm_ttl = 0
		nvm.status = "init"
		nvm.bttns = Buttons
		nvm.input = ""
		meta:set_int("public", 0)
		meta:set_string("formspec", formspec(pos, text))
		if placer then
			meta:set_string("owner", placer:get_player_name())
		end
		meta:set_string("infotext", S("TA3 Terminal"))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local nvm = techage.get_nvm(pos)
		local meta = M(pos)
		local public = meta:get_int("public")
		if public == 1 or
			public == 2 and not minetest.is_protected(pos, player:get_player_name()) or
			public == 0 and player:get_player_name() == meta:get_string("owner") then
			fields.Enter = fields.Enter or fields.key_enter_field
			local action = get_action(nvm, fields)
			local text = action(pos, nvm, fields, player)
			if text then
				meta:set_string("formspec", formspec(pos, text))
			end
		end
	end,

	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		if nvm.ttl and nvm.ttl > 1 then
			nvm.ttl = nvm.ttl - 1
			return true
		end
		
		if nvm.status == "running" then
			local res = nanobasic.run(pos, 100)
			if res == nanobasic.NB_BUSY then
				if techage.is_activeformspec(pos) then
					local text = nanobasic.get_screen_buffer(pos)
					M(pos):set_string("formspec", formspec(pos, text))
				end
				return true
			elseif res == nanobasic.NB_ERROR then
				nvm.status = "error"
				nvm.bttns = {"Edit", "", "", "", "", "Stop", "", ""}
				nvm.input = ""
				nvm.ttl = nil
				local text = nanobasic.get_screen_buffer(pos)
				M(pos):set_string("formspec", formspec(pos, text))
			elseif res == nanobasic.NB_END then
				nvm.status = "stopped"
				nvm.bttns = {"Edit", "", "", "", "Run", "Stop", "", ""}
				nvm.input = ""
				nvm.ttl = nil
				local text = nanobasic.get_screen_buffer(pos)
				M(pos):set_string("formspec", formspec(pos, text))
			elseif res == nanobasic.NB_BREAK then
				local lineno = nanobasic.pop_num(pos);
				nanobasic.print(pos, string.format("Break in line %d\n", lineno));
				nvm.status = "break"
				nvm.bttns = {"", "", "", "", "", "Stop", "Continue", "List"}
				nvm.input = InputField
				nvm.ttl = nil
				local text = nanobasic.get_screen_buffer(pos)
				M(pos):set_string("formspec", formspec(pos, text))
			elseif res >= nanobasic.NB_XFUNC then
				return Functions[res] and Functions[res](pos, nvm) or false
			else
				print("res = ", res)
				return false
			end
		end
		return false
	end,

	on_rightclick = function(pos, node, clicker)
		local nvm = techage.get_nvm(pos)
		local text
		nvm.trm_ttl = minetest.get_gametime() + SCREENSAVER_TIME
		if nvm.status == "edit" then
			text = M(pos):get_string("code")
		else
			text = nanobasic.get_screen_buffer(pos) or ""
		end
		techage.set_activeformspec(pos, clicker)
		M(pos):set_string("formspec", formspec(pos, text))
	end,

	ta_after_formspec = function(pos, fields, playername)
		if fields.save then
			if M(pos):get_string("opmode") == "terminal" then
				local node = techage.get_node_lvm(pos)
				node.name = "techage:terminal2"
				minetest.swap_node(pos, node)
				local ndef = minetest.registered_nodes["techage:terminal2"]
				ndef.after_place_node(pos)
			end
		end
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		nanobasic.destroy(pos)
	end,

	ta3_formspec = WRENCH_MENU,
	drop = "techage:terminal2",
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

--
-- Register VM external/callback functions
--
local function get_params(pos)
	local payload3 = nanobasic.pop_num(pos) or 0
	if payload3 >= 0x8000000 then
		payload3 = payload3 - 0x100000000
	end
	local payload2 = nanobasic.pop_num(pos) or 0
	if payload2 >= 0x8000000 then
		payload2 = payload2 - 0x100000000
	end
	local payload1 = nanobasic.pop_num(pos) or 0
	if payload1 >= 0x8000000 then
		payload1 = payload1 - 0x100000000
	end
	local cmnd = nanobasic.pop_num(pos)
	local num = nanobasic.pop_num(pos) or 0
	local owner = M(pos):get_string("owner")
	local own_num = M(pos):get_string("node_number")
	return owner, num, own_num, {payload1, payload2, payload3}
end

local function get_str_param(pos)
	local payload3 = nanobasic.pop_num(pos) -- dummy value
	local payload2 = nanobasic.pop_num(pos) -- dummy value
	local payload1 = nanobasic.pop_str(pos) or ""
	local cmnd = nanobasic.pop_num(pos)
	local num = nanobasic.pop_num(pos) or 0
	local owner = M(pos):get_string("owner")
	local own_num = M(pos):get_string("node_number")
	return owner, num, own_num, payload1
end

local function error_handling(pos, num, sts)
	local nvm = techage.get_nvm(pos)
	if sts > 0 and nvm.error_label_addr and nvm.error_label_addr > 0 then
		local err = ErrorStr[sts] or "unknown error"
		nanobasic.push_num(pos, num)
		nanobasic.push_str(pos, err)
		nanobasic.set_pc(pos, nvm.error_label_addr)
	end
end

register_ext_function("input", {nanobasic.NB_STR}, nanobasic.NB_NUM, function(pos, nvm)
	nvm.status = "input_num"
	local s = nanobasic.pop_str(pos)
	nanobasic.print(pos, s .. "?  ")
	nvm.bttns = {"", "", "", "", "", "Stop", "", ""}
	nvm.input = InputField
	local text = nanobasic.get_screen_buffer(pos) or ""
	M(pos):set_string("formspec", formspec(pos, text))
	return false  -- stop execution
end)

register_ext_function("input$", {nanobasic.NB_STR}, nanobasic.NB_STR, function(pos, nvm)
	nvm.status = "input_str"
	local s = nanobasic.pop_str(pos)
	nanobasic.print(pos, s .. "?  ")
	nvm.bttns = {"", "", "", "", "", "Stop", "", ""}
	nvm.input = InputField
	local text = nanobasic.get_screen_buffer(pos) or ""
	M(pos):set_string("formspec", formspec(pos, text))
	return false  -- stop execution
end)

register_ext_function("sleep", {nanobasic.NB_NUM}, nanobasic.NB_NONE, function(pos, nvm)
	local t = nanobasic.pop_num(pos) or 0
	nvm.ttl = t / CYCLE_TIME
	if techage.is_activeformspec(pos) then
		local text = nanobasic.get_screen_buffer(pos)
		M(pos):set_string("formspec", formspec(pos, text))
	end
	return true
end)

register_ext_function("time", {}, nanobasic.NB_NUM, function(pos, nvm)
	nanobasic.push_num(pos, minetest.get_gametime() or 0)
	return true
end)

register_ext_function("daytime", {}, nanobasic.NB_NUM, function(pos, nvm)
	nanobasic.push_num(pos, math.floor(minetest.get_timeofday() * 1440) or 0)
	return true
end)

register_ext_function("daytime$", {nanobasic.NB_NUM}, nanobasic.NB_STR, function(pos, nvm)
	local british = nanobasic.pop_num(pos) or 0
	local t = minetest.get_timeofday()
	local h = math.floor(t * 24) % 24
	local m = math.floor(t * 1440) % 60
	
	if british == 1 then
		if h < 12 then
			nanobasic.push_str(pos, string.format("%02d:%02d am", h, m))
		else
			nanobasic.push_str(pos, string.format("%02d:%02d pm", h - 12, m))
		end
	else
		nanobasic.push_str(pos, string.format("%02d:%02d", h, m))
	end
	return true
end)

register_ext_function("hold", {}, nanobasic.NB_NONE, function(pos, nvm)
	local own_num = M(pos):get_string("node_number")
	techage.cmnd_hold(own_num)
	return true
end)

register_ext_function("release", {}, nanobasic.NB_NONE, function(pos, nvm)
	local own_num = M(pos):get_string("node_number")
	techage.cmnd_release(own_num)
	return true
end)

-- num: cmd(num: node_num, num: cmnd, any: pyld1, num: pyld2, num: pyld3)
register_ext_function("cmd", {nanobasic.NB_NUM, nanobasic.NB_NUM, nanobasic.NB_ANY, nanobasic.NB_ANY, nanobasic.NB_ANY}, nanobasic.NB_NUM, function(pos, nvm)
	local cmnd = nanobasic.peek_num(pos, 4) or 0
	if cmnd < 64 then -- command with payload as number(s)
		local owner, num, own_num, payload = get_params(pos)
		if techage.not_protected(tostring(num), owner) then
			techage.counting_add(owner, 1)
			local sts, resp = techage.beduino_send_cmnd(own_num, num, cmnd, payload)
			nanobasic.push_num(pos, sts)
			error_handling(pos, num, sts)
		else
			nanobasic.push_num(pos, 4)
			error_handling(pos, num, 4)
		end
	elseif cmnd < 128 then -- command with payload as string
		local owner, num, own_num, payload = get_str_param(pos)
		if techage.not_protected(tostring(num), owner) then
			techage.counting_add(owner, 1)
			local sts, resp = techage.beduino_send_cmnd(own_num, num, cmnd, payload)
			nanobasic.push_num(pos, sts)
			error_handling(pos, num, sts)
		else
			nanobasic.push_num(pos, 4)
			error_handling(pos, num, 4)
		end
	elseif cmnd < 192 then -- request with payload as number(s) and result as number
		local owner, num, own_num, payload = get_params(pos)
		if techage.not_protected(tostring(num), owner) then
			techage.counting_add(owner, 1)
			local sts, resp = techage.beduino_request_data(own_num, num, cmnd, payload)
			if type(resp) == "table" then
				nanobasic.push_num(pos, resp[1] or 0)
			else
				nanobasic.push_num(pos, 5)
				sts = 5
			end
			error_handling(pos, num, sts)
		else
			nanobasic.push_num(pos, 4)
			error_handling(pos, num, 4)
		end
	else
		local owner, num, own_num, payload = get_str_param(pos)
		if techage.not_protected(tostring(num), owner) then
			techage.counting_add(owner, 1)
			local sts, resp = techage.beduino_request_data(own_num, num, cmnd, payload)
			if type(resp) == "table" then
				nanobasic.push_num(pos, resp[1] or 0)
			else
				nanobasic.push_num(pos, 5)
				sts = 5
			end
			error_handling(pos, num, sts)
		else
			nanobasic.push_num(pos, 4)
			error_handling(pos, num, 4)
		end
	end
	return true
end)

-- str: cmd(num: node_num, num: cmnd, any: pyld1, any: pyld2, num: pyld3)
register_ext_function("cmd$", {nanobasic.NB_NUM, nanobasic.NB_NUM, nanobasic.NB_ANY, nanobasic.NB_ANY, nanobasic.NB_ANY}, nanobasic.NB_STR, function(pos, nvm)
	local cmnd = nanobasic.peek_num(pos, 4) or 0
	if cmnd >= 128 then -- request with payload as number(s) and result as string
		local owner, num, own_num, payload = get_params(pos)
		if techage.not_protected(tostring(num), owner) then
			techage.counting_add(owner, 1)
			local sts, resp = techage.beduino_request_data(own_num, num, cmnd, payload)
			if type(resp) == "string" then
				nanobasic.push_str(pos, resp)
			else
				nanobasic.push_str(pos, "")
				sts = 5
			end
			error_handling(pos, num, sts)
		else
			nanobasic.push_str(pos, "")
			error_handling(pos, num, 4)
		end
	end
	return true
end)

-- none: chat(str: msg)
register_ext_function("chat", {nanobasic.NB_STR}, nanobasic.NB_NONE, function(pos, nvm)
	local msg = nanobasic.pop_str(pos) or ""
	local owner = M(pos):get_string("owner")
	minetest.chat_send_player(owner, msg)
	return true
end)

-- none: dputs(num: node_num, num: row, str: text)
register_ext_function("dputs", {nanobasic.NB_NUM, nanobasic.NB_NUM, nanobasic.NB_STR}, nanobasic.NB_NONE, function(pos, nvm)
	local text = nanobasic.pop_str(pos) or ""
	local row = nanobasic.pop_num(pos) or 0
	local num = nanobasic.pop_num(pos) or 0
	local own_num = M(pos):get_string("node_number")
	local owner = M(pos):get_string("owner")
	if techage.not_protected(tostring(num), owner) then
		techage.counting_add(owner, 1)
		if row == 0 then -- add line
			techage.send_single(own_num, num, "add", text)
		else
			local payload = safer_lua.Store()
			payload.set("row", row)
			payload.set("str", text)
			techage.send_single(own_num, num, "set", payload)
		end
	end
	return true
end)

-- none: dclr(num: node_num)
register_ext_function("dclr", {nanobasic.NB_NUM}, nanobasic.NB_NONE, function(pos, nvm)
	local num = nanobasic.pop_num(pos) or 0
	local own_num = M(pos):get_string("node_number")
	local owner = M(pos):get_string("owner")
	if techage.not_protected(tostring(num), owner) then
		techage.counting_add(owner, 1)
		techage.send_single(own_num, num, "clear", nil)
	end
	return true
end)

-- none: door(str: node_pos, str: state)
register_ext_function("door", {nanobasic.NB_STR, nanobasic.NB_STR}, nanobasic.NB_NONE, function(pos, nvm)
	local state = nanobasic.pop_str(pos) or ""
	local spos = nanobasic.pop_str(pos) or 0
	local doorpos = minetest.string_to_pos("(" .. spos .. ")")
	local owner = M(pos):get_string("owner")
	if pos then
		local door = doors.get(doorpos)
		if door then
			techage.counting_add(owner, 1)
			local player = {
				get_player_name = function() return owner end,
				is_player = function() return true end,
			}
			if state == "open" then
				door:open(player)
			elseif state == "close" then
				door:close(player)
			end
		end
	end
	return true
end)

-- str: iname(str: item_name)
register_ext_function("iname$", {nanobasic.NB_STR}, nanobasic.NB_STR, function(pos, nvm)
	local item_name = nanobasic.pop_str(pos) or ""
	local item = minetest.registered_items[item_name]
	if item and item.description then
		local s = minetest.get_translated_string("en", item.description)
		nanobasic.push_str(pos, s or "")
	else
		nanobasic.push_str(pos, "")
	end
	return true
end)

register_ext_function("reset", {}, nanobasic.NB_NONE, function(pos, nvm)
	nanobasic.reset(pos)
	return true
end)

--
-- Register user input actions: register_action(states, key, function)
--
register_action({"init", "stopped", "error", "break"}, "Edit", function(pos, nvm, fields)
	nvm.status = "edit"
	nvm.bttns = {"", "Save", "Renum", "Cancel", "Run", "", "", ""}
	nvm.input = ""
	return M(pos):get_string("code")
end)

register_action({"edit"}, "Save", function(pos, nvm, fields)
	nanobasic.clear_screen(pos)
	local code = sort_lines(pos, nvm, fields.code)
	if code == nil then
		nvm.status = "error"
		nvm.bttns = {"Edit", "", "", "", "", "Stop", "", ""}
		nvm.input = ""
		M(pos):set_string("code", fields.code)
		return nanobasic.get_screen_buffer(pos) or ""
	end
	M(pos):set_string("code", code)
	return code
end)

register_action({"edit"}, "Renum", function(pos, nvm, fields)
	nanobasic.clear_screen(pos)
	local code = sort_lines(pos, nvm, fields.code)
	if code == nil then
		nvm.status = "error"
		nvm.bttns = {"Edit", "", "", "", "", "Stop", "", ""}
		nvm.input = ""
		M(pos):set_string("code", fields.code)
		return nanobasic.get_screen_buffer(pos) or ""
	end
	code = renumber_lines(pos, nvm, code)
	M(pos):set_string("code", code)
	return code
end)

register_action({"edit"}, "Cancel", function(pos, nvm, fields)
	nvm.status = "stopped"
	nvm.bttns = {"Edit", "", "", "", "Run", "Stop", "", ""}
	nvm.input = ""
	return nanobasic.get_screen_buffer(pos) or ""
end)

register_action({"init", "edit", "stopped"}, "Run", function(pos, nvm, fields)
	if nvm.status == "edit" then
		M(pos):set_string("code", fields.code)
	end
	local code = M(pos):get_string("code")
	if nanobasic.create(pos, code) then
		nvm.status = "running"
		nvm.bttns = {"", "", "", "", "", "Stop", "", "List"}
		nvm.input = ""
		nvm.variables = nanobasic.get_variable_list(pos)
		nvm.onload_label_addr = nanobasic.get_label_address(pos, "64000") or 0
		nvm.error_label_addr = nanobasic.get_label_address(pos, "65000") or 0
		nvm.ttl = nil
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		return nanobasic.get_screen_buffer(pos) or ""
	else
		nvm.status = "error"
		nvm.bttns = {"Edit", "", "", "", "", "Stop", "", ""}
		nvm.input = ""
		return nanobasic.get_screen_buffer(pos) or ""
	end
end)

register_action({"break"}, "Continue", function(pos, nvm, fields)
	nvm.status = "running"
	nvm.bttns = {"", "", "", "", "", "Stop", "", "List"}
	nvm.input = ""
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	return nanobasic.get_screen_buffer(pos) or ""
end)

register_action({"break"}, "List", function(pos, nvm, fields)
	nvm.status = "break"
	nvm.bttns = {"", "", "", "", "", "Stop", "Continue", "List"}
	nvm.input = InputField
	return M(pos):get_string("code")
end)

register_action({"running"}, "List", function(pos, nvm, fields, player)
	nvm.bttns = {"", "", "", "", "", "Stop", "Continue", ""}
	nvm.input = ""
	techage.reset_activeformspec(pos, player)
	return M(pos):get_string("code")
end)

register_action({"running"}, "Continue", function(pos, nvm, fields, player)
	nvm.bttns = {"", "", "", "", "", "Stop", "", "List"}
	nvm.input = ""
	techage.set_activeformspec(pos, player)
	return nanobasic.get_screen_buffer(pos) or ""
end)

register_action({"break"}, "Enter", function(pos, nvm, fields)
	nvm.status = "break"
	nvm.bttns = {"", "", "", "", "", "Stop", "Continue", "List"}
	nvm.input = InputField
	local s = fields.input:lower()
	local var_name, arr_idx = s:match('^(%w+)%s*,%s*([0-9]*)$')
	if var_name == nil then
		 var_name, arr_idx = s, "0"
	end
	if nvm.variables[var_name] then
		arr_idx = tonumber(arr_idx)
		local var_type, var_idx = nvm.variables[var_name][1], nvm.variables[var_name][2]
		local val = nanobasic.read_variable(pos, var_type, var_idx, arr_idx)
		if var_type == nanobasic.NB_NUM then
			nanobasic.print(pos, string.format("%s = %u\n", var_name, val));
		elseif var_type == nanobasic.NB_STR then
			nanobasic.print(pos, string.format("%s = \"%s\"\n", var_name, val));
		else
			nanobasic.print(pos, string.format("%s(%u) = %u\n", var_name, arr_idx, val));
		end
	else
		nanobasic.print(pos, string.format("Variable '%s' is unknown\n", var_name));
	end
	return nanobasic.get_screen_buffer(pos) or ""
end)

register_action({"stopped", "init"}, "Stop", function(pos, nvm, fields)
	nvm.status = "init"
	nanobasic.print(pos, "\nProgram stopped.\n")
	nvm.bttns = Buttons
	nvm.input = ""
	nanobasic.clear_screen(pos)
	return poweron_message(pos)
end)

register_action({"running", "input_num", "input_str"}, "Stop", function(pos, nvm, fields)
	nvm.status = "stopped"
	nanobasic.print(pos, "\nProgram stopped.\n")
	nvm.bttns = {"Edit", "", "", "", "Run", "Stop", "", ""}
	nvm.input = ""
	return nanobasic.get_screen_buffer(pos) or ""
end)

register_action({"break", "error"}, "Stop", function(pos, nvm, fields)
	nvm.status = "stopped"
	nanobasic.print(pos, "\nProgram stopped.\n")
	nvm.bttns = {"Edit", "", "", "", "Run", "Stop", "", ""}
	nvm.input = ""
	return nanobasic.get_screen_buffer(pos) or ""
end)

register_action(States, "larger", function(pos, nvm, fields)
	nvm.trm_text_size = math.min((nvm.trm_text_size or 0) + 1, 8)
	return fields.code or nanobasic.get_screen_buffer(pos) or ""
end)

register_action(States, "smaller", function(pos, nvm, fields)
	nvm.trm_text_size = math.max((nvm.trm_text_size or 0) - 1, -8)
	return fields.code or nanobasic.get_screen_buffer(pos) or ""
end)

register_action(States, "quit", function(pos, nvm, fields)
	nvm.trm_ttl = 0
	return ""
end)

register_action({"input_num"}, "Enter", function(pos, nvm, fields)
	nanobasic.print(pos, fields.input .. "\n")
	nanobasic.push_num(pos, tonumber(fields.input) or 0)
	nvm.status = "running"
	nvm.bttns = {"", "", "", "", "", "Stop", "", ""}
	nvm.input = ""
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	return nanobasic.get_screen_buffer(pos) or ""
end)

register_action({"input_str"}, "Enter", function(pos, nvm, fields)
	nanobasic.print(pos, fields.input .. "\n")
	nanobasic.push_str(pos, fields.input)
	nvm.status = "running"
	nvm.bttns = {"", "", "", "", "", "Stop", "", ""}
	nvm.input = ""
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	return nanobasic.get_screen_buffer(pos) or ""
end)


techage.register_node({"techage:basic_terminal"}, {
	on_node_load = function(pos)
		nanobasic.vm_restore(pos)
		local nvm = techage.get_nvm(pos)
		if nvm.status == "running" then
			if nvm.onload_label_addr and nvm.onload_label_addr > 0 then
				nanobasic.set_pc(pos, nvm.onload_label_addr)
			end
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end,
})

