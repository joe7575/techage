--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 TES Generator (dummy)
	- can be started and stopped
    - provides netID of cable network
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

minetest.register_node("techage:ta4_generator", {
	description = S("TA4 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_hole_electric.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_generator.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_generator.png^[transformFX]",
	},

	after_place_node = function(pos)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta4_generator_on", {
	description = S("TA4 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_hole_electric.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta4.png",
		{
			image = "techage_filling4_ta4.png^techage_appl_generator4.png^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_appl_generator4.png^[transformFX]^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},

	paramtype2 = "facedir",
	drop = "",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

-- The generator is a dummy, it only has to network connection to check the netID
power.register_nodes({"techage:ta4_generator", "techage:ta4_generator_on"}, Cable, "con", {"R"})

-- controlled by the turbine
techage.register_node({"techage:ta4_generator", "techage:ta4_generator_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "netID" then
			local outdir = M(pos):get_int("outdir")
			return networks.determine_netID(pos, Cable, outdir)
		elseif topic == "start" then
			swap_node(pos, "techage:ta4_generator_on")
		elseif topic == "stop" then
			swap_node(pos, "techage:ta4_generator")
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		return "unsupported"
	end,
	on_node_load = function(pos)
		-- remove legacy formspec
		M(pos):set_string("formspec", "")
	end,
})

minetest.register_craft({
	output = "techage:ta4_generator",
	recipe = {
		{"", "dye:blue", ""},
		{"", "techage:generator", ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})
