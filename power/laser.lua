--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Laser beam emitter and receiver 
	
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = techage.power
local networks = techage.networks

minetest.register_node("techage:laser_emitter", {
	description = S("TA4 Laser Beam Emitter"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser_hole.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
	},

	after_place_node = function(pos, placer)
		local tube_dir = networks.side_to_outdir(pos, "F")
		Cable:prepare_pairing(pos, tube_dir, "")
		Cable:after_place_node(pos, {tube_dir})
		
		local pos1, pos2 = techage.renew_laser(pos, true)
		if pos1 then
			local node = techage.get_node_lvm(pos2)
			if node.name == "techage:laser_receiver" then
				Cable:pairing(pos2, "laser")
				Cable:pairing(pos, "laser")
			else
				minetest.chat_send_player(placer:get_player_name(), S("Valid destination positions:") .. " " .. P2S(pos1) .. " " .. S("to") .. " " .. P2S(pos2))
			end
		else
			minetest.chat_send_player(placer:get_player_name(), S("The line of sight is blocked"))
		end
		minetest.get_node_timer(pos):start(2)
	end,

	on_timer = function(pos, elapsed)
		local pos1, pos2 = techage.renew_laser(pos)
		if pos1 then
			local node = techage.get_node_lvm(pos2)
			if node.name == "techage:laser_receiver" then
				Cable:pairing(pos2, "laser")
				Cable:pairing(pos, "laser")
			end
		end
		return true
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.del_laser(pos)
		Cable:stop_pairing(pos, oldmetadata, "")
		local tube_dir = tonumber(oldmetadata.fields.tube_dir or 0)
		Cable:after_dig_node(pos, {tube_dir})
	end,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:laser_receiver", {
	description = S("TA4 Laser Beam Receiver"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser_hole.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
	},

	after_place_node = function(pos, placer)
		local tube_dir = networks.side_to_outdir(pos, "F")
		Cable:prepare_pairing(pos, tube_dir, "")
		Cable:after_place_node(pos, {tube_dir})
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:stop_pairing(pos, oldmetadata, "")
		local tube_dir = tonumber(oldmetadata.fields.tube_dir or 0)
		Cable:after_dig_node(pos, {tube_dir})
	end,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Cable:add_secondary_node_names({"techage:laser_emitter", "techage:laser_receiver"})
Cable:set_valid_sides("techage:laser_emitter", {"F"})
Cable:set_valid_sides("techage:laser_receiver", {"F"})

