--[[

	Techage
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	commands.lua:

	Register all basic controller commands

]]--

-- store protection data locally
local LocalRef = {}
local function not_protected(owner, numbers)
	if owner and numbers then
		LocalRef[owner] = LocalRef[owner] or {}
		if LocalRef[owner][numbers] == nil then
			LocalRef[owner][numbers] = techage.check_numbers(numbers, owner)
		end
		return LocalRef[owner][numbers]
	end
	return false
end

techage.lua_ctlr.register_function("get_input", {
	cmnd = function(self, num)
		num = tostring(num or "")
		return techage.lua_ctlr.get_input(self.meta.number, num)
	end,
	help = ' $get_input(num)  --> "on", "off", or nil\n'..
		' Read local input value from device with number "num".\n'..
		' example: inp = $get_input("1234")\n'..
		" The device has to be connected with the controller."
})

techage.lua_ctlr.register_function("get_next_input", {
	cmnd = function(self)
		return techage.lua_ctlr.get_next_input(self.meta.number)
	end,
	help = ' $get_next_input()  --> number and state\n'..
		' Similar to $get_input(), but provides the\n'..
		' input node number in addition.\n'..
		' example: num, state = $get_next_input()\n'..
		' This function deletes the input and returns\n'..
		' nil if no further input value is available.'
})

techage.lua_ctlr.register_function("read_data", {
	cmnd = function(self, num, cmnd, data)
		num = tostring(num or "")
		cmnd = tostring(cmnd or "")
		if not_protected(self.meta.owner, num) then
			return techage.send_single(self.meta.number, num, cmnd, data)
		end
	end,
	help = " $read_data(num, cmnd, add_data)\n"..
		" This function is deprecated.\n"..
		" It will be removed in future releases.\n"..
		" Use $send_cmnd(num, cmnd, add_data) instead."
})

techage.lua_ctlr.register_function("time_as_str", {
	cmnd = function(self)
		local t = minetest.get_timeofday()
		local h = math.floor(t*24) % 24
		local m = math.floor(t*1440) % 60
		return string.format("%02d:%02d", h, m)
	end,
	help = " $time_as_str()  --> e.g. '18:45'\n"..
		" Read time of day as string (24h).\n"..
		' example: time = $time_as_str()'
})

techage.lua_ctlr.register_function("time_as_num", {
	cmnd = function(self, num)
		local t = minetest.get_timeofday()
		local h = math.floor(t*24) % 24
		local m = math.floor(t*1440) % 60
		return h * 100 + m
	end,
	help = " $time_as_num()  --> e.g.: 1845\n"..
		" Read time of day as number (24h).\n"..
		' example: time = $time_as_num()'
})

techage.lua_ctlr.register_action("send_cmnd", {
	cmnd = function(self, num, cmnd, data)
		num = tostring(num or "")
		cmnd = tostring(cmnd or "")
		if not_protected(self.meta.owner, num) then
			return techage.send_single(self.meta.number, num, cmnd, data)
		end
	end,
	help = " $send_cmnd(num, cmnd, add_data)\n"..
		' Send a command to the device with number "num".\n'..
		' "cmnd" is the command as text string\n'..
		' "add_data" is additional data (optional)\n'..
		' example: $send_cmnd("1234", "on")'
})

techage.lua_ctlr.register_action("set_filter", {
	cmnd = function(self, num, slot, val)
		num = tostring(num or "")
		slot = tostring(slot or "red")
		val = tostring(val or "on")
		if not_protected(self.meta.owner, num) then
			techage.send_single(self.meta.number, num, "port", slot.."="..val)
		end
	end,
	help = " $set_filter(num, slot, val)\n"..
		' Turn on/off a Distributor filter slot.\n'..
		' example: $set_filter("1234", "red", "off")'
})

techage.lua_ctlr.register_action("get_filter", {
	cmnd = function(self, num, slot)
		num = tostring(num or "")
		slot = tostring(slot or "red")
		if not_protected(self.meta.owner, num) then
			return techage.send_single(self.meta.number, num, "port", slot)
		end
	end,
	help = " $get_filter(num, slot)\n"..
		' Read state of a Distributor filter slot.\n'..
		' Return value is "on" or "off".\n'..
		' example: state = $get_filter("1234", "red")'
})

techage.lua_ctlr.register_action("display", {
	cmnd = function(self, num, row, text)
		num = tostring(num or "")
		row = tonumber(row or 1) or 1
		text = tostring(text or "")
		if not_protected(self.meta.owner, num) then
			if text:byte(1) ~= 32 then -- left aligned?
				text = "<"..text	-- use the '<' lcdlib control char for left-aligned
			else
				text = text:sub(2) -- delete blank for centered
			end
			if row == 0 then -- add line?
				techage.send_single(self.meta.number, num, "add", text)
			else
				local payload = safer_lua.Store()
				payload.set("row", row)
				payload.set("str", text)
				techage.send_single(self.meta.number, num, "set", payload)
			end
		end
	end,
	help = " $display(num, row, text)\n"..
		' Send a text line to the display with number "num".\n'..
		" 'row' is a value from 1..5, or 0 for scroll screen\n"..
		" and add a new line. If the first char of the string\n"..
		" is a blank, the text will be horizontally centered.\n"..
		' example: $display("123", 1, "Hello "..name)'

})

techage.lua_ctlr.register_action("clear_screen", {
	cmnd = function(self, num)
		num = tostring(num or "")
		if not_protected(self.meta.owner, num) then
			techage.send_single(self.meta.number, num, "clear", nil)
		end
	end,
	help = " $clear_screen(num)\n"..
		' Clear the screen of the display\n'..
		' with number "num".\n'..
		' example: $clear_screen("1234")'
})

techage.lua_ctlr.register_action("chat", {
	cmnd = function(self, text)
		text = tostring(text or "")
		minetest.chat_send_player(self.meta.owner, "[TA4 Lua Controller] "..text)
	end,
	help =  " $chat(text,...)\n"..
		" Send yourself a chat message.\n"..
		' example: $chat("Hello "..name)'
})

techage.lua_ctlr.register_action("door", {
	cmnd = function(self, pos, text)
		pos = tostring(pos or "")
		text = tostring(text or "")
		pos = minetest.string_to_pos("("..pos..")")
		if pos then
			local door = doors.get(pos)
			if door then
				local player = {
					get_player_name = function() return self.meta.owner end,
					is_player = function() return true end,
				}
				if text == "open" then
					door:open(player)
				elseif text == "close" then
					door:close(player)
				end
			end
		end
	end,
	help =  " $door(pos, text)\n"..
		' Open/Close a door at position "pos"\n'..
		' example: $door("123,7,-1200", "close")\n'..
		" Hint: Use the Techage Programmer to\ndetermine the door position."
})

techage.lua_ctlr.register_function("item_description", {
	cmnd = function(self, itemstring)
		local item_def = minetest.registered_items[itemstring]
		if item_def and item_def.description then
			return minetest.get_translated_string("en", item_def.description)
		end
		return ""
	end,
	help = " $item_description(itemstring)\n"..
			" Get the description for a specified itemstring.\n"..
			' example: desc = $item_description("default:apple")'
})


-- function not_protected(owner, number(s))
techage.lua_ctlr.not_protected = not_protected
