--[[

	sl_controller
	=============

	Copyright (C) 2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	commands.lua:
	
	Register all basic controller commands

]]--

-- store protection data locally
local LocalRef = {}
local function not_protected(owner, numbers)
	LocalRef[owner] = LocalRef[owner] or {}
	if LocalRef[owner][numbers] == nil then
		LocalRef[owner][numbers] = techage.check_numbers(numbers, owner)
	end
	return LocalRef[owner][numbers]
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

techage.lua_ctlr.register_function("get_status", {
	cmnd = function(self, num) 
		num = tostring(num or "")
		return techage.send_single(self.meta.number, num, "state", nil)
	end,
	help = " $get_status(num) ,\n"..
		" Read status string from a remote device.\n"..
		' example: sts = $get_status("1234")'
})

techage.lua_ctlr.register_function("get_player_action", {
	cmnd = function(self, num) 
		num = tostring(num or "")
		return unpack(techage.send_single(self.meta.number, num, "player_action", nil) or {"","",""})
	end,
	help = " $get_player_action(num) ,\n"..
		" Read player action status from a Sensor Chest.\n"..
		' example: player, action, item = $get_player_action("1234")'
})

--techage.lua_ctlr.register_function("get_counter", {
--	cmnd = function(self, num) 
--		num = tostring(num or "")
--		return techage.send_single(self.meta.number, num, "counter", nil)
--	end,
--	help = " $get_counter(num)\n"..
--		" Read number of pushed items from a\n"..
--		" Pusher/Distributor node.\n"..
--		" The Pusher returns a single value (number)\n"..
--		" The Distributor returns a list with 4 values\n"..
--		" like: {red=1, green=0, blue=8, yellow=0}\n"..
--		' example: cnt = $get_counter("1234")\n'
--})

--techage.lua_ctlr.register_function("clear_counter", {
--	cmnd = function(self, num) 
--		num = tostring(num or "")
--		return techage.send_single(self.meta.number, num, "clear_counter", nil)
--	end,
--	help = " $clear_counter(num)\n"..
--		" Set counter(s) from Pusher/Distributor to zero.\n"..
--		' example: $clear_counter("1234")'
--})

techage.lua_ctlr.register_function("get_fuel_value", {
	cmnd = function(self, num) 
		num = tostring(num or "")
		return techage.send_single(self.meta.number, num, "fuel", nil)
	end,
	help = " $get_fuel_value(num)\n"..
		" Read fuel value from fuel consuming blocks.\n"..
		' example: val = $get_fuel_value("1234")'
})

--techage.lua_ctlr.register_function("get_num_items", {
--	cmnd = function(self, num, idx) 
--		num = tostring(num or "")
--		idx = tonumber(idx)
--		return techage.send_single(self.meta.number, num, "num_items", idx)
--	end,
--	help = " $get_num_items(num)\n"..
--		" Read number of stored items in one\n"..
--		" storage (1..8) from a Warehouse Box.\n"..
--		' example: cnt = $get_num_items("1234", 4)\n'
--})

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

techage.lua_ctlr.register_function("playerdetector", {
	cmnd = function(self, num) 
		num = tostring(num or "")
		if not_protected(self.meta.owner, num) then
			return techage.send_single(self.meta.number, num, "name", nil)
		end
	end,
	help = ' $playerdetector(num) --> e.g. "Joe"\n'..
		' "" is returned if no player is nearby.\n'..
		' example: name = $playerdetector("1234")'
})

techage.lua_ctlr.register_action("send_cmnd", {
	cmnd = function(self, num, text) 
		num = tostring(num or "")
		text = tostring(text or "")
		if not_protected(self.meta.owner, num) then
			techage.send_single(self.meta.number, num, text, nil)
		end
	end,
	help = " $send_cmnd(num, text)\n"..
		' Send a command to the device with number "num".\n'..
		' example: $send_cmnd("1234", "on")'
})

techage.lua_ctlr.register_action("set_filter", {
	cmnd = function(self, num, slot, val) 
		num = tostring(num or "")
		slot = tostring(slot or "red")
		val = tostring(val or "on")
		if not_protected(self.meta.owner, num) then
			techage.send_single(self.meta.number, num, "filter", {slot=slot, val=val})
		end
	end,
	help = " $set_filter(num, slot, val)\n"..
		' Turn on/off a Distributor filter slot.\n'..
		' example: $set_filter("1234", "red", "off")'
})


techage.lua_ctlr.register_action("display", {
	cmnd = function(self, num, row, text1, text2, text3)
		num = tostring(num or "")
		text1 = tostring(text1 or "")
		text2 = tostring(text2 or "")
		text3 = tostring(text3 or "")
		if not_protected(self.meta.owner, num) then
			techage.send_single(self.meta.number, num, "set", {row = row, str = text1..text2..text3})
		end
	end,
	help = " $display(num, row, text,...)\n"..
		' Send a text line to the display with number "num".\n'..
		" 'row' is a value from 1..5\n"..
		" The function accepts up to 3 text parameters\n"..
		' example: $display("0123", 1, "Hello ", name, " !")'
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
	cmnd = function(self, text1, text2, text3) 
		text1 = tostring(text1 or "")
		text2 = tostring(text2 or "")
		text3 = tostring(text3 or "")
		minetest.chat_send_player(self.meta.owner, "[TA4 Lua Controller] "..text1..text2..text3)
	end,
	help =  " $chat(text,...)\n"..
		" Send yourself a chat message.\n"..
		" The function accepts up to 3 text parameters\n"..
		' example: $chat("Hello ", name)'
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
