--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Cart Detector/Starter

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end

local logic = techage.logic
local CYCLE_TIME = 2

local function switch_off(pos)
	local node = minetest.get_node(pos)
	if node.name == "techage:ta3_cartdetector_on" then
		logic.swap_node(pos, "techage:ta3_cartdetector_off")
		logic.send_off(pos, M(pos))
	end
end

local function switch_on(pos)
	logic.swap_node(pos, "techage:ta3_cartdetector_on")
	if logic.send_on(pos, M(pos)) then
		minetest.after(1, switch_off, pos)
	end
end

local function node_timer(pos)
	if minecart.is_cart_available(pos, nil, 1.5) then
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
	techage.remove_node(pos, oldnode, oldmetadata)
end

minetest.register_node("techage:ta3_cartdetector_off", {
	description = S("TA3 Cart Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png^[transformR90",
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
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png^[transformR90",
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
			local node = minetest.get_node(pos)
			local dir = minetest.facedir_to_dir(node.param2)
			minecart.punch_cart(pos, nil, 1.6, dir)
		elseif topic == "state" then
			local node = techage.get_node_lvm(pos)
			if node.name == "techage:ta3_cartdetector_on" then
				return "on"
			else
				return "off"
			end
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 1 then
			local node = minetest.get_node(pos)
			local dir = minetest.facedir_to_dir(node.param2)
			minecart.punch_cart(pos, nil, 1.6, dir)
			return 0
		else
			return 2
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 142 then  -- Binary State
			local node = techage.get_node_lvm(pos)
			if node.name == "techage:ta3_cartdetector_on" then
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
})

-- Register default cart in addition
minecart.tEntityNames["carts:cart"] = true
