--[[

	TechAge
	=======

	Copyright (C) 2017-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Flip-flop

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local DESCR = S("TA3 Flip-Flop")

local logic = techage.logic

local function switch_on(pos)
	logic.swap_node(pos, "techage:ta3_flipflop_on")
	logic.send_on(pos, M(pos))
end

local function switch_off(pos)
	logic.swap_node(pos, "techage:ta3_flipflop_off")
	logic.send_off(pos, M(pos))
end

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""

	return "formspec_version[4]size[10,3.5]"..
	"box[0.2,0.2;9.6,0.6;#c6e8ff]" ..
		"label[0.4,0.5;" .. minetest.colorize( "#000000", DESCR) .. "]" ..

		"field[1.0,1.5;8,0.6;numbers;" .. S("Insert destination node number(s)") .. ";" .. numbers .. "]" ..

		"button_exit[3.5,2.7;3,0.6;exit;" .. S("Save") .. "]"
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
		meta:set_string("formspec", formspec(meta))
	elseif fields.exit == "close" then
		meta:set_string("formspec", formspec(meta))
	end
end

minetest.register_node("techage:ta3_flipflop_off", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_flipflop.png",
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta3_flipflop_off", DESCR)
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

minetest.register_node("techage:ta3_flipflop_on", {
	description = DESCR,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_flipflop_on.png",
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
	drop = "techage:ta3_flipflop_off"
})

minetest.register_craft({
	output = "techage:ta3_flipflop_off",
	recipe = {
		{"", "group:wood", ""},
		{"default:mese_crystal_fragment", "default:steel_ingot", "techage:vacuum_tube"},
		{"", "group:wood", ""},
	},
})

techage.register_node({
		"techage:ta3_flipflop_off", "techage:ta3_flipflop_on"
	}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "on" then
				minetest.get_node_timer(pos):start(0.1)
				return true
			elseif topic == "off" then
				return true
			else
				return "unsupported"
			end
		end,
	}
)
