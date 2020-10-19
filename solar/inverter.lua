--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Solar Power DC/AC Inverter
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos

local Cable = techage.ElectricCable
local Solar = techage.TA4_Cable
local power = techage.power
local networks = techage.networks

local CYCLE_TIME = 2
local PWR_PERF = 100

local function determine_power(pos, nvm)
	-- determine DC node position
	local outdir = M(pos):get_int("leftdir")
	local max_power, num_inverter = power.get_power(pos, outdir, Solar, "techage:ta4_solar_inverter")
	if num_inverter == 1 then
		nvm.max_power = math.min(PWR_PERF, max_power)
	else
		nvm.max_power = 0
	end
	return max_power, num_inverter
end

local function determine_power_from_time_to_time(pos, nvm)
	local time = minetest.get_timeofday() or 0
	if time < 6.00/24.00 or time > 18.00/24.00 then
		nvm.ticks = 0
		nvm.max_power = 0
		return
	end
	nvm.ticks = nvm.ticks or 0
	if (nvm.ticks % 10) == 0 then -- calculate max_power not to often
		determine_power(pos, nvm)
	else
		nvm.max_power = nvm.max_power or 0
	end
	nvm.ticks = nvm.ticks + 1
end

local function formspec(self, pos, nvm)
	local max_power = nvm.max_power or 0
	local delivered = nvm.delivered or 0
	local arrow = "image[2.5,1.5;1,1;techage_form_arrow_bg.png^[transformR270]"
	if nvm.running then
		arrow = "image[2.5,1.5;1,1;techage_form_arrow_fg.png^[transformR270]"
	end
	return "size[6,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;5.8,0.5;#c6e8ff]"..
		"label[2.5,-0.1;"..minetest.colorize( "#000000", S("Inverter")).."]"..
		power.formspec_label_bar(0,   0.8, S("Power DC"), PWR_PERF, max_power)..
		power.formspec_label_bar(3.5, 0.8, S("Power AC"), max_power, delivered)..
		arrow..
		"image_button[2.5,3;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2.5,3;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function can_start(pos, nvm, state)
	local max_power, num_inverter = determine_power(pos, nvm)
	if num_inverter > 1 then return "solar network error" end
	if max_power == 0 then return "no solar power" end
	return true
end

local function start_node(pos, nvm, state)
	nvm.running = true
	nvm.delivered = 0
	nvm.ticks = 0
	local outdir = M(pos):get_int("outdir")
	power.generator_start(pos, Cable, CYCLE_TIME, outdir, nvm.max_power)
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	nvm.delivered = 0
	local outdir = M(pos):get_int("outdir")
	power.generator_stop(pos, Cable, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_solar_inverter",
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	formspec_func = formspec,
	infotext_name = S("TA4 Solar Inverter"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	determine_power_from_time_to_time(pos, nvm)
	--if nvm.max_power > 0 then
		local outdir = M(pos):get_int("outdir")
		nvm.delivered = power.generator_alive(pos, Cable, CYCLE_TIME, outdir, nvm.max_power)
	--else
		--nvm.delivered = 0
	--end
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
	
	if fields.update then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	determine_power(pos, nvm)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function tubelib2_on_update2(pos, outdir, tlib2, node) 
	power.update_network(pos, outdir, tlib2)
end

minetest.register_node("techage:ta4_solar_inverter", {
	description = S("TA4 Solar Inverter"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_ta4_cable.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inverter.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inverter.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	after_place_node = function(pos)
		local nvm = techage.get_nvm(pos)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		M(pos):set_int("leftdir", networks.side_to_outdir(pos, "L"))
		Cable:after_place_node(pos)
		Solar:after_place_node(pos)
		local number = techage.add_node(pos, "techage:ta4_solar_inverter")
		State:node_init(pos, nvm, number)
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end,
	
	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		Solar:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	tubelib2_on_update2 = tubelib2_on_update2,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	networks = {
		ele1 = {
			sides = {R = 1},
			ntype = "gen1",
			nominal = PWR_PERF,
		},
		ele2 = {
			sides = {L = 1},
			ntype = "con1",
		},
	}
})

Cable:add_secondary_node_names({"techage:ta4_solar_inverter"})
Solar:add_secondary_node_names({"techage:ta4_solar_inverter"})

techage.register_node({"techage:ta4_solar_inverter"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "delivered" then
			return math.floor((nvm.delivered or 0) + 0.5)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
})	

minetest.register_craft({
	output = "techage:ta4_solar_inverter",
	recipe = {
		{'default:steel_ingot', 'dye:green', 'default:steel_ingot'},
		{'', 'techage:ta4_wlanchip', 'techage:electric_cableS'},
		{'default:steel_ingot', "techage:baborium_ingot", 'default:steel_ingot'},
	},
})

--minetest.register_craft({
--	output = "techage:ta4_solar_inverterDC",
--	recipe = {
--		{'default:steel_ingot', 'dye:green', 'default:steel_ingot'},
--		{'techage:ta4_power_cableS', '', ''},
--		{'default:steel_ingot', "techage:baborium_ingot", 'default:steel_ingot'},
--	},
--})
