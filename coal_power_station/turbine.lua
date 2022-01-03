--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Power Station Turbine

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.SteamPipe

local function transfer_cooler(pos, topic, payload)
	return techage.transfer(pos, 6, topic, payload, Pipe,
		{"techage:cooler", "techage:cooler_on"})
end

local function transfer_generator(pos, topic, payload)
	return techage.transfer(pos, "R", topic, payload, nil,
		{"techage:generator", "techage:generator_on"})
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
		mem.handle = minetest.sound_play("techage_turbine", {
			pos = pos,
			gain = 1,
			max_hear_distance = 15,
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
	Pipe:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	stop_sound(pos)
	Pipe:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node)
	swap_node(pos, "techage:turbine")
	stop_sound(pos)
end

minetest.register_node("techage:turbine", {
	description = S("TA3 Turbine"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_appl_turbine.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_turbine.png^techage_frame_ta3.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	tubelib2_on_update2 = tubelib2_on_update2,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:turbine_on", {
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_steam_hole.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_turbine4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_turbine4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},

	tubelib2_on_update2 = tubelib2_on_update2,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Pipe:add_secondary_node_names({"techage:turbine", "techage:turbine_on"})

techage.register_node({"techage:turbine", "techage:turbine_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "trigger" then  -- used by boiler
			if not transfer_cooler(pos, topic, payload) then
				return 0
			end
			local power = transfer_generator(pos, topic, payload)
			if not power or power <= 0 and nvm.running then
				swap_node(pos, "techage:turbine")
				stop_sound(pos)
				nvm.running = false
				return 0
			end
			return power
		elseif topic == "start" then  -- used by generator
			swap_node(pos, "techage:turbine_on")
			play_sound(pos)
			nvm.running = true
			return true
		elseif topic == "stop" then  -- used by generator
			swap_node(pos, "techage:turbine")
			stop_sound(pos)
			nvm.running = false
			return true
		end
	end,
	on_node_load = function(pos, node)
		if node.name == "techage:turbine_on" then
			play_sound(pos)
		end
	end,
})

minetest.register_craft({
	output = "techage:turbine",
	recipe = {
		{"basic_materials:steel_bar", "techage:steam_pipeS", "default:wood"},
		{"techage:steam_pipeS", "basic_materials:gear_steel", ""},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})
