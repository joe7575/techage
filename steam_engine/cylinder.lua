--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Steam Engine Cylinder

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.SteamPipe

local function transfer_flywheel(pos, topic, payload)
	return  techage.transfer(pos, "R", topic, payload, nil,
		{"techage:flywheel", "techage:flywheel_on"})
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
		mem.handle = minetest.sound_play("techage_steamengine", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 8,
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
	swap_node(pos, "techage:cylinder")
	stop_sound(pos)
end

minetest.register_node("techage:cylinder", {
	description = S("TA2 Cylinder"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_steam_hole.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_cylinder.png^techage_frame_ta2.png",
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

minetest.register_node("techage:cylinder_on", {
	description = S("TA2 Cylinder"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_open.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_steam_hole.png",
		{
			image = "techage_filling4_ta2.png^techage_cylinder4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
		{
			image = "techage_filling4_ta2.png^techage_cylinder4.png^techage_frame4_ta2.png",
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

Pipe:add_secondary_node_names({"techage:cylinder", "techage:cylinder_on"})

techage.register_node({"techage:cylinder", "techage:cylinder_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "trigger" then  -- used by firebox
			local power = transfer_flywheel(pos, topic, payload)
			if not power or power <= 0 and nvm.running then
				swap_node(pos, "techage:cylinder")
				stop_sound(pos)
				nvm.running = false
				return 0
			end
			return power
		elseif topic == "start" then  -- used by flywheel
			swap_node(pos, "techage:cylinder_on")
			play_sound(pos)
			nvm.running = true
			return true
		elseif topic == "stop" then  -- used by flywheel
			swap_node(pos, "techage:cylinder")
			stop_sound(pos)
			nvm.running = false
			return true
		end
	end,
	on_node_load = function(pos, node)
		--print("on_node_load", node.name)
		if node.name == "techage:cylinder_on" then
			play_sound(pos)
		end
	end,
})

minetest.register_craft({
	output = "techage:cylinder",
	recipe = {
		{"basic_materials:steel_bar", "techage:iron_ingot", "default:wood"},
		{"techage:steam_pipeS", "basic_materials:gear_steel", ""},
		{"default:wood", "techage:iron_ingot", "basic_materials:steel_bar"},
	},
})
