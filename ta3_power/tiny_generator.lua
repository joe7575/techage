--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Tiny Power Generator

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local firebox = techage.firebox
local power = techage.power
local fuel = techage.fuel
local Pipe = techage.LiquidPipe
local liquid = techage.liquid
local networks = techage.networks

local CYCLE_TIME = 2
local PWR_CAPA = 12
local EFFICIENCY = 2.5

local function formspec(self, pos, nvm)
	local fuel_percent = 0
	if nvm.running then
		fuel_percent = ((nvm.burn_cycles or 1) * 100) / (nvm.burn_cycles_total or 1)
	end
	return "size[8,6]"..
		--"box[0,-0.1;3.8,0.5;#c6e8ff]"..
		--"label[1,-0.1;"..minetest.colorize( "#000000", S("Tiny Generator")).."]"..
		--power.formspec_label_bar(0, 0.8, S("power"), PWR_CAPA, nvm.provided)..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		fuel.formspec_fuel(1, 0, nvm)..
		"button[1.6,1;1.8,1;update;"..S("Update").."]"..
		"image_button[5.5,0.5;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"image[6.5,0;1,2;"..power.formspec_power_bar(PWR_CAPA, nvm.provided).."]"..
		"list[current_player;main;0,2.3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, nvm, state)
	if nvm.burn_cycles > 0 or (nvm.liquid and nvm.liquid.amount and nvm.liquid.amount > 0) then 
		return true 
	end
	return false
end

local function start_node(pos, nvm, state)
	nvm.running = true
	power.generator_start(pos, nvm, PWR_CAPA)
	minetest.sound_play("techage_generator", {
		pos = pos, 
		gain = 1,
		max_hear_distance = 10})
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	nvm.provided = 0
	power.generator_stop(pos, nvm)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:tiny_generator",
	node_name_active = "techage:tiny_generator_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	formspec_func = formspec,
	infotext_name = S("TA3 Tiny Power Generator"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function burning(pos, nvm)
	local ratio = math.max((nvm.provided or PWR_CAPA) / PWR_CAPA, 0.02)
	
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	nvm.burn_cycles = (nvm.burn_cycles or 0) - ratio
	if nvm.burn_cycles <= 0 then
		if nvm.liquid.amount > 0 then
			nvm.liquid.amount = nvm.liquid.amount - 1
			nvm.burn_cycles = fuel.burntime(nvm.liquid.name) * EFFICIENCY / CYCLE_TIME
			nvm.burn_cycles_total = nvm.burn_cycles
			return true
		else
			nvm.liquid.name = nil 
			State:fault(pos, nvm)
			return false
		end
	else
		return true
	end
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	if nvm.running and burning(pos, nvm) then
		nvm.provided = power.generator_alive(pos, nvm)
		minetest.sound_play("techage_generator", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 10})
		return true
	else
		nvm.provided = 0
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end


local function formspec_clbk(pos, nvm)
	return formspec(State, pos, nvm)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	minetest.after(0.5, fuel.move_item, pos, stack, formspec_clbk)
end

local function on_rightclick(pos)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local _liquid = {
	fuel_cat = fuel.BT_NAPHTHA,
	capa = fuel.CAPACITY,
	peek = liquid.srv_peek,
	put = function(pos, indir, name, amount)
		if fuel.valid_fuel(name, fuel.BT_NAPHTHA) then
			return liquid.srv_put(pos, indir, name, amount)
		end
		return amount
	end,
	take = liquid.srv_take,
}

local _networks = {
	pipe = {
		sides = techage.networks.AllSides, -- Pipe connection sides
		ntype = "tank",
	},
}

minetest.register_node("techage:tiny_generator", {
	description = S("TA3 Tiny Power Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_appl_electric_gen_top.png^techage_frame_ta3_top.png",
		"techage_appl_electric_gen_top.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_front.png^[transformFX]^techage_frame_ta3.png",
		"techage_appl_electric_gen_front.png^techage_frame_ta3.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	on_construct = function(pos)
		local nvm = techage.get_nvm(pos)
		local number = techage.add_node(pos, "techage:tiny_generator")
		nvm.running = false
		nvm.burn_cycles = 0
		State:node_init(pos, nvm, number)
		local meta = M(pos)
		meta:set_string("formspec", formspec(State, pos, nvm))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
	end,

	
	allow_metadata_inventory_put = fuel.allow_metadata_inventory_put,
	allow_metadata_inventory_take = fuel.allow_metadata_inventory_take,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	can_dig = fuel.can_dig,
	liquid = _liquid,
	networks = _networks,
})

minetest.register_node("techage:tiny_generator_on", {
	description = S("TA3 Tiny Power Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_appl_electric_gen_top.png^techage_frame_ta3_top.png",
		"techage_appl_electric_gen_top.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_frame_ta3.png",
		{
			image = "techage_appl_electric_gen_front4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_appl_electric_gen_front4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
	},
	
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	light_source = 4,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	allow_metadata_inventory_put = fuel.allow_metadata_inventory_put,
	allow_metadata_inventory_take = fuel.allow_metadata_inventory_take,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	can_dig = fuel.can_dig,
	liquid = _liquid,
	networks = _networks,
})

Pipe:add_secondary_node_names({"techage:tiny_generator", "techage:tiny_generator_on"})

techage.power.register_node({"techage:tiny_generator", "techage:tiny_generator_on"}, {
	conn_sides = {"R"},
	power_network  = Power,
})

techage.register_node({"techage:tiny_generator", "techage:tiny_generator_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "load" then
			return power.percent(PWR_CAPA, nvm.provided)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_node_load = function(pos)
		State:on_node_load(pos)
	end,
})	

minetest.register_craft({
	output = "techage:tiny_generator",
	recipe = {
		{'default:steel_ingot', 'techage:usmium_nuggets', 'default:steel_ingot'},
		{'dye:red', 'basic_materials:gear_steel', 'techage:electric_cableS'},
		{'default:steel_ingot', 'techage:vacuum_tube', 'default:steel_ingot'},
	},
})

