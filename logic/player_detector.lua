--[[

	TechAge
	=======

	Copyright (C) 2017-2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Player Detector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic
local CYCLE_TIME = 1

local function switch_on(pos)
	if logic.swap_node(pos, "techage:ta3_playerdetector_on") then
		logic.send_on(pos, M(pos))
	end
end

local function switch_off(pos)
	if logic.swap_node(pos, "techage:ta3_playerdetector_off") then
		logic.send_off(pos, M(pos))
	end
end

local function scan_for_player(pos)
	local mem = tubelib2.get_mem(pos)
	local meta = minetest.get_meta(pos)
	local names = meta:get_string("names") or ""
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 4)) do
		if object:is_player() then
			if names == "" then 
				mem.player_name = object:get_player_name()
				return true 
			end
			for _,name in ipairs(string.split(names, " ")) do
				if object:get_player_name() == name then 
					mem.player_name = name
					return true 
				end
			end
		end
	end
	mem.player_name = nil
	return false
end

local function formspec_help()
	return "size[8,6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"label[3,0;Player Detector Help]"..
		"label[0,1;Input the number(s) of the destination node(s).\n"..
		"Separate numbers via blanks, like '123 234'.\n\n"..
		"Input the player name(s) separated by blanks,\nor empty for all players.]"..
		"button_exit[3,5;2,1;exit;close]"
end


local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	local names = meta:get_string("names") or ""
	return "size[7,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"field[0.3,0.6;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"field[0.3,2;7,1;names;Insert player name(s) (optional):;"..names.."]" ..
		"button[0.9,3;2.5,1;help;help]"..
		"button_exit[3.5,3;2.5,1;exit;Save]"
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	local meta = minetest.get_meta(pos)
	if fields.exit == "Save" then
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Player Detector"))
		end
		meta:set_string("names", fields.names)
		meta:set_string("formspec", formspec(meta))
	elseif fields.help ~= nil then
		meta:set_string("formspec", formspec_help())
	elseif fields.exit == "close" then
		meta:set_string("formspec", formspec(meta))
	end
end

minetest.register_node("techage:ta3_playerdetector_off", {
	description = S("TA3 Player Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_playerdetector.png",
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta3_playerdetector_off", S("TA3 Player Detector"))
		logic.infotext(meta, S("TA3 Player Detector"))
		meta:set_string("formspec", formspec(meta))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_receive_fields = on_receive_fields,
	
	on_timer = function (pos, elapsed)
		if scan_for_player(pos) then
			switch_on(pos)
		end
		return true
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Player Detector"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
		tubelib2.del_mem(pos)
	end,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta3_playerdetector_on", {
	description = "TA3 Player Detector",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_playerdetector_on.png",
	},
	on_receive_fields = on_receive_fields,
	
	on_timer = function (pos, elapsed)
		if not scan_for_player(pos) then
			switch_off(pos)
		end
		return true
	end,
	
	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Player Detector"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
		tubelib2.del_mem(pos)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_playerdetector_off"
})

minetest.register_craft({
	output = "techage:ta3_playerdetector_off",
	recipe = {
		{"", "group:wood", "default:mese_crystal"},
		{"", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", ""},
	},
})

techage.register_node({"techage:ta3_playerdetector_off", "techage:ta3_playerdetector_on"}, {
	on_recv_message = function(pos, topic, payload)
		if topic == "name" then
			local mem = tubelib2.get_mem(pos)
			return mem.player_name or ""
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})		

