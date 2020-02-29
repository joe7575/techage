--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	ICTA Controller - Stopwatch
	
	Start/stop the watch with an on/off commands.
	The player name clicking the stop is stored in addition.

]]--

 -- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic

local function retrieve_clicker_name(number)
	local pos = techage.get_node_info(number).pos
	if pos then
		local meta = minetest.get_meta(pos)
		return meta:get_string("clicker_name") or "<unknown>"
	end
	return "<error>"
end

-- env = {
--     event = <bool>,
--     last_event = <number>  -- last event time
--     ticks = <number,
--     pos = <pos>,
--     timer = gen_table(8, 0),
--     blocked = gen_table(8, false),
--     result = gen_table(8, false),
--     condition = gen_table(8, false),
--     input = <table>,  -- node number is key
--     number = <number>,
--     owner = <string>,
-- },
--
-- return cond_result, trigger_action
function techage.stopwatch(env, data)
	if env.input[data.number] == "on" then
		env.time = env.last_event
		if not env.highscore then
			env.highscore = 99999
		end
		return nil, false
	else
		local time = (env.last_event - env.time) / 1000000
		local name = retrieve_clicker_name(data.number)
		env.highscore = math.min(time, env.highscore)
		local s1 = string.format("%2.1f s", time)
		local s2 = string.format("%2.1f s", env.highscore)
		env.stopwatch_result = {s1, s2, name}
		return nil, true
	end
end

techage.icta_register_condition("stopwatch", {
	title = "stopwatch",
	formspec = {
		{
			type = "numbers", 
			name = "number", 
			label = "Switch number", 
			default = "",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Hint: Stop the time between switching on\nand switching off of the connected switch.", 
		},
	},
	code = function(data, environ)
		return "techage.stopwatch"
	end,
	button = function(data, environ) 
		return 'stopwatch('..sl.fmt_number(data.number)..')'
	end,
})

techage.icta_register_action("stopwatch", {
	title = "stopwatch",
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
			choices = "1,2,3,4,5,6,7,8,9", 
			default = "1",
		},
		{
			type = "ascii", 
			name = "text",
			label = "label",      
			default = "",
		},
		{
			type = "textlist", 
			name = "type",
			label = "type",      
			choices = "time,highscore,name", 
			default = "time",
		},
		{
			type = "label", 
			name = "lbl", 
			label = "Hint: Display number for the output\nof time, highscore and player name.", 
		},
	},
	button = function(data, environ) 
		return "lcd("..sl.fmt_number(data.number)..","..data.row..","..data.type..')'
	end,
	code = function(data, environ)
		local idx = ({time=1, highscore= 2, name=3})[data.type]
		local s1 = string.format('local payload = {row = %s, str = "%s "..env.stopwatch_result['..idx..']}', data.row, techage.escape(data.text))
		local s2 = string.format('techage.send_multi("%s", "%s", "row", payload)', environ.number, data.number)
		return s1.."\n\t"..s2
	end,
})
