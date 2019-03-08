-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")


local POWER_CONSUME = 4
local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		--"image[2,0.5;1,2;"..techage.generator_formspec_level(mem)..
		"image_button[3,1.2;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		--"button[5.5,1.2;1.8,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, mem, state)
	-- signal power consumption
	mem.power_consume = POWER_CONSUME
	-- goto RUNNING or FAULT, depending on power supply
	return mem.power_supply
end

local function start_node(pos, mem, state)
	techage.consumer_check_power_consumption(pos)
end

local function stop_node(pos, mem, state)
	mem.power_consume = 0
	techage.consumer_check_power_consumption(pos)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ele_consumer",
	node_name_active = "techage:ele_consumer_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	--print("node_timer")
	local mem = tubelib2.get_mem(pos)
	return State:is_active(mem)
end

-- To be able to check if power connection is on the 
-- correct node side (mem.power_dir == in_dir)
local function valid_power_dir(pos, mem, in_dir)
	--print("valid_power_dir", mem.power_dir, in_dir)
	return true
end

local function turn_power_on(pos, in_dir, on)
	local mem = tubelib2.get_mem(pos)
	mem.power_supply = on
	local state = State:get_state(mem)
	
	if on and state == techage.FAULT then
		State:stop(pos, mem)
		State:start(pos, mem)
	elseif not on and state == techage.RUNNING then
		State:fault(pos, mem)
	end
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
		'techage_electric_button.png',
		'techage_electric_button.png',
		'techage_electric_button.png',
	},
	techage = {
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.ElectricCable,
		power_side = "L",
		valid_power_dir = valid_power_dir,
		turn_on = turn_power_on,
	},
	
	after_place_node = function(pos, placer)
		local mem = techage.consumer_after_place_node(pos, placer)
		mem.power_consume = 0
		mem.power_supply = false
		on_rightclick(pos)
		State:node_init(pos, mem, "")
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		techage.consumer_after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = techage.consumer_after_tube_update,
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
		power_consumption =	techage.consumer_power_consumption,
		power_network = techage.ElectricCable,
		power_side = "L",
		valid_power_dir = valid_power_dir,
		turn_on = turn_power_on,
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		techage.consumer_after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = techage.consumer_after_tube_update,
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

