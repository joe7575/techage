--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Electrolyzer

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
local STANDBY_TICKS = 3
local PWR_NEEDED = 30
local PWR_UNITS_PER_HYDROGEN_ITEM = 80
local CAPACITY = 200

local function formspec(self, pos, nvm)
	local amount = (nvm.liquid and nvm.liquid.amount) or 0
	local lqd_name = (nvm.liquid and nvm.liquid.name) or "techage:liquid"
	local arrow = "image[3,1.5;1,1;techage_form_arrow_bg.png^[transformR270]"
	if nvm.running then
		arrow = "image[3,1.5;1,1;techage_form_arrow_fg.png^[transformR270]"
	end
	if amount > 0 then
		lqd_name = lqd_name.." "..amount
	end
	return "size[6,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;5.8,0.5;#c6e8ff]"..
		"label[2.5,-0.1;"..minetest.colorize( "#000000", S("Electrolyzer")).."]"..
		techage.power.formspec_label_bar(0.1, 0.8, S("Electricity"), PWR_NEEDED, nvm.taken)..
		arrow..
		"image_button[3,2.5;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[3,2.5;1,1;"..self:get_state_tooltip(nvm).."]"..
		techage.item_image(4.5,2, lqd_name)
end

local function start_node(pos, nvm, state)
	nvm.running = true
	nvm.taken = 0
	power.consumer_start(pos, Cable, CYCLE_TIME)
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	nvm.taken = 0
	power.consumer_stop(pos, Cable)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_electrolyzer",
	node_name_active = "techage:ta4_electrolyzer_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA4 Electrolyzer"),
	start_node = start_node,
	stop_node = stop_node,
})

local function on_power(pos)
	local nvm = techage.get_nvm(pos)
	State:start(pos, nvm)
	nvm.running = true
end

local function on_nopower(pos)
	local nvm = techage.get_nvm(pos)
	State:stop(pos, nvm)
	nvm.running = false
end

local function is_running(pos, nvm) 
	return nvm.running 
end

local function generating(pos, nvm)
	nvm.num_pwr_units = nvm.num_pwr_units or 0
	nvm.countdown = nvm.countdown or 0
	--print("electrolyzer", nvm.running, nvm.taken, nvm.num_pwr_units, nvm.liquid.amount)
	if nvm.taken > 0 then
		nvm.num_pwr_units = nvm.num_pwr_units + (nvm.taken or 0)
		if nvm.num_pwr_units >= PWR_UNITS_PER_HYDROGEN_ITEM then
			nvm.liquid.amount = nvm.liquid.amount + 1
			nvm.liquid.name = "techage:hydrogen"
			nvm.num_pwr_units = nvm.num_pwr_units - PWR_UNITS_PER_HYDROGEN_ITEM
		end
	end
end	

-- converts power into hydrogen
local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	
	if nvm.liquid.amount < CAPACITY then
		nvm.taken = power.consumer_alive(pos, Cable, CYCLE_TIME)
		generating(pos, nvm)
		State:keep_running(pos, nvm, 1) -- TODO warum hier 1 und nicht COUNTDOWN_TICKS?
	else
		State:blocked(pos, nvm, S("full"))
		power.consumer_stop(pos, Cable)
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return true
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	nvm.running = false
	nvm.num_pwr_units = 0
	local number = techage.add_node(pos, "techage:ta4_electrolyzer")
	State:node_init(pos, nvm, number)
	local node = minetest.get_node(pos)
	M(pos):set_int("in_dir", techage.side_to_indir("R", node.param2))
	Pipe:after_place_node(pos)
	Cable:after_place_node(pos)
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
		sides = {R = 1}, -- Pipe connection sides
		ntype = "tank",
	},
	ele1 = {
		sides = {L = 1}, -- Cable connection sides
		ntype = "con2",
		on_power = on_power,
		on_nopower = on_nopower,
		nominal = PWR_NEEDED,
		is_running = is_running,
	},
}

local liquid_def = {
	capa = CAPACITY,
	peek = liquid.srv_peek,
	put = function(pos, indir, name, amount)
		local leftover = liquid.srv_put(pos, indir, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return leftover
	end,
	take = function(pos, indir, name, amount)
		amount, name = liquid.srv_take(pos, indir, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return amount, name
	end
}

minetest.register_node("techage:ta4_electrolyzer", {
	description = S("TA4 Electrolyzer"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_electrolyzer.png^techage_appl_ctrl_unit.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_electrolyzer.png^techage_appl_ctrl_unit.png",
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

minetest.register_node("techage:ta4_electrolyzer_on", {
	description = S("TA4 Electrolyzer"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_electrolyzer4.png^techage_appl_ctrl_unit4.png^[transformFX",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_electrolyzer4.png^techage_appl_ctrl_unit4.png",
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

Cable:add_secondary_node_names({"techage:ta4_electrolyzer", "techage:ta4_electrolyzer_on"})
Pipe:add_secondary_node_names({"techage:ta4_electrolyzer", "techage:ta4_electrolyzer_on"})
techage.register_node({"techage:ta4_electrolyzer", "techage:ta4_electrolyzer_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "load" then
			return techage.power.percent(CAPACITY, (nvm.liquid and nvm.liquid.amount) or 0)
		elseif topic == "delivered" then
			return -math.floor((nvm.taken or 0) + 0.5)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
})	

minetest.register_craft({
	output = "techage:ta4_electrolyzer",
	recipe = {
		{'default:steel_ingot', 'dye:blue', 'default:steel_ingot'},
		{'techage:electric_cableS', 'default:glass', 'techage:tubeS'},
		{'default:steel_ingot', "techage:ta4_wlanchip", 'default:steel_ingot'},
	},
})

