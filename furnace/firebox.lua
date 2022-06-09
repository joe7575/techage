--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Industrial Furnace Firebox

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local firebox = techage.firebox
local fuel = techage.fuel
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

local CYCLE_TIME = 2
local EFFICIENCY = 2 -- burn cycles
local CATEGORY = 3

local function has_fuel(pos, nvm)
	return (nvm.burn_cycles or 0) > 0 or (nvm.liquid and nvm.liquid.amount and nvm.liquid.amount > 0)
end

local function stop_firebox(pos, nvm)
	nvm.running = false
	firebox.swap_node(pos, "techage:furnace_firebox")
	minetest.get_node_timer(pos):stop()
	M(pos):set_string("formspec", fuel.formspec(nvm))
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	if nvm.running then
		nvm.burn_cycles = (nvm.burn_cycles or 0) - 1
		if nvm.burn_cycles <= 0 then
			if nvm.liquid.amount > 0 then
				nvm.liquid.amount = nvm.liquid.amount - 1
				nvm.burn_cycles = fuel.burntime(nvm.liquid.name) * EFFICIENCY / CYCLE_TIME
				nvm.burn_cycles_total = nvm.burn_cycles
			else
				nvm.liquid.name = nil
				stop_firebox(pos, nvm)
				return false
			end
		end
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", fuel.formspec(nvm))
	end
	return true
end

local function start_firebox(pos, nvm)
	if not nvm.running then
		nvm.running = true
		node_timer(pos, 0)
		firebox.swap_node(pos, "techage:furnace_firebox_on")
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		M(pos):set_string("formspec", fuel.formspec(nvm))
	end
end

local function booster_cmnd(pos, cmnd)
	return techage.transfer(
		pos,
		"L",  -- outdir
		cmnd,  -- topic
		nil,  -- payload
		nil,  -- network
		{"techage:ta3_booster", "techage:ta3_booster_on"})
end

minetest.register_node("techage:furnace_firebox", {
	description = S("TA3 Furnace Oil Burner"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_open.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_appl_firehole.png^techage_frame_ta3.png",
	},
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = node_timer,
	can_dig = fuel.can_dig,
	on_punch = fuel.on_punch,
	on_receive_fields = fuel.on_receive_fields,
	on_rightclick = fuel.on_rightclick,

	on_construct = function(pos)
		local nvm = techage.get_nvm(pos)
		techage.add_node(pos, "techage:furnace_firebox")
		nvm.running = false
		nvm.burn_cycles = 0
		nvm.liquid = {}
		nvm.liquid.amount =  0
		local meta = M(pos)
		meta:set_string("formspec", fuel.formspec(nvm))
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
	end,
})

minetest.register_node("techage:furnace_firebox_on", {
	description = S("TA3 Furnace Oil Burner"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		"techage_concrete.png^techage_frame_ta3.png",
		{
			image = "techage_concrete4.png^techage_appl_firehole4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	paramtype2 = "facedir",
	light_source = 8,
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	drop = "techage:furnace_firebox",

	on_timer = node_timer,
	can_dig = fuel.can_dig,
	on_receive_fields = fuel.on_receive_fields,
	on_punch = fuel.on_punch,
	on_rightclick = fuel.on_rightclick,
})

minetest.register_craft({
	output = "techage:furnace_firebox",
	recipe = {
		{'techage:basalt_stone', 'techage:basalt_stone', 'techage:basalt_stone'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'techage:basalt_stone', 'techage:basalt_stone', 'techage:basalt_stone'},
	},
})

techage.register_node({"techage:furnace_firebox", "techage:furnace_firebox_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "state" then
			return nvm.running and "running" or "stopped"
		elseif topic == "fuel" then
			return fuel.get_fuel_amount(nvm)
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 128 then
			return 0, techage.get_node_lvm(pos).name
		elseif topic == 129 then  -- State
			return 0, {nvm.running and techage.RUNNING or techage.STOPPED}
		elseif topic == 132 then  -- Fuel Level
			return 0, {fuel.get_fuel_amount(nvm)}
		else
			return 2, ""
		end
	end,
	-- called from furnace_top
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "fuel" then
			return has_fuel(pos, nvm) and booster_cmnd(pos, "power")
		elseif topic == "running" then
			return nvm.running and booster_cmnd(pos, "running")
		elseif topic == "start" then
			start_firebox(pos, nvm)
			booster_cmnd(pos, "start")
		elseif topic == "stop" then
			stop_firebox(pos, nvm)
			booster_cmnd(pos, "stop")
		end
	end,
	on_node_load = function(pos, node)
		local inv = M(pos):get_inventory()
		if not inv:is_empty("fuel") then
			local nvm = techage.get_nvm(pos)
			nvm.liquid = nvm.liquid or {}
			local count = inv:get_stack("fuel", 1):get_count()
			nvm.liquid.amount = (nvm.liquid.amount or 0) + count
			nvm.liquid.name = "techage:gasoline"
			inv:set_stack("fuel", 1, nil)
		end
	end,
})

liquid.register_nodes({"techage:furnace_firebox", "techage:furnace_firebox_on"},
	Pipe, "tank", nil, fuel.get_liquid_table(fuel.BT_OIL, fuel.CAPACITY, start_firebox))
