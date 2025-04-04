--[[

	TechAge
	=======

	Copyright (C) 2020-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Move Controller II (replaces the ta4_movecontroller)

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S

local MP = minetest.get_modpath("techage")
local mark = dofile(MP .. "/basis/mark_lib.lua")
local fly = techage.flylib2

local MAX_DIST = techage.maximum_move_controller_distance
local MAX_BLOCKS = 16


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
}

local function formspec1(nvm, meta)
	local status = meta:get_string("status")
	local base_pos = nvm.lNodes and nvm.lNodes[1] and nvm.lNodes[1].base_pos or vector.zero()
	base_pos = " " .. P2S(base_pos) or ""

	return "size[8,7.5]" ..
		"tabheader[0,0;tab;" .. S("Control,Inventory") .. ";1;;true]" ..
		"box[0,-0.1;7.2,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", S("TA4 Move Controller")) .. "]" ..
		techage.wrench_image(7.4, -0.05) ..
		"button[0.1,0.7;3.8,1;record;" .. S("Record") .. "]" ..
		"button[4.1,0.7;3.8,1;done;"  .. S("Done") .. "]" ..
		"button_exit[0.1,2.0;3.8,1;show;"  .. S("Show start positions") .. "]" ..
		"label[4.1,2.2;" .. S("Pos 1:") .. base_pos .. "]" ..
		"button_exit[0.1,3.3;3.8,1;move;"  .. S("Test move") .. "]" ..
		"button_exit[4.1,3.3;3.8,1;reset;" .. S("Reset") .. "]" ..
		"label[0.3,5.0;" .. status .. "]"
end

local function presets(nvm, inv, idx, x, y)
	local node = nvm.lNodes[idx]
	local slot = inv:get_stack("main", idx)
	if node then
		if slot:is_empty() then
			return "item_image[" .. x .. "," .. y .. ";1,1;" .. node.name .. "]" .. 
					"image[" .. x .. "," .. y .. ";1,1;techage_white_frame.png]"
		end
	end
	return ""
end

local function tooltips(nvm, inv, idx, x, y)
	local node = nvm.lNodes[idx]
	local slot = inv:get_stack("main", idx)
	if node then
		if slot:is_empty() then
			if node.curr_pos then
				return "tooltip[" .. x .. "," .. y .. ";1,1;" .. S("Node at pos") .. ": " .. P2S(node.curr_pos) .. ";#0C3D32;#FFFFFF]"
			else
				return "tooltip[" .. x .. "," .. y .. ";1,1;" .. S("missing") .. ";#0C3D32;#FFFFFF]"
			end
		end
	end
	return ""
end

local function formspec2(nvm, meta)

	local tbl = {}
	local inv = meta:get_inventory()
	nvm.lNodes = nvm.lNodes or {}
	for idx = 1,MAX_BLOCKS do
		local x = ((idx-1) % 8) + 0.3
		local y = math.floor((idx-1) / 8) * 2.4
		tbl[#tbl+1] = "label[" .. x .."," .. y .. ";" .. idx .. "]"
		x = ((idx-1) % 8)
		y = math.floor((idx-1) / 8) + 0.5
		tbl[#tbl+1] = presets(nvm, inv, idx, x, y)
		tbl[#tbl+1] = tooltips(nvm, inv, idx, x, y)
	end
	return "size[8,7]" ..
		"tabheader[0,0;tab;" .. S("Control,Inventory") .. ";2;;true]" ..
		table.concat(tbl, "") ..
		"list[context;main;0,0.5;8,2;]" ..
		"list[current_player;main;0,3.3;8,4;]" ..
		"listring[context;main]" ..
		"listring[current_player;main]"
end


minetest.register_node("techage:ta4_movecontroller2", {
	description = S("TA4 Move Controller II"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_movecontroller.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', MAX_BLOCKS)
		techage.logic.after_place_node(pos, placer, "techage:ta4_movecontroller2", S("TA4 Move Controller II"))
		techage.logic.infotext(meta, S("TA4 Move Controller II"))
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec1(nvm, meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)

		if fields.tab == "2" then
			meta:set_string("formspec", formspec2(nvm, meta))
			return
		elseif fields.tab == "1" then
			meta:set_string("formspec", formspec1(nvm, meta))
			return
		elseif fields.record then
			nvm.recording = true
			nvm.running = nil
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all blocks that shall be moved"))
			mark.unmark_all(name)
			mark.start(name, MAX_BLOCKS)
			meta:set_string("formspec", formspec1(nvm, meta))
		elseif fields.done and nvm.recording then
			nvm.recording = false
			local name = player:get_player_name()
			local pos_list = mark.get_poslist(name)
			local text = #pos_list.." "..S("block positions are stored.")
			nvm.running = nil
			meta:set_string("status", text)
			nvm.lNodes = fly.get_nodes(pos_list)
			mark.unmark_all(name)
			mark.stop(name)
			meta:set_string("formspec", formspec1(nvm, meta))
		elseif fields.move then
			nvm.lNodes = nvm.lNodes or {}
			local node = nvm.lNodes[1]
			if node then
				local dest_pos = {x = node.base_pos.x, y = node.base_pos.y + 5, z = node.base_pos.z}
				fly.move_nodes(pos, nvm, dest_pos, 0)
			end
		elseif fields.reset then
			fly.reset_nodes(pos, nvm, 0)
		elseif fields.show then
			local name = player:get_player_name()
			local lpos = fly.get_node_base_positions(nvm.lNodes or {})
			mark.mark_positions(name, lpos, 300)
		end
	end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec1(nvm, meta))
	end,

	allow_metadata_inventory_move = function() return 0 end,
	allow_metadata_inventory_take = function() return 0 end,
	allow_metadata_inventory_put = function() return 0 end,

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

local INFO = [[Commands: 'state', 'moveto']]

techage.register_node({"techage:ta4_movecontroller2"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		nvm.lNodes = nvm.lNodes or {}
		if topic == "info" then
			return INFO
		elseif topic == "state" then
			return nvm.running and "running" or "stopped"
		elseif topic == "moveto" then
			local destpos = fly.get_pos(payload)
			if destpos then
				if fly.valid_distance(nvm, destpos, 0, MAX_DIST) then
					return fly.move_nodes(pos, nvm, destpos, 0)
				else
					M(pos):set_string("status", S("Distance too large!"))
				end
			else
				M(pos):set_string("status", S("Command syntax error!"))
			end
			return false
		elseif topic == "getpos" then
			if nvm.lNodes[1] then
				local cpos = nvm.lNodes[1].curr_pos
				local spos = string.sub(P2S(cpos), 2, -2)
				return spos
			end
		elseif topic == "reset" then
			return fly.reset_nodes(pos, nvm, 0)
		end
		return false
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		nvm.lNodes = nvm.lNodes or {}
		if topic == 24 then  -- moveto xyz
			local destpos = {
				x = techage.in_range(techage.beduino_signed_var(payload[1]), -32768, 32767),
				y = techage.in_range(techage.beduino_signed_var(payload[2]), -32768, 32767),
				z = techage.in_range(techage.beduino_signed_var(payload[3]), -32768, 32767),
			}
			if fly.valid_distance(nvm, destpos, 0, MAX_DIST) then
				return fly.move_nodes(pos, nvm, destpos, 0) and 0 or 3
			else
				M(pos):set_string("status", S("Distance too large!"))
				return 3
			end
		elseif topic == 19 then  -- reset
			return fly.reset_nodes(pos, nvm, 0) and 0 or 3
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
		--print("techage.was_normal_shutdown()", techage.was_normal_shutdown())
	end,
})

minetest.register_craft({
	output = "techage:ta4_movecontroller2",
	recipe = {"techage:ta4_movecontroller"},
	type = "shapeless",
})
