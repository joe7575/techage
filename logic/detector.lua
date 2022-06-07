--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Item detector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local NDEF = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}) end

local logic = techage.logic
local BLOCKING_TIME = 8 -- seconds
local ON_TIME = 1

local WRENCH_MENU = {
	{
		type = "dropdown",
		choices = "1,2,4,6,8,12,16",
		name = "ontime",
		label = S("On Time") .. " [s]",
		tooltip = S("The time between the 'on' and 'off' commands."),
		default = "1",
	},
	{
		type = "dropdown",
		choices = "2,4,6,8,12,16,20",
		name = "blockingtime",
		label = S("Blocking Time") .. " [s]",
		tooltip = S("The time after the 'off' command\nuntil the next 'on' command is accepted."),
		default = "8",
	},
	{
		type = "items",
		name = "config",
		label = S("Configured Items"),
		tooltip = S("Items which generate an 'on' command.\nIf empty, all passed items generate an 'on' command."),
		size = 4,
	}
}

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
		local meta = M(pos)
		local on_time = math.max(meta:get_int("ontime"), ON_TIME)
		local blocking_time = tonumber(meta:get_string("blockingtime")) or BLOCKING_TIME
		logic.send_on(pos, meta, on_time)
		mem.time = t + blocking_time + on_time
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
		techage.wrench_image(7, -0.1) ..
		"field[0.5,1;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"button_exit[2,2;3,1;exit;"..S("Save").."]"
end

local function after_place_node3(pos, placer)
	local meta = M(pos)
	local inv = meta:get_inventory()
	inv:set_size('cfg', 4)
	logic.after_place_node(pos, placer, "techage:ta3_detector_off", S("TA3 Detector"))
	logic.infotext(meta, S("TA3 Detector"))
	meta:set_string("formspec", formspec(meta))
end

local function after_place_node4(pos, placer)
	local meta = M(pos)
	local inv = meta:get_inventory()
	inv:set_size('cfg', 4)
	logic.after_place_node(pos, placer, "techage:ta4_detector_off", S("TA4 Detector"))
	logic.infotext(meta, S("TA4 Detector"))
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
	techage.remove_node(pos, oldnode, oldmetadata)
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

	after_place_node = after_place_node3,
	on_receive_fields = on_receive_fields,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	ta3_formspec = WRENCH_MENU,

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
	ta3_formspec = WRENCH_MENU,

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

	after_place_node = after_place_node4,
	on_receive_fields = on_receive_fields,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	ta3_formspec = WRENCH_MENU,

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
	ta3_formspec = WRENCH_MENU,

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
		if techage.safe_push_items(pos, in_dir, stack) then
			local inv =  minetest.get_inventory({type = "node", pos = pos})
			if not inv or inv:is_empty("cfg") or inv:contains_item("cfg", ItemStack(stack:get_name())) then
				switch_on(pos)
			end
			return true
		end
		return false
	end,
	is_pusher = true,  -- is a pulling/pushing node
})

techage.register_node({"techage:ta4_detector_off", "techage:ta4_detector_on"}, {
	on_push_item = function(pos, in_dir, stack)
		if techage.safe_push_items(pos, in_dir, stack) then
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
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 6 then  -- Detector Block Reset
			local nvm = techage.get_nvm(pos)
			nvm.counter = 0
			return 0
		else
			return 2
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 139 then
			local nvm = techage.get_nvm(pos)
			return 0, {nvm.counter or 0}
		else
			return 2, ""
		end
	end,
})
