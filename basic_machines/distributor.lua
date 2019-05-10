--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	TA2/TA3/TA4 Distributor
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local N = minetest.get_node
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local SRC_INV_SIZE = 8

local COUNTDOWN_TICKS = 10
local STANDBY_TICKS = 10
local CYCLE_TIME = 4

local function formspec(self, pos, mem)
	local filter = minetest.deserialize(M(pos):get_string("filter")) or {false,false,false,false}
	return "size[10.5,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;2,4;]"..
	"image[2,1.5;1,1;techage_form_arrow.png]"..
	"image_button[2,3;1,1;"..self:get_state_button_image(mem)..";state_button;]"..
	"checkbox[3,0;filter1;On;"..dump(filter[1]).."]"..
	"checkbox[3,1;filter2;On;"..dump(filter[2]).."]"..
	"checkbox[3,2;filter3;On;"..dump(filter[3]).."]"..
	"checkbox[3,3;filter4;On;"..dump(filter[4]).."]"..
	"image[4,0;0.3,1;techage_inv_red.png]"..
	"image[4,1;0.3,1;techage_inv_green.png]"..
	"image[4,2;0.3,1;techage_inv_blue.png]"..
	"image[4,3;0.3,1;techage_inv_yellow.png]"..
	"list[context;red;4.5,0;6,1;]"..
	"list[context;green;4.5,1;6,1;]"..
	"list[context;blue;4.5,2;6,1;]"..
	"list[context;yellow;4.5,3;6,1;]"..
	"list[current_player;main;1.25,4.5;8,4;]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(1.25,4.5)
end


--local Side2Color = {B="red", L="green", F="blue", R="yellow"}
local SlotColors = {"red", "green", "blue", "yellow"}
local Num2Ascii = {"B", "L", "F", "R"} 
local FilterCache = {} -- local cache for filter settings

local function filter_settings(pos)
	local meta = M(pos)
	local param2 = minetest.get_node(pos).param2
	local inv = meta:get_inventory()
	local filter = minetest.deserialize(meta:get_string("filter")) or {false,false,false,false}
	local ItemFilter = {}  -- {<item:name> = {dir,...}]
	local OpenPorts = {}  -- {dir, ...}
	
	-- collect all filter settings
	for idx,slot in ipairs(SlotColors) do
		if filter[idx] == true then
			local side = Num2Ascii[idx]
			local out_dir = techage.side_to_outdir(side, param2)
			if inv:is_empty(slot) then
				table.insert(OpenPorts, out_dir)
			else
				for _,stack in ipairs(inv:get_list(slot)) do
					local name = stack:get_name()
					if name ~= "" then
						if not ItemFilter[name] then
							ItemFilter[name] = {}
						end
						table.insert(ItemFilter[name], out_dir)
					end
				end
			end
		end
	end
	
	FilterCache[minetest.hash_node_position(pos)] = {
		ItemFilter = ItemFilter, 
		OpenPorts = OpenPorts,
	}
end

-- Return filter table and list of open ports.
-- (see test data)
local function get_filter_settings(pos)
--	local ItemFilter = {
--		["default:dirt"] = {1,2},
--		["default:cobble"] = {4},
--	}
--	local OpenPorts = {3}
--	return ItemFilter, OpenPorts
	
	local hash = minetest.hash_node_position(pos)
	if FilterCache[hash] == nil then
		filter_settings(pos)
	end
	return FilterCache[hash].ItemFilter, FilterCache[hash].OpenPorts
end


local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local inv = M(pos):get_inventory()
	local list = inv:get_list(listname)
	
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "src" then
		TRD(pos).State:start_if_standby(pos)
		return stack:get_count()
	elseif stack:get_count() == 1 and 
			(list[index]:get_count() == 0 or stack:get_name() ~= list[index]:get_name()) then
		filter_settings(pos)
		return 1
	end
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = M(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end


local function push_item(pos, filter, item_name, num_items, mem)
	local idx = 1
	local num_pushed = 0
	local num_ports = #filter
	local amount = math.floor(math.max((num_items + 1) / num_ports, 1))
	local successful = false
	while num_pushed < num_items do
		local push_dir = filter[idx]
		local num_to_push = math.min(amount, num_items - num_pushed)
		if techage.push_items(pos, push_dir, ItemStack(item_name.." "..num_to_push)) then
			num_pushed = num_pushed + num_to_push
			successful = true
			mem.port_counter[push_dir] = (mem.port_counter[push_dir] or 0) + num_to_push
		end
		idx = idx + 1
		if idx > num_ports then
			idx = 1
			if not successful then break end
		end
	end
	return num_pushed
end

-- move items to output slots
local function distributing(pos, inv, trd, mem)
	local item_filter, open_ports = get_filter_settings(pos)
	local sum_num_pushed = 0
	local num_pushed = 0
	
	-- start searching after last position
	local offs = mem.last_index or 1
	
	for i = 1, SRC_INV_SIZE do
		local idx = ((i + offs - 1) % 8) + 1
		local stack = inv:get_stack("src", idx)
		local item_name = stack:get_name()
		local num_items = stack:get_count()
		local num_to_push = math.min(trd.num_items - sum_num_pushed, num_items)
		num_pushed = 0
		
		if item_filter[item_name] then
			-- Push items based on filter
			num_pushed = push_item(pos, item_filter[item_name], item_name, num_to_push, mem)
		end
		if num_pushed == 0 and #open_ports > 0 then
			-- Push items based on open ports
			num_pushed = push_item(pos, open_ports, item_name, num_to_push, mem)
		end
			
		sum_num_pushed = sum_num_pushed + num_pushed
		stack:take_item(num_pushed)
		inv:set_stack("src", idx, stack)
		if sum_num_pushed >= trd.num_items then 
			mem.last_index = idx
			break 
		end
	end
	
	if num_pushed == 0 then
		trd.State:blocked(pos, mem)
	else
		trd.State:keep_running(pos, mem, COUNTDOWN_TICKS, 1)
	end
end

-- move items to the output slots
local function keep_running(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	mem.port_counter = mem.port_counter or {}
	local trd = TRD(pos)
	local inv = M(pos):get_inventory()
	if not inv:is_empty("src") then
		distributing(pos, inv, trd, mem)
	else
		trd.State:idle(pos, mem)
	end
	return trd.State:is_active(mem)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local meta = M(pos)
	local trd = TRD(pos)
	local filter = minetest.deserialize(meta:get_string("filter"))
	if fields.filter1 ~= nil then
		filter[1] = fields.filter1 == "true"
	elseif fields.filter2 ~= nil then
		filter[2] = fields.filter2 == "true"
	elseif fields.filter3 ~= nil then
		filter[3] = fields.filter3 == "true"
	elseif fields.filter4 ~= nil then
		filter[4] = fields.filter4 == "true"
	end
	meta:set_string("filter", minetest.serialize(filter))
	
	filter_settings(pos)
	
	local mem = tubelib2.get_mem(pos)
	if fields.state_button ~= nil then
		trd.State:state_button_event(pos, mem, fields)
	else
		meta:set_string("formspec", formspec(trd.State, pos, mem))
	end
end

-- techage command to turn on/off filter channels
local function change_filter_settings(pos, slot, val)
	local slots = {["red"] = 1, ["green"] = 2, ["blue"] = 3, ["yellow"] = 4}
	local meta = M(pos)
	local filter = minetest.deserialize(meta:get_string("filter"))
	local num = slots[slot] or 1
	if num >= 1 and num <= 4 then
		filter[num] = val == "on"
	end
	meta:set_string("filter", minetest.serialize(filter))
	
	filter_settings(pos)
	
	local mem = tubelib2.get_mem(pos)
	meta:set_string("formspec", formspec(TRD(pos).State, pos, mem))
	return true
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = M(pos):get_inventory()
	return inv:is_empty("src")
end

local tiles = {}
-- '#' will be replaced by the stage number
-- '{power}' will be replaced by the power PNG
tiles.pas = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_appl_distri.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_yellow.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_green.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_red.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_blue.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	{
		image = "techage_filling4_ta#.png^techage_appl_distri4.png^techage_frame4_ta#_top.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 1.0,
		},
	},
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_yellow.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_green.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_red.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_blue.png",
}
tiles.def = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_appl_distri.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_yellow.png^techage_appl_defect.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_green.png^techage_appl_defect.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_red.png^techage_appl_defect.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_distri_blue.png^techage_appl_defect.png",
}

local tubing = {
	on_pull_item = function(pos, in_dir, num)
		local inv = M(pos):get_inventory()
		return techage.get_items(inv, "src", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		local inv = M(pos):get_inventory()
		return techage.put_items(inv, "src", stack)
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local inv = M(pos):get_inventory()
		return techage.put_items(inv, "src", stack)
	end,
	on_recv_message = function(pos, topic, payload)
		if topic == "filter" then
			return change_filter_settings(pos, payload.slot, payload.val)
		elseif topic == "counter" then
			local meta = minetest.get_meta(pos)
			return minetest.deserialize(meta:get_string("item_counter")) or 
					{red=0, green=0, blue=0, yellow=0}
		elseif topic == "clear_counter" then
			local meta = minetest.get_meta(pos)
			meta:set_string("item_counter", minetest.serialize({red=0, green=0, blue=0, yellow=0}))
		else		
			local resp = TRD(pos).State:on_receive_message(pos, topic, payload)
			if resp then
				return resp
			else
				return "unsupported"
			end
		end
	end,
	
	on_node_load = function(pos)
		TRD(pos).State:on_node_load(pos)
	end,
	on_node_repair = function(pos)
		return TRD(pos).State:on_node_repair(pos)
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 = 
	techage.register_consumer("distributor", I("Distributor"), tiles, {
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		has_item_meter = true,
		aging_factor = 10,
		formspec = formspec,
		tubing = tubing,
		after_place_node = function(pos, placer)
			local meta = M(pos)
			local filter = {false,false,false,false}
			meta:set_string("filter", minetest.serialize(filter))
			local inv = meta:get_inventory()
			inv:set_size('src', 8)
			inv:set_size('yellow', 6)
			inv:set_size('green', 6)
			inv:set_size('red', 6)
			inv:set_size('blue', 6)
		end,
		can_dig = can_dig,
		node_timer = keep_running,
		on_receive_fields = on_receive_fields,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		
		on_metadata_inventory_move = function(pos, from_list, from_index, to_list)
			if from_list ~= "src" or to_list ~= "src" then
				filter_settings(pos)
			end
		end,
		on_metadata_inventory_put = function(pos, listname)
			if listname ~= "src" then
				filter_settings(pos)
			end
		end,
		on_metadata_inventory_take = function(pos, listname)
			if listname ~= "src" then
				filter_settings(pos)
			end
		end,
		
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,4,12,36},
	})

minetest.register_craft({
	output = node_name_ta2.." 2",
	recipe = {
		{"group:wood", "techage:iron_ingot", "group:wood"},
		{"techage:tubeS", "default:mese_crystal", "techage:tubeS"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
	},
})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "techage:iron_ingot", ""},
		{"", node_name_ta2, ""},
		{"", "techage:vacuum_tube", ""},
	},
})
