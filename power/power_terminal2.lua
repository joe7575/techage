--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA3 Power Terminal

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local S = techage.S

local CYCLE_TIME = 2

local Cable = techage.ElectricCable
local power = techage.power
local networks = techage.networks
local STOPPED = techage.power.STOPPED
local NOPOWER = techage.power.NOPOWER
local RUNNING = techage.power.RUNNING

local HELP = [[Commands
help   print this text
cls    clear screen
gen1   print all cat. 1 generators
gen2   print all cat. 2 generators
con2   print all cat. 2 consumers
num    print number of network blocks
pow    print provided and needed power]]


local Generators = {
	S("Power station"),
	S("Tiny generator"),
	S("Solar system") ,
	S("Wind turbine"),
	S("Accu Box"),
	S("Energy storage"),
	S("Fuel cell cat. 1"),
	S("Fuel cell cat. 2"),
	S("Electrolyzer"),
	S("TA2 Generator"),
}

local Storage = {
	[S("Accu Box")] = true,
	[S("Energy storage")] = true,
	[S("Fuel cell cat. 1")] = true,
	[S("Fuel cell cat. 2")] = true,
	[S("Electrolyzer")] = true,
}

local GeneratorPerformances = {
	80,   -- S("Power station")
	12,   -- S("Tiny generator")
	100,  -- S("Solar system")
	70,   -- S("Wind turbine")
	10,   -- S("Accu Box")
	60,   -- S("Energy storage")
	33,   -- S("Fuel cell cat. 1")
	34,   -- S("Fuel cell cat. 2")
	35,   -- S("Electrolyzer")
	24,   -- S("TA2 Generator")
}

--
-- Generate the needed tables for the formspec
--
local Gentypes = table.concat(Generators, ",")
local Gentype2Idx = {}
local Gentype2Maxvalue = {}
local Gentype = {}

for idx,name in ipairs(Generators) do
	Gentype2Idx[name] = idx
	Gentype2Maxvalue[name] = GeneratorPerformances[idx]
	Gentype[GeneratorPerformances[idx]] = name
end

local function short_node_name(nominal)
	return Gentype[nominal or 1] or "unknown"
end

local function generator_data(gen_tbl, nominal)
	local pow_max = 0
	local pow_curr = 0
	local num_nodes = 0

	for i,gen in ipairs(gen_tbl or {}) do
		if gen.nominal == nominal then
			local nvm = techage.get_nvm(gen.pos)
			if nvm.ele1 and nvm.ele1.gstate and nvm.ele1.galive and nvm.ele1.given then
				num_nodes = num_nodes + 1
				if nvm.ele1.gstate == RUNNING then
					pow_max = pow_max + (nvm.ele1.curr_power or nominal)
					if nvm.ele1.galive > 0 and nvm.ele1.given > 0 then
						pow_curr = pow_curr + nvm.ele1.given
					end
				end
			end
		end
	end
	
	return pow_max, pow_curr, num_nodes
end

local function get_generator_data(gen)
	local nvm = techage.get_nvm(gen.pos)
	local pow_max = 0
	local pow_curr = 0
	if nvm.ele1 and nvm.ele1.gstate and nvm.ele1.galive and nvm.ele1.given then
		if nvm.ele1.gstate == RUNNING then
			if nvm.ele1.curr_power and nvm.ele1.curr_power > 0 then
				pow_max = nvm.ele1.curr_power
			else
				pow_max = gen.nominal
			end
			if nvm.ele1.galive > 0 and nvm.ele1.given > 0 then
				pow_curr = nvm.ele1.given
			end
		end
	end
	return pow_curr, pow_max
end

local function get_consumer_data(gen)
	local nvm = techage.get_nvm(gen.pos)
	local pow_max = 0
	local pow_curr = 0
	if nvm.ele1 and nvm.ele1.cstate and nvm.ele1.calive and nvm.ele1.taken then
		if nvm.ele1.cstate == RUNNING then
			pow_max = gen.nominal
			if nvm.ele1.calive > 0 and nvm.ele1.taken > 0 then
				pow_curr = nvm.ele1.taken
			end
		end
	end
	return pow_curr, pow_max
end

local function consumer_data(gen_tbl, nominal)
	local pow_max = 0
	local pow_curr = 0
	local num_nodes = 0

	for i,gen in ipairs(gen_tbl or {}) do
		if gen.nominal == nominal then
			local nvm = techage.get_nvm(gen.pos)
			if nvm.ele1 and nvm.ele1.cstate and nvm.ele1.calive and nvm.ele1.taken then
				num_nodes = num_nodes + 1
				if nvm.ele1.cstate == RUNNING then
					pow_max = pow_max + nominal
					if nvm.ele1.calive > 0 and nvm.ele1.taken > 0 then
						pow_curr = pow_curr + nvm.ele1.taken
					end
				end
			end
		end
	end
	
	return pow_max, pow_curr, num_nodes
end

local function storage_load(gen_tbl, nominal)
	local load_curr = 0 -- percentage
	local num = 0
	
	for i,gen in ipairs(gen_tbl or {}) do
		if gen.nominal == nominal then
			local ndef = techage.NodeDef[techage.get_node_lvm(gen.pos).name]
			if ndef and ndef.on_recv_message then
				local resp, _ = ndef.on_recv_message(gen.pos, "0", "load")
				if type(resp) == "number" then
					load_curr = load_curr + resp
					num = num + 1
				end
			end
		end
	end
	
	if num > 0 then
		return math.floor(load_curr / num)
	else
		return 0
	end
end

local function calc_network_data_type(pos, nvm, gentype)
	local pow_max1, pow_curr1, num_nodes1, pow_stored1
	local pow_max2, pow_curr2, num_nodes2, pow_stored2
	local nominal = Gentype2Maxvalue[gentype]
	local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
	
	if gentype == S("Accu Box") or gentype == S("Energy storage") then
		pow_max1, pow_curr1, num_nodes1 = generator_data(netw.gen2, nominal)
		pow_max2, pow_curr2, num_nodes2 = consumer_data(netw.con2, nominal)
		pow_stored1 = storage_load(netw.con2, Gentype2Maxvalue[gentype]).." %"
		pow_stored2 = pow_stored1
	elseif gentype == S("Fuel cell cat. 2") then
		pow_max1, pow_curr1, num_nodes1 = generator_data(netw.gen2, nominal)
		pow_max2, pow_curr2, num_nodes2 = 0, 0, 0
		pow_stored1 = storage_load(netw.gen2, Gentype2Maxvalue[gentype]).." %"
		pow_stored2 = "-"
	elseif gentype == S("Fuel cell cat. 1") then
		pow_max1, pow_curr1, num_nodes1 = generator_data(netw.gen1, nominal)
		pow_max2, pow_curr2, num_nodes2 = 0, 0, 0
		pow_stored1 = storage_load(netw.gen1, Gentype2Maxvalue[gentype]).." %"
		pow_stored2 = "-"
	elseif gentype == S("Electrolyzer") then
		pow_max1, pow_curr1, num_nodes1 = 0, 0, 0
		pow_max2, pow_curr2, num_nodes2 = consumer_data(netw.con2, nominal)
		pow_stored2 = storage_load(netw.con2, Gentype2Maxvalue[gentype]).." %"
		pow_stored1 = "-"
	else -- gen1 generators
		pow_max1, pow_curr1, num_nodes1 = generator_data(netw.gen1, nominal)
		pow_max2, pow_curr2, num_nodes2 = 0, 0, 0
		pow_stored1 = "-"
		pow_stored2 = "-"
	end
	return netw, 
		{pow_max = pow_max1, pow_curr = pow_curr1, num_nodes = num_nodes1, pow_stored = pow_stored1},
		{pow_max = pow_max2, pow_curr = pow_curr2, num_nodes = num_nodes2, pow_stored = pow_stored2}
end

local function calc_network_data_total(pos, nvm)
	local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
	
	local pow_max1 = netw.available1 or 0
	local pow_max2 = netw.available2 or 0
	local pow_used1 = netw.on and math.min(netw.needed1 + netw.needed2, netw.available1) or 0
	local pow_used2 = netw.on and math.max(netw.needed1 - pow_used1, -netw.available2) or 0
	local num_nodes1 = #(netw.gen1 or {})
	local num_nodes2 = #(netw.gen2 or {})
	
	return netw, 
		{pow_max = pow_max1, pow_curr = pow_used1, num_nodes = num_nodes1},
		{pow_max = pow_max2, pow_curr = pow_used2, num_nodes = num_nodes2}
end

local function get_state(netw)
	local state = ""
	local needed = techage.power.get_con1_sum(netw, "ele1") or 0
	
	if #(netw.gen1 or {}) + #(netw.gen2 or {}) == 0 then
		state = S("No power grid or running generator!")
	elseif needed > (netw.available1 or 0) then
		state = S("Probably too many consumers (")..needed.." "..S("ku is needed").."!)"
	elseif (netw.num_nodes or 0) < techage.networks.MAX_NUM_NODES then
		state = S("Number of power grid blocks")..": "..(netw.num_nodes or 0)..",  "..S("Max. needed power")..": "..needed.. " ku"
	else
		state = S("To many blocks in the power grid!")
	end 
	return state
end	

local function column(x,y, data)
	if data.pow_stored then
		return 
			"label["..x..","..(y+0.0)..";"..data.num_nodes.. "]"..
			"label["..x..","..(y+0.5)..";"..data.pow_max..   " ku]"..
			"label["..x..","..(y+1.0)..";"..data.pow_curr..  " ku]"..
			"label["..x..","..(y+1.5)..";"..data.pow_stored.."]"
	else
		return 
			"label["..x..","..(y+0.0)..";"..data.num_nodes.. "]"..
			"label["..x..","..(y+0.5)..";"..data.pow_max..   " ku]"..
			"label["..x..","..(y+1.0)..";"..data.pow_curr..  " ku]"
	end
end

local function formspec_type(pos, nvm)
	return "size[5,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;4.8,0.5;#c6e8ff]"..
		"label[1.5,-0.1;"..minetest.colorize( "#000000", S("Select type")).."]"..
		"dropdown[0,1;5.2;gentype;"..Gentypes..";"..(nvm.gentype_idx or 1).."]".. 
		"style_type[button;bgcolor=#395c74]"..
		"button[0,2.4;5,1;set;"..S("Store").."]"
end

local function formspec1(pos, nvm)
	local gentype = nvm.gentype or S("Power station")
	local netw, gen1, gen2 = calc_network_data_type(pos, nvm, gentype)
	local _, sum1, sum2 = calc_network_data_total(pos, nvm)
	netw.prop = ((netw.prop or 0) + 1) % 2
	local star = netw.prop == 1 and "*" or ""
	local state = get_state(netw)
	
	return "size[11,9]"..
		"tabheader[0,0;tab;status,console;1;;true]".. 
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;10.8,0.5;#c6e8ff]"..
		"label[4.5,-0.1;"..minetest.colorize( "#000000", S("Network Data")).."]"..
		"label[10.5,-0.1;"..minetest.colorize( "#000000", star).."]"..
		
		"style_type[button;bgcolor=#395c74]"..
		"button[0,0.7;3,1;config;"..S("Type").."]"..
		
		"box[0,1.6;10.8,0.4;#c6e8ff]"..
		"box[0,2.15;10.8,0.4;#395c74]"..
		"box[0,2.65;10.8,0.4;#395c74]"..
		"box[0,3.15;10.8,0.4;#395c74]"..
		"box[0,3.65;10.8,0.4;#395c74]"..
		"label[0.1,1.55;"..minetest.colorize( "#000000", gentype).."]"..
		"label[5.7,1.55;"..minetest.colorize( "#000000", S("Output")).."]"..
		"label[8.2,1.55;"..minetest.colorize( "#000000", S("Intake")).."]"..
		"label[0.1,2.1;"..S("Number blocks:").."]"..
		"label[0.1,2.6;"..S("Maximum power:").."]"..
		"label[0.1,3.1;"..S("Current power:").."]"..
		"label[0.1,3.6;"..S("Energy stored:").."]"..
		column(5.7, 2.1, gen1)..
		column(8.2, 2.1, gen2)..

		--"box[0,5.3;8.8,0.4;#c6e8ff]"..
		"box[0,4.5;10.8,0.4;#c6e8ff]"..
		"box[0,5.05;10.8,0.4;#395c74]"..
		"box[0,5.55;10.8,0.4;#395c74]"..
		"box[0,6.05;10.8,0.4;#395c74]"..
		"label[0.1,4.45;"..minetest.colorize( "#000000", S("Power grid total")).."]"..
		"label[5.7,4.45;"..minetest.colorize( "#000000", S("Generators")).."]"..
		"label[8.2,4.45;"..minetest.colorize( "#000000", S("Storage systems")).."]"..
		"label[0.1,5.0;"..S("Number blocks:").."]"..
		"label[0.1,5.5;"..S("Maximum power:").."]"..
		"label[0.1,6.0;"..S("Current power:").."]"..
		column(5.7, 5.0, sum1)..
		column(8.2, 5.0, sum2)..
		"box[0,7.75;10.8,0.4;#000000]"..
		"label[0.1,7.7;"..state.."]"
end

local function formspec2(pos, mem)
	local meta = M(pos)
	local output = meta:get_string("output")
	local command = mem.cmnd or "help"
	output = minetest.formspec_escape(output)
	output = output:gsub("\n", ",")
	
	return "size[11,9]"..
		"tabheader[0,0;tab;status,console;2;;true]".. 
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;10.8,0.5;#c6e8ff]"..
		"label[4.5,-0.1;"..minetest.colorize( "#000000", S("Network Data")).."]"..
		"style_type[table,field;font=mono]"..
		"table[0,0.5;10.8,7.8;output;"..output..";200]"..
		"field[0.4,8.7;8.6,1;cmnd;;"..command.."]" ..
		"field_close_on_enter[cmnd;false]"..
		"button[8.9,8.4;2,1;enter;"..S("Enter").."]"
end

local function generators(pos, gen_tbl)
	local tbl = {}
	for _, item in ipairs(gen_tbl) do
		if item and item.pos then
			local node = techage.get_node_lvm(item.pos)
			local ndef = minetest.registered_nodes[node.name]
			local name = short_node_name(item.nominal)
			local spos = P2S(item.pos)
			local pow_curr, pow_max = get_generator_data(item, ndef)
			if Storage[name] then
				local load_percent = 0
				local tdef = techage.NodeDef[node.name]
				if tdef and tdef.on_recv_message then
					load_percent = tdef.on_recv_message(item.pos, "0", "load") or 0
				end
				local s = string.format("%-16s %s = %u/%u ku (%u %%)", 
						spos, name, pow_curr, pow_max, load_percent)
				tbl[#tbl + 1] = s
			else
				local s = string.format("%-16s %s = %u/%u ku", spos, name, pow_curr, pow_max)
				tbl[#tbl + 1] = s
			end
		end
	end
	return table.concat(tbl, "\n")
end

local function consumers(pos, gen_tbl)
	local tbl = {}
	for _, item in ipairs(gen_tbl) do
		if item and item.pos then
			local node = techage.get_node_lvm(item.pos)
			local ndef = minetest.registered_nodes[node.name]
			local name = short_node_name(item.nominal)
			local spos = P2S(item.pos)
			local pow_curr, pow_max = get_consumer_data(item, ndef)
			if Storage[name] then
				local load_percent = 0
				local tdef = techage.NodeDef[node.name]
				if tdef and tdef.on_recv_message then
					load_percent = tdef.on_recv_message(item.pos, "0", "load") or 0
				end
				local s = string.format("%-16s %s = %u/%u ku (%u %%)", 
						spos, name, pow_curr, pow_max, load_percent)
				tbl[#tbl + 1] = s
			else
				local s = string.format("%-16s %s = %u/%u ku", spos, name, pow_curr, pow_max)
				tbl[#tbl + 1] = s
			end
		end
	end
	return table.concat(tbl, "\n")
end

local function number_nodes(pos, netw)
	return
		"num. generators cat. 1: " .. #(netw.gen1 or {}) .. "\n" ..
		"num. generators cat. 2: " .. #(netw.gen2 or {}) .. "\n" ..
		"num. consumers  cat. 1: " .. #(netw.con1 or {}) .. "\n" ..
		"num. consumers  cat. 2: " .. #(netw.con2 or {})
end	

local function power_network(pos, netw)
	return
		"pow. generators cat. 1: " .. (netw.available1 or 0) .. " ku\n" ..
		"pow. generators cat. 2: " .. (netw.available2 or 0) .. " ku\n" ..
		"pow. consumers  cat. 1: " .. (netw.needed1 or 0) .. " ku\n" ..
		"pow. consumers  cat. 2: " .. (netw.needed2 or 0) .. " ku"
end	


local function output(pos, command, text)
	local meta = M(pos)
	text = meta:get_string("output") .. "\n$ " .. command .. "\n" .. (text or "")
	text = text:sub(-2000,-1)
	meta:set_string("output", text)
end

local function command(pos, nvm, command)
	local meta = M(pos)
	
	if command then
		command = command:sub(1,80)
		command = string.trim(command)
		
		if command == "cls" then
			meta:set_string("output", "")
		elseif command == "help" then
			output(pos, command, HELP)
		elseif command == "gen1" then
			local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
			output(pos, command, generators(pos, netw.gen1 or {}))
		elseif command == "gen2" then
			local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
			output(pos, command, generators(pos, netw.gen2 or {}))
		elseif command == "con2" then
			local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
			output(pos, command, consumers(pos, netw.con2 or {}))
		elseif command == "num" then
			local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
			output(pos, command, number_nodes(pos, netw))
		elseif command == "pow" then
			local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
			output(pos, command, power_network(pos, netw))
		elseif command ~= "" then
			output(pos, command, "")
		end
	end
end	

minetest.register_node("techage:ta3_power_terminal", {
	description = S("TA3 Power Terminal"),
	inventory_image = "techage_power_terminal_front.png",
	tiles = {
		"techage_power_terminal_top.png",
		"techage_power_terminal_top.png",
		"techage_power_terminal_side.png",
		"techage_power_terminal_side.png",
		"techage_power_terminal_back.png",
		"techage_power_terminal_front.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, 0/16,  8/16, 8/16, 8/16},
		},
	},
	
	after_place_node = function(pos)
		local nvm = techage.get_nvm(pos)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "B"))
		Cable:after_place_node(pos)
		M(pos):set_string("formspec", formspec1(pos, nvm))
	end,
	after_dig_node = function(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node) 
		power.update_network(pos, outdir, tlib2)
	end,
	on_rightclick = function(pos, node, clicker)
		local mem = techage.get_mem(pos)
		if mem.active_formspec == 2 then
			M(pos):set_string("formspec", formspec2(pos, mem))
		else
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec1(pos, nvm))
		end
	end,
	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec1(pos, nvm))
		end
		return true
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local nvm = techage.get_nvm(pos)
		local mem = techage.get_mem(pos)
		
		if fields.key_enter_field or fields.enter then
			command(pos, nvm, fields.cmnd)
			mem.cmnd = ""
			M(pos):set_string("formspec", formspec2(pos, mem))
			mem.cmnd = fields.cmnd
		elseif fields.config then
			techage.reset_activeformspec(pos, player)
			M(pos):set_string("formspec", formspec_type(pos, nvm))
		elseif fields.set then
			nvm.gentype = fields.gentype
			nvm.gentype_idx = Gentype2Idx[fields.gentype] or 1
			techage.set_activeformspec(pos, player)
			M(pos):set_string("formspec", formspec1(pos, nvm))
		elseif fields.tab == "1" then
			M(pos):set_string("formspec", formspec1(pos, nvm))
			techage.set_activeformspec(pos, player)
			mem.active_formspec = 1
		elseif fields.tab == "2" then
			M(pos):set_string("formspec", formspec2(pos, mem))
			techage.reset_activeformspec(pos, player)
			mem.active_formspec = 2
		elseif fields.key_up and mem.cmnd then
			M(pos):set_string("formspec", formspec2(pos, mem))
		end
	end,
	
	networks = {
		ele1 = {
			sides = {B = 1}, -- Cable connection side
			ntype = "term",
		},
	},
	
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	on_rotate = screwdriver.disallow,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

Cable:add_secondary_node_names({"techage:ta3_power_terminal"})

minetest.register_craft({
	output = "techage:ta3_power_terminal",
	recipe = {
		{"", "techage:usmium_nuggets", "default:steel_ingot"},
		{"", "techage:basalt_glass_thin", "default:copper_ingot"},
		{"", "techage:vacuum_tube", "default:steel_ingot"},
	},
})
