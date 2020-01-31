--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Cart Detector/Starter

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic
local CYCLE_TIME = 2

local function switch_on(pos)
	if logic.swap_node(pos, "techage:ta3_cartdetector_on") then
		logic.send_on(pos, M(pos))
	end
end

local function switch_off(pos)
	if logic.swap_node(pos, "techage:ta3_cartdetector_off") then
		logic.send_off(pos, M(pos))
	end
end

local function check_cart(pos)	
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		if object:get_entity_name() == "minecart:cart" then
			return true
		end
	end
	return false
end

local function punch_cart(pos)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		if object:get_entity_name() == "minecart:cart" then
			object:punch(object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = 1},
			}, minetest.facedir_to_dir(0))
			break -- start only one cart
		end
	end
end	

local function node_timer(pos)
	if check_cart(pos)then
		switch_on(pos)
	else
		switch_off(pos)
	end
	return true
end

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	return "size[7.5,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"field[0.5,1;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"button_exit[2,2.2;3,1;accept;"..S("accept").."]"
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	local meta = minetest.get_meta(pos)
	if fields.accept then
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Cart Detector"))
		end
		meta:set_string("formspec", formspec(meta))
	end
end

local function techage_set_numbers(pos, numbers, player_name)
	local meta = M(pos)
	local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Cart Detector"))
	meta:set_string("formspec", formspec(meta))
	return res
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos)
end

minetest.register_node("techage:ta3_cartdetector_off", {
	description = S("TA3 Cart Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_cartdetector.png",
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta3_cartdetector_off", S("TA3 Player Detector"))
		logic.infotext(meta, S("TA3 Cart Detector"))
		meta:set_string("formspec", formspec(meta))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta3_cartdetector_on", {
	description = "TA3 Cart Detector",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_cartdetector_on.png",
	},
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_cartdetector_off"
})

minetest.register_craft({
	output = "techage:ta3_cartdetector_off",
	recipe = {
		{"", "group:wood", "default:mese_crystal"},
		{"", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", "basic_materials:motor"},
	},
})

techage.register_node({"techage:ta3_cartdetector_off", "techage:ta3_cartdetector_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "on" then
			punch_cart(pos)
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})		

