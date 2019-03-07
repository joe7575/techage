-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 16

local function formspec(self, pos, mem)
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[2,0.5;1,2;"..techage.generator_formspec_level(mem)..
		"image_button[3,1.2;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"button[5.5,1.2;1.8,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		default.get_hotbar_bg(0, 3)
end

local function can_start(pos, mem, state)
	print("can_start")
	local sum = techage.calc_power_consumption(pos, mem, 8)
	print("sum", sum)
	if sum > 0 then
		M(pos):set_string("infotext", "On:"..sum.." / "..8)
		return true
	end
	return false
end

local function start_node(pos, mem, state)
	print("start_node")
	techage.generator_on(pos, mem)
end

local function stop_node(pos, mem, state)
	techage.generator_off(pos, mem)
	M(pos):set_string("infotext", "Off")
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:generator",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	has_item_meter = true,
	aging_factor = 10,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})


local function distibuting(pos, mem)
	local sum = techage.calc_power_consumption(pos, mem, 8)
	if sum > 0 then
		State:keep_running(pos, mem, COUNTDOWN_TICKS)
	else
		State:fault(pos, mem)	
	end
	M(pos):set_string("infotext", "On:"..sum.." / "..8)
end

local function node_timer(pos, elapsed)
	--print("node_timer")
	local mem = tubelib2.get_mem(pos)
	distibuting(pos, mem)
	return State:is_active(mem)
end

local function valid_power_dir(pos, mem, in_dir)
	return mem.power_dir == in_dir
end

local function turn_power_on(pos, in_dir, on)
	local mem = tubelib2.get_mem(pos)
	if State:is_active(mem) and not on then
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

minetest.register_node("techage:generator", {
	description = "TechAge Generator",
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png^techage_electric_plug.png',
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png',
		'techage_electric_button.png^techage_electric_power.png',
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	techage = {
		power_consumption =	techage.generator_power_consumption,
		power_network = techage.ElectricCable,
		power_consume = 0,
		valid_power_dir = valid_power_dir,
		turn_on = turn_power_on,
	},
	
	after_place_node = function(pos, placer)
		local mem = techage.generator_after_place_node(pos)
		State:node_init(pos, mem, "")
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		techage.generator_after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = techage.generator_after_tube_update,	
	on_destruct = techage.generator_on_destruct,
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
})

