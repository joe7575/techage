--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2 Steam Engine Boiler

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")


local CYCLE_TIME = 4
local HEAT_STEP = 10
local WATER_CONSUMPTION = 2
local MAX_WATER = 10
local POWER = 10

local Water = {
	["bucket:bucket_river_water"] = true,
	["bucket:bucket_water"] = true,
	["bucket:bucket_empty"] = true,
}

local function formspec(mem)
	local temp = mem.temperature or 20
	local button = mem.running and I("Stop") or I("Start")
	return "size[8,7]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image_button[0,0.2;1,1;techage_form_inventory.png;storage;;true;false;]"..
		"list[context;water;1,0.2;1,1;]"..
		"image_button[0,1.6;1,1;techage_form_input.png;input;;true;false;]"..
		"list[context;input;1,1.6;1,1;]"..		
		"image[1,1.6;1,1;bucket_water.png]"..
		"image[1,1.6;1,1;techage_form_mask.png]"..
		"image[3,0.5;1,2;techage_form_temp_bg.png^[lowpart:"..
		temp..":techage_form_temp_fg.png]"..
		"image[4,0.5;1,2;"..techage.generator_formspec_level(mem)..
		"button[6,0.5;2,1;start;"..button.."]"..
		"button[6,1.5;2,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		"listring[current_name;water]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 3)
end

local function can_dig(pos, player)
	local inv = M(pos):get_inventory()
	local mem = tubelib2.get_mem(pos)
	return inv:is_empty("water") and inv:is_empty("input") and not mem.running
end

local function move_to_water(pos)
	local inv = M(pos):get_inventory()
	local water_stack = inv:get_stack("water", 1)
	local input_stack = inv:get_stack("input", 1)
	
	if input_stack:get_name() == "bucket:bucket_empty" and input_stack:get_count() == 1 then
		if water_stack:get_count() > 0 then
			water_stack:set_count(water_stack:get_count() - 1)
			input_stack = ItemStack("bucket:bucket_water")
			inv:set_stack("water", 1, water_stack)
			inv:set_stack("input", 1, input_stack)
		end
	elseif water_stack:get_count() < MAX_WATER then
		if water_stack:get_count() == 0 then
			water_stack = ItemStack("default:water_source")
		else
			water_stack:set_count(water_stack:get_count() + 1)
		end
		input_stack = ItemStack("bucket:bucket_empty")
		inv:set_stack("water", 1, water_stack)
		inv:set_stack("input", 1, input_stack)
	end
end

local function start_boiler(pos)
	local mem = tubelib2.get_mem(pos)
	mem.water_level = mem.water_level or 0
	local inv = M(pos):get_inventory()
	local water_stack = inv:get_stack("water", 1)
	print("trigger_boiler", mem.fire_trigger, mem.water_level, water_stack:get_count())
	if mem.fire_trigger and (mem.water_level > 0 or water_stack:get_count() > 0) then
		if not minetest.get_node_timer(pos):is_started() then
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "input" and Water[stack:get_name()] then
		start_boiler(pos)
		return stack:get_count()
	end
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "input" then
		return stack:get_count()
	end
	return 0
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	if fields.update then
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("formspec", formspec(mem))
	end

	if fields.start then
		local mem = tubelib2.get_mem(pos)
		mem.running = not (mem.running or false)
		if mem.running then
			techage.generator_on(pos, POWER)
		else
			techage.generator_off(pos)
		end
		M(pos):set_string("formspec", formspec(mem))
	end
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(mem))
end

local function get_water(pos)
	local inv = M(pos):get_inventory()
	local items = inv:get_stack("water", 1)
	if items:get_count() > 0 then
		local taken = items:take_item(1)
		inv:set_stack("water", 1, items)
		return true
	end
	return false
end

local function node_timer(pos)
	local mem = tubelib2.get_mem(pos)
	mem.temperature = mem.temperature or 20
	mem.water_level = math.max((mem.water_level or 0) - WATER_CONSUMPTION, 0)
	
	print(mem.fire_trigger, mem.running, mem.temperature, mem.water_level)
	
	if mem.fire_trigger then
		mem.temperature = math.min(mem.temperature + HEAT_STEP, 100)
	else
		mem.temperature = math.max(mem.temperature - HEAT_STEP, 20)
	end
	
	if mem.water_level == 0 then
		if get_water(pos) then
			mem.water_level = 100
		else
			mem.temperature = 20
		end
	end
	
	if mem.temperature > 80 and mem.running then
		techage.generator_on(pos, POWER)
	else
		techage.generator_off(pos)
	end
	mem.fire_trigger = false
	return mem.temperature > 20
end


minetest.register_node("techage:boiler", {
	description = I("TA2 Boiler"),
	tiles = {"techage_boiler.png"},
	drawtype = "mesh",
	mesh = "techage_boiler.obj",
	selection_box = {
		type = "fixed",
		fixed = {-10/32, -16/32, -10/32, 10/32, 46/32, 10/32},
	},
	
	can_dig = can_dig,
	on_timer = node_timer,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	
	techage = {
		network = techage.SteamPipe,
		power_consumption = function(pos, dir)
			techage.generator_power_consumption(pos, dir)
		end,
		trigger_boiler = function(pos)
			local mem = tubelib2.get_mem(pos)
			mem.fire_trigger = true
			start_boiler(pos)
		end,
	},
	
	on_destruct = function(pos)
		techage.generator_on_destruct({x=pos.x, y=pos.y+1, z=pos.z})
	end,
	
	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('water', 1)
		inv:set_size('input', 1)
		local node = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		if node.name ~= "air" then
			return
		end
		minetest.add_node({x=pos.x, y=pos.y+1, z=pos.z}, {name = "techage:boiler2", param2 = minetest.get_node(pos).param2})
	end,

	after_place_node = function(pos, placer, pointed_thing)
		techage.generator_after_place_node({x=pos.x, y=pos.y+1, z=pos.z}, placer)
		local mem = tubelib2.get_mem(pos)
		mem.running = false
		mem.water_level = 0
		mem.temperatur = 20
		M(pos):set_string("formspec", formspec(mem))
	end,
	
	on_metadata_inventory_put = function(pos)
		minetest.after(0.5, move_to_water, pos)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local node = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		if node.name == "techage:boiler2" then
			minetest.remove_node({x=pos.x, y=pos.y+1, z=pos.z})
			techage.generator_after_dig_node({x=pos.x, y=pos.y+1, z=pos.z}, oldnode, oldmetadata, digger)
		end
	end,

	paramtype2 = "facedir",
	groups = {cracky=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

-- boiler2 
minetest.register_node("techage:boiler2", {
	description = ("TA2 Boiler"),
	tiles = {"techage_boiler2.png"},
	drawtype = "mesh",
	mesh = "techage_boiler.obj",
	selection_box = {
		type = "fixed",
		fixed = {-10/32, -16/32, -10/32, 10/32, 16/32, 10/32},
	},
	
	techage = {
		network = techage.SteamPipe,
		power_consumption = function(pos, dir)
			techage.generator_power_consumption({x=pos.x, y=pos.y-1, z=pos.z}, dir)
		end,
	},
	
	after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir) 
		techage.generator_after_tube_update(node, 
				{x=pos.x, y=pos.y-1, z=pos.z}, out_dir, peer_pos, peer_in_dir)
	end,
	
	diggable = false,
	--pointable = false,
	groups = {not_in_creative_inventory = 1},
})

