--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Booster

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local PWR_NEEDED = 3
local CYCLE_TIME = 2

local Cable = techage.ElectricCable
local power = networks.power

local function infotext(pos, state)
	M(pos):set_string("infotext", S("TA3 Booster")..": "..state)
end

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_booster", {
			pos = pos,
			gain = 1,
			max_hear_distance = 7,
			loop = true})
		if mem.handle == -1 then
			minetest.after(1, play_sound, pos)
		end
	end
end

local function stop_sound(pos)
	local mem = techage.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	Cable:after_place_node(pos)
	local node = minetest.get_node(pos)
	local indir = techage.side_to_indir("R", node.param2)
	M(pos):set_int("indir", indir)
	infotext(pos, "stopped")
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

minetest.register_node("techage:ta3_booster", {
	description = S("TA3 Booster"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_appl_arrow.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_compressor.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_compressor.png^[transformFX^techage_frame_ta3.png",
	},

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed == PWR_NEEDED then
			swap_node(pos, "techage:ta3_booster_on")
			infotext(pos, "running")
			play_sound(pos)
		end
		return true
	end,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

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
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
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

	on_timer = function(pos, elapsed)
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed < PWR_NEEDED then
			swap_node(pos, "techage:ta3_booster")
			infotext(pos, "no power")
			stop_sound(pos)
		end
		return true
	end,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory = 1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:ta3_booster", "techage:ta3_booster_on"}, Cable, "con", {"B", "F", "L", "D", "U"})

-- for intra machine communication
techage.register_node({"techage:ta3_booster", "techage:ta3_booster_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if M(pos):get_int("indir") == in_dir then
			local nvm = techage.get_nvm(pos)
			if topic == "power" then
				return techage.get_node_lvm(pos).name == "techage:ta3_booster_on" or
						power.power_available(pos, Cable)
			elseif topic == "running" then
				return techage.get_node_lvm(pos).name == "techage:ta3_booster_on"
			elseif topic == "start" and not nvm.running then
				if power.power_available(pos, Cable) then
					nvm.running = true
					minetest.get_node_timer(pos):start(CYCLE_TIME)
					swap_node(pos, "techage:ta3_booster_on")
					infotext(pos, "running")
					play_sound(pos)
				else
					infotext(pos, "no power")
				end
			elseif topic == "stop" then
				nvm.running = false
				swap_node(pos, "techage:ta3_booster")
				minetest.get_node_timer(pos):stop()
				infotext(pos, "stopped")
				stop_sound(pos)
			end
		end
	end,
	on_node_load = function(pos, node)
		if node.name == "techage:ta3_booster_on" then
			play_sound(pos)
		end
	end,
})

minetest.register_craft({
	output = "techage:ta3_booster",
	recipe = {
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
		{"", "basic_materials:gear_steel", ""},
		{"basic_materials:steel_bar", "default:wood", "basic_materials:steel_bar"},
	},
})
