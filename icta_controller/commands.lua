--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	ICTA Controller - Register all controller commands

]]--

 -- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic
	
local function send_single_string(environ, number, topic, payload)
	payload = payload or "nil"
	local s = 'techage.send_single("%s", "%s", "%s", %s)'
	return string.format(s, environ.number, number, topic, payload)
end
	
local function send_multi_string(environ, numbers, topic, payload)	
	payload = payload or "nil"
	local s = 'techage.send_multi("%s", "%s", "%s", %s)'
	return string.format(s, environ.number, numbers, topic, payload)
end

function techage.operand(s)
	if s == "is" then
		return "== "
	elseif s == "is not" then
		return "~= "
	elseif s == "greater" then
		return "> "
	elseif s == "less" then
		return "< "
	end
end


function techage.fmt_number(num)
	local mtch = num:match('^(%d+).*')
	if mtch and num ~= mtch then
		return mtch.."..."
	end
	return num
end

-- '#' is used as placeholder for rule numbers and has to be escaped
function techage.icta_escape(s)
	s = tostring(s)
	return s:gsub("#", '"..string.char(35).."')
end


techage.icta_register_condition("initial", {
	title = "initial",
	formspec = {
		{
			type = "label", 
			name = "lbl", 
			label = "Condition is true only after\ncontroller start.", 
		},
	},
	-- Return two chunks of executable Lua code for the controller, according:
	--    return <read condition>, <expected result>
	code = function(data, environ) 
		return 'env.ticks', '== 1'
	end,
	button = function(data, environ) return "Initial after start" end,
})

techage.icta_register_condition("true", {
	title = "true",
	formspec = {
		{
			type = "label", 
			name = "lbl", 
			label = "Condition is always true.", 
		},
	},
	code = function(data, environ) 
		return '"true"', '== "true"'
	end,
	button = function(data, environ) return "true" end,
})

techage.icta_register_condition("condition", {
	title = "condition",
	formspec = {
		{
			type = "textlist", 
			name = "condition",
			label = "condition row number",      
			choices = "1,2,3,4,5,6,7,8", 
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			label = "condition",      
			choices = "was true, was not true",
			default = "was true",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Used to execute two or more\nactions based on one condition.", 
		},
	},
	code = function(data, environ) 
		local idx = data.condition:byte(-1) - 0x30
		local expected_result = "== false"
		if data.operand == "was true" then
			expected_result = "== true"
		end
		return "env.condition["..idx.."]", expected_result
	end,
	button = function(data, environ) return "cond("..data.condition:sub(-1,-1)..","..data.operand..")" end,
})

techage.icta_register_condition("input", {
	title = "inputs",
	formspec = {
		{
			type = "digits",
			name = "number",
			label = "block number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			choices = "is,is not",
			default = "is",
		},
		{
			type = "textlist",
			name = "value",
			choices = "on,off,invalid",
			default = "on",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "An input is only available,\nif a block sends on/off\ncommands to the controller.", 
		},
	},
	button = function(data, environ)  -- default button label
		return 'inp('..techage.fmt_number(data.number)..','..data.operand.." "..data.value..')'
	end,
	code = function(data, environ)  
		return 'env.input["'..data.number..'"]',
			techage.operand(data.operand)..'"'..data.value..'"'
	end,
})

techage.icta_register_condition("state", {
	title = "read block state",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "block number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			label = "",
			choices = "is,is not",
			default = "is",
		},
		{
			type = "textlist",
			name = "value",
			label = "",
			choices = "stopped,running,standby,blocked,nopower,fault,unloaded,invalid",
			default = "stopped",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read the state of a TA3/TA4 machine.\n", 
		},
	},
	button = function(data, environ)  -- default button label
		return 'sts('..techage.fmt_number(data.number)..","..data.operand..' '..data.value..')'
	end,
	code = function(data, environ) 
		return send_single_string(environ, data.number, "state"),
			techage.operand(data.operand)..'"'..data.value..'"'
	end,
})

techage.icta_register_condition("fuel", {
	title = "read amount of fuel",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "block number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			label = "",
			choices = "greater,less",
			default = "greater",
		},
		{
			type = "digits",
			name = "value",
			label = "than",
			default = ""
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read and evaluate the fuel value\nof a fuel consuming block.", 
		},
	},
	button = function(data, environ) 
		return 'fuel('..techage.fmt_number(data.number)..","..data.operand..' '..data.value..')'
	end,
	code = function(data, environ) 
		return send_single_string(environ, data.number, "fuel"),
			techage.operand(data.operand)..tonumber(data.value)
	end,
})

techage.icta_register_condition("load", {
	title = "read power/liquid load",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "block number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			label = "",
			choices = "greater,less",
			default = "greater",
		},
		{
			type = "digits",
			name = "value",
			label = "than",
			default = ""
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read and evaluate the load (0..100)\nof a tank/storage block.", 
		},
	},
	button = function(data, environ) 
		return 'load('..techage.fmt_number(data.number)..","..data.operand..' '..data.value..')'
	end,
	code = function(data, environ) 
		return send_single_string(environ, data.number, "load"),
			techage.operand(data.operand)..tonumber(data.value)
	end,
})

techage.icta_register_condition("depth", {
	title = "read quarry depth",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "quarry number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			label = "",
			choices = "greater,less",
			default = "greater",
		},
		{
			type = "digits",
			name = "value",
			label = "than",
			default = ""
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read and evaluate the current\ndepth of a quarry block.", 
		},
	},
	button = function(data, environ) 
		return 'depth('..techage.fmt_number(data.number)..","..data.operand..' '..data.value..')'
	end,
	code = function(data, environ) 
		return send_single_string(environ, data.number, "depth"),
			techage.operand(data.operand)..tonumber(data.value)
	end,
})

techage.icta_register_condition("delivered", {
	title = "read delivered power",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "block number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			label = "",
			choices = "greater,less",
			default = "greater",
		},
		{
			type = "digits",
			name = "value",
			label = "than",
			default = ""
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read and evaluate the delivered\npower of a generator block.\nPower consuming blocks like accus\ncould also provide a negative value.", 
		},
	},
	button = function(data, environ) 
		return 'deliv('..techage.fmt_number(data.number)..","..data.operand..' '..data.value..')'
	end,
	code = function(data, environ) 
		return send_single_string(environ, data.number, "delivered"),
			techage.operand(data.operand)..tonumber(data.value)
	end,
})

techage.icta_register_condition("chest", {
	title = "read chest state",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "chest number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			label = "",
			choices = "is,is not",
			default = "is",
		},
		{
			type = "textlist",
			name = "value",
			label = "",
			choices = "empty,loaded,full,invalid",
			default = "empty",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read the state from a Techage chest\n"..
				"and other similar blocks.", 
		},
	},
	button = function(data, environ)  -- default button label
		return 'chest('..techage.fmt_number(data.number)..","..data.operand..' '..data.value..')'
	end,
	code = function(data, environ) 
		return send_single_string(environ, data.number, "state"),
			techage.operand(data.operand)..'"'..data.value..'"'
	end,
})

techage.icta_register_condition("signaltower", {
	title = "read Signal Tower state",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "Signal Tower number",
			default = "",
		},
		{
			type = "textlist",
			name = "operand",
			choices = "is,is not",
			default = "is",
		},
		{
			type = "textlist",
			name = "value",
			choices = "off,green,amber,red,invalid",
			default = "off",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read the color state\nof a Signal Tower.", 
		},
	},
	button = function(data, environ)  -- default button label
		return 'tower('..techage.fmt_number(data.number)..","..data.operand..' '..data.value..')'
	end,
	code = function(data, environ) 
		return send_single_string(environ, data.number, "state"),
			techage.operand(data.operand)..'"'..data.value..'"'
	end,
})

techage.icta_register_action("signaltower", {
	title = "send Signal Tower command",
	formspec = {
		{
			type = "numbers", 
			name = "number", 
			label = "Signal Tower number", 
			default = "",
		},
		{
			type = "textlist", 
			name = "value",
			label = "lamp color",      
			choices = "off,green,amber,red", 
			default = "red",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Turn on/off a Signal Tower lamp.", 
		},
	},
	button = function(data, environ) 
		return 'tower('..techage.fmt_number(data.number)..","..data.value..')'
	end,
	code = function(data, environ)
		return send_multi_string(environ, data.number, data.value)
	end,
})

techage.icta_register_action("switch", {
	title = "turn block on/off",
	formspec = {
		{
			type = "numbers", 
			name = "number", 
			label = "block number(s)", 
			default = "",
		},
		{
			type = "textlist", 
			name = "value",
			label = "state",      
			choices = "on,off", 
			default = "on",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Used for lamps, machines, gates,...", 
		},
	},
	button = function(data, environ) 
		return 'turn('..techage.fmt_number(data.number)..","..data.value..')'
	end,
	code = function(data, environ)
		return send_multi_string(environ, data.number, data.value)
	end,
})

techage.icta_register_action("display", {
	title = "Display: overwrite one line",
	formspec = {
		{
			type = "numbers", 
			name = "number", 
			label = "Display number", 
			default = "",
		},
		{
			type = "textlist", 
			name = "row", 
			label = "Display line", 
			choices = "1,2,3,4,5", 
			default = "1",
		},
		{
			type = "ascii", 
			name = "text",
			label = "text",      
			default = "",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Use a '*' character as reference\nto any condition result", 
		},
	},
	code = function(data, environ) 
		local s1 = string.format('local text = string.gsub("%s", "*", tostring(env.result[#]))', techage.icta_escape(data.text))
		local s2 = string.format('local payload = {row = %s, str = text}', data.row)
		local s3 = send_multi_string(environ, data.number, "set", "payload")
		return s1.."\n\t"..s2.."\n\t"..s3
	end,
	button = function(data, environ) 
		return "lcd("..techage.fmt_number(data.number)..","..data.row..',"'..data.text..'")'
	end,
})

techage.icta_register_action("cleardisplay", {
	title = "Display: Clear screen",
	formspec = {
		{
			type = "number", 
			name = "number", 
			label = "Display number", 
			default = "",
		},
	},
	code = function(data, environ) 
		return send_multi_string(environ, data.number, "clear")
	end,
	button = function(data, environ) 
		return "clear lcd("..techage.fmt_number(data.number)..")"
	end,
})

techage.icta_register_action("chat", {
	title = "send chat message",
	formspec = {
		{
			type = "ascii", 
			name = "text",
			label = "message",      
			default = "",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "The chat message is send to the\nController owner, only.", 
		},
	},
	code = function(data, environ) 
		return 'minetest.chat_send_player("'..environ.owner..'", "[TA4 ICTA Controller] '..data.text..'    ")'
	end,
	button = function(data, environ) 
		return 'chat("'..data.text:sub(1,12)..'")'
	end,
})

function techage.icta_door_toggle(pos, owner, state)
	pos = minetest.string_to_pos("("..pos..")")
	if pos then
		local door = doors.get(pos)
		if door then
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
end

techage.icta_register_action("door", {
	title = "open/close door",
	formspec = {
		{
			type = "digits", 
			name = "pos", 
			label = "door position like: 123,7,-1200", 
			default = "",
		},
		{
			type = "textlist", 
			name = "door_state",
			label = "door state",      
			choices = "open,close", 
			default = "open",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "For standard doors like the Steel Doors.\n"..
				"Use the Techage Info Tool to\neasily determine a door position.", 
		},
	},
	code = function(data, environ) 
		return 'techage.icta_door_toggle("'..data.pos..'", "'..environ.owner..'", "'..data.door_state..'")'
	end,
	button = function(data, environ) 
		return 'door("'..data.pos..'",'..data.door_state..")"
	end,
})

function techage.icta_player_detect(own_num, number, name)
	local state = techage.send_single(own_num, number, "name", nil)
	if state ~= "" then
		if name == "*" or string.find(name, state) then
			return state
		end
	elseif name == "-" then
		return state
	end
	return nil
end

techage.icta_register_condition("playerdetector", {
	title = "read Player Detector",
	formspec = {
		{
			type = "number",
			name = "number",
			label = "Player Detector number",
			default = "",
		},
		{
			type = "ascii",
			name = "name",
			label = "player name(s) or * for all",
			default = "",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Read and check the name\nof a Player Detector.\nUse a '*' character for all player names.\n Use a '-' character for no player.", 
		},
	},
	
	code = function(data, environ) 
		return 'techage.icta_player_detect("'..environ.number..'", "'..data.number..'", "'..data.name..'")', "~= nil"
	end,
	button = function(data, environ) 
		return "detector("..techage.fmt_number(data.number)..","..data.name:sub(1,8)..")"
	end,
})

techage.icta_register_action("set_filter", {
	title = "turn Distributor filter on/off",
	formspec = {
		{
			type = "number", 
			name = "number", 
			label = "distri number", 
			default = "",
		},
		{
			type = "textlist", 
			name = "color",
			label = "filter port",      
			choices = "red,green,blue,yellow", 
			default = "red",
		},
		{
			type = "textlist", 
			name = "value",
			label = "state",      
			choices = "on,off", 
			default = "on",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "turn Distributor filter port on/off\n", 
		},
	},
	button = function(data, environ) 
		return 'turn('..techage.fmt_number(data.number)..","..data.color..","..data.value..')'
	end,
	code = function(data, environ)
		local payload = '{slot = "'..data.color..'", val = "'..data.value..'"}'
		return send_single_string(environ, data.number, "filter", payload)
	end,
})

