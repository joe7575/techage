--[[

	TechAge
	=======

	Copyright (C) 2017-2021 Joachim Stolberg

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
	S("\nRule:\n<output> = true/false if <input-expression> is true\n") ..
	S("\n<output> is the block number to which the\ncommand should be sent.\n") ..
	S("\nThe following applies to inputs/outputs:\ntrue is 'on' and false is 'off'\n") ..
	S("\n<input-expression> is a boolean expression\nwhere input numbers are evaluated.\n") ..
	S("\nExamples:\n1234 == true\n1234 == false\n1234 == true and 2345 == false\n2345 ~= 3456\n") ..
	S("\nValid operators:\nand   or   true   false   ==   ~=   (   )\n") ..
	S("'~=' means: not equal\n") ..
	S("\nAll rules are checked with each received\ncommand.") ..
	S("\nThe internal processing time for all\ncommands is 100 ms.")

--  mem.io_tbl = {
--    i123 = true,   -- "on" received
--    i124 = false,  -- "off" received
--	  o456 = false,  -- last output val
--  }

local ValidSymbols = {
	["and"] = true,
	["or"] = true,
	["true"] = true,
	["false"] = true,
	["=="] = true,
	["~="] = true,
	["("] = true,
	[")"] = true,
}

local Dropdown = {
	[""] = 1, 
	["true"] = 2, 
	["false"] = 3
}

local function check_expr(expr)
	local origin = expr
	-- Add blanks for the syntax check
	expr = expr:gsub("==", " == ")
	expr = expr:gsub("~=", " ~= ")
	expr = expr:gsub("%(", " ( ")
	expr = expr:gsub("%)", " ) ")
	
	-- First syntax check
	for sym in expr:gmatch("[^%s]+") do
		if not ValidSymbols[sym] and string.find(sym, '^[0-9]+$') == nil then
			return "Unexpected symbol '"..sym.."'"
		end
	end
	-- Second syntax check
	local code, _ = loadstring("return " .. expr)
	if not code then
		return "Syntax error in '" .. origin .. "'"
	end
end

local function check_num(num, player_name)
	if not techage.check_numbers(num, player_name) then
		return "Invalid node number '"..num.."'"
	end
end

local function send(pos, num, val)
	local own_num = M(pos):get_string("node_number")
	local nvm = techage.get_nvm(pos)
	nvm.io_tbl = nvm.io_tbl or {}
	nvm.io_tbl["o" .. num] = val == "on" and true or false
	techage.send_single(own_num, num, val)
end

local function check_syntax(line, owner, outp, expr)
	local err = check_num(outp, owner)
	if not err then
		err = check_expr(expr)
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

local function get_code(pos, nvm)
	local meta = M(pos)
	local mem = techage.get_mem(pos)
	local tbl = {}
	local owner = M(pos):get_string("owner")
	
	for i = 1,NUM_RULES do
		local outp = meta:get_string("outp" .. i)
		local val  = meta:get_string("val"  .. i)
		local expr = meta:get_string("expr" .. i)
		
		if outp ~= "" and val ~= "" and expr ~= "" then
			local res, err = check_syntax(i, owner, outp, expr)
			if res then
				val = val == "true" and "on" or "off"
				-- add prefix 'i' to all numbers
				expr = string.gsub(expr, '([0-9]+)', "i%1")
				tbl[#tbl + 1]  = "if "..expr.." then send(pos, "..outp..", '"..val.."') end"
			else
				nvm.error = err
				mem.code = nil
				return
			end
		end
	end
	
	local str = table.concat(tbl, "\n")
	local code = compile(nvm, str)
	nvm.io_tbl.send = send
	nvm.io_tbl.pos = pos
	setfenv(code, nvm.io_tbl)
	return code
end

local function execute(pos)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.code = mem.code or get_code(pos, nvm)
	if mem.code then
		local res, _ = pcall(mem.code)
		if not res then
			nvm.error = "Unknown runtime error"
		end
	end
end

local function data(nvm)
	local inp = {}
	local outp = {}
	for k,v in pairs(nvm.io_tbl) do
		if k ~= "send" and k ~= "pos" then
			if k:byte(1) == 105 then -- 'i'
				inp[#inp+1] = k:sub(2) .. " = " .. dump(v)
			else
				outp[#outp+1] = k:sub(2) .. " = " .. dump(v)
			end
		end
	end
	return table.concat(inp, ",  "), table.concat(outp, ",  ")
end

local function rules(meta)
	local tbl = {}
	
	tbl[#tbl + 1] = "label[-0.2,0;<outp>]"
	tbl[#tbl + 1] = "label[1.4,0;=]"
	tbl[#tbl + 1] = "label[1.8,0;<bool>]"
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
		tbl[#tbl + 1] = "dropdown[1.8," .. y3 .. ";1.6,1;val" .. i ..";,true,false;" .. val .. "]"
		tbl[#tbl + 1] = "label[3.5," .. y2 .. ";if]"
		tbl[#tbl + 1] = "field[4.2," .. y1 .. ";5,1;expr" .. i ..";;" .. expr .. "]"
	end
	return table.concat(tbl, "")
end

local function formspec(pos, meta)
	local nvm = techage.get_nvm(pos)
	local err = nvm.error or "ok"
	err = minetest.formspec_escape(err)
	nvm.io_tbl = nvm.io_tbl or {}
	local inputs, outputs = data(nvm)
	return "size[9.4,7.7]" ..
		"tabheader[0,0;tab;"..S("Rules") .. "," .. S("Help")..";1;;true]" ..
		"container[0.4,0.1]" ..
		rules(meta) ..
		"container_end[]" ..
		"label[0,4.5;" .. S("Inputs") .. ":]" ..
		"label[2,4.5;" .. inputs .."]" ..
		"label[0,5.1;" .. S("Outputs") .. ":]" ..
		"label[2,5.1;" .. outputs .."]" ..
		"label[0,5.7;" .. S("Syntax") .. ":]" ..
		"label[2,5.7;" .. err .. "]" ..
		"button[1.5,7.0;3,1;update;" .. S("Update") .. "]" ..
		"button[5,7.0;3,1;store;" .. S("Store") .. "]"
end

local function formspec_help()
	return "size[9.4,7.7]" ..
		"tabheader[0,0;tab;"..S("Rules") .. "," .. S("Help")..";2;;true]" ..
		"textarea[0.3,0.3;9.3,8;;;"..minetest.formspec_escape(HELP).."]"
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
		nvm.io_tbl = {}
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
		end
		
		if fields.tab == "2" then
			meta:set_string("formspec", formspec_help())
		else
			local nvm = techage.get_nvm(pos)
			get_code(pos, nvm)
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
		get_code(pos, nvm)
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
		nvm.io_tbl = nvm.io_tbl or {}
		
		if topic == "on" then
			nvm.io_tbl["i" .. src] = true
		elseif topic == "off" then
			nvm.io_tbl["i" .. src] = false
		else
			return "unsupported"
		end
		minetest.get_node_timer(pos):start(0.1)
	end,
})		


