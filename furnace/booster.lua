--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Booster

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local D = techage.Debug

local PWR_NEEDED = 3
local CYCLE_TIME = 2

local Power = techage.ElectricCable
local power = techage.power

local function infotext(pos, state)
	M(pos):set_string("infotext", S("TA3 Booster")..": "..state)
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos, mem)
	if mem.running then
		swap_node(pos, "techage:ta3_booster_on")
		infotext(pos, "running")
	end
	if D.dbg2 then D.dbg("booster on_power") end
	mem.is_powered = true
end

local function on_nopower(pos, mem)
	swap_node(pos, "techage:ta3_booster")
	infotext(pos, "no power")
	if D.dbg2 then D.dbg("booster on_nopower") end
	mem.is_powered = false
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running and mem.is_powered then
		minetest.sound_play("techage_booster", {
			pos = pos, 
			gain = 1,
			max_hear_distance = 7})
	end
	if mem.running then
		power.consumer_alive(pos, mem)
	end
	return mem.running
end

minetest.register_node("techage:ta3_booster", {
	description = S("TA3 Booster"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_appl_arrow.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_biogas.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_compressor.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_compressor.png^[transformFX^techage_frame_ta3.png",
	},
	
	on_construct = tubelib2.init_mem,
	after_place_node = function(pos, placer)
		-- secondary 'after_place_node', called by power. Don't use tubelib2.init_mem(pos)!!!
		local mem = tubelib2.get_mem(pos)
		local node = minetest.get_node(pos)
		local indir = techage.side_to_indir("R", node.param2)
		M(pos):set_int("indir", indir)
		infotext(pos, "stopped")
	end,
	on_timer = node_timer,
	
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
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
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
	
	on_timer = node_timer,
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory = 1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:ta3_booster", "techage:ta3_booster_on"}, {
	power_network = Power,
	conn_sides = {"F", "B", "U", "D", "L"},
	on_power = on_power,
	on_nopower = on_nopower,
})

-- for intra machine communication
techage.register_node({"techage:ta3_booster", "techage:ta3_booster_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if M(pos):get_int("indir") == in_dir then
			local mem = tubelib2.get_mem(pos)
			if topic == "power" then
				if D.dbg2 then D.dbg("booster power") end
				return power.power_available(pos, mem, 0)
			elseif topic == "start" and not mem.running then
				if D.dbg2 then D.dbg("booster try start", mem.pwr_master_pos, mem.pwr_power_provided_cnt) end
				if power.power_available(pos, mem, 0) then
					mem.running = true
					if D.dbg2 then D.dbg("booster start") end
					power.consumer_start(pos, mem, CYCLE_TIME, PWR_NEEDED)
					minetest.get_node_timer(pos):start(CYCLE_TIME)
				else
					if D.dbg2 then D.dbg("booster no power") end
					infotext(pos, "no power")
				end
			elseif topic == "stop" then
				mem.running = false
				if D.dbg2 then D.dbg("booster stop") end
				swap_node(pos, "techage:ta3_booster")
				power.consumer_stop(pos, mem)
				minetest.get_node_timer(pos):stop()
				infotext(pos, "stopped")
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

techage.register_entry_page("ta3f", "booster",
	S("TA3 Booster"), 
	S("Part of the TA3 Industrial Furnace and further machines. Used to increase the air/gas pressure."), 
	"techage:ta3_booster")
