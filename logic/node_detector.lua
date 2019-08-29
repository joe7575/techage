--[[

	TechAge
	=======

	Copyright (C) 2017-2019 Joachim Stolberg

	GPL v3
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

local function formspec(meta, mem)
	local numbers = meta:get_string("numbers") or ""
	local label = S("added")..","..S("removed")..","..S("added or removed")
	return "size[7.5,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"field[0.5,0.6;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"label[0.2,1.6;"..S("Send signal if nodes have been:").."]"..
		"dropdown[0.2,2.1;7.3,1;mode;"..label..";"..(mem.mode or 3).."]"..
		"button_exit[2,3.2;3,1;accept;"..S("accept").."]"
end

local function any_node_changed(pos)
	local mem = tubelib2.get_mem(pos)
	if not mem.pos1 or not mem.pos2 or not mem.num then
		local node = minetest.get_node(pos)
		local param2 = (node.param2 + 2) % 4
		mem.pos1 = logic.dest_pos(pos, param2, {0})
		mem.pos2 = logic.dest_pos(pos, param2, {0,0,0})
		mem.num = #minetest.find_nodes_in_area(mem.pos1, mem.pos2, {"air"})
		return false
	end
	local num = #minetest.find_nodes_in_area(mem.pos1, mem.pos2, {"air"})
	
	if mem.num ~= num then
		if mem.mode == 1 and num < mem.num then 
			mem.num = num
			return true
		elseif mem.mode == 2 and num > mem.num then 
			mem.num = num
			return true
		elseif mem.mode == 3 then
			mem.num = num
			return true
		end
		mem.num = num
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	local mem = tubelib2.get_mem(pos)
	local meta = M(pos)
	if fields.accept then
		mem.mode = DropdownValues[fields.mode] or 3
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Node Detector"))
		end
	end
	meta:set_string("formspec", formspec(meta, mem))
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
		local mem = tubelib2.init_mem(pos)
		logic.after_place_node(pos, placer, "techage:ta3_repeater", S("TA3 Node Detector"))
		logic.infotext(meta, S("TA3 Node Detector"))
		mem.mode = 3 -- default mode
		meta:set_string("formspec", formspec(meta, mem))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		any_node_changed(pos)
	end,
	
	on_timer = node_timer,
	on_receive_fields = on_receive_fields,
	
	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Node Detector"))
		meta:set_string("formspec", formspec(meta, tubelib2.get_mem(pos)))
		return res
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
		tubelib2.del_mem(pos)
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
		meta:set_string("formspec", formspec(meta, tubelib2.get_mem(pos)))
		return res
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
		tubelib2.del_mem(pos)
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
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})		

techage.register_entry_page("ta3l", "node_detector",
	S("TA3 Node Detector"), 
	S("The Node Detector can send a 'on' signal when it detects that nodes appear@n"..
		"or disappear, but has to be configured accordingly.@n"..
		"Valid nodes are all kind of blocks and plants.@n"..
		"The sensor range is 3 nodes/meters in the arrow direction."),
	"techage:ta3_nodedetector_on")
