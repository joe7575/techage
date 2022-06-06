--[[

	TechAge
	=======

	Copyright (C) 2020-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Turn Controller

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S

local MP = minetest.get_modpath("techage")
local fly  = dofile(MP .. "/basis/fly_lib.lua")
local mark = dofile(MP .. "/basis/mark_lib.lua")

local MAX_BLOCKS = 16

local function formspec(nvm, meta)
	local status = meta:get_string("status")
	local path = meta:contains("path") and meta:get_string("path") or "0,3,0"
	return "size[8,3]" ..
		"box[0,-0.1;7.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", S("TA4 Turn Controller")) .. "]" ..
		--techage.wrench_image(7.4, -0.05) ..
		"button[0.1,0.7;3.8,1;record;" .. S("Record") .. "]" ..
		"button[4.1,0.7;3.8,1;done;" .. S("Done") .. "]" ..
		"button[0.1,1.5;3.8,1;left;" .. S("Turn left") .. "]" ..
		"button[4.1,1.5;3.8,1;right;" .. S("Turn right") .. "]" ..
		"label[0.3,2.5;" .. status .. "]"
end


minetest.register_node("techage:ta4_turncontroller", {
	description = S("TA4 Turn Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_turn.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		techage.logic.after_place_node(pos, placer, "techage:ta4_turncontroller", S("TA4 Turn Controller"))
		techage.logic.infotext(meta, S("TA4 Turn Controller"))
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
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all blocks that shall be turned"))
			mark.start(name, MAX_BLOCKS)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.done then
			local name = player:get_player_name()
			local pos_list = mark.get_poslist(name)
			local text = #pos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			nvm.lpos = pos_list
			mark.unmark_all(name)
			mark.stop(name)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.left then
			meta:set_string("status", "")
			if nvm.lpos then
				local new_posses = fly.rotate_nodes(pos, nvm.lpos, "l")
				if new_posses then
					nvm.lpos = new_posses
					local name = player:get_player_name()
					mark.stop(name)
				end
			end
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.right then
			meta:set_string("status", "")
			if nvm.lpos then
				local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
				if new_posses then
					nvm.lpos = new_posses
					local name = player:get_player_name()
					mark.stop(name)
				end
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

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local INFO = [[Commands: 'left', 'right', 'uturn']]

techage.register_node({"techage:ta4_turncontroller"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "info" then
			return INFO
		elseif topic == "left" then
			local nvm = techage.get_nvm(pos)
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "l")
			if new_posses then
				nvm.lpos = new_posses
				return true
			end
			return false
		elseif topic == "right" then
			local nvm = techage.get_nvm(pos)
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
			if new_posses then
				nvm.lpos = new_posses
				return true
			end
			return false
		elseif topic == "uturn" then
			local nvm = techage.get_nvm(pos)
			local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
			if new_posses then
				nvm.lpos = new_posses
				new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
				if new_posses then
					nvm.lpos = new_posses
					return true
				end
			end
			return false
		end
		return false
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 12 then
			if payload[1] == 1 then
				local nvm = techage.get_nvm(pos)
				local new_posses = fly.rotate_nodes(pos, nvm.lpos, "l")
				if new_posses then
					nvm.lpos = new_posses
					return 0
				end
				return 3
			elseif payload[1] == 2 then
				local nvm = techage.get_nvm(pos)
				local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
				if new_posses then
					nvm.lpos = new_posses
					return 0
				end
				return 3
			elseif payload[1] == 3 then
				local nvm = techage.get_nvm(pos)
				local new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
				if new_posses then
					nvm.lpos = new_posses
					new_posses = fly.rotate_nodes(pos, nvm.lpos, "r")
					if new_posses then
						nvm.lpos = new_posses
						return 0
					end
				end
				return 3
			end
			return 2
		else
			return 2
		end
	end,
})

minetest.register_craft({
	output = "techage:ta4_turncontroller",
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"techage:aluminum", "techage:baborium_ingot", "techage:aluminum"},
		{"group:wood", "basic_materials:gear_steel", "group:wood"},
	},
})
