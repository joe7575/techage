--[[

	TechAge
	=======

	Copyright (C) 2017-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Signal Repeater

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic
local OVER_LOAD_MAX = 10
local CYCLE_TIME = 2

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	return "size[7.5,3]"..
		"field[0.5,1;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"button_exit[2,2;3,1;exit;"..S("Save").."]"
end

minetest.register_node("techage:ta3_repeater", {
	description = S("TA3 Repeater"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_repeater.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = techage.get_mem(pos)
		logic.after_place_node(pos, placer, "techage:ta3_repeater", S("TA3 Repeater"))
		logic.infotext(meta, S("TA3 Repeater"))
		meta:set_string("formspec", formspec(meta))
		mem.overload_cnt = 0
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Repeater"))
			meta:set_string("formspec", formspec(meta))
		end
	end,

	on_timer = function(pos,elapsed)
		local mem = techage.get_mem(pos)
		mem.overload_cnt = 0
		return true
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Repeater"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "techage:ta3_repeater",
	recipe = {
		{"", "group:wood", ""},
		{"techage:vacuum_tube", "", "techage:vacuum_tube"},
		{"", "group:wood", ""},
	},
})

techage.register_node({"techage:ta3_repeater"}, {
	on_recv_message = function(pos, src, topic, payload)
		local mem = techage.get_mem(pos)
		mem.overload_cnt = (mem.overload_cnt or 0) + 1
		if mem.overload_cnt > OVER_LOAD_MAX then
			logic.infotext(M(pos), S("TA3 Repeater"), "fault (overloaded)")
			minetest.get_node_timer(pos):stop()
			return false
		else
			local numbers = M(pos):get_string("numbers") or ""
			techage.counting_start(M(pos):get_string("owner"))
			techage.send_multi(src, numbers, topic, payload)
			techage.counting_stop()
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})
