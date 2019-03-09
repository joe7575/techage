-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUMPTION = 2
local STANDBY_TICKS = 4
local CYCLE_TIME = 4

local Cable = techage.ElectricCable
local consumer = techage.consumer

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image_button[3,1.2;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function valid_power_dir(pos, power_dir, in_dir)
	return power_dir == in_dir
end

local function start_node(pos, mem, state)
	consumer.turn_power_on(pos, POWER_CONSUMPTION)
end

local function stop_node(pos, mem, state)
	consumer.turn_power_on(pos, 0)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ele_consumer",
	node_name_active = "techage:ele_consumer_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	start_node = start_node,
	stop_node = stop_node,
})

local function lamp_turn_on_clbk(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	local state = State:get_state(mem)
	
	if sum > 0 and state == techage.FAULT then
		State:stop(pos, mem)
		State:start(pos, mem)
	elseif sum <= 0 and state == techage.RUNNING then
		State:fault(pos, mem)
	end
end

local function node_timer(pos, elapsed)
	print("node_timer")
	local mem = tubelib2.get_mem(pos)
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
end

minetest.register_node("techage:ele_consumer", {
	description = "Consumer",
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_button.png',
		'techage_electric_button.png',
		'techage_electric_button.png',
		'techage_electric_button.png^techage_electric_plug.png',
		'techage_electric_button.png',
		'techage_electric_button.png',
	},
	techage = {
		turn_on = lamp_turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Cable,
		power_side = "L",
		valid_power_dir = valid_power_dir,
	},
	
	after_place_node = function(pos, placer)
		local mem = consumer.after_place_node(pos, placer)
		State:node_init(pos, mem, "")
		on_rightclick(pos)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		consumer.after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = consumer.after_tube_update,
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,

	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ele_consumer_on", {
	description = "Consumer",
	tiles = {
		'techage_electric_button.png',
	},
	techage = {
		turn_on = lamp_turn_on_clbk,
		read_power_consumption = consumer.read_power_consumption,
		power_network = Cable,
		power_side = "L",
		valid_power_dir = valid_power_dir,
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		consumer.after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = consumer.after_tube_update,
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,

	paramtype = "light",
	light_source = LIGHT_MAX,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drop = "techage:ele_consumer",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

