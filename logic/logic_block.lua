--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Logic Block 2

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic
local NUM_RULES = 4

local HELP = S("Send an 'on'/'off' command if the\nexpression becomes true.\n") ..
	S("\nRule:\n<output> = on/off if <input-expression> is true\n") ..
	S("\n<output> is the block number to which the\ncommand should be sent.\n") ..
	S("\n<input-expression> is a boolean expression\nwhere input numbers are evaluated.\n") ..
	S("\nExamples:\n1234 == on\n1234 == off\n1234 == on and 2345 == off\n2345 ~= 3456\n") ..
	S("\nValid operators:\nand   or   on   off   me   ==   ~=   (   )\n") ..
	S("'~=' means: not equal\n") ..
	S("'me' has to be used for the own block number.\n") ..
	S("\nAll rules are checked with each received\ncommand.") ..
	S("\nThe internal processing time for all\ncommands is 100 ms.")

local ValidSymbols = {
	["me"] = true,
	["and"] = true,
	["or"] = true,
	["on"] = true,
	["off"] = true,
	["=="] = true,
	["~="] = true,
	["("] = true,
	[")"] = true,
}

local Dropdown = {
	[""] = 1,
	["on"] = 2,
	["off"] = 3
}

local function check_expr(pos, expr)
	local nvm = techage.get_nvm(pos)
	local origin = expr
	-- Add blanks for the syntax check
	expr = expr:gsub("==", " == ")
	expr = expr:gsub("~=", " ~= ")
	expr = expr:gsub("%(", " ( ")
	expr = expr:gsub("%)", " ) ")

	-- First syntax check
	local old_sym = "or"  -- valid default value
	for sym in expr:gmatch("[^%s]+") do
		if not ValidSymbols[sym] and string.find(sym, '^[0-9]+$') == nil then
			return "Unexpected symbol '"..sym.."'"
		end
		if string.find(sym, '^[0-9]+$') and sym == nvm.own_num then
			return "Invalid node number '"..sym.."'"
		end
		-- function call check
		if sym == "(" and (old_sym ~= "and" and old_sym ~= "or") then
			return "Syntax error at '" .. sym .. "'"
		end
		old_sym = sym
	end
	-- Second syntax check
	local code, _ = loadstring("return " .. expr)
	if not code then
		return "Syntax error in '" .. origin .. "'"
	end
end

local function check_num(pos, num, player_name)
	local nvm = techage.get_nvm(pos)

	if num ~= "me" and (num == nvm.own_num or
			not techage.check_numbers(num, player_name)) then
		return "Invalid node number '"..num.."'"
	end
end

local function debug(mem, text)
	mem.debug = mem.debug or {}
	if #mem.debug > 20 then
		table.remove(mem.debug, 1)
	end
	local s = string.format("%.3f", techage.SystemTime) .. " s: " .. text
	table.insert(mem.debug, s)
end

local function send(pos, num, val)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	debug(mem, "(outp) " .. num .. " = " .. val)

	if num == "me" then
		nvm.outp_tbl = nvm.outp_tbl or {}
		nvm.outp_tbl.me = val
		-- set the input directly
		nvm.inp_tbl = nvm.inp_tbl or {}
		nvm.inp_tbl.me = val
	else
		nvm.outp_tbl = nvm.outp_tbl or {}
		nvm.outp_tbl[num] = val
		nvm.own_num = nvm.own_num or M(pos):get_string("node_number")
		techage.send_single(nvm.own_num, num, val)
	end
end

local function get_inputs(pos)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	-- old data is needed for formspec 'input' values
	nvm.old_inp_tbl = table.copy(nvm.inp_tbl or {})
	for _, num in ipairs(mem.outp_num or {}) do
		nvm.old_inp_tbl[num] = nvm.outp_tbl[num] or "off"
	end
	return nvm.old_inp_tbl
end

local function check_syntax(pos, line, owner, outp, expr)
	local err = check_num(pos, outp, owner)
	if not err then
		err = check_expr(pos, expr)
		if not err then
			return true, "ok"
		end
	end
	return false, "Error(" .. line .. "): " .. err
end

local function compile(nvm, str)
    if str then
        local code, _ = loadstring(str)
		if code then
			nvm.error = "ok"
			return code
		else
			nvm.error = "Unknown compile error"
		end
    end
end

local function data(nvm)
	local inp = {}
	local outp = {}
	for num, val in pairs(nvm.old_inp_tbl or {}) do
		if num == nvm.own_num then num = "me" end
		inp[#inp+1] = num .. " = " .. tostring(val)
	end
	for num, val in pairs(nvm.outp_tbl or {}) do
		if num == nvm.own_num then num = "me" end
		outp[#outp+1] = num .. " = " .. tostring(val)
	end
	return table.concat(inp, ",  "), table.concat(outp, ",  ")
end

local function get_code(pos, nvm, mem)
	local meta = M(pos)
	local tbl = {"local inputs = get_inputs(pos) or {}"}
	local owner = M(pos):get_string("owner")
	nvm.own_num = nvm.own_num or M(pos):get_string("node_number")
	mem.outp_num = {}

	for i = 1,NUM_RULES do
		local outp = meta:get_string("outp" .. i)
		local val  = meta:get_string("val"  .. i)
		local expr = meta:get_string("expr" .. i)

		if outp ~= "" and val ~= "" and expr ~= "" then
			local res, err = check_syntax(pos, i, owner, outp, expr)
			if res then
				expr = string.gsub(expr, '([0-9]+)', 'inputs["%1"]')
				expr = string.gsub(expr, 'me', 'inputs["me"]')
				expr = string.gsub(expr, 'on', '"on"')
				expr = string.gsub(expr, 'off', '"off"')
				tbl[#tbl + 1]  = "if "..expr.." then send(pos, '"..outp.."', '"..val.."') end"
				table.insert(mem.outp_num, outp)
			else
				nvm.error = err
				return
			end
		end
	end

	local str = table.concat(tbl, "\n")
	local code = compile(nvm, str)
	if code then
		local env = {}
		env.send = send
		env.pos = pos
		env.get_inputs = get_inputs
		setfenv(code, env)

		return code
	end
end

local function execute(pos)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.code = mem.code or get_code(pos, nvm, mem)
	if mem.code then
		local res, _ = pcall(mem.code)
		if not res then
			nvm.error = "Unknown runtime error"
			mem.code = nil
		end
	end
end

local function rules(meta)
	local tbl = {}

	tbl[#tbl + 1] = "label[-0.2,0;<outp>]"
	tbl[#tbl + 1] = "label[1.4,0;=]"
	tbl[#tbl + 1] = "label[1.8,0;<cmnd>]"
	tbl[#tbl + 1] = "label[3.5,0;if]"
	tbl[#tbl + 1] = "label[4.2,0;<inp expression> is true]"


	for i = 1,NUM_RULES do
		local y1 = (i * 0.9) - 0.1
		local y2 = (i * 0.9) - 0.2
		local y3 = (i * 0.9) - 0.3
		local outp = meta:get_string("outp" .. i)
		local val  = meta:get_string("val"  .. i)
		local expr = meta:get_string("expr" .. i)
		val = Dropdown[val] or 1

		tbl[#tbl + 1] = "field[0," .. y1 .. ";1.6,1;outp" .. i ..";;" .. outp .. "]"
		tbl[#tbl + 1] = "label[1.4," .. y2 .. ";=]"
		tbl[#tbl + 1] = "dropdown[1.8," .. y3 .. ";1.6,1;val" .. i ..";,on,off;" .. val .. "]"
		tbl[#tbl + 1] = "label[3.5," .. y2 .. ";if]"
		tbl[#tbl + 1] = "field[4.2," .. y1 .. ";5.6,1;expr" .. i ..";;" .. expr .. "]"
	end
	return table.concat(tbl, "")
end

local function formspec(pos, meta)
	local nvm = techage.get_nvm(pos)
	local err = nvm.error or "ok"
	err = minetest.formspec_escape(err)
	nvm.io_tbl = nvm.io_tbl or {}
	local inputs, outputs = data(nvm)
	local bt = nvm.blocking_time or 1
	return "size[10,8.2]" ..
		"tabheader[0,0;tab;"..S("Rules") .. "," .. S("Help") .. "," .. S("Debug") .. ";1;;true]" ..
		"container[0.4,0.1]" ..
		rules(meta) ..
		"container_end[]" ..

		"label[0.2,4.4;" .. S("Blocking Time") .. "]"..
		"field[4.6,4.5;2,1;bt;;" .. bt .. "]"..
		"label[6.3,4.4;s]"..

		"label[0,5.3;" .. S("Inputs") .. ":]" ..
		"label[2,5.3;" .. inputs .."]" ..
		"label[0,5.9;" .. S("Outputs") .. ":]" ..
		"label[2,5.9;" .. outputs .."]" ..
		"label[0,6.5;" .. S("Syntax") .. ":]" ..
		"label[2,6.5;" .. err .. "]" ..
		"button[1.5,7.5;3,1;update;" .. S("Update") .. "]" ..
		"button[5.6,7.5;3,1;store;" .. S("Store") .. "]"
end

local function formspec_help()
	return "size[10,8.2]" ..
		"tabheader[0,0;tab;"..S("Rules") .. "," .. S("Help") .. "," .. S("Debug") .. ";2;;true]" ..
		"textarea[0.3,0.3;9.9,8.5;;;"..minetest.formspec_escape(HELP).."]"
end

local function formspec_debug(mem)
	mem.debug = mem.debug or {}
	local s = table.concat(mem.debug, "\n")
	return "size[10,8.2]" ..
		"tabheader[0,0;tab;"..S("Rules") .. "," .. S("Help") .. "," .. S("Debug") .. ";3;;true]" ..
		"textarea[0.3,0.3;9.9,8.5;;;"..minetest.formspec_escape(s).."]" ..
		"button[1.5,7.5;3,1;update2;" .. S("Update") .. "]" ..
		"button[5.6,7.5;3,1;clear;" .. S("Clear") .. "]"
end

minetest.register_node("techage:ta3_logic2", {
	description = S("TA3 Logic Block"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_logic.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		logic.after_place_node(pos, placer, "techage:ta3_logic2", S("TA3 Logic Block"))
		logic.infotext(meta, S("TA3 Logic Block"))
		meta:set_string("formspec", formspec(pos, meta))
		meta:set_string("owner", placer:get_player_name())
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)

		if fields.store then
			for i = 1,NUM_RULES do
				meta:set_string("outp" .. i, fields["outp" .. i] or "")
				meta:set_string("val"  .. i, fields["val"  .. i] or "")
				meta:set_string("expr" .. i, fields["expr" .. i] or "")
			end
			local nvm = techage.get_nvm(pos)
			nvm.blocking_time = tonumber(fields.bt) or 0.1
			nvm.inp_tbl = {me = "off"}
			nvm.outp_tbl = {}
		elseif fields.update2 then
			local mem = techage.get_mem(pos)
			meta:set_string("formspec", formspec_debug(mem))
		elseif fields.clear then
			local mem = techage.get_mem(pos)
			mem.debug = {}
			meta:set_string("formspec", formspec_debug(mem))
		end

		if fields.tab == "2" then
			meta:set_string("formspec", formspec_help())
		elseif fields.tab == "3" then
			local mem = techage.get_mem(pos)
			meta:set_string("formspec", formspec_debug(mem))
		else
			local nvm = techage.get_nvm(pos)
			local mem = techage.get_mem(pos)
			mem.code = nil
			get_code(pos, nvm, mem)
			meta:set_string("formspec", formspec(pos, meta))
		end
	end,

	on_timer = function(pos)
		execute(pos)
		return false
	end,

	on_rightclick = function(pos, node, clicker)
		if minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec(pos, meta))
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "techage:ta3_logic2",
	recipe = {
		{"", "group:wood", ""},
		{"techage:vacuum_tube", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", ""},
	},
})

techage.register_node({"techage:ta3_logic2"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		local mem = techage.get_mem(pos)
		nvm.own_num = nvm.own_num or M(pos):get_string("node_number")
		nvm.blocking_time = nvm.blocking_time or M(pos):get_float("blocking_time")
		nvm.inp_tbl = nvm.inp_tbl or {}

		if src ~= nvm.own_num then
			if topic == "on" then
				debug(mem, "(inp) " .. src .. " = on")
				nvm.inp_tbl[src] = "on"
			elseif topic == "off" then
				debug(mem, "(inp) " .. src .. " = off")
				nvm.inp_tbl[src] = "off"
			else
				debug(mem, "(inp) invalid command")
				return "unsupported"
			end

			local t = math.max((mem.ttl or 0) - techage.SystemTime, 0.1)
			minetest.get_node_timer(pos):start(t)
			mem.ttl = techage.SystemTime + (nvm.blocking_time or 0)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		local mem = techage.get_mem(pos)
		nvm.own_num = nvm.own_num or M(pos):get_string("node_number")
		nvm.blocking_time = nvm.blocking_time or M(pos):get_float("blocking_time")
		nvm.inp_tbl = nvm.inp_tbl or {}

		if src ~= nvm.own_num then
			if topic == 1 and payload[1] == 1 then
				debug(mem, "(inp) " .. src .. " = on")
				nvm.inp_tbl[src] = "on"
				return 0
			elseif topic == 1 and payload[1] == 0 then
				debug(mem, "(inp) " .. src .. " = off")
				nvm.inp_tbl[src] = "off"
				return 0
			else
				debug(mem, "(inp) invalid command")
				return 2
			end
			local t = math.max((mem.ttl or 0) - techage.SystemTime, 0.1)
			minetest.get_node_timer(pos):start(t)
			mem.ttl = techage.SystemTime + (nvm.blocking_time or 0)
		end
	end,
})
