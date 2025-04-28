--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 SynthVault
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
local STANDBY_TICKS = 2
local COUNTDOWN_TICKS = 64
local NUM_ITEMS = 2
local VAULT_SLOTS = 8
local VAULT_SIZE  = 100000
local PWR_NEEDED = 24
local EX_POINTS = 50
local DESC = S("TA5 SynthVault")

local function store_items(pos, mem, force)
	mem.cycle_cnt = (mem.cycle_cnt or 0) + 1
	if force or mem.cycle_cnt > 10 then
		print("store_items", P2S(pos))
		M(pos):set_string("items", minetest.serialize(mem.items))
		mem.cycle_cnt = 0
	end
end

local function restore_items(pos, mem)
	if mem.items == nil then
		local meta = M(pos)
		if meta:contains("items") then
			mem.items = minetest.deserialize(meta:get_string("items"))
		else
			mem.items = {}
		end
	end
end

local function item_image(x, y, itemname, item_count)
	local text = minetest.formspec_escape(ItemStack(itemname):get_description())
	local tooltip = "tooltip["..x..","..y..";1,1;"..text..";#0C3D32;#FFFFFF]"
	local box = "box[" .. (x + 1.2) .. "," .. (y + 0.2) .. ";2,0.6;#808080]"
	local label = "label[" .. (x + 1.2) .. "," .. (y + 0.5) .. ";" .. string.format("%8d", item_count) .. "]"

	return "box[" .. x .. "," .. y .. ";1,1;#808080]" ..
		"style_type[label;font=mono]" ..
		"item_image[" .. x .. "," .. y .. ";1,1;" .. itemname .. "]" ..
		tooltip .. box .. label
end

local function formspec1(self, pos, nvm)
	local opmode = nvm.opmode or 1
	return "formspec_version[8]" ..
		"size[10.2,9.6]" ..
		"tabheader[0,0;tab;" .. S("Control,Vault") .. ";1;;true]" ..
		"box[0.2,0.2;9.8,0.5;#c6e8ff]" ..
		"label[0.5,0.45;" .. minetest.colorize( "#000000", DESC) .. "]" ..
		"label[5.7,1.5;" .. S("Configured\nItem") .. "]" ..
		"list[context;main;4.5,1.2;1,1;]" ..
		"image[2.5,1;1,1;"..techage.get_power_image(pos, nvm) .. "]" ..
		"image_button[2.5,2.5;1,1;" .. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[2.5,2.5;1,1;" .. self:get_state_tooltip(nvm) .. "]" ..
		"dropdown[4.5,3;4,0.6;opmode;" .. S("Digitize") .. "," .. S("Reassemble") .. ";" .. opmode .. ";true]" .. 
		"list[current_player;main;0.2,4.4;8,4;]" ..
		"listring[context;main]" ..
		"listring[current_player;main]"
end

local function formspec2(self, pos, nvm)
	local mem = techage.get_mem(pos)
	restore_items(pos, mem)
	local tbl = {}
	local idx = 1
	for key, val in pairs(mem.items) do
		if idx % 2 == 1 then
			tbl[#tbl + 1] = item_image(1, (idx + 2) * 0.6, key, val)
		else
			tbl[#tbl + 1] = item_image(6, (idx + 1) * 0.6, key, val)
		end
		idx = idx + 1
	end
	return "formspec_version[8]" ..
		"size[10.2,9.6]" ..
		"tabheader[0,0;tab;" .. S("Control,Vault") .. ";2;;true]" ..
		"box[0.2,0.2;9.8,0.5;#c6e8ff]" ..
		"label[0.5,0.45;" .. minetest.colorize( "#000000", DESC) .. "]" ..
		table.concat(tbl, "")
end

local function formspec(self, pos, nvm)
	if nvm.fs_tab2 then
		return formspec2(self, pos, nvm)
	else
		return formspec1(self, pos, nvm)
	end
end

local function add_item(mem, item_name, item_count)
	local size = 0
	local keys = {}
	for key, val in pairs(mem.items) do
		size = size + 1
		keys[#keys + 1] = key
	end

	if size >= VAULT_SLOTS then
		return false
	end
	mem.items[item_name] = item_count
	mem.keys = table.sort(keys)
	return true
end

local function stop_node(pos, nvm, state)
	local mem = techage.get_mem(pos)
	store_items(pos, mem, true)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta5_synthvault_pas",
	node_name_active = "techage:ta5_synthvault_act",
	cycle_time = CYCLE_TIME,
	infotext_name = DESC,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	stop_node = stop_node,
})

local function consume_power(pos, nvm)
	if techage.needs_power(nvm) then
		local taken = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if techage.is_running(nvm) then
			if taken < PWR_NEEDED then
				State:nopower(pos, nvm)
			else
				return true  -- keep running
			end
		elseif taken == PWR_NEEDED then
			State:start(pos, nvm)
		end
	end
end

local function on_receive_fields(pos, formname, fields, player)
	print("on_receive_fields", dump(fields))
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	print("on_receive_fields", dump(fields))
	if fields.tab == "1" then
		nvm.fs_tab2 = false
		meta:set_string("formspec", formspec(State, pos, nvm))
		return
	elseif fields.tab == "2" then
		nvm.fs_tab2 = true
		meta:set_string("formspec", formspec(State, pos, nvm))
		return
	else
		if fields.opmode then
			nvm.opmode = tonumber(fields.opmode)
		end
		State:state_button_event(pos, nvm, fields)
	end
end

local function digitize(pos, nvm, stack)
	local item_name = stack and stack:get_name() or nil
	local tube_dir = M(pos):get_int("tube_dir")
	local items = techage.pull_items(pos, tube_dir, NUM_ITEMS, item_name)
	if items ~= nil then
		item_name = items:get_name()
		local item_count = items:get_count()
		local ndef = minetest.registered_items[item_name] or minetest.registered_nodes[item_name]
		if ndef then
			print("Item name", item_name)
			if item_count == 1 then
				local meta = items:get_meta()
				local data = meta:to_table()
				if next(data.fields) or items:get_wear() > 0 then
					techage.unpull_items(pos, tube_dir, items)
					return true
				end
			end
			local mem = techage.get_mem(pos)
			restore_items(pos, mem)
			if mem.items[item_name] then
				if mem.items[item_name] + item_count <= VAULT_SIZE then
					mem.items[item_name] = mem.items[item_name] + item_count
					store_items(pos, mem)
					State:keep_running(pos, nvm, COUNTDOWN_TICKS)
				else
					techage.unpull_items(pos, tube_dir, items)
					State:idle(pos, nvm)
				end
			elseif add_item(mem, item_name, item_count) then
				store_items(pos, mem)
				State:keep_running(pos, nvm, COUNTDOWN_TICKS)
			else
				techage.unpull_items(pos, tube_dir, items)
				State:idle(pos, nvm)
			end
			if techage.is_activeformspec(pos) then
				print("formspec")
				M(pos):set_string("formspec", formspec(State, pos, nvm))
			end
		end
	end
	return true
end

local function reassemble(pos, nvm, stack)
end

minetest.register_node("techage:ta5_synthvault_pas", {
	description = DESC,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_in_out.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_turbine.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_turbine.png^techage_frame_ta5.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local node = minetest.get_node(pos)
		local tube_dir = techage.side_to_outdir("R", node.param2)
		local number = techage.add_node(pos, "techage:ta5_synthvault_pas")
		State:node_init(pos, nvm, number)
		meta:set_int("tube_dir", tube_dir)
		meta:set_string("owner", placer:get_player_name())
		Tube:after_place_node(pos, {tube_dir})
		Cable:after_place_node(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 1)
		nvm.items = {}
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

	on_receive_fields = on_receive_fields,

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

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
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

minetest.register_node("techage:ta5_synthvault_act", {
	description = DESC,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_in_out.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		{
			name = "techage_appl_turbine4.png^[transformR180]^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		{
			name = "techage_appl_turbine4.png^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		},

	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		print("on_timer", nvm.techage_countdown)
		consume_power(pos, nvm)
		if State:is_active(nvm) then
			print("on_timer: active")
			if nvm.opmode == 1 then
				print("on_timer: digitize")
				local inv = M(pos):get_inventory()
				local stack = inv:get_stack("main", 1)
				return digitize(pos, nvm, stack)
			elseif nvm.opmode == 2 then
				print("on_timer: reassemble")
				local inv = M(pos):get_inventory()
				local stack = inv:get_stack("main", 1)
				return reassemble(pos, nvm, stack)
			end
			return true
		end
		store_items(pos, mem, true)
		return false
	end,

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

techage.register_node({"techage:ta5_synthvault_pas", "techage:ta5_synthvault_act"}, {
	on_recv_message = function(pos, src, topic, payload)
		return CRD(pos).State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
	end,
})

power.register_nodes({"techage:ta5_synthvault_pas", "techage:ta5_synthvault_act"}, Cable, "con", {"B", "L", "F", "D", "U"})
Tube:set_valid_sides({"techage:ta5_synthvault_pas", "techage:ta5_synthvault_act"}, {"R"})
