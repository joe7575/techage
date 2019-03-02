--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	distributor.lua:
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local N = minetest.get_node

local NUM_FILTER_ELEM = 6
local NUM_FILTER_SLOTS = 4

local COUNTDOWN_TICKS = 4
local STANDBY_TICKS = 8
local CYCLE_TIME = 2

local function formspec(self, pos, meta)
	local filter = minetest.deserialize(meta:get_string("filter")) or {false,false,false,false}
	return "size[10.5,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;2,4;]"..
	"image[2,1.5;1,1;tubelib_gui_arrow.png]"..
	"image_button[2,3;1,1;"..self:get_state_button_image(meta)..";state_button;]"..
	"checkbox[3,0;filter1;On;"..dump(filter[1]).."]"..
	"checkbox[3,1;filter2;On;"..dump(filter[2]).."]"..
	"checkbox[3,2;filter3;On;"..dump(filter[3]).."]"..
	"checkbox[3,3;filter4;On;"..dump(filter[4]).."]"..
	"image[4,0;0.3,1;tubelib_red.png]"..
	"image[4,1;0.3,1;tubelib_green.png]"..
	"image[4,2;0.3,1;tubelib_blue.png]"..
	"image[4,3;0.3,1;tubelib_yellow.png]"..
	"list[context;red;4.5,0;6,1;]"..
	"list[context;green;4.5,1;6,1;]"..
	"list[context;blue;4.5,2;6,1;]"..
	"list[context;yellow;4.5,3;6,1;]"..
	"list[current_player;main;1.25,4.5;8,4;]"..
	"listring[context;src]"..
	"listring[current_player;main]"
end

local State = tubelib.NodeStates:new({
	node_name_passive = "tubelib:distributor",
	node_name_active = "tubelib:distributor_active",
	node_name_defect = "tubelib:distributor_defect",
	infotext_name = "Tubelib Distributor",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	aging_factor = 10,
	formspec_func = formspec,
})

-- Return a key/value table with all items and the corresponding stack numbers
local function invlist_content_as_kvlist(list)
	local res = {}
	for idx,items in ipairs(list) do
		local name = items:get_name()
		if name ~= "" then
			res[name] = idx
		end
	end
	return res
end

-- Return the total number of list entries
local function invlist_num_entries(list)
	local res = 0
	for _,items in ipairs(list) do
		local name = items:get_name()
		if name ~= "" then
			res = res + items:get_count()
		end
	end
	return res
end

-- Return a gapless table with all items
local function invlist_entries_as_list(list)
	local res = {}
	for _,items in ipairs(list) do
		if items:get_count() > 0 then
			res[#res+1] = {items:get_name(), items:get_count()}
		end
	end
	return res
end


local function AddToTbl(kvTbl, new_items)
	for _, l in ipairs(new_items) do 
		kvTbl[l[1]] = true 
	end
	return kvTbl
end

-- return the number of items to be pushed to an unconfigured slot
local function num_items(moved_items, name, filter_item_names, rejected_item_names)
	if filter_item_names[name] == nil then  -- not configured in one filter?
		if moved_items < MAX_NUM_PER_CYC then
			return math.min(4, MAX_NUM_PER_CYC - moved_items)
		end
	end
	if rejected_item_names[name] then  -- rejected item from another slot?
		if moved_items < MAX_NUM_PER_CYC then
			return math.min(rejected_item_names[name], MAX_NUM_PER_CYC - moved_items)
		end
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local meta = M(pos)
	local inv = meta:get_inventory()
	local list = inv:get_list(listname)
	
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "src" then
		if State:get_state(M(pos)) == tubelib.STANDBY then
			State:start(pos, meta)
		end
		return stack:get_count()
	elseif invlist_num_entries(list) < MAX_NUM_PER_CYC then
		return stack:get_count()
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

local SlotColors = {"red", "green", "blue", "yellow"}
local Num2Ascii = {"B", "L", "F", "R"} -- color to side translation
local FilterCache = {} -- local cache for filter settings

local function filter_settings(pos)
	local hash = minetest.hash_node_position(pos)
	local meta = M(pos)
	local inv = meta:get_inventory()
	local filter = minetest.deserialize(meta:get_string("filter")) or {false,false,false,false}
	local kvFilterItemNames = {} -- {<item:name> = true,...}
	local kvSide2ItemNames = {} -- {"F" = {<item:name>,...},...}
	
	-- collect all filter settings
	for idx,slot in ipairs(SlotColors) do
		local side = Num2Ascii[idx]
		if filter[idx] == true then
			local list = inv:get_list(slot)
			local filter = invlist_entries_as_list(list)
			AddToTbl(kvFilterItemNames, filter)
			kvSide2ItemNames[side] = filter
		end
	end
	
	FilterCache[hash] = {
		kvFilterItemNames = kvFilterItemNames, 
		kvSide2ItemNames = kvSide2ItemNames,
		kvRejectedItemNames = {},
	}
end

-- move items from configured filters to the output
local function distributing(pos, meta)
	local player_name = meta:get_string("player_name")
	local slot_idx = meta:get_int("slot_idx") or 1
	meta:set_int("slot_idx", (slot_idx + 1) % NUM_FILTER_SLOTS)
	local side = Num2Ascii[slot_idx+1]
	local listname = SlotColors[slot_idx+1]
	local inv = meta:get_inventory()
	local list = inv:get_list("src")
	local kvSrc = invlist_content_as_kvlist(list)
	local counter = minetest.deserialize(meta:get_string("item_counter")) or 
			{red=0, green=0, blue=0, yellow=0}
	
	-- calculate the filter settings only once
	local hash = minetest.hash_node_position(pos)
	if FilterCache[hash] == nil then
		filter_settings(pos)
	end
	
	-- read data from Cache 
	-- all filter items as key/value  {<item:name> = true,...}
	local kvFilterItemNames = FilterCache[hash].kvFilterItemNames
	-- filter items of one slot as list  {{<item:name>, <num-items>},...}
	local items = FilterCache[hash].kvSide2ItemNames[side]
	-- rejected items from other filter slots
	local rejected = FilterCache[hash].kvRejectedItemNames
	
	if items == nil then return end
	
	local moved_items_total = 0
	if next(items) then
		for _,item in ipairs(items) do
			local name, num = item[1], item[2]
			if kvSrc[name] then
				local item = tubelib.get_this_item(meta, "src", kvSrc[name], num) -- <<=== tubelib
				if item then
					if not tubelib.push_items(pos, side, item, player_name) then -- <<=== tubelib
						tubelib.put_item(meta, "src", item)
						rejected[name] = num
					else
						counter[listname] = counter[listname] + num
						moved_items_total = moved_items_total + num
					end
				end
			end
		end
	end
	
	-- move additional items from unconfigured filters to the output
	if next(items) == nil then
		local moved_items = 0
		for name,_ in pairs(kvSrc) do
			local num = num_items(moved_items, name, kvFilterItemNames, rejected)
			if num then
				local item = tubelib.get_this_item(meta, "src", kvSrc[name], num) -- <<=== tubelib
				if item then
					if not tubelib.push_items(pos, side, item, player_name) then -- <<=== tubelib
						tubelib.put_item(meta, "src", item)
					else
						counter[listname] = counter[listname] + num
						moved_items = moved_items + num
						moved_items_total = moved_items_total + num
					end
				end
			end
		end
		-- delete list for next slot round
		if moved_items > 0 then
			FilterCache[hash].kvRejectedItemNames = {}
		end
	end
	meta:set_string("item_counter", minetest.serialize(counter))
	if moved_items_total > 0 then
		State:keep_running(pos, meta, COUNTDOWN_TICKS, moved_items_total)
	else
		State:idle(pos, meta)
	end
end

-- move items to the output slots
local function keep_running(pos, elapsed)
	local meta = M(pos)
	distributing(pos, meta)
	return State:is_active(meta)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local meta = M(pos)
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
	
	if fields.state_button ~= nil then
		State:state_button_event(pos, fields)
	else
		meta:set_string("formspec", formspec(State, pos, meta))
	end
end

-- tubelib command to turn on/off filter channels
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
	
	meta:set_string("formspec", formspec(State, pos, meta))
	return true
end

minetest.register_node("tubelib:distributor", {
	description = "Tubelib Distributor",
	tiles = {
		-- up, down, right, left, back, front
		'tubelib_distributor.png',
		'tubelib_front.png',
		'tubelib_distributor_yellow.png',
		'tubelib_distributor_green.png',
		"tubelib_distributor_red.png",
		"tubelib_distributor_blue.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local number = tubelib.add_node(pos, "tubelib:distributor") -- <<=== tubelib
		local filter = {false,false,false,false}
		meta:set_string("filter", minetest.serialize(filter))
		State:node_init(pos, number)
		meta:set_string("player_name", placer:get_player_name())

		local inv = meta:get_inventory()
		inv:set_size('src', 8)
		inv:set_size('yellow', 6)
		inv:set_size('green', 6)
		inv:set_size('red', 6)
		inv:set_size('blue', 6)
		meta:set_string("item_counter", minetest.serialize({red=0, green=0, blue=0, yellow=0}))
	end,

	on_receive_fields = on_receive_fields,

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		local inv = M(pos):get_inventory()
		return inv:is_empty("src")
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		tubelib.remove_node(pos) -- <<=== tubelib
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
	end,
	
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,

	on_timer = keep_running,
	on_rotate = screwdriver.disallow,
	
	drop = "",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_node("tubelib:distributor_active", {
	description = "Tubelib Distributor",
	tiles = {
		-- up, down, right, left, back, front
		{
			image = "tubelib_distributor_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		'tubelib_front.png',
		'tubelib_distributor_yellow.png',
		'tubelib_distributor_green.png',
		"tubelib_distributor_red.png",
		"tubelib_distributor_blue.png",
	},

	on_receive_fields = on_receive_fields,
	
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,

	on_timer = keep_running,
	on_rotate = screwdriver.disallow,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {crumbly=0, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("tubelib:distributor_defect", {
	description = "Tubelib Distributor",
	tiles = {
		-- up, down, right, left, back, front
		'tubelib_distributor.png',
		'tubelib_front.png',
		'tubelib_distributor_yellow.png^tubelib_defect.png',
		'tubelib_distributor_green.png^tubelib_defect.png',
		"tubelib_distributor_red.png^tubelib_defect.png",
		"tubelib_distributor_blue.png^tubelib_defect.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local number = tubelib.add_node(pos, "tubelib:distributor") -- <<=== tubelib
		State:node_init(pos, number)
		meta:set_string("player_name", placer:get_player_name())

		local filter = {false,false,false,false}
		meta:set_string("filter", minetest.serialize(filter))
		local inv = meta:get_inventory()
		inv:set_size('src', 8)
		inv:set_size('yellow', 6)
		inv:set_size('green', 6)
		inv:set_size('red', 6)
		inv:set_size('blue', 6)
		meta:set_string("item_counter", minetest.serialize({red=0, green=0, blue=0, yellow=0}))
		State:defect(pos, meta)
	end,

	on_receive_fields = on_receive_fields,

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		local inv = M(pos):get_inventory()
		return inv:is_empty("src")
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		tubelib.remove_node(pos) -- <<=== tubelib
	end,
	
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,

	on_rotate = screwdriver.disallow,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output = "tubelib:distributor 2",
	recipe = {
		{"group:wood", 		"default:steel_ingot",  "group:wood"},
		{"tubelib:tubeS", 	"default:mese_crystal",	"tubelib:tubeS"},
		{"group:wood", 		"default:steel_ingot",  "group:wood"},
	},
})


--------------------------------------------------------------- tubelib
tubelib.register_node("tubelib:distributor", 
	{"tubelib:distributor_active", "tubelib:distributor_defect"}, {
	on_pull_item = function(pos, side)
		return tubelib.get_item(M(pos), "src")
	end,
	on_push_item = function(pos, side, item)
		return tubelib.put_item(M(pos), "src", item)
	end,
	on_unpull_item = function(pos, side, item)
		return tubelib.put_item(M(pos), "src", item)
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
			local resp = State:on_receive_message(pos, topic, payload)
			if resp then
				return resp
			else
				return "unsupported"
			end
		end
	end,
	
	on_node_load = function(pos)
		State:on_node_load(pos)
	end,
	on_node_repair = function(pos)
		return State:on_node_repair(pos)
	end,
})	
--------------------------------------------------------------- tubelib
