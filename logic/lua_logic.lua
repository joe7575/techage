--[[

	TechAge
	=======

	Copyright (C) 2017-2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Lua Logic Block

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic

--  mem.inp_tbl = {
--    n001 = true,   -- "on" received
--    n002 = false,  -- "off" received
--    inp = true,    -- last input
--	  outp = false,  -- last output
--  }

local ValidSymbols = {
	["if"] = true,
	["then"] = true,
	["else"] = true,
	["end"] = true,
	["return"] = true,
	["not"] = true,
	["and"] = true,
	["or"] = true,
	["inp"] = true,
	["outp"] = true,
	["true"] = true,
	["false"] = true,
	["nil"] = true,
	["=="] = true,
	["~="] = true,
	["("] = true,
	[")"] = true,
}
local function check(expression)
	for _, sym in ipairs(string.split(expression, " ")) do
		if not ValidSymbols[sym] and string.find(sym, '^[n0-9]+$') == nil then
			return false, "Error: Invalid symbol '"..sym.."'"
		end
	end
	return true, "ok"
end

local function compile(mem, expression)
	local res, err = check(expression)
    if res then
        local code, err = loadstring(expression, "")
		if code then
			mem.code = code
			mem.error = "ok"
		else
			mem.code = nil
			mem.error = err
		end
	else
		mem.code = nil
		mem.error = err
   end
end

local function get_code(pos, mem)
	local meta = M(pos)
	local if_expr = meta:get_string("if_expr") or ""
	local then_expr = meta:get_string("then_expr") or ""
	local else_expr = meta:get_string("else_expr") or ""
	local expr = "if "..if_expr.." then return "..then_expr.." else return "..else_expr.." end"
	compile(mem, expr)
	return mem.code
end

local function eval(pos, mem)
	mem.code = mem.code or get_code(pos, mem)
	if mem.code then
		setfenv(mem.code, mem.inp_tbl)
		local res, sts = pcall(mem.code)
		if res then
			mem.error = "ok"
			if sts == true and mem.inp_tbl.outp ~= true then
				mem.inp_tbl.outp = sts
				return "on"
			elseif sts == false and mem.inp_tbl.outp ~= false then 
				mem.inp_tbl.outp = sts
				return "off"
			end
		else
			mem.error = "Error: "..sts
		end
	end
end

local function data(mem)
	local tbl = {"inp = "..dump(mem.inp_tbl.inp), "outp = "..dump(mem.inp_tbl.outp)}
	for k,v in pairs(mem.inp_tbl) do
		if k ~= "inp" and k ~= "outp" then
			tbl[#tbl+1] = k.." = "..dump(v)
		end
	end
	return table.concat(tbl, ",  ")
end

local function formspec(pos, meta)
	local mem = tubelib2.get_mem(pos)
	local numbers = meta:get_string("numbers") or ""
	local if_expr = meta:get_string("if_expr") or ""
	local then_expr = meta:get_string("then_expr") or ""
	local else_expr = meta:get_string("else_expr") or ""
	local err = mem.error or "ok"
	if err ~= "ok" then 
		err = string.sub(err, 15)
	end
	err = minetest.formspec_escape(err)
	mem.inp_tbl = mem.inp_tbl or {inp = false, outp = false}
	local data = data(mem)
	return "size[9,8]"..
		"background[0,0;9,1.3;techage_formspec_bg.png]"..
		"field[0.5,0.2;8.5,2;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"label[0,1.4;Variables:           "..data.."]"..
		"label[0,2;Valid symbols:   not  and  or  true  false  nil  ==  ~=  (  )]"..
		"background[0,2.6;9,4;techage_formspec_bg.png]"..
		"label[0.1,2.8;if]"..
		"field[0.8,2.9;7,1;if_expr;;"..if_expr.."]" ..
		"label[7.6,2.8;then]"..
		"label[0.6,3.8;return]"..
		"field[2,3.9;7,1;then_expr;;"..then_expr.."]" ..
		"label[0.1,4.5;else]"..
		"label[0.6,5.2;return]"..
		"field[2,5.3;7,1;else_expr;;"..else_expr.."]" ..
		"label[0.1,6;end]"..
		"label[0,6.8;Result:  "..err.."]"..
		"button[2,7.3;2.5,1;update;"..S("Update").."]"..
		"button[5,7.3;2.5,1;store;"..S("Store").."]"
end

minetest.register_node("techage:ta3_logic", {
	description = S("TA3 Logic Block"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_logic.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		mem.inp_tbl = {inp = false, outp = false}
		logic.after_place_node(pos, placer, "techage:ta3_logic", S("TA3 Logic Block"))
		logic.infotext(meta, S("TA3 Logic Block"))
		meta:set_string("formspec", formspec(pos, meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		
		local meta = M(pos)
		local mem = tubelib2.get_mem(pos)
		if fields.numbers and fields.numbers ~= "" then
			if techage.check_numbers(fields.numbers, player:get_player_name()) then
				meta:set_string("numbers", fields.numbers)
				logic.infotext(M(pos), S("TA3 Logic Block"))
			end
		end
		if fields.if_expr and fields.if_expr ~= "" then
			meta:set_string("if_expr", fields.if_expr)
		end
		if fields.then_expr and fields.then_expr ~= "" then
			meta:set_string("then_expr", fields.then_expr)
		end
		if fields.else_expr and fields.else_expr ~= "" then
			meta:set_string("else_expr", fields.else_expr)
		end
		if fields.store then
			get_code(pos, mem)
		end
		meta:set_string("formspec", formspec(pos, meta))
	end,
	
	on_timer = function(pos,elapsed)
		local mem = tubelib2.get_mem(pos)
		local topic = eval(pos, mem)
		if topic then
			local meta = M(pos)
			local own_num = meta:get_string("node_number") or ""
			local numbers = meta:get_string("numbers") or ""
			techage.send_multi(own_num, numbers, topic)
		end
		return false
	end,
	
	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Logic Block"))
		meta:set_string("formspec", formspec(pos, meta))
		return res
	end,
	
	after_dig_node = function(pos)
		techage.remove_node(pos)
		tubelib2.del_mem(pos)
	end,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "techage:ta3_logic",
	recipe = {
		{"", "group:wood", ""},
		{"", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", ""},
	},
})

techage.register_node({"techage:ta3_logic"}, {
	on_recv_message = function(pos, src, topic, payload)
		local mem = tubelib2.get_mem(pos)
		mem.inp_tbl = mem.inp_tbl or {outp = false}
		
		if topic == "on" then
			mem.inp_tbl.inp = true
			mem.inp_tbl["n"..src] = true
		elseif topic == "off" then
			mem.inp_tbl.inp = false
			mem.inp_tbl["n"..src] = false
		else
			return "unsupported"
		end
		minetest.get_node_timer(pos):start(0.1)
	end,
	on_node_load = function(pos)
		
	end,
})		


