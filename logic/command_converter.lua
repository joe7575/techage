--[[

	TechAge
	=======

	Copyright (C) 2017-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Commannd Converter

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local DESCR = S("TA3 Command Converter")

local logic = techage.logic

local sDelay = "0,1,2,3,4,5,7,10,15,20,30,45,60"

local function switch_on(pos)
	logic.swap_node(pos, "techage:ta3_command_converter_on")
	logic.send_cmnd(pos, "command_on", "")
end

local function switch_off(pos)
	logic.swap_node(pos, "techage:ta3_command_converter_off")
	logic.send_cmnd(pos, "command_off", "")
end

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	local command_on = meta:get_string("command_on")
	local command_off = meta:get_string("command_off")
	local delay_on = techage.dropdown_index(sDelay, meta:get_string("delay_on"))
	local delay_off = techage.dropdown_index(sDelay, meta:get_string("delay_off"))

	return "formspec_version[4]size[10,6]"..
	"box[0.2,0.2;9.6,0.6;#c6e8ff]" ..
		"label[0.4,0.5;" .. minetest.colorize( "#000000", DESCR) .. "]" ..

		"field[1.0,1.5;8,0.6;numbers;" .. S("Insert destination node number(s)") .. ";" .. numbers .. "]" ..

		"label[0.6,2.7;" .. S("Receive") .. "]" ..
		"label[2.8,2.7;" .. S("Sent command") .. "]" ..
		"label[7.34,2.7;" .. S("Send delay (s)") .. "]" ..

		"box[0.5,3.1;1.2,0.6;#888]" ..
		"label[0.6,3.4;on]" ..
		"field[2.7,3.1;3.5,0.6;command_on;;" .. command_on .. "]" ..
		"dropdown[7.2,3.1;2,0.6;delay_on;" .. sDelay .. ";" .. delay_on .. ";false]" ..

		"box[0.5,4.0;1.2,0.6;#888]" ..
		"label[0.6,4.3;off]" ..
		"field[2.7,4.0;3.5,0.6;command_off;;" .. command_off .. "]" ..
		"dropdown[7.2,4.0;2,0.6;delay_off;" .. sDelay .. ";" .. delay_off .. ";false]" ..

		"button_exit[3.5,5.2;3,0.6;exit;" .. S("Save") .. "]"
end

local function techage_set_numbers(pos, numbers, player_name)
	local meta = M(pos)
	local res = logic.set_numbers(pos, numbers, player_name, DESCR)
	meta:set_string("formspec", formspec(meta))
	return true --res
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = minetest.get_meta(pos)
	if fields.exit and fields.exit ~= "" then
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), DESCR)
		end
		meta:set_string("command_on", fields.command_on)
		meta:set_string("command_off", fields.command_off)
		meta:set_int("delay_on", fields.delay_on or 0)
		meta:set_int("delay_off", fields.delay_off or 0)
		meta:set_string("formspec", formspec(meta))
	elseif fields.exit == "close" then
		meta:set_string("formspec", formspec(meta))
	end
end

minetest.register_node("techage:ta3_command_converter_off", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_command_converter.png",
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta3_command_converter_off", DESCR)
		logic.infotext(meta, DESCR)
		meta:set_string("formspec", formspec(meta))
	end,

	on_timer = function (pos, elapsed)
		switch_on(pos)
	end,

	on_receive_fields = on_receive_fields,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta3_command_converter_on", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_command_converter_on.png",
	},

	on_timer = function (pos, elapsed)
		switch_off(pos)
	end,

	on_receive_fields = on_receive_fields,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_command_converter_off"
})

minetest.register_craft({
	output = "techage:ta3_command_converter_off",
	recipe = {
		{"", "group:wood", ""},
		{"default:mese_crystal_fragment", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", ""},
	},
})

techage.register_node({
		"techage:ta3_command_converter_off", "techage:ta3_command_converter_on"
	}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "on" then
				local delay = M(pos):get_int("delay_on") or 0
				if delay > 0 then
					minetest.get_node_timer(pos):start(delay)
				else
					switch_on(pos)
				end
				return true
			elseif topic == "off" then
				local delay = M(pos):get_int("delay_off") or 0
				if delay > 0 then
					minetest.get_node_timer(pos):start(delay)
				else
					switch_off(pos)
				end
				return true
			else
				return "unsupported"
			end
		end,
	}
)