--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Door/Gate Controller
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	return "size[7.5,3]"..
		"field[0.5,1;7,1;numbers;"..S("Insert door/gate block number(s)")..";"..numbers.."]" ..
		"button_exit[2,2;3,1;exit;"..S("Save").."]"
end

local function store_door_data(pos)
	local nvm = techage.get_nvm(pos)
	nvm.door_state = false
	local numbers = M(pos):get_string("numbers")
	nvm.door_blocks = {}
	for _,num in ipairs(string.split(numbers, " ")) do
		local info = techage.get_node_info(num)
		if info and info.pos then
			local node = techage.get_node_lvm(info.pos)
			table.insert(nvm.door_blocks, {pos = info.pos, name = node.name, param2 = node.param2})
		end
	end
end

local function swap_door_nodes(pos, open)
	local nvm = techage.get_nvm(pos)
	if nvm.door_state ~= open then
		nvm.door_state = open
		for _,item in ipairs(nvm.door_blocks or {}) do
			if item.pos and item.name and item.param2 then
				local node = techage.get_node_lvm(item.pos)
				if open then
					if node.name == item.name then
						minetest.remove_node(item.pos)
					else
						item.name = nil
					end
				elseif node.name == "air" then
					minetest.add_node(item.pos, {name = item.name, param2 = item.param2})			
				else
					minetest.add_item(pos, item.pos, {name = item.name})
				end
			end
		end
	end
end

minetest.register_node("techage:ta3_doorcontroller", {
	description = S("TA3 Door Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_doorcontroller.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = techage.get_mem(pos)
		logic.after_place_node(pos, placer, "techage:ta3_doorcontroller", S("TA3 Door Controller"))
		logic.infotext(meta, S("TA3 Door Controller"))
		meta:set_string("formspec", formspec(meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		if techage.check_numbers(fields.numbers, player:get_player_name()) then
			swap_door_nodes(pos, false)
			meta:set_string("numbers", fields.numbers)
			logic.infotext(M(pos), S("TA3 Door Controller"))
			meta:set_string("formspec", formspec(meta))
			store_door_data(pos)
		end
	end,
	
	techage_set_numbers = function(pos, numbers, player_name)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, S("TA3 Repeater"))
		if res then
			swap_door_nodes(pos, false)
			meta:set_string("formspec", formspec(meta))
			store_door_data(pos)
		end
		return res
	end,
	
	after_dig_node = function(pos)
		swap_door_nodes(pos, false)
		techage.remove_node(pos)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.register_node({"techage:ta3_doorcontroller"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "on" then
			swap_door_nodes(pos, true)
		elseif topic == "off" then
			swap_door_nodes(pos, false)
		end
	end,
})		

minetest.register_craft({
	output = "techage:ta3_doorcontroller",
	recipe = {
		{"", "group:wood",""},
		{"techage:vacuum_tube", "", "default:mese_crystal_fragment"},
		{"", "group:wood", ""},
	},
})

