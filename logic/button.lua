--[[

	TechAge
	=======

	Copyright (C) 2017-2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Logic button
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic

local function switch_on(pos)
	local cycle_time = M(pos):get_int("cycle_time")
	logic.swap_node(pos, "techage:button_on")
	logic.send_on(pos, M(pos), cycle_time)
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
end

local function switch_off(pos)
	logic.swap_node(pos, "techage:button_off")
	logic.send_off(pos, M(pos))
end

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	local idx = meta:get_int("cycle_idx") or 0
	if idx == 0 then idx = 1 end
	return "size[7.5,6]"..
		"dropdown[0.2,0;3;type;switch,button 2s,button 4s,button 8s,button 16s,button 32s;"..idx.."]".. 
		"field[0.5,2;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"checkbox[1,3;public;public;false]"..
		"button_exit[2,4;3,1;exit;"..S("Save").."]"
end

minetest.register_node("techage:button_off", {
	description = S("TA3 Button/Switch"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_button_off.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:button_off", S("TA3 Button/Switch"))
		logic.infotext(meta, S("TA3 Button/Switch"))
		meta:set_string("formspec", formspec(meta))
		meta:set_string("public", "false")
		meta:set_int("cycle_time", 0)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		print(dump(fields))
		local meta = M(pos)
		if not techage.check_numbers(fields.numbers, player:get_player_name()) then
			return
		end
		
		meta:set_string("numbers", fields.numbers)
		if fields.public then
			meta:set_string("public", fields.public)
		end
		local cycle_time = nil
		if fields.type == "switch" then
			meta:set_int("cycle_idx", 1)
			cycle_time = 0
		elseif fields.type == "button 2s" then
			meta:set_int("cycle_idx", 2)
			cycle_time = 2
		elseif fields.type == "button 4s" then
			meta:set_int("cycle_idx", 3)
			cycle_time = 4
		elseif fields.type == "button 8s" then
			meta:set_int("cycle_idx", 4)
			cycle_time = 8
		elseif fields.type == "button 16s" then
			meta:set_int("cycle_idx", 5)
			cycle_time = 16
		elseif fields.type == "button 32s" then
			meta:set_int("cycle_idx", 6)
			cycle_time = 32
		end
		if cycle_time ~= nil then
			meta:set_int("cycle_time", cycle_time)
		end
		logic.infotext(meta, S("TA3 Button/Switch"))
		if fields.exit then
			meta:set_string("formspec", nil)
		else
			meta:set_string("formspec", formspec(meta))
		end
	end,
	
	on_rightclick = function(pos, node, clicker)
		local meta = M(pos)
		local numbers = meta:get_string("numbers")
		if numbers ~= "" and numbers ~= nil then
			if meta:get_string("public") == "true" or 
					clicker:get_player_name() == meta:get_string("owner") then
				switch_on(pos)
			end
		end
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Button/Switch"))
		meta:set_string("formspec", formspec(meta))
		return res
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
	end,
	
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("techage:button_on", {
	description = ("TA3 Button/Switch"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_button_on.png",
	},

	on_rightclick = function(pos, node, clicker)
		local meta = M(pos)
		local numbers = meta:get_string("numbers")
		if numbers ~= "" and numbers ~= nil then
			if meta:get_string("public") == "true" or 
					clicker:get_player_name() == meta:get_string("owner") then
				switch_off(pos)
			end
		end
	end,

	on_timer = switch_off,
	on_rotate = screwdriver.disallow,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Button/Switch"))
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
	drop = "techage:button_off",
})

minetest.register_craft({
	output = "techage:button_off",
	recipe = {
		{"", "group:wood", ""},
		{"default:glass", "techage:vacuum_tube", ""},
		{"", "group:wood", ""},
	},
})

techage.register_entry_page("ta3l", "button",
	S("TA3 Button/Switch"), 
	S("The Button/Switch is used to send on/off commands to machines/nodes.@n"..
		"It can be configured as switch or as button with configurable cycle time from 2 to 32s)"),
	"techage:button_on")
