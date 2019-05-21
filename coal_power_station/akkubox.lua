--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Akku Box

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 4
local CYCLE_TIME = 2
local POWER_CONSUMPTION = 10
local POWER_MAX_LOAD = 300
local POWER_HYSTERESIS = 10
local Power = techage.ElectricCable

local function formspec(self, pos, mem)
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[0,0.5;1,2;"..techage.power.formspec_power_bar(POWER_MAX_LOAD, mem.capa).."]"..
		"label[0.2,2.5;Load]"..
		"button[1.1,1;1.8,1;update;"..I("Update").."]"..
		"image_button[3,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"image[4,0.5;1,2;"..techage.power.formspec_load_bar(mem.charging).."]"..
		"label[4.2,2.5;Flow]"
end


local function start_node(pos, mem, state)
	techage.power.power_distribution(pos)
end

local function stop_node(pos, mem, state)
	mem.charging = nil
	techage.power.power_distribution(pos)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta3_akku",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	start_node = start_node,
	stop_node = stop_node,
})

--
-- Power network callbacks
--

-- Pass1: Power balance calculation
local function on_power_pass1(pos, mem)
	print("on_power_pass1", mem.charging)
	if State:is_active(mem) and mem.capa > POWER_HYSTERESIS then
		mem.correction = POWER_CONSUMPTION  -- uncharging
	else
		mem.correction = 0
	end
	return -mem.correction  
end	
		
-- Pass2: Power balance adjustment
local function on_power_pass2(pos, mem, sum)
	print("on_power_pass2", mem.charging, sum)
	if State:is_active(mem) then
		if sum > mem.correction + POWER_CONSUMPTION and 
				mem.capa < POWER_MAX_LOAD - POWER_HYSTERESIS then
			mem.charging = true
			return mem.correction + POWER_CONSUMPTION
		elseif sum > mem.correction then
			mem.charging = nil  -- turn off
			return mem.correction
		elseif sum > -POWER_CONSUMPTION and mem.capa > POWER_HYSTERESIS then
			mem.charging = false  -- uncharging
			return 0
		else
			mem.charging = nil  -- turn off
			return mem.correction
		end
	else
		return 0
	end
end

-- Pass3: Power balance result
local function on_power_pass3(pos, mem, sum)
	print("on_power_pass3", mem.charging, sum)
	mem.power_result = sum
end


local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	print("node_timer", mem.charging, mem.capa)
	if State:is_active(mem) then
		mem.capa = mem.capa or 0
		if mem.charging == true then
			if mem.capa < POWER_MAX_LOAD then
				mem.capa = mem.capa + 1
			else
				mem.charging = nil  -- turn off
				techage.power.power_distribution(pos)
			end
		elseif mem.charging == false then  -- uncharging
			if mem.capa > 0 then
				mem.capa = mem.capa - 1
			else
				mem.charging = nil  -- turn off
				techage.power.power_distribution(pos)
			end
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
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("formspec", formspec(State, pos, mem))
	end
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
end

local function get_capa(itemstack)
	local meta = itemstack:get_meta()
	if meta then
		return meta:get_int("capa")
	end
	return 0
end

local function set_capa(pos, oldnode, digger, capa)
	local node = ItemStack(oldnode.name)
	local meta = node:get_meta()
	meta:set_int("capa", capa or 0)
	local text = I("TA3 Akku Box").." ("..techage.power.percent(POWER_MAX_LOAD, capa).." %)"
	meta:set_string("description", text)
	local inv = minetest.get_inventory({type="player", name=digger:get_player_name()})
	local left_over = inv:add_item("main", node)
	if left_over:get_count() > 0 then
		minetest.add_item(pos, node)
	end
end

minetest.register_node("techage:ta3_akku", {
	description = I("TA3 Akku Box"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_electric.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
	},

	on_construct = tubelib2.init_mem,

	after_place_node = function(pos, placer, itemstack)
		local mem = tubelib2.get_mem(pos)
		State:node_init(pos, mem, "")
		mem.capa = get_capa(itemstack)
		on_rightclick(pos)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local mem = tubelib2.get_mem(pos)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		set_capa(pos, oldnode, digger, mem.capa)
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

techage.power.register_node({"techage:ta3_akku"}, {
	on_power_pass1 = on_power_pass1,
	on_power_pass2 = on_power_pass2,
	on_power_pass3 = on_power_pass3,
	conn_sides = {"R"},
	power_network  = Power,
})

techage.register_help_page(I("TA3 Akku Box"), 
I([[Used to store electrical energy.
Charged in about 10 min, 
provides energy for 10 min.]]), "techage:ta3_akku")


minetest.register_craft({
	output = "techage:ta3_akku",
	recipe = {
		{"default:tin_ingot", "default:tin_ingot", "default:wood"},
		{"default:copper_ingot", "default:copper_ingot", "techage:electric_cableS"},
		{"techage:iron_ingot", "techage:iron_ingot", "default:wood"},
	},
})
