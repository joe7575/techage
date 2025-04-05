--[[

	TechAge
	=======

	Copyright (C) 2020-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Move Controller

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S

local MP = minetest.get_modpath("techage")
local mark = dofile(MP .. "/basis/mark_lib.lua")
local fly = techage.flylib

local MAX_DIST = techage.maximum_move_controller_distance
local MAX_BLOCKS = techage.maximum_move_controller_blocks

local WRENCH_MENU = {
	{
		type = "dropdown",
		choices = "0.5,1,2,4,6,8",
		name = "max_speed",
		label = S("Maximum Speed"),
		tooltip = S("Maximum speed for moving blocks"),
		default = "8",
	},
	{
		type = "float",
		name = "height",
		label = S("Move block height"),
		tooltip = S("Value in the range of 0.0 to 1.0"),
		default = "1.0",
	},
	{
		type = "float",
		name = "offset",
		label = S("Object offset"),
		tooltip = S("Y-offset for non-player objects like vehicles (-0.5 to 0.5)"),
		default = "0.0",
	},
	{
		type = "dropdown",
		choices = "A-B / B-A,move xyz",
		name = "opmode",
		label = S("Operational mode"),
		tooltip = S("Switch to the remote controlled 'move xyz' mode"),
		default = "A-B / B-A",
	},
}

local function formspec(nvm, meta)
	local status = meta:get_string("status")
	local path = minetest.formspec_escape(meta:contains("path") and meta:get_string("path") or "0,3,0")
	local buttons
	if meta:get_string("opmode") == "move xyz" then
		buttons = "field[0.4,2.3;3.8,1;path;" .. S("Move distance") .. ";" .. path .. "]" ..
			"button_exit[4.1,2.0;3.8,1;move2;" .. S("Move") .. "]" ..
			"button_exit[0.1,3.0;3.8,1;reset;" .. S("Reset") .. "]" ..
			"button_exit[4.1,3.0;3.8,1;show;" .. S("Show positions") .. "]"
	else
		buttons = "field[0.4,2.3;3.8,1;path;" .. S("Move distance (A to B)") .. ";" .. path .. "]" ..
			"button_exit[0.1,3.0;3.8,1;moveAB;" .. S("Move A-B") .. "]" ..
			"button_exit[4.1,3.0;3.8,1;moveBA;" .. S("Move B-A") .. "]" ..
			"button[4.1,2.0;3.8,1;store;" .. S("Store") .. "]" ..
			"button_exit[0.1,4.0;3.8,1;show;" .. S("Show positions") .. "]" ..
			"button_exit[4.1,4.0;3.8,1;reset;" .. S("Reset") .. "]"
	end
	return "size[8,5.5]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"box[0,-0.1;7.2,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", S("TA4 Move Controller")) .. "]" ..
		techage.wrench_image(7.4, -0.05) ..
		"button_exit[0.1,0.7;3.8,1;record;" .. S("Record") .. "]" ..
		"button[4.1,0.7;3.8,1;done;" .. S("Done") .. "]" ..
		buttons ..
		"label[0.3,5.0;" .. status .. "]"
end

minetest.register_node("techage:ta4_movecontroller", {
	description = S("TA4 Move Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_movecontroller.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		techage.logic.after_place_node(pos, placer, "techage:ta4_movecontroller", S("TA4 Move Controller"))
		techage.logic.infotext(meta, S("TA4 Move Controller"))
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec(nvm, meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)

		if fields.record then
			nvm.lpos1 = {}
			nvm.lpos2 = {}
			nvm.moveBA = false
			nvm.recording = true
			nvm.running = nil
			nvm.lastpos = nil
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all blocks that shall be moved"))
			mark.unmark_all(name)
			mark.start(name, MAX_BLOCKS)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.done and nvm.recording then
			nvm.recording = false
			local name = player:get_player_name()
			local pos_list = mark.get_poslist(name)
			if fly.to_vector(fields.path or "", MAX_DIST) then
				meta:set_string("path", fields.path)
			end
			local text = #pos_list.." "..S("block positions are stored.")
			nvm.running = nil
			nvm.lastpos = nil
			meta:set_string("status", text)
			nvm.lpos1 = pos_list
			mark.unmark_all(name)
			mark.stop(name)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.store then
			if fly.to_vector(fields.path or "", MAX_DIST) then
				meta:set_string("path", fields.path)
				meta:set_string("status", S("Stored"))
			else
				meta:set_string("status", S("Error: Invalid distance !!"))
			end
			meta:set_string("formspec", formspec(nvm, meta))
			local name = player:get_player_name()
			mark.stop(name)
			nvm.moveBA = false
			nvm.running = nil
			nvm.lastpos = nil
		elseif fields.moveAB then
			meta:set_string("status", "")
			if fly.move_to_other_pos(pos, false) then
				meta:set_string("formspec", formspec(nvm, meta))
				local name = player:get_player_name()
				mark.stop(name)
			end
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.moveBA then
			meta:set_string("status", "")
			if fly.move_to_other_pos(pos, true) then
				meta:set_string("formspec", formspec(nvm, meta))
				local name = player:get_player_name()
				mark.stop(name)
			end
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.move2 then
			if fly.to_vector(fields.path or "", MAX_DIST) then
				meta:set_string("path", fields.path)
			end
			local line = fly.to_vector(meta:get_string("path"), MAX_DIST)
			if line then
				fly.move_to(pos, line)
			end
		elseif fields.reset then
			fly.reset_move(pos)
			nvm.running = false
		elseif fields.show then
			local name = player:get_player_name()
			mark.mark_positions(name, nvm.lpos1, 300)
		end
	end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec(nvm, meta))
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		mark.unmark_all(name)
		mark.stop(name)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	ta4_formspec = WRENCH_MENU,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local INFO = [[Commands: 'state', 'a2b', 'b2a', 'move']]

techage.register_node({"techage:ta4_movecontroller"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		local move_xyz = M(pos):get_string("opmode") == "move xyz"
		if topic == "info" then
			return INFO
		elseif topic == "state" then
			return nvm.running and "running" or "stopped"
		elseif not move_xyz and topic == "a2b" then
			return fly.move_to_other_pos(pos, false)
		elseif not move_xyz and topic == "b2a" then
			return fly.move_to_other_pos(pos, true)
		elseif not move_xyz and topic == "move" then
			return fly.move_to_other_pos(pos, nvm.moveBA == false)
		elseif move_xyz and topic == "move2" then
			local line = fly.to_vector(payload, MAX_DIST)
			if line then
				return fly.move_to(pos, line)
			end
			return false
		elseif move_xyz and topic == "moveto" then
			local destpos = fly.to_vector(payload)
			if destpos then
				return fly.move_to_abs(pos, destpos, MAX_DIST)
			end
			return false
		elseif topic == "reset" then
			return fly.reset_move(pos)
		end
		return false
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		local move_xyz = M(pos):get_string("opmode") == "move xyz"
		--print("on_beduino_receive_cmnd", P2S(pos), move_xyz, topic, payload[1])
		if not move_xyz and topic == 11 then
			if payload[1] == 1 then
				return fly.move_to_other_pos(pos, false) and 0 or 3
			elseif payload[1] == 2 then
				return fly.move_to_other_pos(pos, true) and 0 or 3
			elseif payload[1] == 3 then
				return fly.move_to_other_pos(pos, nvm.moveBA == false) and 0 or 3
			end
		elseif move_xyz and topic == 18 then  -- move xyz
			local line = {
				x = techage.in_range(techage.beduino_signed_var(payload[1]), -1000, 1000),
				y = techage.in_range(techage.beduino_signed_var(payload[2]), -1000, 1000),
				z = techage.in_range(techage.beduino_signed_var(payload[3]), -1000, 1000),
			}
			return fly.move_to(pos, line) and 0 or 3
		elseif move_xyz and topic == 24 then  -- moveto xyz
			local dest = {
				x = techage.in_range(techage.beduino_signed_var(payload[1]), -32768, 32767),
				y = techage.in_range(techage.beduino_signed_var(payload[2]), -32768, 32767),
				z = techage.in_range(techage.beduino_signed_var(payload[3]), -32768, 32767),
			}
			return fly.move_to_abs(pos, dest, MAX_DIST) and 0 or 3
		elseif move_xyz and topic == 19 then  -- reset
			return fly.reset_move(pos) and 0 or 3
		else
			return 2
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 129 then
			return 0, {nvm.running and 1 or 6}
		end
		return 2, ""
	end,
	on_node_load = function(pos, node)
		M(pos):set_string("teleport_mode", "") -- delete not working (legacy) op mode
		M(pos):set_string("status", "")
		techage.get_nvm(pos).running = false
	end,
})

minetest.register_node("techage:rack_and_pinion", {
	description = S("TA Rack and Pinion"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"techage_rack_and_pinion.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -16/32, 14.1/32,  6/32,  16/32, 16/32},
		},
	},
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:moveblock", {
	description = "Techage Invisible Move Block",
	drawtype = "glasslike_framed_optional",
	inventory_image = 'techage_inv_invisible.png',
	tiles = {"blank.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -14/32, 16/32},
		},
	},
	paramtype = "light",
	light_source = 0,
	sunlight_propagates = true,
	walkable = false,
	pointable = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_glass_defaults(),
})


minetest.register_craft({
	output = "techage:ta4_movecontroller",
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"default:mese_crystal_fragment", "techage:ta4_wlanchip", "default:mese_crystal_fragment"},
		{"group:wood", "basic_materials:gear_steel", "group:wood"},
	},
})

minetest.register_craft({
	output = "techage:rack_and_pinion 10",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"basic_materials:steel_bar", "default:steel_ingot", "basic_materials:steel_bar"},
		{"", "default:steel_ingot", ""},
	},
})
