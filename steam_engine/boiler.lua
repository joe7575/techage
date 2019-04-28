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
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local CYCLE_TIME = 4
local STANDBY_TICKS = 2
local COUNTDOWN_TICKS = 2
local HEAT_STEP = 10
local WATER_CONSUMPTION = 0.5
local MAX_WATER = 10
local POWER_CAPACITY = 10

local Pipe = techage.SteamPipe
local generator = techage.generator


local Water = {
	["bucket:bucket_river_water"] = true,
	["bucket:bucket_water"] = true,
	["bucket:bucket_empty"] = true,
}

local function formspec(self, pos, mem)
	local temp = mem.temperature or 20
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
		"image[2,0.5;1,2;techage_form_temp_bg.png^[lowpart:"..
		temp..":techage_form_temp_fg.png]"..
		"image[7,0.5;1,2;"..generator.formspec_level(mem, mem.power_result)..
		"image_button[6,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"button[3,1.5;2,1;update;"..I("Update").."]"..
		"list[current_player;main;0,3;8,4;]"..
		"listring[current_name;water]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 3)
end

local function start_node(pos, mem, state)
	generator.turn_power_on(pos, POWER_CAPACITY)
end

local function stop_node(pos, mem, state)
	generator.turn_power_on(pos, 0)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:boiler2",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	has_item_meter = false,
	formspec_func = formspec,
	start_node = start_node,
	stop_node = stop_node,
})

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

local function water_temperature(pos, mem)
	mem.temperature = mem.temperature or 20
	if mem.fire_trigger then
		mem.temperature = math.min(mem.temperature + HEAT_STEP, 100)
	else
		mem.temperature = math.max(mem.temperature - HEAT_STEP, 20)
	end
	mem.fire_trigger = false
	
	if mem.water_level == 0 then
		if get_water(pos) then
			mem.water_level = 100
		else
			mem.temperature = 20
		end
	end
	return mem.temperature
end

local function steaming(pos, mem, temp)
	mem.water_level = math.max((mem.water_level or 0) - WATER_CONSUMPTION, 0)
	if temp >= 80 then
		if mem.power_result > 0 then
			State:keep_running(pos, mem, COUNTDOWN_TICKS)
		else
			State:fault(pos, mem)	
		end
	else
		State:stop(pos, mem)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local temp = water_temperature(pos, mem)
	if State:is_active(mem) then
		steaming(pos, mem, temp)
	end
	return mem.temperature > 20
end

local function turn_power_on(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	-- store result for formspec
	mem.power_result = sum
	if State:is_active(mem) and sum <= 0 then
		State:fault(pos, mem)
		-- No automatic turn on
		mem.power_capacity = 0
	end
	M(pos):set_string("formspec", formspec(State, pos, mem))
end
		
local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	State:state_button_event(pos, mem, fields)
	
	if fields.update then
		M(pos):set_string("formspec", formspec(State, pos, mem))
	end
end

		
local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
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
	
	if input_stack:get_name() == "bucket:bucket_empty" then
		if input_stack:get_count() == 1 then
			if water_stack:get_count() > 0 then
				water_stack:set_count(water_stack:get_count() - 1)
				input_stack = ItemStack("bucket:bucket_water")
				inv:set_stack("water", 1, water_stack)
				inv:set_stack("input", 1, input_stack)
			end
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


local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "input" and Water[stack:get_name()] then
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

minetest.register_node("techage:boiler1", {
	description = I("TA2 Boiler Base"),
	tiles = {"techage_boiler.png"},
	drawtype = "mesh",
	mesh = "techage_boiler.obj",
	selection_box = {
		type = "fixed",
		fixed = {-8/32, -16/32, -8/32, 8/32, 16/32, 8/32},
	},

	--paramtype2 = "facedir",
	groups = {cracky=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

-- boiler2: Main part, needed as generator
minetest.register_node("techage:boiler2", {
	description = I("TA2 Boiler Top"),
	tiles = {"techage_boiler2.png"},
	drawtype = "mesh",
	mesh = "techage_boiler.obj",
	selection_box = {
		type = "fixed",
		fixed = {-10/32, -48/32, -10/32, 10/32, 16/32, 10/32},
	},
	
	can_dig = can_dig,
	on_timer = node_timer,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	
	techage = {
		turn_on = turn_power_on,
		read_power_consumption = generator.read_power_consumption,
		power_network = Pipe,
		trigger_boiler = function(pos)
			local mem = tubelib2.get_mem(pos)
			mem.fire_trigger = true
			if not minetest.get_node_timer(pos):is_started() then
				minetest.get_node_timer(pos):start(CYCLE_TIME)
			end
		end,
		power_side = "U",
	},
	
	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('water', 1)
		inv:set_size('input', 1)
	end,
	
	after_place_node = function(pos, placer)
		local mem = generator.after_place_node(pos)
		State:node_init(pos, mem, "")
		local node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		if node.name == "techage:boiler1" then
			on_rightclick(pos)
		end
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		State:after_dig_node(pos, oldnode, oldmetadata, digger)
		generator.after_dig_node(pos, oldnode)
	end,
	
	after_tube_update = generator.after_tube_update,	
	
	on_metadata_inventory_put = function(pos)
		minetest.after(0.5, move_to_water, pos)
	end,
	
	--paramtype2 = "facedir",
	groups = {cracky=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techage:boiler1",
	recipe = {
		{"techage:iron_ingot", "", "techage:iron_ingot"},
		{"default:bronze_ingot", "", "default:bronze_ingot"},
		{"techage:iron_ingot", "default:bronze_ingot", "techage:iron_ingot"},
	},
})

minetest.register_craft({
	output = "techage:boiler2",
	recipe = {
		{"techage:iron_ingot", "techage:steam_pipeS", "techage:iron_ingot"},
		{"default:bronze_ingot", "", "default:bronze_ingot"},
		{"techage:iron_ingot", "", "techage:iron_ingot"},
	},
})
