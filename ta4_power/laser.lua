--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

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
local power = networks.power

minetest.register_node("techage:ta4_laser_emitter", {
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
		local number = techage.add_node(pos, "techage:ta4_laser_emitter")
		M(pos):set_string("node_number", number)
		local res, pos1, pos2 = techage.renew_laser(pos, true)
		if pos1 then
			local node = techage.get_node_lvm(pos2)
			if node.name == "techage:ta4_laser_receiver" then
				Cable:pairing(pos2, "laser")
				Cable:pairing(pos, "laser")
			else
				minetest.chat_send_player(placer:get_player_name(),
					S("Valid destination positions:") .. " " ..
					P2S(pos1) .. " " .. S("to") .. " " .. P2S(pos2))
			end
		else
			minetest.chat_send_player(placer:get_player_name(), S("Laser beam error!"))
		end
		minetest.get_node_timer(pos):start(2)
	end,

	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		local res, pos1, pos2 = techage.renew_laser(pos)
		if pos1 then
			local node = techage.get_node_lvm(pos2)
			if node.name == "techage:ta4_laser_receiver" then
				Cable:pairing(pos2, "laser")
				Cable:pairing(pos, "laser")
				nvm.running = true
			else
				local metadata = M(pos):to_table()
				Cable:stop_pairing(pos, metadata, "")
				local tube_dir = tonumber(metadata.fields.tube_dir or 0)
				Cable:after_dig_node(pos, {tube_dir})
				nvm.running = false
			end
		elseif not res then
			techage.del_laser(pos)
			local metadata = M(pos):to_table()
			Cable:stop_pairing(pos, metadata, "")
			local tube_dir = tonumber(metadata.fields.tube_dir or 0)
			Cable:after_dig_node(pos, {tube_dir})
			nvm.running = false
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

minetest.register_node("techage:ta4_laser_receiver", {
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

techage.register_node({"techage:ta4_laser_emitter"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local nvm = techage.get_nvm(pos)
			return nvm.running and "running" or "stopped"
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 142 then  -- Binary State
			local nvm = techage.get_nvm(pos)
			return 0, {nvm.running and 1 or 0}
		else
			return 2, ""
		end
	end,
})

power.register_nodes({"techage:ta4_laser_emitter", "techage:ta4_laser_receiver"}, Cable, "special", {"F"})

minetest.register_craft({
	output = "techage:ta4_laser_emitter",
	recipe = {
		{"techage:ta4_carbon_fiber", "dye:blue", "techage:ta4_carbon_fiber"},
		{"techage:electric_cableS", "basic_materials:energy_crystal_simple", "techage:ta4_leds"},
		{"default:steel_ingot", "techage:ta4_wlanchip", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "techage:ta4_laser_receiver",
	recipe = {
		{"techage:ta4_carbon_fiber", "dye:blue", "techage:ta4_carbon_fiber"},
		{"techage:electric_cableS", "basic_materials:gold_wire", "default:obsidian_glass"},
		{"default:steel_ingot", "techage:ta4_wlanchip", "default:steel_ingot"},
	},
})
