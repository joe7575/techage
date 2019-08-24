--[[

	TechAge
	=======

	Copyright (C) 2017-2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Item detector
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic
local BLOCKING_TIME = 8 -- seconds

local function switch_on(pos)
	local mem = tubelib2.get_mem(pos)
	local t = minetest.get_gametime()
	if t > (mem.time or 0) then
		logic.swap_node(pos, "techage:ta3_detector_on")
		logic.send_on(pos, M(pos), 1)
		mem.time = t + BLOCKING_TIME
	end
end

local function switch_off(pos)
	logic.swap_node(pos, "techage:ta3_detector_off")
	logic.send_off(pos, M(pos))
end

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	return "size[7.5,3]"..
		"field[0.5,1;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"button_exit[2,2;3,1;exit;"..S("Save").."]"
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

	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta3_detector_off", S("TA3 Detector"))
		logic.infotext(meta, S("TA3 Detector"))
		meta:set_string("formspec", formspec(meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = minetest.get_meta(pos)
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Detector"))
			meta:set_string("formspec", formspec(M(pos)))
		end
	end,
	
	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Detector"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
	end,
	
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

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Detector"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
	end,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_detector_off",
})

minetest.register_craft({
	output = "techage:ta3_detector_off",
	recipe = {
		{"", "group:wood", ""},
		{"techage:tubeS", "techage:vacuum_tube", "techage:tubeS"},
		{"", "group:wood", ""},
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

techage.register_entry_page("ta3l", "detector",
	S("TA3 Detector"), 
	S("The Detector is a special kind of tube block that@n"..
		"outputs an event when items pass through.@n"..
		"It sends an 'on' when an item goes through,@n"..
		"followed by an 'off' event one second later.@n"..
		"After that it blocks further events for 8 seconds."),
	"techage:ta3_detector_on")
