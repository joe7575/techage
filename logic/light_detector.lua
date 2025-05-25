--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Light Detector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end

local logic = techage.logic
local CYCLE_TIME = 2

local function switch_off(pos)
	local node = minetest.get_node(pos)
	if node.name == "techage:ta3_lightdetector_on" then
		logic.swap_node(pos, "techage:ta3_lightdetector_off")
		logic.send_off(pos, M(pos))
	end
end

local function switch_on(pos)
	logic.swap_node(pos, "techage:ta3_lightdetector_on")
	if logic.send_on(pos, M(pos)) then
		minetest.after(1, switch_off, pos)
	end
end

local function node_timer(pos)

	local nvm = techage.get_nvm(pos)

	local trigger = nvm.mode or 7

	local pos_above = {x = pos.x, y = pos.y + 1, z = pos.z}
	if minetest.get_node_light(pos_above, nil) == nil then
		switch_off(pos)
		return true
	end

	if minetest.get_node_light(pos_above, nil) > trigger then
		switch_on(pos)
	else
		switch_off(pos)
	end
	return true
end

local function formspec(meta, nvm)
	local numbers = meta:get_string("numbers") or ""
	local dropdown_label = "1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15" -- Has to be a cleaner way of doing this, but it's just easier this way
	return "size[7.5,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"field[0.5,1;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"label[0.2,1.6;"..S("Send signal if light level is above:").."]"..
		"dropdown[0.2,2.1;7.3,1;mode;"..dropdown_label.."; "..(nvm.mode or 7).."]"..
		"button_exit[2,3.2;3,1;accept;"..S("accept").."]"
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = minetest.get_meta(pos)
	local nvm = techage.get_nvm(pos)

	if fields.accept then
		nvm.mode = tonumber(fields.mode) or 7
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Light Detector"))
		end
		meta:set_string("formspec", formspec(meta, nvm))
	end
end

local function techage_set_numbers(pos, numbers, player_name)
	local meta = M(pos)
	local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Light Detector"))
	meta:set_string("formspec", formspec(meta))
	return res
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos, oldnode, oldmetadata)
end

minetest.register_node("techage:ta3_lightdetector_off", {
	description = S("TA3 Light Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_lightdetector.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png^[transformR90",
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		logic.after_place_node(pos, placer, "techage:ta3_lightdetector_off", S("TA3 Light Detector"))
		logic.infotext(meta, S("TA3 Light Detector"))
		meta:set_string("formspec", formspec(meta, nvm))
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

minetest.register_node("techage:ta3_lightdetector_on", {
	description = "TA3 Light Detector (On)",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_lightdetector_on.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png^[transformR90",
	},
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_lightdetector_off"
})

minetest.register_craft({
	output = "techage:ta3_lightdetector_off",
	recipe = {
		{"", "group:wood", "default:glass"},
		{"", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", "default:mese_crystal"},
	},
})

techage.register_node({"techage:ta3_lightdetector_off", "techage:ta3_lightdetector_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local node = techage.get_node_lvm(pos)
			if node.name == "techage:ta3_lightdetector_on" then
				return "on"
			else
				return "off"
			end
		elseif topic == "light_level" then -- Allow finding the specific light level
			local pos_above = {x = pos.x, y = pos.y + 1, z = pos.z}
			return minetest.get_node_light(pos_above, nil)
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 142 then  -- Binary State
			local node = techage.get_node_lvm(pos)
			if node.name == "techage:ta3_lightdetector_on" then
				return 0, {1}
			else
				return 0, {0}
			end
		elseif topic == 143 then -- Allow finding the specific light level
			local pos_above = {x = pos.x, y = pos.y + 1, z = pos.z}
			return 0, {minetest.get_node_light(pos_above, nil)}
		else
			return 2, ""
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})
