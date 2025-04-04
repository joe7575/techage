--[[

	TechAge
	=======

	Copyright (C) 2020-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fly Controller

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S

local MP = minetest.get_modpath("techage")
local mark = dofile(MP .. "/basis/mark_lib.lua")
local fly = techage.flylib

local MAX_DIST = 1500
local MAX_BLOCKS = 32
local EX_POINTS = 40

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
		choices = "disable,enable",
		name = "teleport_mode",
		label = S("Teleport mode"),
		tooltip = S("Move a player without moving blocks"),
		default = "disable",
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
	local path = minetest.formspec_escape(meta:contains("fs_path") and meta:get_string("fs_path") or
		meta:contains("path") and meta:get_string("path") or "0,3,0")
	return "size[8,6.7]" ..
		"style_type[textarea;font=mono;textcolor=#FFFFFF;border=true]" ..
		"box[0,-0.1;7.2,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", S("TA5 Fly Controller")) .. "]" ..
		techage.wrench_image(7.4, -0.05) ..
		"button[0.1,0.7;3.8,1;record;" .. S("Record") .. "]" ..
		"button[4.1,0.7;3.8,1;done;" .. S("Done") .. "]" ..
		"textarea[0.4,2.1;3.8,4.4;path;" .. S("Flight route (A to B)") .. ";"..path.."]" ..
		"button[4.1,1.8;3.8,1;store;" .. S("Store") .. "]" ..
		"button[4.1,2.6;3.8,1;test;" .. S("Test") .. "]" ..
		"button[4.1,3.4;3.8,1;moveAB;" .. S("Move A-B") .. "]" ..
		"button[4.1,4.2;3.8,1;moveBA;" .. S("Move B-A") .. "]" ..
		"button[4.1,5.0;3.8,1;move;" .. S("Move") .. "]" ..
		"label[0.3,6.3;" .. status .. "]"
end

minetest.register_node("techage:ta5_flycontroller", {
	description = S("TA5 Fly Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_movecontroller.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		techage.logic.after_place_node(pos, placer, "techage:ta5_flycontroller", S("TA5 Fly Controller"))
		techage.logic.infotext(meta, S("TA5 Fly Controller"))
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec(nvm, meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		if techage.get_expoints(player) < EX_POINTS then
			return
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)

		if fields.record then
			nvm.lpos1 = {}
			nvm.lpos2 = {}
			nvm.moveBA = false
			nvm.running = nil
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all blocks that shall be moved"))
			mark.start(name, MAX_BLOCKS)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.done then
			local name = player:get_player_name()
			local pos_list = mark.get_poslist(name)
			local _, err = fly.to_path(fields.path, MAX_DIST)
			if not err then
				meta:set_string("fs_path", fields.path)
				meta:set_string("path", fields.path)
			end
			nvm.running = nil
			local text = #pos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			nvm.lpos1 = pos_list
			mark.unmark_all(name)
			mark.stop(name)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.store then
			local _, err = fly.to_path(fields.path, MAX_DIST)
			if not err then
				meta:set_string("path", fields.path)
				meta:set_string("fs_path", fields.path)
				meta:set_string("status", S("Stored"))
			else
				meta:set_string("path", "0,0,0")
				meta:set_string("fs_path", fields.path)
				meta:set_string("status", err)
			end
			meta:set_string("formspec", formspec(nvm, meta))
			local name = player:get_player_name()
			mark.stop(name)
			nvm.moveBA = false
			nvm.running = nil
		elseif fields.test then
			local path, err = fly.to_path(fields.path, MAX_DIST)
			if err then
				meta:set_string("status", err)
			elseif path and nvm.lpos1 and nvm.lpos1[1] then
				local pos = table.copy(nvm.lpos1[1])
				if pos then
					for _, offs in ipairs(path) do
						local pos2 = vector.add(pos, offs)
						local s = string.format("[TA4 Fly Controller] %s + %s = %s", P2S(pos), P2S(offs), P2S(pos2))
						minetest.chat_send_player(player:get_player_name(), s)
						pos = pos2
					end
					meta:set_string("status", S("See chat output"))
				else
					minetest.chat_send_player(player:get_player_name(), S("[TA4 Fly Controller] Recording is missing!"))
					meta:set_string("status", S("Error: Recording is missing !!"))
				end
			else
				if nvm.lpos1 then
					minetest.chat_send_player(player:get_player_name(), S("[TA4 Fly Controller] Invalid path!"))
					meta:set_string("status", S("Error: Invalid path !!"))
				else
					minetest.chat_send_player(player:get_player_name(), S("[TA4 Fly Controller] Recording is missing!"))
					meta:set_string("status", S("Error: Recording is missing !!"))
				end
			end
			meta:set_string("formspec", formspec(nvm, meta))
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
		elseif fields.move then
			meta:set_string("status", "")
			if fly.move_to_other_pos(pos, nvm.moveBA) then
				meta:set_string("formspec", formspec(nvm, meta))
				local name = player:get_player_name()
				mark.stop(name)
			end
			meta:set_string("formspec", formspec(nvm, meta))
		end
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		mark.unmark_all(name)
		mark.stop(name)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	ta5_formspec = {menu=WRENCH_MENU, ex_points=EX_POINTS},
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local INFO = [[Commands: 'state', 'a2b', 'b2a', 'move', 'move2']]

techage.register_node({"techage:ta5_flycontroller"}, {
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
			return fly.move_to_other_pos(pos, nvm.moveBA)
		elseif move_xyz and topic == "move2" then
			local line = fly.to_vector(payload, MAX_DIST)
			if line then
				return fly.move_to(pos, line)
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
		if not move_xyz and topic == 11 then
			if payload[1] == 1 then
				return fly.move_to_other_pos(pos, false) and 0 or 3
			elseif payload[1] == 2 then
				return fly.move_to_other_pos(pos, true) and 0 or 3
			elseif payload[1] == 3 then
				return fly.move_to_other_pos(pos, nvm.moveBA) and 0 or 3
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
		M(pos):set_string("status", "")
		techage.get_nvm(pos).running = false
	end,
})

minetest.register_craft({
	output = "techage:ta5_flycontroller",
	recipe = {
		{"default:steel_ingot", "dye:red", "default:steel_ingot"},
		{"techage:aluminum", "techage:ta5_aichip", "techage:aluminum"},
		{"group:wood", "basic_materials:gear_steel", "group:wood"},
	},
})
