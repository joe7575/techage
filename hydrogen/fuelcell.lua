--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA4 Fuel Cell

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = techage.power
local Pipe = techage.LiquidPipe
local liquid = techage.liquid
local networks = techage.networks

local CYCLE_TIME = 2
local STANDBY_TICKS = 4
local PWR_CAPA = 34
local PWR_UNITS_PER_HYDROGEN_ITEM = 75
local CAPACITY = 100

local States = {}
local STATE = function(pos) return States[techage.get_node_lvm(pos).name] end

local function is_gen1(nvm)
	if not nvm.running then
		local is_gen1 = dump(nvm.is_gen1 or false)
		return "checkbox[0.3,0.5;is_gen1;"..S("Cat. 1 generator")..";"..is_gen1.."]"..
			"tooltip[0.3,0.5;1,1;"..S("If set, fuelcell will work\nas cat. 1 generator")..";#0C3D32;#FFFFFF]"
	end
	if nvm.is_gen1 then
		return "label[0.5,0.7;"..S("Cat. 1 generator").."]"
	else
		return "label[0.5,0.7;"..S("Cat. 2 generator").."]"
	end
end

local function formspec(self, pos, nvm)
	local amount = (nvm.liquid and nvm.liquid.amount) or 0
	local lqd_name = (nvm.liquid and nvm.liquid.name) or "techage:liquid"
	local arrow = "image[2,1.5;1,1;techage_form_arrow_bg.png^[transformR270]"
	if nvm.running then
		arrow = "image[2,1.5;1,1;techage_form_arrow_fg.png^[transformR270]"
	end
	if amount > 0 then
		lqd_name = lqd_name.." "..amount
	end
	return "size[6,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;5.8,0.5;#c6e8ff]"..
		"label[2.5,-0.1;"..minetest.colorize( "#000000", S("Fuel Cell")).."]"..
		techage.item_image(0.5,2, lqd_name)..
		arrow..
		is_gen1(nvm)..
		"image_button[2,2.5;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2,2.5;1,1;"..self:get_state_tooltip(nvm).."]"..
		techage.power.formspec_label_bar(pos, 3.5, 0.8, S("Electricity"), PWR_CAPA, nvm.given)
end

local function start_node(pos, nvm, state)
	nvm.running = true
	nvm.given = 0
	local outdir = M(pos):get_int("outdir")
	power.generator_start(pos, Cable, CYCLE_TIME, outdir)
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	nvm.given = 0
	local outdir = M(pos):get_int("outdir")
	power.generator_stop(pos, Cable, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_fuelcell",
	node_name_active = "techage:ta4_fuelcell_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA4 Fuel Cell Gen2"),
	start_node = start_node,
	stop_node = stop_node,
})

local function has_hydrogen(nvm)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	nvm.num_pwr_units = nvm.num_pwr_units or 0
	return nvm.num_pwr_units > 0 or (nvm.liquid.amount > 0 and nvm.liquid.name == "techage:hydrogen")
end

local function consuming(pos, nvm)	
	if nvm.num_pwr_units <= 0 then
		nvm.num_pwr_units = nvm.num_pwr_units + PWR_UNITS_PER_HYDROGEN_ITEM
		nvm.liquid.amount = nvm.liquid.amount - 1
	end
	nvm.num_pwr_units = nvm.num_pwr_units - nvm.given
end

-- converts hydrogen into power
local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local state = STATE(pos)
	--print("fuelcell", nvm.running, nvm.given, nvm.num_pwr_units)
	if has_hydrogen(nvm) then
		local outdir = M(pos):get_int("outdir")
		nvm.given = power.generator_alive(pos, Cable, CYCLE_TIME, outdir)
		consuming(pos, nvm)
		state:keep_running(pos, nvm, 1) -- TODO warum hier 1 und nicht COUNTDOWN_TICKS?
	else
		state:standby(pos, nvm)
		nvm.given = 0
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(state, pos, nvm))
	end
	return true
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	if fields.is_gen1 then
		nvm.is_gen1 = fields.is_gen1 == "true"
		local node = minetest.get_node(pos)
		if nvm.is_gen1 then
			node.name = "techage:ta4_fuelcell2"
		else
			node.name = "techage:ta4_fuelcell"
		end
		minetest.swap_node(pos, node)
		local outdir = M(pos):get_int("outdir")
		techage.power.update_network(pos, outdir, Cable)
	end
	STATE(pos):state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(STATE(pos), pos, nvm))
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(STATE(pos), pos, nvm))
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	nvm.running = false
	nvm.num_pwr_units = 0
	local number = techage.add_node(pos, "techage:ta4_fuelcell")
	STATE(pos):node_init(pos, nvm, number)
	local node = minetest.get_node(pos)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	Pipe:after_place_node(pos)
	Cable:after_place_node(pos)
	local inv = M(pos):get_inventory()
	inv:set_size('src', 4)
	inv:set_stack('src', 2, {name = "techage:gasoline", count = 60})
	inv:set_stack('src', 4, {name = "techage:gasoline", count = 60})
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
	Cable:after_dig_node(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	if tlib2.tube_type == "pipe2" then
		liquid.update_network(pos, outdir, tlib2)
	else
		power.update_network(pos, outdir, tlib2)
	end
end

local netw_def = {
	pipe2 = {
		sides = {L = 1}, -- Pipe connection sides
		ntype = "tank",
	},
	ele1 = {
		sides = {R = 1}, -- Cable connection sides
		ntype = "gen2",
		nominal = PWR_CAPA,
	},
}

local liquid_def = {
	capa = CAPACITY,
	peek = liquid.srv_peek,
	put = function(pos, indir, name, amount)
		local leftover = liquid.srv_put(pos, indir, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(STATE(pos), pos, nvm))
		end
		return leftover
	end,
	take = function(pos, indir, name, amount)
		amount, name = liquid.srv_take(pos, indir, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(STATE(pos), pos, nvm))
		end
		return amount, name
	end
}

minetest.register_node("techage:ta4_fuelcell", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png",
	},

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		return liquid.is_empty(pos)
	end,
	
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	on_punch = liquid.on_punch,
	networks = netw_def,
	liquid = liquid_def,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	on_rightclick = on_rightclick,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
})

minetest.register_node("techage:ta4_fuelcell_on", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png^[transformFX",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
	},

	tubelib2_on_update2 = tubelib2_on_update2,
	networks = netw_def,
	liquid = liquid_def,
	on_receive_fields = on_receive_fields,
	on_punch = liquid.on_punch,
	on_timer = node_timer,
	on_rightclick = on_rightclick,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	diggable = false,
	paramtype = "light",
	light_source = 6,
})

-------------------------------------------------------------------------------
-- Gen1 fuellcell
-------------------------------------------------------------------------------
local State2 = techage.NodeStates:new({
	node_name_passive = "techage:ta4_fuelcell2",
	node_name_active = "techage:ta4_fuelcell2_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA4 Fuel Cell Gen1"),
	start_node = start_node,
	stop_node = stop_node,
})

local netw_def2 = {
	pipe2 = {
		sides = {L = 1}, -- Pipe connection sides
		ntype = "tank",
	},
	ele1 = {
		sides = {R = 1}, -- Cable connection sides
		ntype = "gen1",
		nominal = PWR_CAPA - 1, -- to be able to distiguish between cat1 and 2
	},
}

minetest.register_node("techage:ta4_fuelcell2", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png",
	},

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		return liquid.is_empty(pos)
	end,
	
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,
	on_punch = liquid.on_punch,
	networks = netw_def2,
	liquid = liquid_def,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	on_rightclick = on_rightclick,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	drop = "techage:ta4_fuelcell",
})

minetest.register_node("techage:ta4_fuelcell2_on", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png^[transformFX",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
	},

	tubelib2_on_update2 = tubelib2_on_update2,
	networks = netw_def2,
	liquid = liquid_def,
	on_receive_fields = on_receive_fields,
	on_punch = liquid.on_punch,
	on_timer = node_timer,
	on_rightclick = on_rightclick,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	diggable = false,
	paramtype = "light",
	light_source = 6,
})

States["techage:ta4_fuelcell"] = State
States["techage:ta4_fuelcell_on"] = State
States["techage:ta4_fuelcell2"] = State2
States["techage:ta4_fuelcell2_on"] = State2

Cable:add_secondary_node_names({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on", 
		"techage:ta4_fuelcell2", "techage:ta4_fuelcell2_on"})
Pipe:add_secondary_node_names({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on", 
		"techage:ta4_fuelcell2", "techage:ta4_fuelcell2_on"})
techage.register_node({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on", 
		"techage:ta4_fuelcell2", "techage:ta4_fuelcell2_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "load" then
			return techage.power.percent(CAPACITY, (nvm.liquid and nvm.liquid.amount) or 0)
		elseif topic == "delivered" then
			return math.floor((nvm.given or 0) + 0.5)
		else
			return STATE(pos):on_receive_message(pos, topic, payload)
		end
	end,
})	

minetest.register_craft({
	output = "techage:ta4_fuelcell",
	recipe = {
		{'default:steel_ingot', 'dye:blue', 'default:steel_ingot'},
		{'techage:ta3_pipeS', 'techage:ta4_fuelcellstack', 'techage:electric_cableS'},
		{'default:steel_ingot', "techage:ta4_wlanchip", 'default:steel_ingot'},
	},
})
