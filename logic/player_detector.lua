--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 & TA4 Player Detector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local NDEF = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}) end

local logic = techage.logic
local CYCLE_TIME = 1

local function switch_on(pos, stage)
	if logic.swap_node(pos, "techage:ta"..stage.."_playerdetector_on") then
		logic.send_on(pos, M(pos))
	end
end

local function switch_off(pos, stage)
	if logic.swap_node(pos, "techage:ta"..stage.."_playerdetector_off") then
		logic.send_off(pos, M(pos))
	end
end

local function scan_for_player(pos)
	local nvm = techage.get_nvm(pos)
	local meta = minetest.get_meta(pos)
	local names = meta:get_string("names") or ""
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 4)) do
		if object:is_player() then
			if names == "" then
				nvm.player_name = object:get_player_name()
				return true
			end
			for _,name in ipairs(string.split(names, " ")) do
				if object:get_player_name() == name then
					nvm.player_name = name
					return true
				end
			end
		end
	end
	nvm.player_name = nil
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
			logic.infotext(M(pos), NDEF(pos).description)
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
			switch_on(pos, 3)
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
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
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
			switch_off(pos, 3)
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
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_playerdetector_off"
})

minetest.register_node("techage:ta4_playerdetector_off", {
	description = S("TA4 Player Detector"),
	inventory_image = 'techage_smartline_detector_inv.png',
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_smartline_detector.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta4_playerdetector_off", S("TA4 Player Detector"))
		logic.infotext(meta, S("TA4 Player Detector"))
		meta:set_string("formspec", formspec(meta))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_receive_fields = on_receive_fields,

	on_timer = function (pos, elapsed)
		if scan_for_player(pos) then
			switch_on(pos, 4)
		end
		return true
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA4 Player Detector"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_playerdetector_on", {
	description = "TA4 Player Detector",
	inventory_image = 'techage_smartline_detector_inv.png',
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_smartline_detector_on.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},
	on_receive_fields = on_receive_fields,

	on_timer = function (pos, elapsed)
		if not scan_for_player(pos) then
			switch_off(pos, 4)
		end
		return true
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA4 Player Detector"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta4_playerdetector_off"
})

minetest.register_craft({
	output = "techage:ta3_playerdetector_off",
	recipe = {
		{"", "group:wood", "default:mese_crystal"},
		{"", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_playerdetector_off",
	recipe = {
		{"", "techage:aluminum", "dye:blue"},
		{"", "default:copper_ingot", "techage:ta4_wlanchip"},
	},
})

techage.register_node({
		"techage:ta3_playerdetector_off", "techage:ta3_playerdetector_on",
		"techage:ta4_playerdetector_off", "techage:ta4_playerdetector_on"
	}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "name" then
				local nvm = techage.get_nvm(pos)
				return nvm.player_name or ""
			elseif topic == "state" then
				local node = techage.get_node_lvm(pos)
				if node.name == "techage:ta3_playerdetector_on" or
						node.name == "techage:ta4_playerdetector_on" then
					return "on"
				else
					return "off"
				end
			else
				return "unsupported"
			end
		end,
		on_beduino_request_data = function(pos, src, topic, payload)
			if topic == 144 then  -- Player Name
				local nvm = techage.get_nvm(pos)
				return 0, nvm.player_name or ""
			elseif topic == 142 then  -- Binary State
				local node = techage.get_node_lvm(pos)
				if node.name == "techage:ta3_playerdetector_on" or
						node.name == "techage:ta4_playerdetector_on" then
					return 0, {1}
				else
					return 0, {0}
				end
			else
				return 2, ""
			end
		end,
		on_node_load = function(pos)
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end,
	}
)
