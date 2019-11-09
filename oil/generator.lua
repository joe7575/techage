--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Tiny Oil Power Generator

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Power = techage.ElectricCable
local firebox = techage.firebox
local power = techage.power
local fuel = techage.fuel
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CYCLE_TIME = 2
local PWR_CAPA = 12
local EFFICIENCY = 2.5

local function formspec(self, pos, mem)
	local fuel_percent = 0
	if mem.running then
		fuel_percent = ((mem.burn_cycles or 1) * 100) / (mem.burn_cycles_total or 1)
	end
	return "size[8,6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		fuel.formspec_fuel(1, 0, mem)..
		"button[1.6,1;1.8,1;update;"..S("Update").."]"..
		"image_button[5.5,0.5;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"image[6.5,0;1,2;"..power.formspec_power_bar(PWR_CAPA, mem.provided).."]"..
		"list[current_player;main;0,2.3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, mem, state)
	if mem.burn_cycles > 0 or (mem.liquid and mem.liquid.amount and mem.liquid.amount > 0) then 
		return true 
	end
	return false
end

local function start_node(pos, mem, state)
	mem.running = true
	power.generator_start(pos, mem, PWR_CAPA)
	minetest.sound_play("techage_generator", {
		pos = pos, 
		gain = 1,
		max_hear_distance = 10})
end

local function stop_node(pos, mem, state)
	mem.running = false
	mem.provided = 0
	power.generator_stop(pos, mem)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:tiny_generator",
	node_name_active = "techage:tiny_generator_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	formspec_func = formspec,
	infotext_name = "TA3 Tiny Power Generator",
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function burning(pos, mem)
	local ratio = math.max((mem.provided or PWR_CAPA) / PWR_CAPA, 0.02)
	
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	mem.burn_cycles = (mem.burn_cycles or 0) - ratio
	if mem.burn_cycles <= 0 then
		if mem.liquid.amount > 0 then
			mem.liquid.amount = mem.liquid.amount - 1
			mem.burn_cycles = fuel.burntime(mem.liquid.name) * EFFICIENCY / CYCLE_TIME
			mem.burn_cycles_total = mem.burn_cycles
			return true
		else
			mem.liquid.name = nil 
			State:fault(pos, mem)
			return false
		end
	else
		return true
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running and burning(pos, mem) then
		mem.provided = power.generator_alive(pos, mem)
		minetest.sound_play("techage_generator", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 10})
		return true
	else
		mem.provided = 0
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	State:state_button_event(pos, mem, fields)
	
	M(pos):set_string("formspec", formspec(State, pos, mem))
end


local function formspec_clbk(pos, mem)
	return formspec(State, pos, mem)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	minetest.after(0.5, fuel.move_item, pos, stack, formspec_clbk)
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
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
		local mem = tubelib2.init_mem(pos)
		local number = techage.add_node(pos, "techage:tiny_generator")
		mem.running = false
		mem.burn_cycles = 0
		State:node_init(pos, mem, number)
		local meta = M(pos)
		meta:set_string("formspec", formspec(State, pos, mem))
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

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
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
		local mem = tubelib2.get_mem(pos)
		if topic == "load" then
			return power.percent(PWR_CAPA, mem.provided)
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

