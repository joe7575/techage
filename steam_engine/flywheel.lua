--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA2 Steam Engine Flywheel

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local PWR_CAPA = 25

local Axle = techage.Axle
local power = techage.power

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[6,0.5;1,2;"..power.formspec_power_bar(PWR_CAPA, mem.provided).."]"..
		"image_button[5,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"button[2,1.5;2,1;update;"..S("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, mem, state)
	return (mem.firebox_trigger or 0) > 0 -- by means of firebox
end

local function start_node(pos, mem, state)
	mem.generating = true  -- needed for power distribution
	techage.switch_axles(pos, true)
	mem.handle = minetest.sound_play("techage_steamengine", {
		pos = pos, 
		gain = 0.5,
		max_hear_distance = 10})
	power.generator_start(pos, mem, PWR_CAPA)
end

local function stop_node(pos, mem, state)
	mem.generating = false
	techage.switch_axles(pos, false)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
	power.generator_stop(pos, mem)
	mem.provided = 0
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:flywheel",
	node_name_active = "techage:flywheel_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.generating then
		mem.firebox_trigger = (mem.firebox_trigger or 0) - 1
		if mem.firebox_trigger <= 0 then
			State:nopower(pos, mem)
			mem.generating = false
			techage.switch_axles(pos, false)
			power.generator_stop(pos, mem)
			mem.provided = 0
			techage.transfer(pos, "L", "stop", nil, nil, {"techage:cylinder_on"})	
		else
			mem.provided = power.generator_alive(pos, mem)
			State:keep_running(pos, mem, COUNTDOWN_TICKS)
			mem.handle = minetest.sound_play("techage_steamengine", {
				pos = pos, 
				gain = 0.5,
				max_hear_distance = 10})
		end
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

minetest.register_node("techage:flywheel", {
	description = S("TA2 Flywheel"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_axle_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_flywheel.png^[transformFX]",
	},
	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:flywheel_on", {
	description = S("TA2 Flywheel"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		{
			image = "techage_filling4_ta2.png^techage_axle_clutch4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.6,
			},
		},
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		{
			image = "techage_filling8_ta2.png^techage_frame8_ta2.png^techage_flywheel8.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.2,
			},
		},
		{
			image = "techage_filling8_ta2.png^techage_frame8_ta2.png^techage_flywheel8.png^[transformFX]",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.2,
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

techage.power.register_node({"techage:flywheel", "techage:flywheel_on"}, {
	conn_sides = {"R"},
	power_network = Axle,
	after_place_node = function(pos, placer)
		local mem = tubelib2.init_mem(pos)
		State:node_init(pos, mem, "")
		on_rightclick(pos)
	end,

})

techage.register_node({"techage:flywheel", "techage:flywheel_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "trigger" then
			mem.firebox_trigger = 3
			if mem.generating then
				return math.max((mem.provided or PWR_CAPA) / PWR_CAPA, 0.1)
			else
				return 0
			end
		end
	end
})

minetest.register_craft({
	output = "techage:flywheel",
	recipe = {
		{"basic_materials:steel_bar", "dye:red", "default:wood"},
		{"", "basic_materials:gear_steel", "techage:axle"},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})

