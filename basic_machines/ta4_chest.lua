--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 8x2000 Chest
	
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
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

local function repair_inv(nvm)
	nvm.inventory = nvm.inventory or {}
	for i = 1,8 do
		local item = nvm.inventory[i]
		if not item or type(item) ~= "table" 
		or not item.name  or type(item.name)  ~= "string" 
		or not item.count or type(item.count) ~= "number" then
			nvm.inventory[i] = {name = "", count = 0}
		end
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

local function max_stacksize(item_name)
	local ndef = minetest.registered_nodes[item_name] or minetest.registered_items[item_name] or minetest.registered_craftitems[item_name]
	if ndef then 
		return ndef.stack_max
	end
	return 0
end

local function get_stacksize(pos)
	local size = M(pos):get_int("stacksize")
	if size == 0 then 
		return STACK_SIZE 
	end
	return size
end

-- Sort the items into the nvm inventory
local function sort_in(pos, nvm, stack)
	local old_counts = {}
	local orig_count = stack:get_count()
	for idx,item in ipairs(nvm.inventory or {}) do
		if item.name and (item.name == "" or item.name == stack:get_name()) then
			local count = math.min(stack:get_count(), get_stacksize(pos) - item.count)
			old_counts[idx] = item.count -- store old value
			item.count = item.count + count
			item.name = stack:get_name()
			stack:set_count(stack:get_count() - count)
			if stack:get_count() == 0 then
				return true
			end
		end
	end
	-- restore old values
	for idx,cnt in pairs(old_counts) do
		nvm.inventory[idx].count = cnt
	end
	stack:set_count(orig_count)
	return false
end

local function move_items_to_stack(item, stack, num)
	item.count = item.count - num
	stack.count = stack.count + num
	if stack.count > 0 then
		stack.name = item.name
	end
	if item.count == 0 then
		item.name = "" -- empty
	end
	return stack
end	

local function get_item(pos, nvm, item_name, count)
	local stack = {count = 0}
	nvm.inventory = nvm.inventory or {}
	
	if item_name then
		-- Take specified items from the chest
		for _,item in ipairs(nvm.inventory) do
			if item.name == item_name then
				local num = math.min(item.count, count - stack.count, max_stacksize(item.name))
				if M(pos):get_int("assignment") == 1 and num == item.count then
					-- never take the last item
					num = num - 1
				end
				stack = move_items_to_stack(item, stack, num)
				if stack.count == count then
					return ItemStack(stack)
				end
			end
		end
	elseif M(pos):get_int("priority") == 1 then
		-- Take any items. The position within the inventory is from right to left
		for idx = 8,1,-1 do
			local item = nvm.inventory[idx]
			if item.name ~= "" and (stack.name == nil or stack.name == item.name) then
				local num = math.min(item.count, count - stack.count, max_stacksize(item.name))
				if M(pos):get_int("assignment") == 1 and num == item.count then
					-- never take the last item
					num = num - 1
				end
				stack = move_items_to_stack(item, stack, num)
				if stack.count == count then
					return ItemStack(stack)
				end
			end
		end
	else
		-- Take any items. The position within the inventory
		-- is incremented each time so that different item stacks will be considered.
		local mem = techage.get_mem(pos)
		mem.startpos = mem.startpos or 1
		for idx = mem.startpos, mem.startpos + 8 do
			idx = (idx % 8) + 1
			local item = nvm.inventory[idx]
			if item.name ~= "" and (stack.name == nil or stack.name == item.name) then
				local num = math.min(item.count, count - stack.count, max_stacksize(item.name))
				if M(pos):get_int("assignment") == 1 and num == item.count then
					-- never take the last item
					num = num - 1
				end
				stack = move_items_to_stack(item, stack, num)
				if stack.count == count then
					mem.startpos = idx
					return ItemStack(stack)
				end
			end
			mem.startpos = idx
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
		tbl[#tbl+1] = "box["..(xpos - 0.03)..",0;0.86,0.9;#808080]"
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
	local size = get_stacksize(pos)
	local assignment = M(pos):get_int("assignment") == 1 and "true" or "false"
	local priority = M(pos):get_int("priority") == 1 and "true" or "false"
	return "size[8,8.3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		formspec_container(0, 0, nvm, inv)..
		"button[0,3.5;3,1;unlock;"..S("Unlock").."]"..
		"tooltip[0,3.5;3,1;"..S("Unlock connected chest\nif all slots are below 2000")..";#0C3D32;#FFFFFF]"..
		"label[0,3;"..S("Size")..": 8x"..size.."]"..
		"checkbox[4,3;assignment;"..S("keep assignment")..";"..assignment.."]"..
		"tooltip[4,3;2,0.6;"..S("Never completely empty the slots\nwith the pusher to keep the item assignment")..";#0C3D32;#FFFFFF]"..
		"checkbox[4,3.6;priority;"..S("right to left")..";"..priority.."]"..
		"tooltip[4,3.6;2,0.6;"..S("Empty the slots always \nfrom right to left")..";#0C3D32;#FFFFFF]"..
		"list[current_player;main;0,4.6;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
end

local function count_number_of_chests(pos)
	local node = techage.get_node_lvm(pos)
	local dir = techage.side_to_outdir("B", node.param2)
	local pos1 = tubelib2.get_pos(pos, dir)
	local cnt = 1
	while cnt < 50 do
		node = techage.get_node_lvm(pos1)
		if node.name ~= "techage:ta4_chest_dummy" then
			break
		end
		pos1 = tubelib2.get_pos(pos1, dir)
		cnt = cnt + 1
	end
	M(pos):set_int("stacksize", STACK_SIZE * cnt)
end

local function search_chest_in_front(pos, node)
	local dir = techage.side_to_outdir("F", node.param2)
	local pos1 = tubelib2.get_pos(pos, dir)
	local cnt = 1
	while cnt < 50 do
		node = techage.get_node_lvm(pos1)
		if node.name ~= "techage:ta4_chest_dummy" then
			break
		end
		pos1 = tubelib2.get_pos(pos1, dir)
		cnt = cnt + 1
	end
	if node.name == "techage:ta4_chest" then
		minetest.after(1, count_number_of_chests, pos1)
		return true
	end
	return false
end

local function convert_to_chest_again(pos, node, player)
	local dir = techage.side_to_outdir("B", node.param2)
	local pos1 = tubelib2.get_pos(pos, dir)
	local node1 = techage.get_node_lvm(pos1)
	if minetest.is_protected(pos1, player:get_player_name()) then
		return
	end
	if node1.name == "techage:ta4_chest_dummy" then
		node1.name = "techage:ta4_chest"
		minetest.swap_node(pos1, node1)
		--M(pos1):set_int("disabled", 1)
		local nvm = techage.get_nvm(pos1)
		gen_inv(nvm)
		local number = techage.add_node(pos1, "techage:ta4_chest")
		M(pos1):set_string("owner", player:get_player_name())
		M(pos1):set_string("formspec", formspec(pos1))
		M(pos1):set_string("infotext", DESCRIPTION.." "..number)
	end
end	
	
local function unlock_chests(pos, player)
	local nvm = techage.get_nvm(pos)
	for idx = 1,8 do
		if get_count(nvm, idx) > STACK_SIZE then return end
	end
	local node = techage.get_node_lvm(pos)
	convert_to_chest_again(pos, node, player)
	M(pos):set_int("stacksize", STACK_SIZE)
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
	if M(pos):get_int("disabled") ~= 1 then
		local nvm = techage.get_nvm(pos)
		repair_inv(nvm)
		M(pos):set_string("formspec", formspec(pos))
		techage.set_activeformspec(pos, clicker)
	end
end

-- take items from chest
local function move_from_nvm_to_inv(pos, idx)
	local nvm = techage.get_nvm(pos)
	local inv = M(pos):get_inventory()
	local inv_stack = inv:get_stack("main", idx)
	local nvm_stack = get_stack(nvm, idx)
	
	if nvm_stack.count > 0 and inv_stack:get_count() == 0 then
		local count = math.min(nvm_stack.count, max_stacksize(nvm_stack.name))
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
			local count = math.min(inv_stack:get_count(), get_stacksize(pos) - nvm_stack.count)
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
	if fields.unlock then
		unlock_chests(pos, player)
	end
	if fields.assignment then
		M(pos):set_int("assignment", fields.assignment == "true" and 1 or 0)
	end
	if fields.priority then
		M(pos):set_int("priority", fields.priority == "true" and 1 or 0)
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

local function on_rotate(pos, node, user, mode, new_param2)
	if get_stacksize(pos) == STACK_SIZE then
		return screwdriver.rotate_simple(pos, node, user, mode, new_param2)
	else
		return screwdriver.disallow(pos, node, user, mode, new_param2)
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos)
	convert_to_chest_again(pos, oldnode, digger)
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
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_front_ta4.png^techage_appl_warehouse.png",
	},

	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('main', 8)
	end,
	
	after_place_node = function(pos, placer)
		local node = minetest.get_node(pos)
		if search_chest_in_front(pos, node) then
			node.name = "techage:ta4_chest_dummy"
			minetest.swap_node(pos, node)
		else
			local nvm = techage.get_nvm(pos)
			gen_inv(nvm)
			local number = techage.add_node(pos, "techage:ta4_chest")
			M(pos):set_string("owner", placer:get_player_name())
			M(pos):set_string("formspec", formspec(pos))
			M(pos):set_string("infotext", DESCRIPTION.." "..number)
		end
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		return techage.logic.set_numbers(pos, numbers, player_name, DESCRIPTION)
	end,
	
	on_rotate = on_rotate,
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

minetest.register_node("techage:ta4_chest_dummy", {
	description = DESCRIPTION,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_front_ta4.png^techage_appl_warehouse.png",
	},

	on_rightclick = function(pos, node, clicker)
	end,
	paramtype2 = "facedir",
	diggable = false,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


techage.register_node({"techage:ta4_chest"}, {
	on_pull_item = function(pos, in_dir, num, item_name)
		local nvm = techage.get_nvm(pos)
		local res = get_item(pos, nvm, item_name, num)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,
	on_push_item = function(pos, in_dir, stack)
		local nvm = techage.get_nvm(pos)
		local res = sort_in(pos, nvm, stack)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local nvm = techage.get_nvm(pos)
		local res = sort_in(pos, nvm, stack)
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
