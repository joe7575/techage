--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 8x2000 Chest
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local DESCRIPTION = S("TA4 8x2000 Chest")
local STACK_SIZE = 2000

local function gen_inv(nvm)
	nvm.inventory = {}
	for i = 1,8 do
		nvm.inventory[i] = {name = "", count = 0}
	end
end

local function get_stack(nvm, idx)
	nvm.inventory = nvm.inventory or {}
	if nvm.inventory[idx] then
		return nvm.inventory[idx]
	end
	nvm.inventory[idx] = {name = "", count = 0}
	return nvm.inventory[idx]
end

local function get_count(nvm, idx)
	if idx and idx > 0 then
		nvm.inventory = nvm.inventory or {}
		if nvm.inventory[idx] then
			return nvm.inventory[idx].count or 0
		else
			return 0
		end
	else
		local count = 0
		for _,item in ipairs(nvm.inventory or {}) do
			count = count + item.count or 0
		end
		return count
	end
end

local function inv_empty(nvm)
	for _,item in ipairs(nvm.inventory or {}) do
		if item.count and item.count > 0 then
			return false
		end
	end
	return true
end

local function inv_state(nvm)
	local num = 0
	for _,item in ipairs(nvm.inventory or {}) do
		if item.count and item.count > 0 then
			num = num + 1
		end
	end
	if num == 0 then return "empty" end
	if num == 8 then return "full" end
	return "loaded"
end

-- Sort the items into the nvm inventory
-- If the nvm inventry is full, the items are stored in the main inventory
-- If the main inventory is also full, false is returned
local function sort_in(inv, nvm, stack)
	if inv:is_empty("main") then -- the main inv is used for the case the nvm-inventory is full
		for _,item in ipairs(nvm.inventory or {}) do
			if item.name and (item.name == "" or item.name == stack:get_name()) then
				local count = math.min(stack:get_count(), STACK_SIZE - item.count)
				item.count = item.count + count
				item.name = stack:get_name()
				stack:set_count(stack:get_count() - count)
				if stack:get_count() == 0 then
					return true
				end
			end
		end
		inv:add_item("main", stack)
		return true
	end
	return false
end

local function get_item(inv, nvm, item_name, count)
	local stack = {count = 0}
	if not inv:is_empty("main") then
		if item_name then
			local taken = inv:remove_item("main", {name = item_name, count = count})
			if taken:get_count() > 0 then
				return taken
			end
		else
			return techage.get_items(inv, "main", count)
		end
	end
	for _,item in ipairs(nvm.inventory or {}) do
		if (item_name == nil and stack.name == nil) or item.name == item_name then
			local num = math.min(item.count, count - stack.count)
			item.count = item.count - num
			stack.count = stack.count + num
			if item.name ~= "" then
				stack.name = item.name
			end
			if item.count == 0 then
				item.name = "" -- empty
			end
			if stack.count == count then
				return ItemStack(stack)
			end
		end
	end
	if stack.count > 0 then
		return ItemStack(stack)
	end
end

local function formspec_container(x, y, nvm, inv)
	local tbl = {"container["..x..","..y.."]"}
	for i = 1,8 do
		local xpos = i - 1
		tbl[#tbl+1] = "box["..xpos..",0;0.8,0.9;#808080]"
		local stack = get_stack(nvm, i)
		if stack.name ~= "" then
			local itemname = stack.name.." "..stack.count
			--tbl[#tbl+1] = "item_image["..xpos..",1;1,1;"..itemname.."]"
			tbl[#tbl+1] = techage.item_image(xpos, 0, itemname)
		end
		if inv:get_stack("main", i):get_count() == 0 then
			tbl[#tbl+1] = "image_button["..xpos..",1;1,1;techage_form_get_arrow.png;get"..i..";]"
		else
			tbl[#tbl+1] = "image_button["..xpos..",1;1,1;techage_form_add_arrow.png;add"..i..";]"
		end
	end
	tbl[#tbl+1] = "list[context;main;0,2;8,1;]"
	tbl[#tbl+1] = "container_end[]"
	return table.concat(tbl, "")
end

local function formspec(pos)
	local nvm = techage.get_nvm(pos)
	local inv = M(pos):get_inventory()
	return "size[8,7.2]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	formspec_container(0, 0, nvm, inv)..
	"list[current_player;main;0,3.5;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return count
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	M(pos):set_string("formspec", formspec(pos))
	techage.set_activeformspec(pos, player)
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	M(pos):set_string("formspec", formspec(pos))
	techage.set_activeformspec(pos, player)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	M(pos):set_string("formspec", formspec(pos))
	techage.set_activeformspec(pos, player)
end

local function on_rightclick(pos, node, clicker)
	M(pos):set_string("formspec", formspec(pos))
	techage.set_activeformspec(pos, clicker)
end

-- take items from chest
local function move_from_nvm_to_inv(pos, idx)
	local nvm = techage.get_nvm(pos)
	local inv = M(pos):get_inventory()
	local inv_stack = inv:get_stack("main", idx)
	local nvm_stack = get_stack(nvm, idx)
	
	if nvm_stack.count > 0 and inv_stack:get_count() == 0 then
		local count = math.min(nvm_stack.count, 99)
		nvm_stack.count = nvm_stack.count - count
		inv:set_stack("main", idx, {name = nvm_stack.name, count = count})
		if nvm_stack.count == 0 then
			nvm_stack.name = ""
		end
	end
end

-- add items to chest
local function move_from_inv_to_nvm(pos, idx)
	local nvm = techage.get_nvm(pos)
	local inv = M(pos):get_inventory()
	local inv_stack = inv:get_stack("main", idx)
	local nvm_stack = get_stack(nvm, idx)

	if inv_stack:get_count() > 0 then
		if nvm_stack.count == 0 or nvm_stack.name == inv_stack:get_name() then
			local count = math.min(inv_stack:get_count(), STACK_SIZE - nvm_stack.count)
			nvm_stack.count = nvm_stack.count + count
			nvm_stack.name = inv_stack:get_name()
			inv_stack:set_count(inv_stack:get_count() - count)
			inv:set_stack("main", idx, inv_stack)
		end
	end
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	for i = 1,8 do
		if fields["get"..i] ~= nil then
			move_from_nvm_to_inv(pos, i)
			break
		elseif fields["add"..i] ~= nil then
			move_from_inv_to_nvm(pos, i)
			break
		end
	end
	M(pos):set_string("formspec", formspec(pos))
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = minetest.get_meta(pos):get_inventory()
	local nvm = techage.get_nvm(pos)
	return inv:is_empty("main") and inv_empty(nvm)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos)
end

minetest.register_node("techage:ta4_chest", {
	description = DESCRIPTION,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_front_ta4.png",
	},

	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('main', 8)
	end,
	
	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		gen_inv(nvm)
		local number = techage.add_node(pos, "techage:ta4_chest")
		M(pos):set_string("owner", placer:get_player_name())
		M(pos):set_string("formspec", formspec(pos))
		M(pos):set_string("infotext", DESCRIPTION.." "..number)
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return techage.logic.set_numbers(pos, numbers, player_name, DESCRIPTION)
	end,
	
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
	can_dig = can_dig,
	after_dig_node = after_dig_node,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_take = on_metadata_inventory_take,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


techage.register_node({"techage:ta4_chest"}, {
	on_pull_item = function(pos, in_dir, num, item_name)
		local nvm = techage.get_nvm(pos)
		local inv =  M(pos):get_inventory()
		local res = get_item(inv, nvm, item_name, num)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,
	on_push_item = function(pos, in_dir, stack)
		local nvm = techage.get_nvm(pos)
		local inv =  M(pos):get_inventory()
		local res = sort_in(inv, nvm, stack)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local nvm = techage.get_nvm(pos)
		local inv =  M(pos):get_inventory()
		local res = sort_in(inv, nvm, stack)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,
	
	on_recv_message = function(pos, src, topic, payload)
		if topic == "count" then
			local nvm = techage.get_nvm(pos)
			return get_count(nvm, tonumber(payload) or 0)
		elseif topic == "state" then
			local nvm = techage.get_nvm(pos)
			return inv_state(nvm)
		else
			return "unsupported"
		end
	end,
})	

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta4_chest",
	recipe = {"techage:chest_ta4"}
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:chest_ta4",
	recipe = {"techage:ta4_chest"}
})
