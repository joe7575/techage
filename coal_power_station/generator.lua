--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Power Station Generator

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local PWR_CAPA = 80

local Cable = techage.ElectricCable
local provide_power = techage.power.provide_power
local power_switched = techage.power.power_switched

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[6,0.5;1,2;"..techage.power.formspec_power_bar(PWR_CAPA, mem.provided).."]"..
		"image_button[5,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"button[2,1.5;2,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, mem, state)
	return (mem.triggered or 0) > 0 -- by means of firebox
end

local function start_node(pos, mem, state)
	mem.generating = true  -- needed for power distribution
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	power_switched(pos)
end

local function stop_node(pos, mem, state)
	mem.generating = false
	minetest.get_node_timer(pos):stop()
	power_switched(pos)
	mem.provided = 0
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:generator",
	node_name_active = "techage:generator_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	--print("generator", mem.triggered, mem.generating, PWR_CAPA * (mem.power_level or 0))
	mem.triggered = mem.triggered or 0
	if mem.triggered > 0 and mem.generating then
		mem.provided = provide_power(pos, PWR_CAPA * (mem.power_level or 0))
		mem.triggered = mem.triggered - 1
		State:keep_running(pos, mem, COUNTDOWN_TICKS)
	elseif mem.generating then -- trigger missing
		State:stop(pos, mem)
		mem.generating = 0
		mem.provided = 0
	else
		mem.provided = 0
	end
	return State:is_active(mem)
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

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
	if mem.generating then
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

minetest.register_node("techage:generator", {
	description = I("TA3 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png^[transformFX]",
	},
	
	on_construct = tubelib2.init_mem,
	
	after_place_node = function(pos, placer)
		local mem = tubelib2.get_mem(pos)
		State:node_init(pos, mem, "")
		on_rightclick(pos)
	end,

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:generator_on", {
	description = I("TA3 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_generator4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_generator4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},
	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,

	drop = "",
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:generator",
	recipe = {
		{"basic_materials:steel_bar", "dye:green", "default:wood"},
		{"", "basic_materials:gear_steel", "techage:electric_cableS"},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})

techage.power.register_node({"techage:generator", "techage:generator_on"}, {
	conn_sides = {"R"},
	power_network = Cable,
})

-- for logical communication
techage.register_node({"techage:generator", "techage:generator_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		--print("generator", topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "power_level" then
			local mem = tubelib2.get_mem(pos)
			mem.power_level = payload
		elseif topic == "trigger" then
			mem.triggered = 2
			mem.power_level = payload
			if mem.generating then
				return math.max((mem.provided or PWR_CAPA) / PWR_CAPA, 0.02)
			else
				return 0
			end
		end
	end
})

techage.register_help_page(I("TA3 Generator"), 
I([[Part of the Coal Power Station.
Has to be placed side by side
with the TA3 Turbine.
Connect the Generator with your TA3 machines
by means of Electric Cables and Junction Boxes
(see TA3 Coal Power Station)]]), "techage:generator")
