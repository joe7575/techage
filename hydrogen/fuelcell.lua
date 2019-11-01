--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Fuel Cell

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Power = techage.ElectricCable
local power = techage.power

local CYCLE_TIME = 2
local STANDBY_TICKS = 5
local PWR_CAPA = 40
local PWR_UNITS_PER_HYDROGEN_ITEM = 240

local function formspec(self, pos, mem)
	return "size[8,6.6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[context;src;0.5,0;2,2;]"..
		"image[4,0;1,1;techage_form_arrow_fg.png^[transformR270]"..
		"image_button[5,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"button[3.1,1;1.8,1;update;"..S("Update").."]"..
		"image[6.5,0;1,2;"..power.formspec_power_bar(PWR_CAPA, mem.provided).."]"..
		"label[6.7,1.9;"..S("\\[ku\\]").."]"..
		"list[current_player;main;0,2.8;8,4;]" ..
		"listring[current_player;main]"..
		"listring[context;src]" ..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 2.8)
end

local function start_node(pos, mem, state)
	mem.running = true
	mem.provided = 0
	power.generator_start(pos, mem, PWR_CAPA)
end

local function stop_node(pos, mem, state)
	mem.running = false
	mem.provided = 0
	power.generator_stop(pos, mem)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_fuelcell",
	node_name_active = "techage:ta4_fuelcell_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = "TA4 Fuel Cell",
	start_node = start_node,
	stop_node = stop_node,
})

local function get_hydrogen(pos)
	local inv = M(pos):get_inventory()
	local taken = inv:remove_item("src", ItemStack("techage:hydrogen"))
	return taken:get_count() > 0
end

local function contains_hydrogen(pos)
	local inv = M(pos):get_inventory()
	return inv:contains_item("src", ItemStack("techage:hydrogen"))
end
	
-- converts hydrogen into power
local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	mem.num_pwr_units = mem.num_pwr_units or 0
	--print("fuelcell", mem.running, mem.provided, mem.num_pwr_units, techage.get_state_string(mem))
	if mem.running then
		if techage.needs_power(mem) then
			if mem.num_pwr_units <= 0 then
				if get_hydrogen(pos) then
					State:keep_running(pos, mem, 1, 0) -- count items
					mem.num_pwr_units = mem.num_pwr_units + PWR_UNITS_PER_HYDROGEN_ITEM
				else
					State:standby(pos, mem)
					mem.provided = 0
					power.generator_stop(pos, mem)
					M(pos):set_string("formspec", formspec(State, pos, mem))
					return true
				end
			end
			mem.provided = power.generator_alive(pos, mem)
			mem.num_pwr_units = mem.num_pwr_units - mem.provided
		else
			if contains_hydrogen(pos) then
				State:start(pos, mem)
				mem.provided = 0
				power.generator_start(pos, mem, PWR_CAPA)
				M(pos):set_string("formspec", formspec(State, pos, mem))
			end
		end
	end
	return mem.running
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

local function allow_metadata_inventory(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if stack:get_name() == "techage:hydrogen" then
		return stack:get_count()
	end
	return 0
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
end

minetest.register_node("techage:ta4_fuelcell", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inp.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_fuelcell.png^techage_appl_ctrl_unit.png",
	},

	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		local number = techage.add_node(pos, "techage:ta4_fuelcell")
		mem.running = false
		mem.num_pwr_units = 0
		State:node_init(pos, mem, number)
		local meta = M(pos)
		meta:set_string("formspec", formspec(State, pos, mem))
		local inv = meta:get_inventory()
		inv:set_size('src', 4)
	end,

	can_dig = function(pos, player)
		local inv = M(pos):get_inventory()
		return inv:is_empty("src")
	end,
	
	allow_metadata_inventory_put = allow_metadata_inventory,
	allow_metadata_inventory_take = allow_metadata_inventory,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	on_rightclick = on_rightclick,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
})

minetest.register_node("techage:ta4_fuelcell_on", {
	description = S("TA4 Fuel Cell"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inp.png",
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png^[transformFX",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_fuelcell4.png^techage_appl_ctrl_unit4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
	},

	allow_metadata_inventory_put = allow_metadata_inventory,
	allow_metadata_inventory_take = allow_metadata_inventory,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
	on_rightclick = on_rightclick,

	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	diggable = false,
	paramtype = "light",
	light_source = 6,
})

techage.power.register_node({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on"}, {
	conn_sides = {"R"},
	power_network  = Power,
	after_place_node = function(pos)
		local node = minetest.get_node(pos)
		local indir = techage.side_to_indir("L", node.param2)
		M(pos):set_int("in_dir", indir)
	end,	
})

techage.register_node({"techage:ta4_fuelcell", "techage:ta4_fuelcell_on"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("in_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(inv, "src", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("in_dir") == in_dir then
			local inv = M(pos):get_inventory()
			State:start_if_standby(pos)
			return techage.put_items(inv, "src", stack)
		end
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("in_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "src", stack)
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		return State:on_receive_message(pos, topic, payload)
	end,
})	

minetest.register_craft({
	output = "techage:ta4_fuelcell",
	recipe = {
		{'default:steel_ingot', 'dye:blue', 'default:steel_ingot'},
		{'techage:tubeS', 'techage:ta4_fuelcellstack', 'techage:electric_cableS'},
		{'default:steel_ingot', "techage:ta4_wlanchip", 'default:steel_ingot'},
	},
})

