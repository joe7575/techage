--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Electrolyzer v2

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Power = techage.ElectricCable
local power = techage.power
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CYCLE_TIME = 2
local STANDBY_TICKS = 5
local PWR_NEEDED = 40
local PWR_UNITS_PER_HYDROGEN_ITEM = 320
local CAPACITY = 400

local function formspec(self, pos, mem)
	local update = ((mem.countdown or 0) > 0 and mem.countdown) or S("Update")
	return "size[8,6.6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[0.0,0;1,2;"..power.formspec_power_bar(PWR_NEEDED, mem.consumed).."]"..
		"label[0.2,1.9;"..S("\\[ku\\]").."]"..
		"image[2.5,0;1,1;techage_form_arrow_fg.png^[transformR270]"..
		"image_button[3.5,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"tooltip[3.5,1;1,1;"..self:get_state_tooltip(mem).."]"..
		"button[1.6,1;1.8,1;update;"..update.."]"..
		"list[current_player;main;0,2.8;8,4;]" ..
		liquid.formspec_liquid(5, 0, mem)..
		default.get_hotbar_bg(0, 2.8)
end

local function start_node(pos, mem, state)
	mem.running = true
	mem.consumed = 0
	power.secondary_start(pos, mem, PWR_NEEDED, PWR_NEEDED)
end

local function stop_node(pos, mem, state)
	mem.running = false
	mem.consumed = 0
	power.secondary_stop(pos, mem)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta4_electrolyzer2",
	node_name_active = "techage:ta4_electrolyzer2_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = "TA4 Electrolyzer",
	start_node = start_node,
	stop_node = stop_node,
})

-- converts power into hydrogen
local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	mem.num_pwr_units = mem.num_pwr_units or 0
	mem.countdown = mem.countdown or 0
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	print("electrolyzer", mem.running, mem.consumed, mem.num_pwr_units, mem.liquid.amount)
	if mem.running then
		if techage.needs_power(mem) then
			mem.consumed = -power.secondary_alive(pos, mem, 0, 1)
			--print("mem.consumed", mem.consumed)
			if mem.consumed > 0 then
				if mem.liquid.amount < CAPACITY then
					mem.num_pwr_units = mem.num_pwr_units + mem.consumed
					if mem.num_pwr_units >= PWR_UNITS_PER_HYDROGEN_ITEM then
						mem.liquid.amount = mem.liquid.amount + 1
						mem.liquid.name = "techage:hydrogen"
						mem.num_pwr_units = mem.num_pwr_units - PWR_UNITS_PER_HYDROGEN_ITEM
						State:keep_running(pos, mem, 1, 0) -- count items
					end
				else
					State:blocked(pos, mem)
					power.secondary_stop(pos, mem)
				end
			end
		else
			mem.consumed = -power.secondary_alive(pos, mem, 1, 1)
			if mem.liquid.amount < CAPACITY then
				State:start(pos, mem)
				power.secondary_start(pos, mem, PWR_NEEDED, PWR_NEEDED)
			end
		end
	end
	if mem.countdown > 0 then
		mem.countdown = mem.countdown - 1
		M(pos):set_string("formspec", formspec(State, pos, mem))
	end
	return mem.running or mem.countdown > 0
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	State:state_button_event(pos, mem, fields)
	
	mem.countdown = 10
	M(pos):set_string("formspec", formspec(State, pos, mem))
	minetest.get_node_timer(pos):start(CYCLE_TIME)
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
	mem.countdown = 10
	M(pos):set_string("formspec", formspec(State, pos, mem))
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

minetest.register_node("techage:ta4_electrolyzer2", {
	description = S("TA4 Electrolyzer"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_outp.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_electrolyzer.png^techage_appl_ctrl_unit.png^[transformFX",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_electrolyzer.png^techage_appl_ctrl_unit.png",
	},

	on_construct = function(pos)
		local mem = tubelib2.init_mem(pos)
		local number = techage.add_node(pos, "techage:ta4_electrolyzer2")
		mem.running = false
		mem.num_pwr_units = 0
		State:node_init(pos, mem, number)
		local meta = M(pos)
		meta:set_string("formspec", formspec(State, pos, mem))
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('dst', 1)
	end,

	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	
	can_dig = function(pos, player)
		local inv = M(pos):get_inventory()
		return inv:is_empty("dst")
	end,
	
	liquid = {
		capa = CAPACITY,
		peek = liquid.srv_peek,
		put = function(pos, indir, name, amount)
			local leftover = liquid.srv_put(pos, indir, name, amount)
			local inv = M(pos):get_inventory()
			if not inv:is_empty("src") and inv:is_empty("dst") then
				liquid.fill_container(pos, inv)
			end
			return leftover
		end,
		take = liquid.srv_take,
	},
	networks = {
		pipe = {
			sides = {R = 1}, -- Pipe connection sides
			ntype = "tank",
		},
	},
	
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

minetest.register_node("techage:ta4_electrolyzer2_on", {
	description = S("TA4 Electrolyzer"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_outp.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_electrolyzer4.png^techage_appl_ctrl_unit4.png^[transformFX",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_frame4_ta4.png^techage_appl_electrolyzer4.png^techage_appl_ctrl_unit4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
	},

	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	
	liquid = {
		capa = CAPACITY,
		peek = liquid.srv_peek,
		put = function(pos, indir, name, amount)
			local leftover = liquid.srv_put(pos, indir, name, amount)
			local inv = M(pos):get_inventory()
			if not inv:is_empty("src") and inv:is_empty("dst") then
				liquid.fill_container(pos, inv)
			end
			return leftover
		end,
		take = liquid.srv_take,
	},
	networks = {
		pipe = {
			sides = {R = 1}, -- Pipe connection sides
			ntype = "tank",
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

-- Register for power
techage.power.register_node({"techage:ta4_electrolyzer2", "techage:ta4_electrolyzer2_on"}, {
	conn_sides = {"L"},
	power_network  = Power,
	after_place_node = function(pos)
		local node = minetest.get_node(pos)
		local indir = techage.side_to_indir("R", node.param2)
		M(pos):set_int("in_dir", indir)
		Pipe:after_place_node(pos)
	end,	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
})

-- Register for tubes
techage.register_node({"techage:ta4_electrolyzer2", "techage:ta4_electrolyzer2_on"}, liquid.tubing)	

-- Register for pipes
Pipe:add_secondary_node_names({"techage:ta3_tank", "techage:ta4_tank", "techage:oiltank"})

minetest.register_craft({
	output = "techage:ta4_electrolyzer2",
	recipe = {
		{'default:steel_ingot', 'dye:blue', 'default:steel_ingot'},
		{'techage:electric_cableS', 'default:glass', 'techage:tubeS'},
		{'default:steel_ingot', "techage:ta4_wlanchip", 'default:steel_ingot'},
	},
})

