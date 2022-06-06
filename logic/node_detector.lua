--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Node Detector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic
local CYCLE_TIME = 4

local function switch_on(pos)
	if logic.swap_node(pos, "techage:ta3_nodedetector_on") then
		logic.send_on(pos, M(pos))
	end
end

local function switch_off(pos)
	if logic.swap_node(pos, "techage:ta3_nodedetector_off") then
		logic.send_off(pos, M(pos))
	end
end

local DropdownValues = {
	[S("added")] = 1,
	[S("removed")] = 2,
	[S("added or removed")] = 3,
}

local function formspec(meta, nvm)
	local numbers = meta:get_string("numbers") or ""
	local label = S("added")..","..S("removed")..","..S("added or removed")
	return "size[7.5,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"field[0.5,0.6;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"label[0.2,1.6;"..S("Send signal if nodes have been:").."]"..
		"dropdown[0.2,2.1;7.3,1;mode;"..label..";"..(nvm.mode or 3).."]"..
		"button_exit[2,3.2;3,1;accept;"..S("accept").."]"
end

local function any_node_changed(pos)
	local nvm = techage.get_nvm(pos)
	if not nvm.pos1 or not nvm.pos2 or not nvm.num then
		local node = minetest.get_node(pos)
		local param2 = (node.param2 + 2) % 4
		nvm.pos1 = logic.dest_pos(pos, param2, {0})
		nvm.pos2 = logic.dest_pos(pos, param2, {0,0,0})
		nvm.num = #minetest.find_nodes_in_area(nvm.pos1, nvm.pos2, {"air"})
		return false
	end
	local num1 = #minetest.find_nodes_in_area(nvm.pos1, nvm.pos2, {"air"})
	local num2 = #minetest.find_nodes_in_area(nvm.pos1, nvm.pos2, {"ignore"})

	if num2 == 0 and nvm.num ~= num1 then
		if nvm.mode == 1 and num1 < nvm.num then
			nvm.num = num1
			return true
		elseif nvm.mode == 2 and num1 > nvm.num then
			nvm.num = num1
			return true
		elseif nvm.mode == 3 then
			nvm.num = num1
			return true
		end
		nvm.num = num1
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local nvm = techage.get_nvm(pos)
	local meta = M(pos)
	if fields.accept then
		nvm.mode = DropdownValues[fields.mode] or 3
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Node Detector"))
		end
	end
	meta:set_string("formspec", formspec(meta, nvm))
end

local function node_timer(pos)
	if any_node_changed(pos)then
		switch_on(pos)
	else
		switch_off(pos)
	end
	return true
end

minetest.register_node("techage:ta3_nodedetector_off", {
	description = S("TA3 Node Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png^[transformR270",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_nodedetector.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		logic.after_place_node(pos, placer, "techage:ta3_repeater", S("TA3 Node Detector"))
		logic.infotext(meta, S("TA3 Node Detector"))
		nvm.mode = 3 -- default mode
		meta:set_string("formspec", formspec(meta, nvm))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		any_node_changed(pos)
	end,

	on_timer = node_timer,
	on_receive_fields = on_receive_fields,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Node Detector"))
		meta:set_string("formspec", formspec(meta, techage.get_nvm(pos)))
		return res
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy=2, cracky=2, crumbly=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta3_nodedetector_on", {
	description = S("TA3 Node Detector"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png^[transformR270",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_nodedetector_on.png",
	},

	on_timer = node_timer,

	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Node Detector"))
		meta:set_string("formspec", formspec(meta, techage.get_nvm(pos)))
		return res
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "techage:ta3_nodedetector_off",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:ta3_nodedetector_off",
	recipe = {
		{"", "group:wood", ""},
		{"", "default:copper_ingot", "techage:vacuum_tube"},
		{"", "group:wood", "default:mese_crystal"},
	},
})

techage.register_node({"techage:ta3_nodedetector_off", "techage:ta3_nodedetector_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local node = techage.get_node_lvm(pos)
			if node.name == "techage:ta3_nodedetector_off" then
				return "off"
			else
				return "on"
			end
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 142 then
			local node = techage.get_node_lvm(pos)
			if node.name == "techage:ta3_nodedetector_off" then
				return 0, {0}
			else
				return 0, {1}
			end
		else
			return 2, ""
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})
