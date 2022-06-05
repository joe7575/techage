--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Electrolyzer

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

local CYCLE_TIME = 2
local STANDBY_TICKS = 3
local PWR_NEEDED = 35
local PWR_UNITS_PER_HYDROGEN_ITEM = 80
local CAPACITY = 200

local function evaluate_percent(s)
	return (tonumber(s:sub(1, -2)) or 0) / 100
end

local function formspec(self, pos, nvm)
	local amount = (nvm.liquid and nvm.liquid.amount) or 0
	local lqd_name = (nvm.liquid and nvm.liquid.name) or "techage:liquid"
	local arrow = "image[3,1.5;1,1;techage_form_arrow_bg.png^[transformR270]"
	if techage.is_running(nvm) then
		arrow = "image[3,1.5;1,1;techage_form_arrow_fg.png^[transformR270]"
	end
	if amount > 0 then
		lqd_name = lqd_name .. " " .. amount
	end
	return "size[6,4]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"box[0,-0.1;5.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", S("Electrolyzer")) .. "]" ..
		techage.wrench_tooltip(5.4, -0.1)..
		techage.formspec_power_bar(pos, 0.1, 0.8, S("Electricity"), nvm.taken, PWR_NEEDED) ..
		arrow ..
		"image_button[3,2.5;1,1;" .. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[3,2.5;1,1;" .. self:get_state_tooltip(nvm) .. "]" ..
		techage.item_image(4.5,2, lqd_name)
end

local function can_start(pos, nvm, state)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0

	if nvm.liquid.amount < CAPACITY then
		return true
	end
	return S("Storage full")
end

local function start_node(pos, nvm, state)
	nvm.taken  = 0
	nvm.reduction = evaluate_percent(M(pos):get_string("reduction"))
	nvm.turnoff = evaluate_percent(M(pos):get_string("turnoff"))
end

local function stop_node(pos, nvm, state)
	nvm.taken = 0
	nvm.running = nil -- legacy
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_electrolyzer",
	node_name_active = "techage:ta4_electrolyzer_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA4 Electrolyzer"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function generating(pos, nvm)
	nvm.num_pwr_units = nvm.num_pwr_units or 0
	nvm.countdown = nvm.countdown or 0
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
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0

	if nvm.liquid.amount < CAPACITY then
		local in_dir = meta:get_int("in_dir")
		local curr_load = power.get_storage_load(pos, Cable, in_dir, 1)
		if curr_load > (nvm.turnoff or 0) then
			local to_be_taken = PWR_NEEDED * (nvm.reduction or 1)
			nvm.taken = power.consume_power(pos, Cable, in_dir, to_be_taken) or 0
			local running = techage.is_running(nvm)
			if not running and nvm.taken == to_be_taken then
				State:start(pos, nvm)
			elseif running and nvm.taken < to_be_taken then
				State:nopower(pos, nvm)
			elseif running then
				generating(pos, nvm)
				State:keep_running(pos, nvm, 1)
			end
		elseif curr_load == 0 then
			State:nopower(pos, nvm)
		else
			State:standby(pos, nvm, S("Turnoff point reached"))
		end
	else
		State:blocked(pos, nvm, S("Storage full"))
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
	techage.set_activeformspec(pos, player)
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

local function put(pos, indir, name, amount)
	local leftover = liquid.srv_put(pos, indir, name, amount)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return leftover
end

local tool_config = {
	{
		type = "const",
		name = "needed",
		label = S("Maximum power consumption [ku]"),
		tooltip = S("Maximum possible\ncurrent consumption"),
		value = PWR_NEEDED,
	},
	{
		type = "dropdown",
		choices = "20%,40%,60%,80%,100%",
		name = "reduction",
		label = S("Current limitation"),
		tooltip = S("Configurable value\nfor the current limit"),
		default = "100%",
	},
	{
		type = "dropdown",
		choices = "0%,20%,40%,60%,80%,98%",
		name = "turnoff",
		label = S("Turnoff point"),
		tooltip = S("If the charge of the storage\nsystem exceeds the configured value,\nthe block switches off"),
		default = "98%",
	},
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
	on_punch = liquid.on_punch,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	on_rightclick = on_rightclick,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	ta3_formspec = tool_config,
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
	ta3_formspec = tool_config,
})

local liquid_def = {
	capa = CAPACITY,
	peek = function(pos)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local leftover = liquid.srv_put(nvm, name, amount, CAPACITY)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return leftover
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		amount, name = liquid.srv_take(nvm, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return amount, name
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local leftover = liquid.srv_put(nvm, name, amount, CAPACITY)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return leftover
	end,
}

liquid.register_nodes({"techage:ta4_electrolyzer", "techage:ta4_electrolyzer_on"}, Pipe, "tank", {"R"}, liquid_def)
power.register_nodes({"techage:ta4_electrolyzer", "techage:ta4_electrolyzer_on"}, Cable, "con", {"L"})

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
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 134 and payload[1] == 1 then
			return 0, {techage.power.percent(CAPACITY, (nvm.liquid and nvm.liquid.amount) or 0)}
		elseif topic == 135 then
			return 0, {math.floor((nvm.provided or 0) + 0.5)}
		else
			return State:on_beduino_request_data(pos, topic, payload)
		end
	end,
	on_node_load = function(pos, node)
		local meta = M(pos)
		if not meta:contains("reduction") then
			meta:set_string("reduction", "100%")
			meta:set_string("turnoff", "100%")
		end
	end,
})

minetest.register_craft({
	output = "techage:ta4_electrolyzer",
	recipe = {
		{'default:steel_ingot', 'dye:blue', 'default:steel_ingot'},
		{'techage:electric_cableS', 'default:glass', 'techage:ta3_pipeS'},
		{'default:steel_ingot', "techage:ta4_wlanchip", 'default:steel_ingot'},
	},
})
