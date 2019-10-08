--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Power Terminal

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local BLOCKING_TIME = 2

local Param2ToDir = {
	[0] = 6,
	[1] = 5,
	[2] = 2,
	[3] = 4,
	[4] = 1,
	[5] = 3,
}

local function collect_network_data(pos, mem)
	local data = {
		fuel = {},
		wind = {},
		solar = {},
		akku = {},
		stor = {},
		elec = {},
		fcel = {},
	}
	local add = function(kind, attr, val) 
		data[kind][attr] = (data[kind][attr] or 0) + (val or 0) 
	end
	local max = function(kind, attr, val) 
		data[kind][attr] = math.max((data[kind][attr] or 0), (val or 0))
	end
	
	local nnodes = techage.power.limited_connection_walk(pos, 
		function(pos, node, mem, num_hops, num_nodes) 
			if node.name == "techage:generator" or node.name == "techage:generator_on" then
				add("fuel", "num", 1)
				add("fuel", "nomi", mem.pwr_available)
				add("fuel", "curr", mem.provided)
			elseif node.name == "techage:ta3_akku" then
				add("akku", "num", 1)
				add("akku", "nomi", mem.pwr_could_provide)
				add("akku", "curr", mem.delivered)
			elseif node.name == "techage:heatexchanger1" then
				add("stor", "num", 1)
				add("stor", "nomi", mem.pwr_could_provide)
				add("stor", "curr", mem.delivered)
			elseif node.name == "techage:tiny_generator" or node.name == "techage:tiny_generator_on" then
				add("fuel", "num", 1)
				add("fuel", "nomi", mem.pwr_available)
				add("fuel", "curr", mem.provided)
			elseif node.name == "techage:ta4_solar_inverter" then
				add("solar", "num", 1)
				add("solar", "nomi", mem.pwr_available)
				add("solar", "curr", mem.delivered)
			elseif node.name == "techage:ta4_wind_turbine" then
				add("wind", "num", 1)
				add("wind", "nomi", mem.pwr_available)
				add("wind", "curr", mem.delivered)
			elseif node.name == "techage:ta4_fuelcell" or node.name == "techage:ta4_fuelcell_on" then
				add("fcel", "num", 1)
				add("fcel", "nomi", mem.pwr_available)
				add("fcel", "curr", mem.provided)
			elseif node.name == "techage:ta4_electrolyzer" or node.name == "techage:ta4_electrolyzer_on" then
				add("elec", "num", 1)
				add("elec", "nomi", -(mem.pwr_could_need or 0))
				add("elec", "curr", -(mem.consumed or 0))
			end
		end
	)
	return data, nnodes
end

local function formspec(pos)
	local jpos = minetest.deserialize(M(pos):get_string("junction_pos"))
	local data, nnodes = collect_network_data(jpos, tubelib2.get_mem(jpos))
	local get = function(kind) 
		return (data[kind].num or 0).." / "..(data[kind].curr or 0).." ku / "..(data[kind].nomi or 0).. " ku"
	end
	local get = function(kind) 
		return (data[kind].num or 0).." / "..(data[kind].curr or 0).." ku / "..(data[kind].nomi or 0).. " ku"
	end
		
	local alarm = ""
	if nnodes > (techage.MAX_NUM_NODES - 50) then
		alarm = "  (max. "..(techage.MAX_NUM_NODES).." !!!)"
	end
	return "size[10,7.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[2,0.0;"..S("Network Data").."]"..
	"label[3,0.7;"..S("(number / current / max.)").."]"..
	"label[0,1.4;"..S("TA3 Coal/oil")..":]"..       "label[5,1.4;"..get("fuel").."]"..
	"label[0,2.1;"..S("TA3 Akku")..":]"..           "label[5,2.1;"..get("akku").."]"..
	"label[0,2.8;"..S("TA4 Solar Inverter")..":]".. "label[5,2.8;"..get("solar").."]"..
	"label[0,3.5;"..S("TA4 Wind Turbine")..":]"..	"label[5,3.5;"..get("wind").."]"..
	"label[0,4.2;"..S("TA4 Energy Storage")..":]".. "label[5,4.2;"..get("stor").."]"..
	"label[0,4.9;"..S("TA4 Electrolyzer")..":]"..   "label[5,4.9;"..get("elec").."]"..
	"label[0,5.6;"..S("TA4 Fuel Cell")..":]"..      "label[5,5.6;"..get("fcel").."]"..
	"label[0,6.3;"..S("Number of nodes").." : "..nnodes..alarm.."]"..
	"button[2.5,6.8;2,1;update;"..S("Update").."]"
end

local function update_formspec(pos)
	M(pos):set_string("formspec", formspec(pos))
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
	
	after_place_node = function(pos, placer, itemstack)
		local node = minetest.get_node(pos)
		local outdir = techage.side_to_outdir("B", node.param2)
		local jpos = tubelib2.get_pos(pos, outdir)
		local mem = tubelib2.init_mem(pos)
		mem.blocked_until = 0
		local meta = M(pos)
		meta:set_string("junction_pos", minetest.serialize(jpos))
		meta:set_string("formspec", formspec(pos))
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		local mem = tubelib2.get_mem(pos)
		mem.blocked_until = mem.blocked_until or minetest.get_gametime()
		if fields.update and mem.blocked_until < minetest.get_gametime() then
			M(pos):set_string("formspec", formspec(pos))
			mem.blocked_until = minetest.get_gametime() + BLOCKING_TIME
			minetest.after(BLOCKING_TIME + 1, update_formspec, pos)
		end
	end,
	
	on_rightclick = function(pos, node, clicker)
		M(pos):set_string("formspec", formspec(pos))
	end,
	
	paramtype2 = "facedir",
	paramtype = "light",
	on_rotate = screwdriver.disallow,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techage:ta3_power_terminal",
	recipe = {
		{"", "techage:usmium_nuggets", "default:steel_ingot"},
		{"", "techage:basalt_glass_thin", "default:copper_ingot"},
		{"", "techage:vacuum_tube", "default:steel_ingot"},
	},
})

