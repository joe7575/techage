--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Lua Controller

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta

local sHELP = [[TA4 Lua Controller

 This controller is used to control and monitor
 TechAge machines.
 This controller can be programmed in Lua.

 See on GitHub for more help:
 https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md

 or download the PDF file from:
 https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.pdf

]]

techage.lua_ctlr = {}

local Cache = {}

local STATE_STOPPED = 0
local STATE_RUNNING = 1
local CYCLE_TIME = 1
local CREDITS = 10
local MAX_CREDITS = 100

local tCommands = {}
local tFunctions = {" Overview", " Data structures"}
local tHelpTexts = {[" Overview"] = sHELP, [" Data structures"] = safer_lua.DataStructHelp}
local sFunctionList = ""
local tFunctionIndex = {}

safer_lua.config(safer_lua.MaxCodeSize * 4, safer_lua.MaxTableSize, safer_lua.MaxExeTime * 10)

minetest.after(2, function()
	sFunctionList = table.concat(tFunctions, ",")
	for idx,key in ipairs(tFunctions) do
		tFunctionIndex[key] = idx
	end
end)

local function output(pos, text)
	local meta = M(pos)
	text = meta:get_string("output") .. "\n" .. (text or "")
	text = text:sub(-500,-1)
	meta:set_string("output", text)
end

--
-- API functions for function/action registrations
--
function techage.lua_ctlr.register_function(key, attr)
	tCommands[key] = attr.cmnd
	table.insert(tFunctions, " $"..key)
	tHelpTexts[" $"..key] = attr.help
end

function techage.lua_ctlr.register_action(key, attr)
	tCommands[key] = attr.cmnd
	table.insert(tFunctions, " $"..key)
	tHelpTexts[" $"..key] = attr.help
end

local function merge(dest, keys, values)
  for idx,key in ipairs(keys) do
    dest.env[key] = values[idx]
  end
  return dest
end

local function restart_timer(pos, cycletime)
	minetest.get_node_timer(pos):stop()
	if cycletime > 0 then
		minetest.get_node_timer(pos):start(cycletime)
	end
end

techage.lua_ctlr.register_action("print", {
	cmnd = function(self, text)
		local pos = self.meta.pos
		text = tostring(text or "")
		output(pos, text)
		--print("Lua: "..text)
	end,
	help = " $print(text)\n"..
		" Send a text line to the output window.\n"..
		' e.g. $print("Hello "..name)'
})

techage.lua_ctlr.register_action("loopcycle", {
	cmnd = function(self, cycletime)
		cycletime = math.floor(tonumber(cycletime) or 0)
		local pos = self.meta.pos
		minetest.after(0, restart_timer, pos, cycletime)
	end,
	help = "$loopcycle(seconds)\n"..
		" This function allows to change the\n"..
		" call frequency of the loop() function.\n"..
		" value is in seconds, 0 = disable\n"..
		' e.g. $loopcycle(10)'
})

techage.lua_ctlr.register_action("events", {
	cmnd = function(self, event)
		self.meta.events = event or false
	end,
	help = "$events(true/false)\n"..
		" Enable/disable event handling.\n"..
		' e.g. $events(true) -- enable events'
})

techage.lua_ctlr.register_function("get_ms_time", {
	cmnd = function(self)
		return math.floor(minetest.get_us_time() / 1000)
	end,
	help = " ms = $get_ms_time()\n"..
		" returns time with millisecond precision."
})

techage.lua_ctlr.register_function("get_gametime", {
	cmnd = function(self)
		return minetest.get_gametime()
	end,
	help = " t = $get_gametime()\n"..
		" returns the time, in seconds, since the world was created."
})

techage.lua_ctlr.register_function("position", {
	cmnd = function(self, number)
		local info = techage.get_node_info(number)
		if info then
			return S(info.pos)
		end
		return "(-,-,-)"
	end,
	help = " pos = $position(number)\n"..
		" returns the position '(x,y,z)' of the device\n with given number."
})

local function formspec1(meta)
	local state = meta:get_int("state") == techage.RUNNING
	local cmnd = state and "stop;Stop" or "start;Start"
	local init = meta:get_string("init")
	init = minetest.formspec_escape(init)
	return "size[10,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[textarea;font=mono;textcolor=#FFFFFF;border=false]"..
	"tabheader[0,0;tab;init,func,loop,outp,notes,help;1;;true]"..
	"textarea[0.3,0.2;10,8.3;init;function init();"..init.."]"..
	"background[0.1,0.3;9.8,7.0;techage_form_mask.png]"..
	"label[0,7.3;end]"..
	"button_exit[4.4,7.5;1.8,1;cancel;Cancel]"..
	"button[6.3,7.5;1.8,1;save;Save]"..
	"button[8.2,7.5;1.8,1;"..cmnd.."]"
end

local function formspec2(meta)
	local state = meta:get_int("state") == techage.RUNNING
	local cmnd = state and "stop;Stop" or "start;Start"
	local func = meta:get_string("func")
	func = minetest.formspec_escape(func)
	return "size[10,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[textarea;font=mono;textcolor=#FFFFFF;border=false]"..
	"tabheader[0,0;tab;init,func,loop,outp,notes,help;2;;true]"..
	"textarea[0.3,0.2;10,8.3;func;functions:;"..func.."]"..
	"background[0.1,0.3;9.8,7.0;techage_form_mask.png]"..
	"button_exit[4.4,7.5;1.8,1;cancel;Cancel]"..
	"button[6.3,7.5;1.8,1;save;Save]"..
	"button[8.2,7.5;1.8,1;"..cmnd.."]"
end

local function formspec3(meta)
	local state = meta:get_int("state") == techage.RUNNING
	local cmnd = state and "stop;Stop" or "start;Start"
	local loop = meta:get_string("loop")
	loop = minetest.formspec_escape(loop)
	return "size[10,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[textarea;font=mono;textcolor=#FFFFFF;border=false]"..
	"tabheader[0,0;tab;init,func,loop,outp,notes,help;3;;true]"..
	"textarea[0.3,0.2;10,8.3;loop;function loop(ticks, elapsed);"..loop.."]"..
	"background[0.1,0.3;9.8,7.0;techage_form_mask.png]"..
	"label[0,7.3;end]"..
	"button_exit[4.4,7.5;1.8,1;cancel;Cancel]"..
	"button[6.3,7.5;1.8,1;save;Save]"..
	"button[8.2,7.5;1.8,1;"..cmnd.."]"
end

local function formspec4(meta)
	local state = meta:get_int("state") == techage.RUNNING
	local cmnd = state and "stop;Stop" or "start;Start"
	local output = meta:get_string("output")
	output = minetest.formspec_escape(output)
	output = output:gsub("\n", ",")
	return "size[10,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"tabheader[0,0;tab;init,func,loop,outp,notes,help;4;;true]"..
	"table[0.2,0.2;9.5,7;output;"..output..";200]"..
	"button[4.4,7.5;1.8,1;clear;Clear]"..
	"button[6.3,7.5;1.8,1;update;Update]"..
	"button[8.2,7.5;1.8,1;"..cmnd.."]"
end

local function formspec5(meta)
	local notes = meta:get_string("notes")
	notes = minetest.formspec_escape(notes)
	return "size[10,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[textarea;font=mono;textcolor=#FFFFFF;border=false]"..
	"tabheader[0,0;tab;init,func,loop,outp,notes,help;5;;true]"..
	"textarea[0.3,0.2;10,8.3;notes;Notepad:;"..notes.."]"..
	"background[0.1,0.3;9.8,7.0;techage_form_mask.png]"..
	"button_exit[6.3,7.5;1.8,1;cancel;Cancel]"..
	"button[8.2,7.5;1.8,1;save;Save]"
end

local function formspec6(items, pos, text)
	text = minetest.formspec_escape(text)
	return "size[10,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"style_type[textarea;font=mono;textcolor=#FFFFFF]"..
	"tabheader[0,0;tab;init,func,loop,outp,notes,help;6;;true]"..
	"label[0,-0.2;Functions:]"..
	"dropdown[0.3,0.2;10,8.3;functions;"..items..";"..pos.."]"..
	"textarea[0.3,1.3;10,8;help;Help:;"..text.."]"
end

local function patch_error_string(err, line_offs)
	local tbl = {}
	for s in err:gmatch("[^\r\n]+") do
		if s:find("loop:(%d+):") then
			local prefix, line, err = s:match("(.-)loop:(%d+):(.+)")
			if prefix and line and err then
				if tonumber(line) < line_offs then
					table.insert(tbl, prefix.."func:"..line..":"..err)
				else
					line = tonumber(line) - line_offs
					table.insert(tbl, prefix.."loop:"..line..":"..err)
				end
			end
		else
			table.insert(tbl, s)
		end
	end
	return table.concat(tbl, "\n")
end

local function error(pos, err)
	local meta = M(pos)
	local func = meta:get_string("func")
	local _,line_offs = string.gsub(func, "\n", "\n")
	line_offs = line_offs + 1
	err = patch_error_string(err, line_offs)
	output(pos, err)
	local number = meta:get_string("number")
	meta:set_string("infotext", "Controller "..number..": error")
	meta:set_int("state", techage.STOPPED)
	meta:set_string("formspec", formspec4(meta))
	minetest.get_node_timer(pos):stop()
	return false
end

local function compile(pos, meta, number)
	local init = meta:get_string("init")
	local func = meta:get_string("func")
	local loop = meta:get_string("loop")
	local owner = meta:get_string("owner")
	local env = table.copy(tCommands)
	env.meta = {pos=pos, owner=owner, number=number, error=error}
	local code = safer_lua.init(pos, init, func.."\n"..loop, env, error)

	if code then
		Cache[number] = {code=code, inputs={}, events=env.meta.events}
		Cache[number].inputs.term = nil  -- terminal inputs
		Cache[number].inputs.msg = {}  -- message queue
		return true
	end
	return false
end

local function start_controller(pos)
	local meta = M(pos)
	local number = meta:get_string("number")
	meta:set_string("output", "")

	if compile(pos, meta, number) then
		meta:set_int("state", techage.RUNNING)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		meta:set_string("formspec", formspec4(meta))
		meta:set_string("infotext", "Controller "..number..": running")
		return true
	end
	return false
end

local function stop_controller(pos)
	local meta = M(pos)
	local number = meta:get_string("number")
	meta:set_int("state", techage.STOPPED)
	minetest.get_node_timer(pos):stop()
	meta:set_string("infotext", "Controller "..number..": stopped")
	meta:set_string("formspec", formspec3(meta))
end

local function call_loop(pos, elapsed, credits)
	local meta = M(pos)
	local number = meta:get_string("number")
	if meta:get_int("state") == techage.RUNNING then
		if Cache[number] or compile(pos, meta, number) then
			local code = Cache[number].code
			Cache[number].event_pending = false
			local dt = minetest.get_gametime() - (Cache[number].last_time or 0)
			credits = math.min(safer_lua.add_credits(code, credits * dt), MAX_CREDITS)
			Cache[number].last_time = minetest.get_gametime()
			if credits > 0 then
				local res = safer_lua.run_loop(pos, elapsed, code, error)
				local state = res and "running" or "stopped"
				meta:set_string("infotext", "Controller "..number..": "..state.." ("..credits.." credits)")
				return res
			end
			meta:set_string("infotext", "Controller "..number..": running ("..credits.." credits)")
			return true
		end
	end
	return false
end

local function on_timer(pos, elapsed)
	if techage.is_activeformspec(pos) then
		local meta = M(pos)
		meta:set_string("formspec", formspec4(meta))
	end
	return call_loop(pos, elapsed, CREDITS)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local meta = M(pos)

	--print(dump(fields))
	techage.reset_activeformspec(pos, player)
	
	if fields.cancel == nil then
		if fields.init then
			meta:set_string("init", fields.init)
			meta:set_string("formspec", formspec1(meta))
		elseif fields.func then
			meta:set_string("func", fields.func)
			meta:set_string("formspec", formspec2(meta))
		elseif fields.loop then
			meta:set_string("loop", fields.loop)
			meta:set_string("formspec", formspec3(meta))
		elseif fields.notes then
			meta:set_string("notes", fields.notes)
			meta:set_string("formspec", formspec5(meta))
		end
	end

	if fields.update then
		meta:set_string("formspec", formspec4(meta))
		techage.set_activeformspec(pos, player)
	elseif fields.clear then
		meta:set_string("output", "<press update>")
		meta:set_string("formspec", formspec4(meta))
	elseif fields.tab == "1" then
		meta:set_string("formspec", formspec1(meta))
	elseif fields.tab == "2" then
		meta:set_string("formspec", formspec2(meta))
	elseif fields.tab == "3" then
		meta:set_string("formspec", formspec3(meta))
	elseif fields.tab == "4" then
		techage.set_activeformspec(pos, player)
		meta:set_string("formspec", formspec4(meta))
	elseif fields.tab == "5" then
		meta:set_string("formspec", formspec5(meta))
	elseif fields.tab == "6" then
		meta:set_string("formspec", formspec6(sFunctionList, 1, sHELP))
	elseif fields.start == "Start" then
		start_controller(pos)
		minetest.log("action", player:get_player_name() ..
			" starts the sl_controller at ".. minetest.pos_to_string(pos))
	elseif fields.stop == "Stop" then
		stop_controller(pos)
	elseif fields.functions then
		local key = fields.functions
		local text = tHelpTexts[key] or ""
		local pos = tFunctionIndex[key] or 1
		meta:set_string("formspec", formspec6(sFunctionList, pos, text))
	end
end

minetest.register_node("techage:ta4_lua_controller", {
	description = "TA4 Lua Controller",
	inventory_image = "techage_lua_controller_inventory.png",
	wield_image = "techage_lua_controller_inventory.png",
	stack_max = 1,
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_lua_controller.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local number = techage.add_node(pos, "techage:ta4_lua_controller")
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("number", number)
		meta:set_int("state", techage.STOPPED)
		meta:set_string("init", "-- called only once")
		meta:set_string("func", "-- for your functions")
		meta:set_string("loop", "-- called every second")
		meta:set_string("notes", "For your notes / snippets")
		meta:mark_as_private("init")
		meta:mark_as_private("func")
		meta:mark_as_private("loop")
		meta:mark_as_private("notes")
		meta:set_string("formspec", formspec1(meta))
		meta:set_string("infotext", "Controller "..number..": stopped")
	end,

	on_receive_fields = on_receive_fields,

	on_rightclick = function(pos, node, clicker)
		local meta = M(pos)
		if meta:get_int("state") == techage.RUNNING then
			techage.set_activeformspec(pos, clicker)
			meta:set_string("formspec", formspec4(meta))
		end
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	on_timer = on_timer,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=1, cracky=1, crumbly=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_craft({
	output = "techage:ta4_lua_controller",
	recipe = {
		{"basic_materials:plastic_sheet", "dye:blue", "techage:aluminum"},
		{"", "default:copper_ingot", ""},
		{"techage:ta4_ramchip", "techage:ta4_wlanchip", "techage:ta4_ramchip"},
	},
})

-- write inputs from remote nodes
local function set_input(pos, number, input, val)
	if input and M(pos):get_int("state") == techage.RUNNING then
		if (Cache[number] or compile(pos, M(pos), number)) and Cache[number].inputs then
			if input == "msg" then
				if #Cache[number].inputs["msg"] < 10 then
					table.insert(Cache[number].inputs["msg"], val)
				end
			else
				Cache[number].inputs[input] = val
			end
			if Cache[number].events and not Cache[number].event_pending then  -- events enabled
				Cache[number].event_pending = true
				minetest.after(0, call_loop, pos, -1, CREDITS)
			end
		end
	end
end

-- used by the command "input"
function techage.lua_ctlr.get_input(number, input)
	if input then
		if Cache[number] and Cache[number].inputs then
			return Cache[number].inputs[input] or "off"
		end
	end
	return "off"
end

function techage.lua_ctlr.get_next_input(number)
	if Cache[number] and Cache[number].inputs then
		local num, state = next(Cache[number].inputs or {})
		if num ~= "msg" and num ~= "term" then
			if num then
				Cache[number].inputs[num] = nil
			end
			return num, state
		end
	end
end

-- used for Terminal commands
function techage.lua_ctlr.get_command(number)
	if Cache[number] and Cache[number].inputs then
		local cmnd = Cache[number].inputs["term"]
		Cache[number].inputs["term"] = nil
		return cmnd
	end
end

-- used for queued messages
function techage.lua_ctlr.get_msg(number)
	if Cache[number] and Cache[number].inputs then
		return table.remove(Cache[number].inputs["msg"], 1)
	end
end

techage.register_node({"techage:ta4_lua_controller"}, {
	on_recv_message = function(pos, src, topic, payload)
		local meta = M(pos)
		local number = meta:get_string("number")

		if topic == "on" then
			set_input(pos, number, src, topic)
		elseif topic == "off" then
			set_input(pos, number, src, topic)
		elseif topic == "term" then
			set_input(pos, number, "term", payload)
		elseif topic == "msg" then
			set_input(pos, number, "msg", {src = src, data = payload})
		elseif topic == "state" then
			local state = meta:get_int("state") or techage.STOPPED
			return techage.StateStrings[state] or "stopped"
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local meta = M(pos)
		local number = meta:get_string("number")

		if topic == 1 and payload[1] == 1 then
			set_input(pos, number, src, "on")
		elseif topic == 1 and payload[1] == 0 then
			set_input(pos, number, src, "off")
		else
			return 2
		end
		return 0
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local meta = M(pos)

		if topic == 142 then
			local state = meta:get_int("stage") == techage.RUNNING and STATE_RUNNING or STATE_STOPPED
			return 0, {state}
		else
			return 2, ""
		end
	end,
})
