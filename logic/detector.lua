--[[

	TechAge
	=======

	Copyright (C) 2017-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	TA3/TA4 Item detector
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local NDEF = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}) end

local logic = techage.logic
local BLOCKING_TIME = 8 -- seconds

local function switch_on(pos)
	local mem = techage.get_mem(pos)
	local t = minetest.get_gametime()
	if t > (mem.time or 0) then
		local name = techage.get_node_lvm(pos).name
		if name == "techage:ta3_detector_off" then
			logic.swap_node(pos, "techage:ta3_detector_on")
		else
			logic.swap_node(pos, "techage:ta4_detector_on")
		end
		logic.send_on(pos, M(pos), 1)
		mem.time = t + BLOCKING_TIME
	end
end

local function switch_off(pos)
	local name = techage.get_node_lvm(pos).name
	if name == "techage:ta3_detector_on" then
		logic.swap_node(pos, "techage:ta3_detector_off")
	else
		logic.swap_node(pos, "techage:ta4_detector_off")
	end
	logic.send_off(pos, M(pos))
end

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	return "size[7.5,3]"..
		"field[0.5,1;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"button_exit[2,2;3,1;exit;"..S("Save").."]"
end

local function after_place_node(pos, placer)
	local meta = M(pos)
	logic.after_place_node(pos, placer, "techage:ta3_detector_off", NDEF(pos).description)
	logic.infotext(meta, NDEF(pos).description)
	meta:set_string("formspec", formspec(meta))
end

local function on_receive_fields(pos, formname, fields, player)
	local meta = minetest.get_meta(pos)
	if techage.check_numbers(fields.numbers, player:get_player_name()) then
		meta:set_string("numbers", fields.numbers)
		logic.infotext(M(pos), NDEF(pos).description)
		meta:set_string("formspec", formspec(M(pos)))
	end
end

local function techage_set_numbers(pos, numbers, player_name)
	local meta = M(pos)
	local res = logic.set_numbers(pos, numbers, player_name, NDEF(pos).description)
	meta:set_string("formspec", formspec(meta))
	return res
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos)
	techage.del_mem(pos)
end


minetest.register_node("techage:ta3_detector_off", {
	description = S("TA3 Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_outp.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_inp.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_detector.png^[transformFX",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_detector.png",
	},

	after_place_node = after_place_node,
	on_receive_fields = on_receive_fields,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:ta3_detector_on", {
	description = S("TA3 Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_outp.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_inp.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_detector_on.png^[transformFX",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_detector_on.png",
	},

	on_timer = switch_off,
	on_rotate = screwdriver.disallow,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_detector_off",
})

minetest.register_node("techage:ta4_detector_off", {
	description = S("TA4 Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_outp.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inp.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_detector.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_detector.png",
	},

	after_place_node = after_place_node,
	on_receive_fields = on_receive_fields,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	
	on_rotate = screwdriver.disallow,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})


minetest.register_node("techage:ta4_detector_on", {
	description = S("TA4 Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_outp.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inp.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_detector_on.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_detector_on.png",
	},

	on_timer = switch_off,
	on_rotate = screwdriver.disallow,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta4_detector_off",
})

minetest.register_craft({
	output = "techage:ta3_detector_off",
	recipe = {
		{"", "group:wood", ""},
		{"techage:tubeS", "techage:vacuum_tube", "techage:tubeS"},
		{"", "group:wood", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_detector_off",
	recipe = {
		{"", "techage:ta3_detector_off", ""},
		{"", "techage:ta4_wlanchip", ""},
		{"", "", ""},
	},
})

techage.register_node({"techage:ta3_detector_off", "techage:ta3_detector_on"}, {
	on_push_item = function(pos, in_dir, stack)
		if techage.push_items(pos, in_dir, stack) then
			switch_on(pos)
			return true
		end
		return false
	end,
	is_pusher = true,  -- is a pulling/pushing node
})	

techage.register_node({"techage:ta4_detector_off", "techage:ta4_detector_on"}, {
	on_push_item = function(pos, in_dir, stack)
		if techage.push_items(pos, in_dir, stack) then
			switch_on(pos)
			local nvm = techage.get_nvm(pos)
			nvm.counter = (nvm.counter or 0) + stack:get_count()
			return true
		end
		return false
	end,
	is_pusher = true,  -- is a pulling/pushing node
	
	on_recv_message = function(pos, src, topic, payload)
		if topic == "count" then
			local nvm = techage.get_nvm(pos)
			return nvm.counter or 0
		elseif topic == "reset" then
			local nvm = techage.get_nvm(pos)
			nvm.counter = 0
			return true
		else
			return "unsupported"
		end
	end,
})	

