--[[

	TechAge
	=======

	Copyright (C) 2017-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Mesecons converter

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

local function send_message(pos, topic)
	local meta = M(pos)
	local mem = techage.get_mem(pos)
	mem.overload_cnt = (mem.overload_cnt or 0) + 1
	if mem.overload_cnt > OVER_LOAD_MAX then
		logic.infotext(M(pos), S("TA3 Mesecons Converter"), "fault (overloaded)")
		minetest.get_node_timer(pos):stop()
		return false
	end
	local own_num = meta:get_string("node_number")
	local numbers = meta:get_string("numbers")
	techage.send_multi(own_num, numbers, topic)
end

minetest.register_node("techage:ta3_mesecons_converter", {
	description = S("TA3 Mesecons Converter"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_mesecons_converter.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = techage.get_mem(pos)
		logic.after_place_node(pos, placer, "techage:ta3_mesecons_converter", S("TA3 Mesecons Converter"))
		logic.infotext(meta, S("TA3 Mesecons Converter"))
		meta:set_string("formspec", formspec(meta))
		mem.overload_cnt = 0
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		mesecon.on_placenode(pos, minetest.get_node(pos))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Mesecons Converter"))
			meta:set_string("formspec", formspec(meta))
		end
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_timer = function(pos,elapsed)
		local mem = techage.get_mem(pos)
		mem.overload_cnt = 0
		return true
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Mesecons Converter"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,

	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = mesecon.rules.default,
		},
		effector = {
			rules = mesecon.rules.default,
			action_on = function(pos, node)
				send_message(pos, "on")
			end,
			action_off = function(pos, node)
				send_message(pos, "off")
			end,
			action_change = function(pos, node)
				send_message(pos, "change")
			end,
		}
	},

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
		mesecon.on_dignode(pos, oldnode)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "techage:ta3_mesecons_converter",
	recipe = {
		{"techage:ta3_repeater", "mesecons:wire_00000000_off"},
	},
})

techage.register_node({"techage:ta3_mesecons_converter"}, {
	on_recv_message = function(pos, src, topic, payload)
		local mem = techage.get_mem(pos)
		mem.overload_cnt = (mem.overload_cnt or 0) + 1
		if mem.overload_cnt > OVER_LOAD_MAX then
			logic.infotext(M(pos), S("TA3 Mesecons Converter"), "fault (overloaded)")
			minetest.get_node_timer(pos):stop()
			return false
		elseif topic == "on" then
			mesecon.receptor_on(pos, mesecon.rules.default)
		elseif topic == "off" then
			mesecon.receptor_off(pos, mesecon.rules.default)
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})
