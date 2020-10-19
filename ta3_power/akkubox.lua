--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA3 Accu Box

]]--

-- for lazy programmers
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2
local PWR_PERF = 10
local PWR_CAPA = 2000

local Cable = techage.ElectricCable
local power = techage.power
local networks = techage.networks
local in_range = techage.in_range


local function formspec(self, pos, nvm)
	local needed = nvm.needed or 0
	local capa = nvm.capa or 0
	return "size[5,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;4.8,0.5;#c6e8ff]"..
		"label[1,-0.1;"..minetest.colorize( "#000000", S("TA3 Akku Box")).."]"..
		power.formspec_label_bar(0, 0.8, S("Load"), PWR_CAPA, capa)..
		"image_button[2.6,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[3,2;1,1;"..self:get_state_tooltip(nvm).."]"..
		"label[3.7,1.2;"..S("Electricity").."]"..
		"image[3.8,1.7;1,2;"..techage.power.formspec_load_bar(needed, PWR_PERF).."]"
end

local function on_power(pos)
end

local function on_nopower(pos)
end

local function start_node(pos, nvm, state)
	nvm.running = true
	nvm.needed = 0
	local outdir = M(pos):get_int("outdir")
	power.generator_start(pos, Cable, CYCLE_TIME, outdir)
	power.consumer_start(pos, Cable, CYCLE_TIME)
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	nvm.needed = 0
	local outdir = M(pos):get_int("outdir")
	power.generator_stop(pos, Cable, outdir)
	power.consumer_stop(pos, Cable)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta3_akku",
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	formspec_func = formspec,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.capa = nvm.capa or 0
	local outdir = M(pos):get_int("outdir")
	local taken = 0
	local given = 0
	if nvm.capa < PWR_CAPA then
		taken = power.consumer_alive(pos, Cable, CYCLE_TIME)
	end
	if nvm.capa > 0 then
		given = power.generator_alive(pos, Cable, CYCLE_TIME, outdir)
	end
	nvm.needed = taken - given
	nvm.capa = in_range(nvm.capa + nvm.needed, 0, PWR_CAPA)
	--print("node_timer accu "..P2S(pos), nvm.needed, nvm.capa)
	
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	
	return true		
end

local function on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function get_capa(itemstack)
	local meta = itemstack:get_meta()
	if meta then
		return in_range(meta:get_int("capa") * (PWR_CAPA/100), 0, 3000)
	end
	return 0
end

local function set_capa(pos, oldnode, oldmetadata, drops)
	local nvm = techage.get_nvm(pos)
	local capa = nvm.capa
	local meta = drops[1]:get_meta()
	capa = techage.power.percent(PWR_CAPA, capa)
	capa = (math.floor((capa or 0) / 5)) * 5
	meta:set_int("capa", capa)
	local text = S("TA3 Accu Box").." ("..capa.." %)"
	meta:set_string("description", text)
end

local function after_place_node(pos, placer, itemstack)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local own_num = techage.add_node(pos, "techage:ta3_akku")
	meta:set_string("owner", placer:get_player_name())
	meta:set_string("infotext", S("TA3 Accu Box").." "..own_num)
	meta:set_int("outdir", networks.side_to_outdir(pos, "R"))
	meta:set_string("formspec", formspec(State, pos, nvm))
	Cable:after_place_node(pos)
	State:node_init(pos, nvm, own_num)
	nvm.capa = get_capa(itemstack)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, outdir, tlib2)
end

local net_def = {
	ele1 = {
		sides = {R = 1},
		ntype = {"gen2", "con2"},
		nominal = PWR_PERF,
		on_power = on_power,
		on_nopower = on_nopower,
	},
}

minetest.register_node("techage:ta3_akku", {
	description = S("TA3 Accu Box"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_electric.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
	},

	on_timer = node_timer,
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	networks = net_def,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	preserve_metadata = set_capa,
})

Cable:add_secondary_node_names({"techage:ta3_akku"})

-- for logical communication
techage.register_node({"techage:ta3_akku"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "load" then
			return techage.power.percent(PWR_CAPA, nvm.capa)
		elseif topic == "delivered" then
			return -(nvm.needed or 0)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_node_load = function(pos)
		local meta = M(pos)
		meta:set_int("outdir", networks.side_to_outdir(pos, "R"))
		if meta:get_string("node_number") == "" then
			local own_num = techage.add_node(pos, "techage:ta3_akku")
			meta:set_string("node_number", own_num)
			meta:set_string("infotext", S("TA3 Accu Box").." "..own_num)
		end
		local mem = tubelib2.get_mem(pos)
		local nvm = techage.get_nvm(pos)
		nvm.capa = (nvm.capa or 0) + (mem.capa or 0)
		tubelib2.del_mem(pos)
	end,
})

minetest.register_craft({
	output = "techage:ta3_akku",
	recipe = {
		{"default:tin_ingot", "default:tin_ingot", "default:wood"},
		{"default:copper_ingot", "default:copper_ingot", "techage:electric_cableS"},
		{"techage:iron_ingot", "techage:iron_ingot", "default:wood"},
	},
})
