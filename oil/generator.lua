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

local CYCLE_TIME = 2
local PWR_CAPA = 12
local BURN_CYCLE_FACTOR = 2.5

local function formspec(self, pos, mem)
	local fuel_percent = 0
	if mem.generating then
		fuel_percent = ((mem.burn_cycles or 1) * 100) / (mem.burn_cycles_total or 1)
	end
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[current_name;fuel;0.5,1;1,1;]"..
		"image[1.5,1;1,1;default_furnace_fire_bg.png^[lowpart:"..
		fuel_percent..":default_furnace_fire_fg.png]"..
		"button[3,1;1.8,1;update;"..S("Update").."]"..
		"image_button[5.5,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"image[6.5,0.5;1,2;"..power.formspec_power_bar(PWR_CAPA, mem.provided).."]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, mem, state)
	if mem.burn_cycles > 0 then return true end
	local inv = M(pos):get_inventory()
	return not inv:is_empty("fuel")
end

local function start_node(pos, mem, state)
	mem.generating = true
	power.generator_start(pos, mem, PWR_CAPA)
	minetest.sound_play("techage_generator", {
		pos = pos, 
		gain = 1,
		max_hear_distance = 10})
end

local function stop_node(pos, mem, state)
	mem.generating = false
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
	
	mem.burn_cycles = (mem.burn_cycles or 0) - ratio
	if mem.burn_cycles <= 0 then
		local taken = firebox.get_fuel(pos) 
		if taken then
			mem.burn_cycles = (firebox.Burntime[taken:get_name()] or 1) / CYCLE_TIME * BURN_CYCLE_FACTOR

			mem.burn_cycles_total = mem.burn_cycles
			return true
		else
			State:fault(pos, mem)
			return false
		end
	else
		return true
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.generating and burning(pos, mem) then
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
	
	if fields.update then
		M(pos):set_string("formspec", formspec(State, pos, mem))
	end
end

local function allow_metadata_inventory(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if stack:get_name() == "techage:oil_source" then
		return stack:get_count()
	end
	return 0
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
end

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
		mem.generating = false
		mem.burn_cycles = 0
		State:node_init(pos, mem, number)
		local meta = M(pos)
		meta:set_string("formspec", formspec(State, pos, mem))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
	end,

	allow_metadata_inventory_put = allow_metadata_inventory,
	allow_metadata_inventory_take = allow_metadata_inventory,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	can_dig = techage.firebox.can_dig,
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

	allow_metadata_inventory_put = allow_metadata_inventory,
	allow_metadata_inventory_take = allow_metadata_inventory,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	can_dig = techage.firebox.can_dig,
})

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

techage.register_entry_page("ta3ps", "tiny_generator",
	S("TA3 Tiny Power Generator"), 
	S("Small electrical power generator. Needs oil as fuel.@n"..
		"It provides 12 units electrical power@n"..
		"Oil burn time: 100s"), 
	"techage:tiny_generator")

