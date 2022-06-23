--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Sequencer

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic

local HELP = S("Syntax:\n") ..
	S("'[<num>] <command>'\n") ..
	S("\n") ..
	S("<num> is a number from 1 to 50000 and is\n") ..
	S("the timeslot when the command is executed.\n") ..
	S(" - 1 corresponds to 100 ms\n") ..
	S(" - 50000 corresponds to 4 game days\n") ..
	S("\n") ..
	S("<command> is one of the following:\n") ..
	S(" - 'send <node num> <cmnd>' (techage command)\n") ..
	S(" - 'goto <num>'  (jump to another line)\n") ..
	S(" - 'stop' (stop the execution)\n") ..
	S(" - 'nop' (do nothing)\n") ..
	S("\n") ..
	S("Example:\n") ..
	" -- move controller commands\n" ..
	" [1] send 1234 a2b\n" ..
	" [30] send 1234 b2a\n" ..
	" [60] goto 1 -- keep going"

local function strsplit(text)
	text = text:gsub("\r\n", "\n")
	text = text:gsub("\r", "\n")
	return string.split(text, "\n", true)
end

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function command(s)
	local num, cmd, pld = unpack(string.split(s, " ", false, 2))
	if not num or not cmd then
		return S("Invalid command!")
	end
	return {number = num, cmnd = cmd, payload = pld}
end

local function add_error(text, line_num)
	local tbl = {}
	for idx, line in ipairs(strsplit(text)) do
		if idx == line_num and not string.find(line, '--<<== error') then
			tbl[#tbl+1] = line.."  --<<== error"
		else
			tbl[#tbl+1] = line
		end
	end
	return table.concat(tbl, "\n")
end

local function exception(tRes, line, s)
	if tRes then
		tRes.line = line
		tRes.error = s
	end
end

local function compile(s, tRes)
	local tCode = {}
	local old_idx = 0
	local start_idx

	for i, line in ipairs(strsplit(s)) do
		line = trim(line)
		line = string.split(line, "--", true, 1)[1] or ""
		if line ~= "" then
			local idx, cmnd1, cmnd2 = unpack(string.split(line, " ", false, 2))
			idx = tonumber(string.match(idx, "^%[(%d+)%]$"))
			if not idx then
				return exception(tRes, i, "Syntax error!")
			end
			if idx > 50000 then
				return exception(tRes, i, "Order error!")
			end
			if idx <= old_idx then
				return exception(tRes, i, "Order error!")
			end
			start_idx = start_idx or idx
			if old_idx ~= 0 and tCode[old_idx] and not tCode[old_idx].next_idx then
				tCode[old_idx].next_idx = idx
			end
			if cmnd1 == "send" then
				local res = command(cmnd2)
				if type(res) == "string" then
					return exception(tRes, i, res)
				end
				tCode[idx] = res
			elseif cmnd1 == "goto" then
				tCode[idx] = {next_idx = tonumber(cmnd2) or 1}
			elseif cmnd1 == "stop" then
				tCode[idx] = false
			elseif cmnd1 == nil or cmnd1 == "nop" then
				tCode[idx] = {}
			end
			old_idx = idx
		end
	end
	-- Returns:
	-- {
	--   start_idx = 1,
	--   tCode = {
	--     <idx> = {number = <number>, cmnd = <string>, payload = <data>, next_idx = <idx>},
	--     ...
	--   },
	-- }
	return {start_idx=start_idx, tCode=tCode}
end

local function check_syntax(meta)
	local tRes = {}
	local res = compile(meta:get_string("text"), tRes)
	if not res then
		meta:set_string("err_msg", tRes.error)
		meta:set_string("text", add_error(meta:get_string("text"), tRes.line))
		return false
	else
		meta:set_string("err_msg", "")
		return true
	end
end

local function formspec(nvm, meta)
	local text = meta:get_string("text")
	text = minetest.formspec_escape(text)
	local bttn = nvm.running and ("stop;" .. S("Stop")) or ("start;" .. S("Start"))
	local style = nvm.running and "style_type[textarea;font=mono;textcolor=#888888;border=false]" or
		"style_type[textarea;font=mono;textcolor=#FFFFFF;border=false]"
	local textarea = nvm.running and "textarea[0.3,0.2;10,8.3;;;"..text.."]" or
			"textarea[0.3,0.2;10,8.3;text;;"..text.."]"

	return "size[10,8]" ..
		style ..
		"tabheader[0,0;tab;edit,help;1;;true]" ..
		"label[0.1,-0.2;" .. S("Commands") .. ":]" ..
		textarea ..
		"background[0.1,0.3;9.8,7.0;techage_form_mask.png]" ..
		"label[0.1,7.5;" .. meta:get_string("err_msg") .. "]" ..
		"button_exit[3.4,7.5;2.2,1;cancel;" .. S("Cancel") .. "]" ..
		"button[5.6,7.5;2.2,1;save;" .. S("Save") .. "]" ..
		"button[7.8,7.5;2.2,1;" ..  bttn .. "]"
end

local function formspec_help(meta)
	local text = "" --minetest.formspec_escape("hepl")
	return "size[10,8]"..
		"style_type[textarea;font=mono;textcolor=#FFFFFF;border=false]"..
		"tabheader[0,0;tab;edit,help;2;;true]"..
		"textarea[0.3,0.3;10,9;;" .. S("Help") .. ":;"..minetest.formspec_escape(HELP).."]" ..
		"background[0.1,0.3;9.8,8.0;techage_form_mask.png]"
end

local function restart_timer(pos, time)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		timer:stop()
	end
	timer:start(time / 10)
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	if nvm.running then
		local mem = techage.get_mem(pos)
		mem.code = mem.code or compile(M(pos):get_string("text"))
		if mem.code then
			mem.idx = mem.idx or mem.code.start_idx
			local code = mem.code.tCode[mem.idx]
			if code and code.cmnd then
				local src = M(pos):get_string("node_number")
				techage.counting_start(M(pos):get_string("owner"))
				techage.send_single(src, code.number, code.cmnd, code.payload)
				techage.counting_stop()
			end
			if code and code.next_idx then
				local offs = code.next_idx - mem.idx
				minetest.after(0, restart_timer, pos, math.max(offs, 1))
				mem.idx = code.next_idx
			else
				nvm.running = false
				local meta = M(pos)
				meta:set_string("formspec", formspec(nvm, meta))
				logic.infotext(meta, S("TA4 Sequencer"), S("stopped"))
			end
		end
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	nvm.running = nvm.running or false

	if fields.stop then
		nvm.running = false
		minetest.get_node_timer(pos):stop()
		logic.infotext(meta, S("TA4 Sequencer"), S("stopped"))
	elseif not nvm.running then
		if fields.tab == "2" then
			meta:set_string("formspec", formspec_help(meta))
			return
		elseif fields.tab == "1" then
			meta:set_string("formspec", formspec(nvm, meta))
			return
		end

		if fields.save then
			nvm.running = false
			meta:set_string("text", fields.text or "")
			mem.code = nil
			mem.idx = nil
		elseif fields.start then
			if check_syntax(meta) then
				nvm.running = true
				meta:set_string("text", fields.text or "")
				mem.code = nil
				mem.idx = nil
				minetest.get_node_timer(pos):start(0.5)
				logic.infotext(meta, S("TA4 Sequencer"), S("running"))
			end
		end
	end
	meta:set_string("formspec", formspec(nvm, meta))
end

minetest.register_node("techage:ta4_sequencer", {
	description = S("TA4 Sequencer"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_sequencer.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		logic.after_place_node(pos, placer, "techage:ta4_sequencer", S("TA4 Sequencer"))
		logic.infotext(meta, S("TA4 Sequencer"), S("stopped"))
		nvm.running = false
		meta:set_string("formspec", formspec(nvm, meta))
	end,

	on_receive_fields = on_receive_fields,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	on_timer = node_timer,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_craft({
	output = "techage:ta4_sequencer",
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"techage:ta4_ramchip", "default:mese_crystal", "techage:ta4_wlanchip"},
		{"techage:aluminum", "group:wood", "techage:aluminum"},
	},
})

local INFO = [[Commands: 'goto <num>', 'stop', 'on', 'off']]

techage.register_node({"techage:ta4_sequencer"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if (topic == "goto" or topic == "on") and not nvm.running then
			local mem = techage.get_mem(pos)
			nvm.running = true
			mem.idx = tonumber(payload or 1) or 1
			restart_timer(pos, 0.1)
			logic.infotext(M(pos), S("TA4 Sequencer"), S("running"))
		elseif topic == "stop" or topic == "off" then
			nvm.running = false
			minetest.get_node_timer(pos):stop()
			logic.infotext(M(pos), S("TA4 Sequencer"), S("stopped"))
		elseif topic == "info" then
			return INFO
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 13 then
			if payload[1] ~= 0 and not nvm.running then
				local mem = techage.get_mem(pos)
				nvm.running = true
				mem.idx = tonumber(payload or 1) or 1
				restart_timer(pos, 0.1)
				logic.infotext(M(pos), S("TA4 Sequencer"), S("running"))
				return 0
			elseif payload[1] == 0 then
				nvm.running = false
				minetest.get_node_timer(pos):stop()
				logic.infotext(M(pos), S("TA4 Sequencer"), S("stopped"))
				return 0
			end
		end
		return 2
	end,
})
