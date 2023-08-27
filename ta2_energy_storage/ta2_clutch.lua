--[[

	TechAge
	=======

	Copyright (C) 2019-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Axle clutch

]]--

-- for lazy programmers
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local DESCR = S("TA2 Clutch")

local Axle = techage.Axle
local power = networks.power
local control = networks.control

-- Search for a gearbox, which is part of the axle network
local function get_gearbox_pos(pos)
	local outdir = M(pos):get_int("outdir")
	local pos1, dir1 = Axle:get_connected_node_pos(pos, outdir)
	if pos1 then
		local node = minetest.get_node(pos1)
		--print("get_gearbox_pos", node.name)
		if node.name == "techage:gearbox_on" or node.name == "techage:gearbox" then
			return pos1
		end
	end
end

-- Send to the winches
local function control_cmnd(pos, topic)
	-- The clutch is not part of the axle network,
	-- so we have to use a helper function to be able 
	-- to send a command into the network.
	local pos1 = get_gearbox_pos(pos)
	if pos1 then
		control.send(pos1, Axle, 0, "sto", topic)
	end
end

local function switch_on(pos, node)
	if node.name == "techage:ta2_clutch_off" then
		control_cmnd(pos, "on")
		node.name = "techage:ta2_clutch_on"
		minetest.swap_node(pos, node)
		Axle:after_place_tube(pos)
		minetest.sound_play("techage_button", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 5})
	end
end

local function switch_off(pos, node)
	if node.name == "techage:ta2_clutch_on" then
		control_cmnd(pos, "off")
		minetest.swap_node(pos, {name = "techage:ta2_clutch_off", param2 = M(pos):get_int("outdir") - 1})
		Axle:after_dig_tube(pos, node)
		minetest.sound_play("techage_button", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 5})
	end
end

minetest.register_node("techage:ta2_clutch_off", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_appl_arrow3.png^techage_frame_ta2.png^[transformR90",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_appl_arrow3.png^techage_frame_ta2.png^[transformR270",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_clutch.png^techage_frame_ta2.png^[transformR180",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "B"))
	end,
	on_rightclick = switch_on,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta2_clutch_on", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png^[transformR90",
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png^[transformR270",
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_appl_clutch_on.png^techage_frame_ta2.png^[transformR180",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_clutch_clutch.png",
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Axle:after_dig_tube(pos, oldnode, oldmetadata)
	end,
	on_rightclick = switch_off,
	paramtype2 = "facedir",
	drop = "techage:ta2_clutch_off",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:ta2_clutch_off",
	recipe = {
		{"default:junglewood", "techage:axle", "default:wood"},
		{"techage:axle", "basic_materials:gear_steel", "techage:axle"},
		{"default:wood", "techage:axle", "default:junglewood"},
	},
})
