--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA3 Booster

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local POWER_CONSUMPTION = 3

local Power = techage.ElectricCable

local function infotext(pos, state)
	M(pos):set_string("infotext", I("TA3 Booster")..": "..state)
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function play_sound(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		mem.handle = minetest.sound_play("techage_booster", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 7})
		minetest.after(2, play_sound, pos)
	end
end

local function stop_sound(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function on_power_pass1(pos, mem)
	--print("on_power_pass1")
	if mem.running then
		mem.correction = POWER_CONSUMPTION
	else
		mem.correction = 0
	end
	return mem.correction
end	
		
local function on_power_pass2(pos, mem, sum)
	if sum > 0 then
		mem.has_power = true
		return 0
	else
		mem.has_power = false
		return -mem.correction
	end
end

minetest.register_node("techage:ta3_booster", {
	description = I("TA3 Booster"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_appl_arrow.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_biogas.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_biogas.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_compressor.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_compressor.png^[transformFX^techage_frame_ta3.png",
	},
	
	on_construct = tubelib2.init_mem,
	
	after_place_node = function(pos, placer)
		local node = minetest.get_node(pos)
		local indir = techage.side_to_indir("R", node.param2)
		M(pos):set_int("indir", indir)
		infotext(pos, "stopped")
	end,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:ta3_booster_on", {
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_appl_arrow.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_biogas.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_biogas.png^techage_frame_ta3.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_compressor4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.2,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_compressor4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.2,
			},
		},
	},
	
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory = 1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:ta3_booster", "techage:ta3_booster_on"}, {
	on_power_pass1 = on_power_pass1,
	on_power_pass2 = on_power_pass2,
	power_network = Power,
	conn_sides = {"F", "B", "U", "D"},
})

-- for intra machine communication
techage.register_node({"techage:ta3_booster", "techage:ta3_booster_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		--print("ta3_booster", topic, payload, in_dir)
		if M(pos):get_int("indir") == in_dir then
			local mem = tubelib2.get_mem(pos)
			if topic == "power" then
				return mem.has_power
			elseif topic == "start" then
				if mem.has_power then
					mem.running = true
					play_sound(pos)
					swap_node(pos, "techage:ta3_booster_on")
					infotext(pos, "running")
					techage.power.power_distribution(pos)
				else
					infotext(pos, "no power")
				end
			elseif topic == "stop" then
				mem.running = false
				stop_sound(pos)
				swap_node(pos, "techage:ta3_booster")
				if mem.has_power then
					infotext(pos, "stopped")
				else
					infotext(pos, "no power")
				end
				techage.power.power_distribution(pos)
			end
		end
	end
})

minetest.register_craft({
	output = "techage:ta3_booster",
	recipe = {
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
		{"", "basic_materials:gear_steel", ""},
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
	},
})

techage.register_help_page(I("TA3 Booster"), 
I([[Part of the TA3 Industrial Furnace 
and further machines.
Used to increase the air/gas pressure.]]), "techage:ta3_booster")


minetest.register_lbm({
	label = "[techage] Booster sound",
	name = "techage:booster",
	nodenames = {"techage:ta3_booster_on"},
	run_at_every_load = true,
	action = function(pos, node)
		play_sound(pos)
	end
})
