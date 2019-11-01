--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Power Terminal

]]--

-- for lazy programmers
local P2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local S = techage.S

local CYCLE_TIME = 2
local PWR_CAPA = 0.1
local COUNTDOWN = 5

local Cable = techage.ElectricCable
local power = techage.power

local function collect_network_data(pos, mem)
	local data = {
		fuel = {},
		wind = {},
		solar = {},
		akku = {},
		stor = {},
		elec = {},
		fcel = {},
		other = {},
	}
	local add = function(tbl, mem, nomi, real)
		tbl.num = (tbl.num or 0) + 1
		tbl.load = (tbl.load or 0) + (((mem.pwr_node_alive_cnt or 0) > 0) and 1 or 0)
		tbl.nomi = (tbl.nomi or 0) + (nomi or 0)
		tbl.real = (tbl.real or 0) + (((mem.pwr_node_alive_cnt or 0) > 0) and (real or 0) or 0)
	end	
	
	local nnodes = techage.power.limited_connection_walk(pos, 
		function(pos, node, mem, num_hops, num_nodes) 
			if node.name == "techage:generator" or node.name == "techage:generator_on" then
				add(data.fuel, mem, mem.pwr_available, mem.provided)
			elseif node.name == "techage:ta3_akku" then
				add(data.akku, mem, mem.pwr_could_provide, mem.delivered)
			elseif node.name == "techage:heatexchanger1" then
				add(data.stor, mem, mem.pwr_could_provide, mem.delivered)
			elseif node.name == "techage:tiny_generator" or node.name == "techage:tiny_generator_on" then
				add(data.fuel, mem, mem.pwr_available, mem.provided)
			elseif node.name == "techage:ta4_solar_inverter" then
				add(data.solar, mem, mem.pwr_available, mem.delivered)
			elseif node.name == "techage:ta4_wind_turbine" then
				add(data.wind, mem, mem.pwr_available, mem.delivered)
			elseif node.name == "techage:ta4_fuelcell" or node.name == "techage:ta4_fuelcell_on" then
				add(data.fcel, mem, mem.pwr_available, mem.provided)
			elseif node.name == "techage:ta4_electrolyzer" or node.name == "techage:ta4_electrolyzer_on" then
				add(data.elec, mem, -(mem.pwr_could_need or 0), -(mem.consumed or 0))
			elseif mem.pwr_needed and mem.pwr_needed > 0 and (mem.pwr_node_alive_cnt or 0) > 0 then
				add(data.other, mem, -(mem.pwr_needed or 0), (-mem.pwr_needed or 0))
			end
		end
	)
	return data, nnodes
end

local function formspec(pos, mem)
	local data, nnodes = collect_network_data(pos, mem)
	local get = function(kind) 
		return (data[kind].load or 0).." / "..(data[kind].num or 0).."  :  "..
				(data[kind].curr or 0).." / "..(data[kind].nomi or 0).. " ku"
	end
		
	local alarm = ""
	if nnodes > (techage.MAX_NUM_NODES - 50) then
		alarm = "  (max. "..(techage.MAX_NUM_NODES).." !!!)"
	end
	local update = mem.countdown > 0 and mem.countdown or S("Update")
	return "size[9.5,8.2]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[2,0.0;"..S("Network Data").."]"..
	"label[1,0.7;"..S("(Num. nodes loaded / max. : Power current / max.)").."]"..
	"label[0,1.4;"..S("TA3 Coal/oil")..":]"..       "label[5,1.4;"..get("fuel").."]"..
	"label[0,2.1;"..S("TA3 Akku")..":]"..           "label[5,2.1;"..get("akku").."]"..
	"label[0,2.8;"..S("TA4 Solar Inverter")..":]".. "label[5,2.8;"..get("solar").."]"..
	"label[0,3.5;"..S("TA4 Wind Turbine")..":]"..	"label[5,3.5;"..get("wind").."]"..
	"label[0,4.2;"..S("TA4 Energy Storage")..":]".. "label[5,4.2;"..get("stor").."]"..
	"label[0,4.9;"..S("TA4 Electrolyzer")..":]"..   "label[5,4.9;"..get("elec").."]"..
	"label[0,5.6;"..S("TA4 Fuel Cell")..":]"..      "label[5,5.6;"..get("fcel").."]"..
	"label[0,6.3;"..S("Other consumers")..":]"..    "label[5,6.3;"..get("other").."]"..
	"label[0,7;"..S("Number of nodes").." : "..nnodes..alarm.."]"..
	"button[3.5,7.5;2,1;update;"..update.."]"
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	power.generator_alive(pos, mem)
	
	mem.countdown = mem.countdown or 0
	if mem.countdown > 0 then
		mem.countdown = mem.countdown - 1
		M(pos):set_string("formspec", formspec(pos, mem))
	end
	
	return true
end

minetest.register_node("techage:ta3_power_terminal", {
	description = S("TA3 Power Terminal"),
	inventory_image = "techage_power_terminal_front.png",
	tiles = {
		"techage_power_terminal_top.png",
		"techage_power_terminal_top.png",
		"techage_power_terminal_side.png",
		"techage_power_terminal_side.png",
		"techage_power_terminal_back.png",
		"techage_power_terminal_front.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, 0/16,  8/16, 8/16, 8/16},
		},
	},
	
	on_receive_fields = function(pos, formname, fields, player)
		local mem = tubelib2.get_mem(pos)
		mem.countdown = COUNTDOWN
	end,
	
	on_rightclick = function(pos, node, clicker)
		local mem = tubelib2.get_mem(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		power.generator_start(pos, mem, PWR_CAPA)
		mem.countdown = COUNTDOWN
	end,
	
	on_timer = node_timer,
	paramtype2 = "facedir",
	paramtype = "light",
	on_rotate = screwdriver.disallow,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

techage.power.register_node({"techage:ta3_power_terminal"}, {
	power_network  = Cable,
	conn_sides = {"B"},
	after_place_node = function(pos)
		local mem = tubelib2.init_mem(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		power.generator_start(pos, mem, PWR_CAPA)
		local meta = M(pos)
		mem.countdown = 0
		meta:set_string("formspec", formspec(pos, mem))
	end,
})

minetest.register_craft({
	output = "techage:ta3_power_terminal",
	recipe = {
		{"", "techage:usmium_nuggets", "default:steel_ingot"},
		{"", "techage:basalt_glass_thin", "default:copper_ingot"},
		{"", "techage:vacuum_tube", "default:steel_ingot"},
	},
})

