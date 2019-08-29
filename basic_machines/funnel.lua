--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Funnel
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2

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

local function formspec()
	return "size[9,7]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;main;0.5,0;8,2;]"..
	"list[current_player;main;0.5,3.3;8,4;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
end

local function scan_for_objects(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local lua_entity = object:get_luaentity()
		if not object:is_player() and lua_entity and lua_entity.name == "__builtin:item" then
			local obj_pos = object:getpos()
			if lua_entity.itemstring ~= "" and ((obj_pos.y - pos.y) >= 0.4) then
				local stack = ItemStack(lua_entity.itemstring)
				if inv:room_for_item("main", stack) then
					inv:add_item("main", stack)
					object:remove()
				end
			end
			
		end
	end
	return true
end

minetest.register_node("techage:ta3_funnel", {
	description = "TA3 Funnel",
	tiles = {
		-- up, down, right, left, back, front
	"techage_filling_ta3.png^techage_appl_funnel_top.png^techage_frame_ta3_top.png",
	"techage_filling_ta3.png^techage_frame_ta3.png",
	"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_outp.png",
	"techage_filling_ta3.png^techage_frame_ta3.png",
	"techage_filling_ta3.png^techage_appl_funnel.png^techage_frame_ta3.png",
	"techage_filling_ta3.png^techage_appl_funnel.png^techage_frame_ta3.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16, 8/16, -6/16},
			{-8/16, -8/16,  6/16,  8/16, 8/16,  8/16},
			{-8/16, -8/16, -8/16, -6/16, 8/16,  8/16},
			{ 6/16, -8/16, -8/16,  8/16, 8/16,  8/16},
			{-6/16, -8/16, -6/16,  6/16, 4/16,  6/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,   8/16, 8/16, 8/16},
	},

	on_construct = function(pos)
		local meta =  M(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 16)
	end,
	
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local own_num = techage.add_node(pos, "techage:ta3_funnel")
		local node = minetest.get_node(pos)
		meta:set_string("node_number", own_num)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", "TA3 Funnel "..own_num)
		meta:set_string("formspec", formspec())
		meta:set_int("pull_dir", techage.side_to_indir("R", node.param2))
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_timer = scan_for_objects,
	on_rotate = screwdriver.disallow,
		
	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		local inv = M(pos):get_inventory()
		return inv:is_empty("main")
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos)
	end,
	
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


techage.register_node({"techage:ta3_funnel"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(inv, "main", num)
		end
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "main", stack)
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})


minetest.register_craft({
	output = "techage:ta3_funnel",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"group:wood", "default:mese_crystal", "techage:tubeS"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
	},
})

techage.register_entry_page("ta3m", "funnel",
	S("TA3 Funnel"), 
	S("The Funnel collects dropped items and stores them in its inventory.@n"..
		"Items are sucked up when they are dropped on top of the funnel block.@n"..
		"The scan radius is 1 m."), 
	"techage:ta3_funnel")

