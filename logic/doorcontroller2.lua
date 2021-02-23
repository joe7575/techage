--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Door/Gate Controller II
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S = techage.S

local logic = techage.logic

local MarkedNodes = {} -- t[player][hash] = entity 
local CurrentPos  -- to mark punched entities

local function unmark_position(name, pos)
	MarkedNodes[name] = MarkedNodes[name] or {}
	pos = vector.round(pos)
	local hash = minetest.hash_node_position(pos)
	if MarkedNodes[name][hash] then
		MarkedNodes[name][hash]:remove()
		MarkedNodes[name][hash] = nil
		CurrentPos = hash
	end
end

local function unmark_all(name)
	for _,entity in pairs(MarkedNodes[name] or {}) do
		entity:remove()
	end
	MarkedNodes[name] = nil
end

local function mark_position(name, pos)
	MarkedNodes[name] = MarkedNodes[name] or {}
	pos = vector.round(pos)
	local hash = minetest.hash_node_position(pos)
	if hash ~= CurrentPos then -- entity not punched?
		local entity = minetest.add_entity(pos, "techage:marker")
		if entity ~= nil then
			entity:get_luaentity().player_name = name
			MarkedNodes[name][hash] = entity
		end
		CurrentPos = nil
		return true
	end
	CurrentPos = nil
end

local function table_to_poslist(name)
	local lst = {}
	for hash,_ in pairs(MarkedNodes[name] or {}) do
		local pos = minetest.get_position_from_hash(hash)
		table.insert(lst, pos)
	end
	return lst
end

minetest.register_entity(":techage:marker", {
	initial_properties = {
		visual = "cube",
		textures = {
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
		},
		--use_texture_alpha = true,
		physical = false,
		visual_size = {x = 1.1, y = 1.1},
		collisionbox = {-0.55,-0.55,-0.55, 0.55,0.55,0.55},
		glow = 8,
	},
	on_step = function(self, dtime)
		self.ttl = (self.ttl or 600) - 1
		if self.ttl <= 0 then
			local pos = self.object:get_pos()
			unmark_position(self.player_name, pos)
		end
	end,
	on_punch = function(self, hitter)
		local pos = self.object:get_pos()
		local name = hitter:get_player_name()
		if name == self.player_name then
			unmark_position(name, pos)
		end
	end,
})

local function formspec1(meta)
	local status = meta:get_string("status")
	return "size[8,6.5]"..
		"tabheader[0,0;tab;"..S("Ctrl,Inv")..";1;;true]"..
		"button[0.7,0;3,1;record;"..S("Record").."]"..
		"button[4.3,0;3,1;ready;"..S("Done").."]"..
		"button[0.7,1;3,1;show;"..S("Set").."]"..
		"button[4.3,1;3,1;hide;"..S("Remove").."]"..
		"label[0.5,2;"..status.."]"..
		"list[current_player;main;0,2.8;8,4;]"
end

local function formspec2()
	return "size[8,6.5]"..
		"tabheader[0,0;tab;"..S("Ctrl,Inv")..";2;;true]"..
		"list[context;main;0,0;8,2;]"..
		"list[current_player;main;0,2.8;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
end

local function play_sound(pos)
	minetest.sound_play("techage_button", {
		pos = pos, 
		gain = 1,
		max_hear_distance = 15})
end

local function exchange_node(pos, item, param2)
	local node = minetest.get_node_or_nil(pos)
	local meta = minetest.get_meta(pos)
	if node and (not meta or not next((meta:to_table()).fields)) or
			minetest.get_item_group(node.name, "techage_door") then
		if item and item:get_name() ~= "" and param2 then
			minetest.swap_node(pos, {name = item:get_name(), param2 = param2})
		else
			minetest.remove_node(pos)
		end
		if node.name ~= "air" then
			return ItemStack(node.name), node.param2
		end
	end
	return ItemStack(), nil
end

local function exchange_nodes(pos, nvm)
	local meta = M(pos)
	local inv = meta:get_inventory()
	
	local item_list = inv:get_list("main")
	local owner = meta:get_string("owner")
	local res = false
	nvm.pos_list = nvm.pos_list or {}
	nvm.param2_list = nvm.param2_list or {}

	for idx = 1, 16 do
		local pos = nvm.pos_list[idx]
		if pos and not minetest.is_protected(pos, owner) then
			item_list[idx], nvm.param2_list[idx] = exchange_node(pos, item_list[idx], nvm.param2_list[idx])
			res = true
		end
	end
	
	inv:set_list("main", item_list)
	return res
end

local function show_nodes(pos)
	local nvm = techage.get_nvm(pos)
	if not nvm.is_on then
		nvm.is_on = true
		return exchange_nodes(pos, nvm)
	end
end

local function hide_nodes(pos)
	local nvm = techage.get_nvm(pos)
	if nvm.is_on then
		nvm.is_on = false
		return exchange_nodes(pos, nvm)
	end
end

minetest.register_node("techage:ta3_doorcontroller2", {
	description = S("TA3 Door Controller II"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_doorcontroller.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 16)
		logic.after_place_node(pos, placer, "techage:ta3_doorcontroller", S("TA3 Door Controller II"))
		logic.infotext(meta, S("TA3 Door Controller II"))
		meta:set_string("formspec", formspec1(meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		if fields.tab == "2" then
			meta:set_string("formspec", formspec2(meta))
			return
		elseif fields.tab == "1" then
			meta:set_string("formspec", formspec1(meta))
			return
		elseif fields.record then
			local inv = meta:get_inventory()
			if not inv:is_empty("main") then			
				meta:set_string("status", S("Error: Inventory already in use"))
			else
				local nvm = techage.get_nvm(pos)
				nvm.pos_list = nil
				nvm.is_on = false
				meta:set_string("status", S("Recording..."))
				local name = player:get_player_name()
				minetest.chat_send_player(name, S("Click on all the blocks that are part of the door/gate"))
				MarkedNodes[name] = {}
			end
			meta:set_string("formspec", formspec1(meta))
		elseif fields.ready then
			local nvm = techage.get_nvm(pos)
			local name = player:get_player_name()
			local pos_list = table_to_poslist(name)
			local text = #pos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			nvm.pos_list = pos_list
			nvm.is_on = true
			unmark_all(name)
			meta:set_string("formspec", formspec1(meta))
		elseif fields.show then
			if show_nodes(pos) then
				play_sound(pos)
				meta:set_string("status", S("Blocks are back"))
				meta:set_string("formspec", formspec1(meta))
				local name = player:get_player_name()
				MarkedNodes[name] = nil
			end
		elseif fields.hide then
			if hide_nodes(pos) then
				play_sound(pos)
				meta:set_string("status", S("Blocks are disappeared"))
				meta:set_string("formspec", formspec1(meta))
				local name = player:get_player_name()
				MarkedNodes[name] = nil
			end
		end
	end,
	
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return 1
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		
		local inv = minetest.get_inventory({type="node", pos=pos})
		local pos_list = minetest.deserialize(M(pos):get_string("pos_list")) or {}
		if pos_list[index] and inv:get_stack(listname, index):get_count() == 0 then
			return 1
		end
		return 0
	end,
	
	can_dig = function(pos, player)
		if player and minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		
		local inv = minetest.get_inventory({type="node", pos=pos})
		return inv:is_empty("main")
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.register_node({"techage:ta3_doorcontroller2"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "on" then
			return hide_nodes(pos, nil)
		elseif topic == "off" then
			return show_nodes(pos)
		end
		return false
	end,
	on_node_load = function(pos)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		meta:set_string("status", "")
		meta:set_string("formspec", formspec1(meta))
		local pos_list = minetest.deserialize(meta:get_string("pos_list"))
		if pos_list then
			nvm.pos_list = pos_list
			meta:set_string("pos_list", "")
			local inv = meta:get_inventory()
			if inv:is_empty("main") then
				nvm.is_on = true
			end
		end
		local param2_list = minetest.deserialize(meta:get_string("param2_list"))
		if param2_list then
			nvm.param2_list = param2_list
			meta:set_string("param2_list", "")
		end
	end,
})		

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta3_doorcontroller2",
	recipe = {"techage:ta3_doorcontroller"},
})

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if puncher and puncher:is_player() then
		local name = puncher:get_player_name()
		
		if not MarkedNodes[name] then
			return
		end
		
		mark_position(name, pointed_thing.under)
	end
end)