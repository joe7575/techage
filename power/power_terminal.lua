--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA3 Power Terminal Old

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

local function generator_data(gen_tbl)
	local tbl = {
		pow_all=0, pow_on=0, pow_act=0, pow_used=0, 
		num_on=0, num_act=0, num_used=0
	}
	for i,gen in ipairs(gen_tbl or {}) do
		local nvm = techage.get_nvm(gen.pos)
		tbl.pow_all = tbl.pow_all + (gen.nominal or 0)
		if nvm.ele1 and nvm.ele1.gstate and nvm.ele1.gstate ~= STOPPED then
			tbl.num_on = tbl.num_on + 1
			tbl.pow_on = tbl.pow_on + (nvm.ele1.curr_power or gen.nominal or 0)
			if (nvm.ele1.galive or -1) >= 0 then
				tbl.num_act = tbl.num_act + 1
				tbl.pow_act = tbl.pow_act + (nvm.ele1.curr_power or gen.nominal or 0)
				if (nvm.ele1.given or 0) > 0 then
					tbl.num_used = tbl.num_used + 1
					tbl.pow_used = tbl.pow_used + (nvm.ele1.given or 0)
				end
			end
		end
	end
	
	tbl.num_all = #(gen_tbl or {})
	return tbl
end

local function consumer_data(con_tbl)
	local tbl = {
		pow_all=0, pow_on=0, pow_act=0, pow_used=0, 
		num_on=0, num_act=0, num_used=0
	}
	for i,gen in ipairs(con_tbl or {}) do
		local nvm = techage.get_nvm(gen.pos)
		tbl.pow_all = tbl.pow_all + (gen.nominal or 0)
		if nvm.ele1 and nvm.ele1.cstate and nvm.ele1.cstate ~= STOPPED then
			tbl.num_on = tbl.num_on + 1
			tbl.pow_on = tbl.pow_on + (gen.nominal or 0)
			if (nvm.ele1.calive or -1) >= 0 then
				tbl.num_act = tbl.num_act + 1
				tbl.pow_act = tbl.pow_act + (gen.nominal or 0)
				if (nvm.ele1.taken or 0) > 0 then
					tbl.num_used = tbl.num_used + 1
					tbl.pow_used = tbl.pow_used + (nvm.ele1.taken or 0)
				end
			end
		end
	end
	
	tbl.num_all = #(con_tbl or {})
	return tbl
end

local function calc_network_data(pos, nvm)
	local netw = techage.networks.has_network("ele1", nvm.ele1 and nvm.ele1.netID) or {}
	local gen1 = generator_data(netw.gen1)
	local gen2 = generator_data(netw.gen2)
	local con1 = consumer_data(netw.con1)
	local con2 = consumer_data(netw.con2)
	
	return netw, gen1, gen2, con1, con2
end

local function column(x,y, data)
	return 
		"label["..x..","..(y+0.0)..";"..data.num_all.. " ("..data.pow_all.." ku)]"..
		"label["..x..","..(y+0.5)..";"..data.num_on..  " ("..data.pow_on.." ku)]"..
		"label["..x..","..(y+1.0)..";"..data.num_act.. " ("..data.pow_act.." ku)]"..
		"label["..x..","..(y+1.5)..";"..data.num_used.." ("..data.pow_used.." ku)]"
end

local function get_state(netw, gen1, gen2, con1, con2)
	local num_nodes = gen1.num_all + gen2.num_all + con1.num_all + 
		con2.num_all + (#(netw.junc or {})) + (#(netw.term or {}))
	local nload = (gen1.pow_act + gen2.pow_act) / con1.pow_act
	local state = S("Number of all nodes")..": ".. num_nodes
	if not netw.gen1 and not netw.gen2 then
		state = S("No network or active generator available!")
	elseif num_nodes > (techage.ELE1_MAX_CABLE_LENGHT - 50) then
		state = string.format(S("With %u of a maximum of %u blocks you are almost at the limit!"), 
				num_nodes, techage.ELE1_MAX_CABLE_LENGHT)
	elseif nload <= 1.0 then
		state = S("The network is overloaded!")
	elseif nload < 1.2 then
		state = S("The network load is almost at the limit!")
	end 
	return state
end	

local function formspec(pos, nvm)
	local netw, gen1, gen2, con1, con2 = calc_network_data(pos, nvm)
	netw.prop = ((netw.prop or 0) + 1) % 2
	local star = netw.prop == 1 and "*" or ""
	local state = get_state(netw, gen1, gen2, con1, con2)
	
	return "size[10,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;9.8,0.5;#c6e8ff]"..
		"label[4,-0.1;"..minetest.colorize( "#000000", S("Network Data")).."]"..
		"label[9.5,-0.1;"..minetest.colorize( "#000000", star).."]"..
		power.formspec_label_bar(pos, 0,   0.7, S("Genera. 1"), gen1.pow_act, gen1.pow_used)..
		power.formspec_label_bar(pos, 2.5, 0.7, S("Genera. 2"), gen2.pow_act, gen2.pow_used)..
		power.formspec_label_bar(pos, 5,   0.7, S("Consum. 2"), con2.pow_act, con2.pow_used)..
		power.formspec_label_bar(pos, 7.5, 0.7, S("Consum. 1"), con1.pow_act, con1.pow_used)..
		"box[0,4.3;9.8,0.4;#c6e8ff]"..
		"box[0,4.85;9.8,0.4;#395c74]"..
		"box[0,5.35;9.8,0.4;#395c74]"..
		"box[0,5.85;9.8,0.4;#395c74]"..
		"box[0,6.35;9.8,0.4;#395c74]"..
		"label[2,4.3;"..minetest.colorize( "#000000", S("Genera. 1")).."]"..
		"label[4,4.3;"..minetest.colorize( "#000000", S("Genera. 2")).."]"..
		"label[6,4.3;"..minetest.colorize( "#000000", S("Consum. 2")).."]"..
		"label[8,4.3;"..minetest.colorize( "#000000", S("Consum. 1")).."]"..
		"label[0.1,4.8;"..S("All nodes:").."]"..
		"label[0.1,5.3;"..S("Turned on:").."]"..
		"label[0.1,5.8;"..S("Active:").."]"..
		"label[0.1,6.3;"..S("In use:").."]"..
		"box[0,6.95;9.8,0.4;#000000]"..
		"label[0.1,6.9;"..state.."]"..
		column(2, 4.8, gen1)..
		column(4, 4.8, gen2)..
		column(6, 4.8, con2)..
		column(8, 4.8, con1)
end

minetest.register_node("techage:power_terminal", {
	description = S("TA3 Power Terminal Old"),
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
	groups = {cracky = 2, level = 2, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
})

Cable:add_secondary_node_names({"techage:power_terminal"})

