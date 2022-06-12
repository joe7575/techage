--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 8x2000 Chest

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local S = techage.S

local DESCRIPTION = S("TA4 8x2000 Chest")
local STACK_SIZE = 2000

local function gen_stack(inv, idx)
	inv[idx] = {name = "", count = 0}
end

local function gen_inv(nvm)
	nvm.inventory = {}
	for i = 1,8 do
		gen_stack(nvm.inventory, i)
	end
	return nvm.inventory
end

local function repair_inv(nvm)
	nvm.inventory = nvm.inventory or {}
	for i = 1,8 do
		local item = nvm.inventory[i]
		if not item or type(item) ~= "table"
			or not item.name  or type(item.name)  ~= "string" or item.name == ""
			or not item.count or type(item.count) ~= "number" or item.count < 1
		then
			gen_stack(nvm.inventory, i)
		end
	end
end

local function get_stack(nvm, idx)
	nvm.inventory = nvm.inventory or {}
	return nvm.inventory[idx] or gen_stack(nvm.inventory, idx)
end

local function get_count(nvm, idx)
	nvm.inventory = nvm.inventory or {}
	if idx and idx > 0 then
		return nvm.inventory[idx] and nvm.inventory[idx].count or 0
	else
		local count = 0
		for _,item in ipairs(nvm.inventory) do
			count = count + item.count or 0
		end
		return count
	end
end

local function get_itemstring(nvm, idx)
	if idx and idx > 0 then
		nvm.inventory = nvm.inventory or {}
		return nvm.inventory[idx] and nvm.inventory[idx].name or ""
	end
	return ""
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

local function inv_state_num(nvm)
	local num = 0
	for _,item in ipairs(nvm.inventory or {}) do
		if item.count and item.count > 0 then
			num = num + 1
		end
	end
	if num == 0 then return 0 end
	if num == 8 then return 2 end
	return 1
end

local function max_stacksize(item_name)
	-- It is sufficient to use minetest.registered_items as all registration
	-- functions (node, craftitems, tools) add the definitions there.
	local ndef = minetest.registered_items[item_name]
	-- Return 1 as fallback so that slots with unknown items can be emptied.
	return ndef and ndef.stack_max or 1
end

local function get_stacksize(pos)
	local size = M(pos):get_int("stacksize")
	if size == 0 then
		return STACK_SIZE
	end
	return size
end

-- Returns a boolean that indicates if an itemstack and nvmstack can be combined.
-- The second return value is a string describing the reason.
-- This function guarantees not to modify any of both stacks.
local function doesItemStackMatchNvmStack(itemstack, nvmstack)
	if itemstack:get_count() == 0 or nvmstack.count == 0 then
		return true, "Empty stack"
	end
	if nvmstack.name and nvmstack.name ~= "" and nvmstack.name ~= itemstack:get_name() then
		return false, "Mismatching names"
	end

	-- The following seems to be the most reliable approach to compare meta.
	local nvm_meta = ItemStack():get_meta()
	nvm_meta:from_table(minetest.deserialize(nvmstack.meta))
	if not nvm_meta:equals(itemstack:get_meta()) then
		return false, "Mismatching meta"
	end
	if (nvmstack.wear or 0) ~= itemstack:get_wear() then
		return false, "Mismatching wear"
	end
	return true, "Stacks match"
end


-- Generic function for adding items to the 8x2000 Chest
-- This function guarantees not to modify the itemstack.
-- The number of items that were added to the chest is returned.
local function add_to_chest(pos, input_stack, idx)
	local nvm = techage.get_nvm(pos)
	local nvm_stack = get_stack(nvm, idx)
	if input_stack:get_count() == 0 then
		return 0
	end
	if not doesItemStackMatchNvmStack(input_stack, nvm_stack) then
		return 0
	end
	local count = math.min(input_stack:get_count(), get_stacksize(pos) - (nvm_stack.count or 0))
	if nvm_stack.count == 0 then
		nvm_stack.name = input_stack:get_name()
		nvm_stack.meta = minetest.serialize(input_stack:get_meta():to_table())
		nvm_stack.wear = input_stack:get_wear()
	end
	nvm_stack.count = nvm_stack.count + count
	return count
end

local function stackOrNil(stack)
	if stack and stack.get_count and stack:get_count() > 0 then
		return stack
	end
	return nil
end

-- Generic function for taking items from the 8x2000 Chest
-- output_stack is directly modified; but nil can also be supplied.
-- The resulting output_stack is returned from the function.
-- keep_assignment indicates if the meta information for this function should be considered (manual vs. tubes).
local function take_from_chest(pos, idx, output_stack, max_total_count, keep_assignment)
	local nvm = techage.get_nvm(pos)
	local nvm_stack = get_stack(nvm, idx)
	output_stack = output_stack or ItemStack()
	local assignment_count = keep_assignment and M(pos):get_int("assignment") == 1 and 1 or 0
	local count = math.min(nvm_stack.count - assignment_count, max_stacksize(nvm_stack.name) - output_stack:get_count())
	if max_total_count then
		count = math.min(count, max_total_count - output_stack:get_count())
	end
	if count < 1 then
		return stackOrNil(output_stack)
	end
	if not doesItemStackMatchNvmStack(output_stack, nvm_stack) then
		return stackOrNil(output_stack)
	end
	output_stack:add_item(ItemStack({
		name = nvm_stack.name,
		count = count,
		wear = nvm_stack.wear,
	}))
	output_stack:get_meta():from_table(minetest.deserialize(nvm_stack.meta))
	nvm_stack.count = nvm_stack.count - count
	if nvm_stack.count == 0 then
		gen_stack(nvm.inventory or {}, idx)
	end
	return stackOrNil(output_stack)
end

-- Function for adding items to the 8x2000 Chest via automation, e.g. pushers
local function tube_add_to_chest(pos, input_stack)
	local nvm = techage.get_nvm(pos)
	nvm.inventory = nvm.inventory or {}

	-- Backup some values needed for restoring the old
	-- state if items can't fully be added to chest.
	local orig_count = input_stack:get_count()
	local backup = table.copy(nvm.inventory)

	for idx = 1,8 do
		input_stack:take_item(add_to_chest(pos, input_stack, idx))
	end

	if input_stack:get_count() > 0 then
		nvm.inventory = backup -- Restore old nvm inventory
		input_stack:set_count(orig_count) -- Restore input_stack
		return false -- No items were added to chest
	else
		return true -- Items were added successfully
	end
end

-- Function for taking items from the 8x2000 Chest via automation, e.g. pushers
local function tube_take_from_chest(pos, item_name, count)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	nvm.inventory = nvm.inventory or {}
	mem.startpos = mem.startpos or 1
	local prio = M(pos):get_int("priority") == 1
	local startpos = prio and 8 or mem.startpos
	local endpos = prio and 1 or mem.startpos + 8
	local step = prio and -1 or 1
	local itemstack = ItemStack()
	for idx = startpos,endpos,step do
		idx = ((idx - 1) % 8) + 1
		local nvmstack = get_stack(nvm, idx)
		if not item_name or item_name == nvmstack.name then
			take_from_chest(pos, idx, itemstack, count - itemstack:get_count(), true)
			if itemstack:get_count() == count then
				mem.startpos = idx + 1
				return itemstack
			end
		end
		mem.startpos = idx + 1
	end
	return stackOrNil(itemstack)
end

-- Function for manually adding items to the 8x2000 Chest via the formspec
local function inv_add_to_chest(pos, idx)
	local inv = M(pos):get_inventory()
	local inv_stack = inv:get_stack("main", idx)
	local count = add_to_chest(pos, inv_stack, idx)
	inv_stack:set_count(inv_stack:get_count() - count)
	inv:set_stack("main", idx, inv_stack)
end

-- Function for manually taking items from the 8x2000 Chest via the formspec
local function inv_take_from_chest(pos, idx)
	local inv = M(pos):get_inventory()
	local inv_stack = inv:get_stack("main", idx)
	if inv_stack:get_count() > 0 then
		return
	end
	local output_stack = take_from_chest(pos, idx)
	if output_stack then
		inv:set_stack("main", idx, output_stack)
	end
end

local function formspec_container(x, y, nvm, inv)
	local tbl = {"container["..x..","..y.."]"}
	for i = 1,8 do
		local xpos = i - 1
		tbl[#tbl+1] = "box["..(xpos - 0.03)..",0;0.86,0.9;#808080]"
		local stack = get_stack(nvm, i)
		if stack.name ~= "" then
			local itemstack = ItemStack({
				name = stack.name,
				count = stack.count,
				wear = stack.wear,
			})
			local stack_meta_table = (minetest.deserialize(stack.meta) or {}).fields or {}
			for _, key in ipairs({"description", "short_description", "color", "palette_index"}) do
				if stack_meta_table[key] then
					itemstack:get_meta():set_string(key, stack_meta_table[key])
				end
			end
			local itemname = itemstack:to_string()
			--tbl[#tbl+1] = "item_image["..xpos..",1;1,1;"..itemname.."]"
			tbl[#tbl+1] = techage.item_image(xpos, 0, itemname, stack.count)
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
	local param2 = node.param2
	local cnt = 1
	while cnt < 50 do
		node = techage.get_node_lvm(pos1)
		if node.name ~= "techage:ta4_chest_dummy" then
			break
		end
		local meta = M(pos1)
		if meta:contains("param2") and meta:get_int("param2") ~= param2 then
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
	local param2 = node.param2
	local cnt = 1
	while cnt < 50 do
		node = techage.get_node_lvm(pos1)
		if node.name ~= "techage:ta4_chest_dummy" then
			break
		end
		local meta = M(pos1)
		if meta:contains("param2") and meta:get_int("param2") ~= param2 then
			break
		end
		pos1 = tubelib2.get_pos(pos1, dir)
		cnt = cnt + 1
	end
	if node.name == "techage:ta4_chest" then
		minetest.after(1, count_number_of_chests, pos1)
		local nvm = techage.get_nvm(pos)
		nvm.front_chest_pos = pos1
		return true
	end
	return false
end

local function get_front_chest_pos(pos)
	local nvm = techage.get_nvm(pos)
	if nvm.front_chest_pos then
		return nvm.front_chest_pos
	end

	local node = techage.get_node_lvm(pos)
	if search_chest_in_front(pos, node) then
		return nvm.front_chest_pos
	end

	return pos
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

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	for i = 1,8 do
		if fields["get"..i] ~= nil then
			inv_take_from_chest(pos, i)
			break
		elseif fields["add"..i] ~= nil then
			inv_add_to_chest(pos, i)
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
	techage.remove_node(pos, oldnode, oldmetadata)
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
			M(pos):set_int("param2", node.param2)
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
		local res = tube_take_from_chest(pos, item_name, num)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,
	on_push_item = function(pos, in_dir, stack)
		local res = tube_add_to_chest(pos, stack)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local res = tube_add_to_chest(pos, stack)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return res
	end,

	on_recv_message = function(pos, src, topic, payload)
		if topic == "count" then
			local nvm = techage.get_nvm(pos)
			return get_count(nvm, tonumber(payload or 1) or 1)
		elseif topic == "itemstring" then
			local nvm = techage.get_nvm(pos)
			return get_itemstring(nvm, tonumber(payload or 1) or 1)
		elseif topic == "state" then
			local nvm = techage.get_nvm(pos)
			return inv_state(nvm)
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 140 and payload[1] == 1 then  -- Inventory Item Count
			local nvm = techage.get_nvm(pos)
			return 0, {get_count(nvm, tonumber(payload[2] or 1) or 1)}
		elseif topic == 140 and payload[1] == 2 then  -- Inventory Item Name
			local nvm = techage.get_nvm(pos)
			return 0, get_itemstring(nvm, tonumber(payload[2] or 1) or 1)
		elseif topic == 131 then  -- Chest State
			local nvm = techage.get_nvm(pos)
			return 0, {inv_state_num(nvm)}
		else
			return 2, ""
		end
	end,
})

techage.register_node({"techage:ta4_chest_dummy"}, {
	on_pull_item = function(pos, in_dir, num, item_name)
		local fc_pos = get_front_chest_pos(pos)
		local res = tube_take_from_chest(fc_pos, item_name, num)
		if techage.is_activeformspec(fc_pos) then
			M(fc_pos):set_string("formspec", formspec(fc_pos))
		end
		return res
	end,
	on_push_item = function(pos, in_dir, stack)
		local fc_pos = get_front_chest_pos(pos)
		local res = tube_add_to_chest(fc_pos, stack)
		if techage.is_activeformspec(fc_pos) then
			M(fc_pos):set_string("formspec", formspec(fc_pos))
		end
		return res
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local fc_pos = get_front_chest_pos(pos)
		local res = tube_add_to_chest(fc_pos, stack)
		if techage.is_activeformspec(fc_pos) then
			M(fc_pos):set_string("formspec", formspec(fc_pos))
		end
		return res
	end
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
