--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
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

local Generators = {
	S("Power station"),
	S("Tiny generator"),
	S("Solar system") ,
	S("Wind turbine"),
	S("Accu Box"),
	S("Energy storage"),
	S("Fuel cell"),
	S("Electrolyzer"),
}

local Storage = {
	[S("Accu Box")] = true,
	[S("Energy storage")] = true,
	[S("Fuel cell")] = true,
	[S("Electrolyzer")] = true,
}

local GeneratorPerformances = {
	80,   -- S("Power station")
	12,   -- S("Tiny generator")
	100,  -- S("Solar system")
	70,   -- S("Wind turbine")
	10,   -- S("Accu Box")
	60,   -- S("Energy storage")
	25,   -- S("Fuel cell")
	30,   -- S("Electrolyzer")
}

--
-- Generate the needed tables for the formspec
--
local Gentypes = table.concat(Generators, ",")
local Gentype2Idx = {}
local Gentype2Maxvalue = {}

for idx,name in ipairs(Generators) do
	Gentype2Idx[name] = idx
	Gentype2Maxvalue[name] = GeneratorPerformances[idx]
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
				local resp = ndef.on_recv_message(gen.pos, "0", "load")
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
	elseif gentype == S("Fuel cell") then
		pow_max1, pow_curr1, num_nodes1 = generator_data(netw.gen2, nominal)
		pow_max2, pow_curr2, num_nodes2 = 0, 0, 0
		pow_stored1 = storage_load(netw.gen2, Gentype2Maxvalue[gentype]).." %"
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
	
	if #(netw.gen1 or {}) + #(netw.gen2 or {}) == 0 then
		state = S("No power grid or running generator!")
	elseif (netw.num_nodes or 0) < techage.networks.MAX_NUM_NODES then
		state = S("Number of power grid blocks")..": "..(netw.num_nodes or 0)
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

local function formspec(pos, nvm)
	local gentype = nvm.gentype or S("Power station")
	local netw, gen1, gen2 = calc_network_data_type(pos, nvm, gentype)
	local _, sum1, sum2 = calc_network_data_total(pos, nvm)
	netw.prop = ((netw.prop or 0) + 1) % 2
	local star = netw.prop == 1 and "*" or ""
	local state = get_state(netw)
	
	return "size[9,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;8.8,0.5;#c6e8ff]"..
		"label[3.5,-0.1;"..minetest.colorize( "#000000", S("Network Data")).."]"..
		"label[8.5,-0.1;"..minetest.colorize( "#000000", star).."]"..
		
		"style_type[button;bgcolor=#395c74]"..
		"button[0,0.7;3,1;config;"..S("Type").."]"..
		
		"box[0,1.6;8.8,0.4;#c6e8ff]"..
		"box[0,2.15;8.8,0.4;#395c74]"..
		"box[0,2.65;8.8,0.4;#395c74]"..
		"box[0,3.15;8.8,0.4;#395c74]"..
		"box[0,3.65;8.8,0.4;#395c74]"..
		"label[0.1,1.55;"..minetest.colorize( "#000000", gentype).."]"..
		"label[3.7,1.55;"..minetest.colorize( "#000000", S("Output")).."]"..
		"label[6.2,1.55;"..minetest.colorize( "#000000", S("Intake")).."]"..
		"label[0.1,2.1;"..S("Number blocks:").."]"..
		"label[0.1,2.6;"..S("Maximum power:").."]"..
		"label[0.1,3.1;"..S("Current power:").."]"..
		"label[0.1,3.6;"..S("Energy stored:").."]"..
		column(3.7, 2.1, gen1)..
		column(6.2, 2.1, gen2)..

		--"box[0,5.3;8.8,0.4;#c6e8ff]"..
		"box[0,4.5;8.8,0.4;#c6e8ff]"..
		"box[0,5.05;8.8,0.4;#395c74]"..
		"box[0,5.55;8.8,0.4;#395c74]"..
		"box[0,6.05;8.8,0.4;#395c74]"..
		"label[0.1,4.45;"..minetest.colorize( "#000000", S("Power grid total")).."]"..
		"label[3.7,4.45;"..minetest.colorize( "#000000", S("Generators")).."]"..
		"label[6.2,4.45;"..minetest.colorize( "#000000", S("Storage systems")).."]"..
		"label[0.1,5.0;"..S("Number blocks:").."]"..
		"label[0.1,5.5;"..S("Maximum power:").."]"..
		"label[0.1,6.0;"..S("Current power:").."]"..
		column(3.7, 5.0, sum1)..
		column(6.2, 5.0, sum2)..
		"box[0,6.75;8.8,0.4;#000000]"..
		"label[0.1,6.7;"..state.."]"
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
		M(pos):set_string("formspec", formspec(pos, nvm))
	end,
	after_dig_node = function(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node) 
		power.update_network(pos, outdir, tlib2)
	end,
	on_rightclick = function(pos, node, clicker)
		techage.set_activeformspec(pos, clicker)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", formspec(pos, nvm))
	end,
	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos, nvm))
		end
		return true
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local nvm = techage.get_nvm(pos)
		
		if fields.config then
			techage.reset_activeformspec(pos, player)
			M(pos):set_string("formspec", formspec_type(pos, nvm))
		elseif fields.set then
			nvm.gentype = fields.gentype
			nvm.gentype_idx = Gentype2Idx[fields.gentype] or 1
			techage.set_activeformspec(pos, player)
			M(pos):set_string("formspec", formspec(pos, nvm))
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
