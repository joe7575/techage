--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Digitizer
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end

-- Consumer Related Data
local Tube = techage.Tube
local Cable = techage.ElectricCable
local power = networks.power
local MP = minetest.get_modpath(minetest.get_current_modname())
local mConf = dofile(MP .. "/basis/conf_inv.lua")
local CYCLE_TIME = 2
local STANDBY_TICKS = 8
local COUNTDOWN_TICKS = 2
local NUM_ITEMS = 50
local STORAGE_SLOTS = 4 --16
local STORAGE_SIZE  = 500 -- 100000
local PWR_NEEDED = 24
local EX_POINTS = 50
local DESC = S("TA5 Digitizer")

-- items: 
-- {
-- 	[1] = {name = "default:stone", count = 10},
-- 	[2] = {name = "default:gold_ingot", count = 5},
--  ....
-- 	[STORAGE_SLOTS] = {name = "default:diamond", count = 1},
-- }

local function store_items(pos, mem, force)
	if force then
		M(pos):set_string("items", minetest.serialize(mem.items))
	end
end

local function restore_items(pos, mem)
	if mem.items == nil then
		local meta = M(pos)
		if meta:contains("items") then
			mem.items = minetest.deserialize(meta:get_string("items")) or {}
		else
			mem.items = {}
		end
		for idx = 1, STORAGE_SLOTS do
			mem.items[idx] = mem.items[idx] or {name = "", count = 0}
		end
	end
end

local function find_storage_slot_with_space(pos, mem, item_name)
	local match = function(i, force)
		if (mem.items[i].name == item_name and (mem.items[i].count + NUM_ITEMS) <= STORAGE_SIZE)
		or (force and mem.items[i].name == "") then
			mem.items[i].name = item_name
			return i
		end
		return nil -- full
	end

	restore_items(pos, mem)

	-- Try last used slot
	if mem.last_idx and match(mem.last_idx) then
		return mem.last_idx
	end

    -- Try all slots with items
	for i = 1, STORAGE_SLOTS do
		if match(i) then
			mem.last_idx = i
			return i
		end
	end

	-- Try all empty slots also
	for i = 1, STORAGE_SLOTS do
		if match(i, true) then
			mem.last_idx = i
			return i
		end
	end

	mem.last_idx = nil
	return nil -- full
end

local function find_storage_slot_with_items(pos, mem, item_name)
	restore_items(pos, mem)
	for i = STORAGE_SLOTS, 1, -1 do
		if mem.items[i].name == item_name then
			if mem.items[i].count > 0 then
				return i
			else
				mem.items[i].name = ""
			end
		end
	end
	return nil -- empty
end

local function is_empty(pos, mem)
	restore_items(pos, mem)
	for i = 1, STORAGE_SLOTS do
		if mem.items[i].count > 0 then
			return false
		end
	end
	return true -- empty
end

local function delete_empty_slot(pos, mem, idx)
	if mem.items[idx].name ~= "" and mem.items[idx].count == 0 then
		mem.items[idx].name = ""
	end
end

local function item_image(x, y, item_name, item_count)
	local box = "box[" .. (x + 1.2) .. "," .. (y + 0.2) .. ";2,0.6;#808080]"
	local label = "label[" .. (x + 1.2) .. "," .. (y + 0.5) .. ";" .. string.format("%8d", item_count or 0) .. "]"
	local text = ""
	local tooltip = ""

	if item_name ~= "" and item_count > 0 then
		text = minetest.formspec_escape(ItemStack(item_name):get_description())
		tooltip = "tooltip["..x..","..y..";1,1;"..text..";#0C3D32;#FFFFFF]"
	end

	return "box[" .. x .. "," .. y .. ";1,1;#808080]" ..
		"style_type[label;font=mono]" ..
		"item_image[" .. x .. "," .. y .. ";1,1;" .. item_name .. "]" ..
		tooltip .. box .. label
end

local function fs_container(rows, text)
	local size = 130
	return "scrollbaroptions[max=" .. size .. "]" ..
		"scrollbar[9.6,1.2;0.4,8.2;vertical;wrenchmenu;]" ..
		"scroll_container[0.2,1;9.4,8;wrenchmenu;vertical;]" ..
		text ..
		"scroll_container_end[]"
end

local function formspec1(self, pos, nvm)
	local opmode = nvm.opmode or 1
	return "formspec_version[8]" ..
		"size[10.2,9.6]" ..
		"tabheader[0,0;tab;" .. S("Control,Storage") .. ";1;;true]" ..
		"box[0.2,0.2;9.8,0.5;#c6e8ff]" ..
		"label[0.5,0.45;" .. minetest.colorize( "#000000", DESC) .. "]" ..
		"label[5.7,1.5;" .. S("Configured\nItem") .. "]" ..
		"list[context;main;4.5,1.2;1,1;]" ..
		"image[2.5,1;1,1;"..techage.get_power_image(pos, nvm) .. "]" ..
		"tooltip[2.5,1;1,1;" .. S("Needs @1 ku power", PWR_NEEDED) .. "]" ..
		"image_button[2.5,2.5;1,1;" .. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[2.5,2.5;1,1;" .. self:get_state_tooltip(nvm) .. "]" ..
		"dropdown[4.5,3;4,0.6;opmode;" .. S("pull") .. "," .. S("push") .. ";" .. opmode .. ";true]" .. 
		"list[current_player;main;0.2,4.4;8,4;]" ..
		"listring[context;main]" ..
		"listring[current_player;main]"
end

local function formspec2(self, pos, nvm)
	local mem = techage.get_mem(pos)
	restore_items(pos, mem)
	local tbl = {}
	local idx = 1
	for idx = 1, STORAGE_SLOTS do
		local name, count = mem.items[idx].name, mem.items[idx].count
		if idx % 2 == 1 then
			tbl[#tbl + 1] = item_image(0.5, (idx + 0) * 0.6, name, count)
		else
			tbl[#tbl + 1] = item_image(5.5, (idx - 1) * 0.6, name, count)
		end
	end
	return "formspec_version[8]" ..
		"size[10.2,9.6]" ..
		"tabheader[0,0;tab;" .. S("Control,Storage") .. ";2;;true]" ..
		"box[0.2,0.2;9.8,0.5;#c6e8ff]" ..
		"label[0.5,0.45;" .. minetest.colorize( "#000000", DESC) .. "]" ..
		fs_container(#tbl, table.concat(tbl, ""))
end

local function formspec(self, pos, nvm)
	if nvm.fs_tab2 then
		return formspec2(self, pos, nvm)
	else
		return formspec1(self, pos, nvm)
	end
end

local function configured_item(pos)
	local inv = M(pos):get_inventory()
	local stack = inv:get_stack('main', 1)
	if stack and stack:get_count() > 0 then
		return stack:get_name()
	end
	return nil
end

local function config_item(pos, payload)
	local inv = M(pos):get_inventory()
	local stack = ItemStack(payload)
	inv:set_stack("main", 1, stack)
end

local function stop_node(pos, nvm, state)
end

local function can_start(pos, nvm, state)
	if configured_item(pos) then
		local mem = techage.get_mem(pos)
		mem.last_idx = nil
		return true
	end
	return S("no configured item")
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta5_digitizer_pas",
	node_name_active = "techage:ta5_digitizer_act",
	cycle_time = CYCLE_TIME,
	infotext_name = DESC,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	stop_node = stop_node,
	can_start = can_start,
})

local function consume_power(pos, nvm)
	if techage.needs_power(nvm) then
		local taken = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if techage.is_running(nvm) then
			if taken < PWR_NEEDED then
				State:nopower(pos, nvm)
				return false
			else
				return true
			end
		elseif taken == PWR_NEEDED then
			State:start(pos, nvm)
			return false
		else
			return false
		end
	end
	return true
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	if fields.tab == "1" then
		nvm.fs_tab2 = false
		meta:set_string("formspec", formspec(State, pos, nvm))
		return
	elseif fields.tab == "2" then
		nvm.fs_tab2 = true
		techage.set_activeformspec(pos, player)
		meta:set_string("formspec", formspec(State, pos, nvm))
		return
	else
		if fields.opmode then
			nvm.opmode = tonumber(fields.opmode)
		end
		State:state_button_event(pos, nvm, fields)
	end
end

local function digitize(pos, nvm, mem)
	local item_name = configured_item(pos)
	if item_name == nil then
		State:fault(pos, nvm, S("No configured item"))
		return false
	end

	local tube_dir = M(pos):get_int("tube_dir")
	local idx = find_storage_slot_with_space(pos, mem, item_name)
	if idx then
		-- Take always NUM_ITEMS or nothing
		local leftover = techage.pull_items(pos, tube_dir, NUM_ITEMS, item_name)
		if leftover and leftover:get_count() == NUM_ITEMS then
			mem.items[idx].count = mem.items[idx].count + NUM_ITEMS
			State:keep_running(pos, nvm, COUNTDOWN_TICKS)
			return true
		elseif leftover and leftover:get_count() > 0 then
			techage.unpull_items(pos, tube_dir, leftover)
		end
		delete_empty_slot(pos, mem, idx)
		-- Pulled nothing, try again later
		State:idle(pos, nvm)
		return false
	end
	-- No space in storage, stop execution
	State:blocked(pos, nvm, S("Storage full"))
	return false
end

local function reassemble(pos, nvm, mem)
	local item_name = configured_item(pos)
	if item_name == nil then
		State:fault(pos, nvm, S("No configured item"))
		return false
	end

	local tube_dir = M(pos):get_int("tube_dir")
	local idx = find_storage_slot_with_items(pos, mem, item_name)
	if idx then
		local count = math.min(mem.items[idx].count, NUM_ITEMS)
		local stack = ItemStack({name = item_name, count = count})
		local leftover = techage.push_items(pos, tube_dir, stack)
		local pushed = not leftover and 0 or leftover ~= true and count - leftover:get_count() or count
		mem.items[idx].count = mem.items[idx].count - pushed
		if pushed > 0 then
			State:keep_running(pos, nvm, COUNTDOWN_TICKS)
			return true
		else
			-- Can't push items, try again later
			State:blocked(pos, nvm, "Can't push, no space")
		end
		return false
	end
	-- No items in storage, stop execution
	State:blocked(pos, nvm, "No items in storage")
	return false
end

local function on_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	print("on_timer", nvm.opmode)
	if consume_power(pos, nvm) then
		local mem = techage.get_mem(pos)
		local changed = false
		if nvm.opmode == 1 then
			changed = digitize(pos, nvm, mem)
		else
			changed = reassemble(pos, nvm, mem)
		end
		store_items(pos, mem, changed)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
	end
	return true -- keep running
end

minetest.register_node("techage:ta5_digitizer_pas", {
	description = DESC,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_in_out.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_digitizer_off.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_digitizer_off.png^techage_frame_ta5.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		-- Don't allow placing if itemstack has metadata
		if techage.cordlesss_crewdriver_only(pos, placer, itemstack) then
			return true
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local node = minetest.get_node(pos)
		local tube_dir = techage.side_to_outdir("R", node.param2)
		local number = techage.add_node(pos, "techage:ta5_digitizer_pas")
		State:node_init(pos, nvm, number)
		meta:set_int("tube_dir", tube_dir)
		meta:set_string("owner", placer:get_player_name())
		Tube:after_place_node(pos, {tube_dir})
		Cable:after_place_node(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 1)
	end,

	ta_rotate_node = function(pos, node, new_param2)
		local meta = M(pos)
		Cable:after_dig_node(pos)
		Tube:after_dig_node(pos)
		minetest.swap_node(pos, {name = node.name, param2 = new_param2})
		local tube_dir = techage.side_to_outdir("R", new_param2)
		meta:set_int("tube_dir", tube_dir)
		Tube:after_place_node(pos, {tube_dir})
		Cable:after_place_node(pos)
	end,

	on_timer = on_timer,
	on_receive_fields = on_receive_fields,
	ta_preserve_nodedata = techage.preserve_nodedata,
	ta_restore_nodedata = techage.restore_nodedata,
	--preserve_metadata = techage.preserve_node,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return mConf.allow_conf_inv_put(pos, listname, index, stack, player)
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return mConf.allow_conf_inv_take(pos, listname, index, stack, player)
	end,

	ta_can_remove = function(pos, digger)
		if minetest.is_protected(pos, digger:get_player_name()) then
			return false
		end
		local inv = M(pos):get_inventory()
		if inv:is_empty("main") then
			return true
		else
			minetest.record_protection_violation(pos, digger:get_player_name())
			return false
		end
	end,

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		local mem = techage.get_mem(pos)
		if is_empty(pos, mem) then
			return true
		else
			minetest.record_protection_violation(pos, player:get_player_name())
			return false
		end
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		--techage.remove_node(pos, oldnode, oldmetadata)
		--techage.post_remove_node(pos)
		Tube:after_dig_node(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:ta5_digitizer_act", {
	description = DESC,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_in_out.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		{
			name = "techage_appl_digitizer_on4.png^[transformR180]^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.2,
			},
		},
		{
			name = "techage_appl_digitizer_on4.png^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.2,
			},
		},
		},

	on_timer = on_timer,
	on_receive_fields = on_receive_fields,

	on_rightclick = function(pos, node, clicker)
		local nvm = techage.get_nvm(pos)
		techage.set_activeformspec(pos, clicker)
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return 0
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	is_ground_content = false,
	drop = "",
	diggable = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_glass_defaults(),
})

techage.register_node({"techage:ta5_digitizer_pas", "techage:ta5_digitizer_act"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "pull" then
			local nvm = techage.get_nvm(pos)
			if not techage.is_running(nvm) and configured_item(pos) then
				nvm.opmode = 1
				State:start(pos, nvm)
				return true
			end
			return false
		elseif topic == "push" then
			local nvm = techage.get_nvm(pos)
			if not techage.is_running(nvm) and configured_item(pos) then
				nvm.opmode = 2
				State:start(pos, nvm)
				return true
			end
			return false
		elseif topic == "config" then
			local nvm = techage.get_nvm(pos)
			if techage.is_running(nvm) then
				State:stop(pos, nvm)
			end
			if payload and type(payload) == "string" then
				config_item(pos, payload)
				return true
			end
			return false
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return State:on_beduino_request_data(pos, topic, payload)
	end,
})

power.register_nodes({"techage:ta5_digitizer_pas", "techage:ta5_digitizer_act"}, Cable, "con", {"B", "L", "F", "D", "U"})
Tube:set_valid_sides({"techage:ta5_digitizer_pas", "techage:ta5_digitizer_act"}, {"R"})

-- techage.register_node({"techage:tiny_generator", "techage:tiny_generator_on"}, {
-- 	on_push_item = function(pos, in_dir, stack)
-- 		return in_dir == M(pos):get_int("pull_dir") and techage.safe_push_items(pos, in_dir, stack)
-- 	end,
-- 	is_pusher = true, -- is a pulling/pushing node

-- 	on_recv_message = function(pos, src, topic, payload)
-- 		if topic == "pull" then -- Deprecated command, use config/limit/start instead
-- 			local nvm = techage.get_nvm(pos)
-- 			CRD(pos).State:stop(pos, nvm)
-- 			nvm.item_count = math.min(configured_item(pos, payload), 12)
-- 			nvm.rmt_num = src
-- 			CRD(pos).State:start(pos, nvm)
-- 			return true
-- 		elseif topic == "config" then  -- Set item type
-- 			local nvm = techage.get_nvm(pos)
-- 			CRD(pos).State:stop(pos, nvm)
-- 			configured_item(pos, payload)
-- 			return true
-- 		elseif topic == "limit" then  -- Set push limit
-- 			local nvm = techage.get_nvm(pos)
-- 			CRD(pos).State:stop(pos, nvm)
-- 			set_limit(pos, nvm, payload)
-- 			return true
-- 		elseif topic == "count" then  -- Get number of push items
-- 			local nvm = techage.get_nvm(pos)
-- 			return nvm.num_items or 0
-- 		else
-- 			return CRD(pos).State:on_receive_message(pos, topic, payload)
-- 		end
-- 	end,
-- 	on_beduino_receive_cmnd = function(pos, src, topic, payload)
-- 		if topic == 65 then  -- Set item type
-- 			local nvm = techage.get_nvm(pos)
-- 			CRD(pos).State:stop(pos, nvm)
-- 			configured_item(pos, payload)
-- 			return 0
-- 		elseif topic == 68 or topic == 20 then  -- Set push limit
-- 			local nvm = techage.get_nvm(pos)
-- 			CRD(pos).State:stop(pos, nvm)
-- 			set_limit(pos, nvm, payload[1])
-- 			return 0
-- 		else
-- 			local nvm = techage.get_nvm(pos)
-- 			if nvm.limit then
-- 				nvm.num_items = 0
-- 			end
-- 			return CRD(pos).State:on_beduino_receive_cmnd(pos, topic, payload)
-- 		end
-- 	end,
-- 	on_beduino_request_data = function(pos, src, topic, payload)
-- 		if topic == 150 then  -- Get number of pushed items
-- 			local nvm = techage.get_nvm(pos)
-- 			return 0, {nvm.num_items or 0}
-- 		else
-- 			return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
-- 		end
-- 	end,
