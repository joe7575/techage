--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Tiny Power Generator

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local firebox = techage.firebox
local fuel = techage.fuel
local Pipe = techage.LiquidPipe
local power = networks.power
local liquid = networks.liquid

local CYCLE_TIME = 2
local STANDBY_TICKS = 1
local COUNTDOWN_TICKS = 2
local PWR_PERF = 12
local EFFICIENCY = 2.5

local function formspec(self, pos, nvm)
	return "size[5,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;4.8,0.5;#c6e8ff]"..
		"label[0.2,-0.1;"..minetest.colorize( "#000000", S("Tiny Generator")).."]"..
		fuel.fuel_container(0, 0.9, nvm)..
		"image[1.4,1.6;1,1;techage_form_arrow_bg.png^[transformR270]"..
		"image_button[1.4,3.2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[1.5,3;1,1;"..self:get_state_tooltip(nvm).."]"..
		techage.formspec_power_bar(pos, 2.5, 0.8, S("Electricity"), nvm.provided, PWR_PERF)
end

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_generator", {
			pos = pos,
			gain = 1,
			max_hear_distance = 10,
			loop = true})
		if mem.handle == -1 then
			minetest.after(1, play_sound, pos)
		end
	end
end

local function stop_sound(pos)
	local mem = techage.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function has_fuel(pos, nvm)
	return (nvm.burn_cycles or 0) > 0 or (nvm.liquid and nvm.liquid.amount and nvm.liquid.amount > 0)
end

local function can_start(pos, nvm, state)
	if has_fuel(pos, nvm) then
		return true
	end
	return S("no fuel")
end

local function start_node(pos, nvm, state)
	local meta = M(pos)
	nvm.provided = 0
	local outdir = meta:get_int("outdir")
	play_sound(pos)
	power.start_storage_calc(pos, Cable, outdir)
	techage.evaluate_charge_termination(nvm, meta)
end

local function stop_node(pos, nvm, state)
	nvm.provided = 0
	local outdir = M(pos):get_int("outdir")
	stop_sound(pos)
	power.start_storage_calc(pos, Cable, outdir)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:tiny_generator",
	node_name_active = "techage:tiny_generator_on",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	infotext_name = S("TA3 Tiny Power Generator"),
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function burning(pos, nvm)
	local ratio = math.max((nvm.provided or PWR_PERF) / PWR_PERF, 0.02)

	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	nvm.burn_cycles = (nvm.burn_cycles or 0) - ratio
	if nvm.burn_cycles <= 0 then
		if nvm.liquid.amount > 0 then
			nvm.liquid.amount = nvm.liquid.amount - 1
			nvm.burn_cycles = fuel.burntime(nvm.liquid.name) * EFFICIENCY / CYCLE_TIME
			nvm.burn_cycles_total = nvm.burn_cycles
		else
			nvm.liquid.name = nil
		end
	end
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local running = techage.is_running(nvm)
	local fuel = has_fuel(pos, nvm)
	if running and not fuel then
		State:standby(pos, nvm, S("no fuel"))
		stop_node(pos, nvm, State)
	elseif not running and fuel then
		State:start(pos, nvm)
		-- start_node() is called implicit
	elseif running then
		local meta = M(pos)
		local outdir = meta:get_int("outdir")
		local tp1 = tonumber(meta:get_string("termpoint1"))
		local tp2 = tonumber(meta:get_string("termpoint2"))
		nvm.provided = power.provide_power(pos, Cable, outdir, PWR_PERF, tp1, tp2)
		local val = power.get_storage_load(pos, Cable, outdir, PWR_PERF)
		if val > 0 then
			nvm.load = val
		end
		burning(pos, nvm)
		State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return State:is_active(nvm)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if techage.is_running(nvm) then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
end

minetest.register_node("techage:tiny_generator", {
	description = S("TA3 Tiny Power Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_appl_electric_gen_top.png^techage_frame_ta3_top.png",
		"techage_appl_electric_gen_top.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_front.png^[transformFX]^techage_frame_ta3.png",
		"techage_appl_electric_gen_front.png^techage_frame_ta3.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	after_place_node = function(pos, placer, itemstack)
		local nvm = techage.get_nvm(pos)
		local number = techage.add_node(pos, "techage:tiny_generator")
		nvm.burn_cycles = 0
		if itemstack then
			local stack_meta = itemstack:get_meta()
			if stack_meta then
				local liquid_name = stack_meta:get_string("liquid_name")
				local liquid_amount = stack_meta:get_int("liquid_amount")
				if liquid_name ~= "" and fuel.burntime(liquid.name) and
				   liquid_amount >= 0 and liquid_amount <= fuel.CAPACITY then
					nvm.liquid = nvm.liquid or {}
					nvm.liquid.name = liquid_name
					nvm.liquid.amount = liquid_amount
				end
			end
		end
		State:node_init(pos, nvm, number)
		M(pos):set_string("formspec", formspec(State, pos, nvm))
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	preserve_metadata = function(pos, oldnode, oldmetadata, drops)
		local nvm = techage.get_nvm(pos)
		if nvm.liquid and nvm.liquid.name and nvm.liquid.amount > 0 then
			-- generator tank is not empty
			local meta = drops[1]:get_meta()
			meta:set_string("liquid_name", nvm.liquid.name)
			meta:set_int("liquid_amount", nvm.liquid.amount)
			meta:set_string("description", S("TA3 Tiny Power Generator") .. " (fuel: " ..
			                tostring(nvm.liquid and nvm.liquid.amount or 0) .. "/" ..
					tostring(fuel.CAPACITY) .. ")")
		end
	end,

	get_generator_data = get_generator_data,
	ta3_formspec = techage.generator_settings("ta3", PWR_PERF),
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_punch = fuel.on_punch,
	on_timer = node_timer,
})

minetest.register_node("techage:tiny_generator_on", {
	description = S("TA3 Tiny Power Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_appl_electric_gen_top.png^techage_frame_ta3_top.png",
		"techage_appl_electric_gen_top.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_appl_hole_electric.png^techage_frame_ta3.png",
		"techage_appl_electric_gen_side.png^techage_frame_ta3.png",
		{
			image = "techage_appl_electric_gen_front4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
		{
			image = "techage_appl_electric_gen_front4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.8,
			},
		},
	},

	paramtype = "light",
	paramtype2 = "facedir",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	light_source = 4,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	get_generator_data = get_generator_data,
	ta3_formspec = techage.generator_settings("ta3", PWR_PERF),
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_punch = fuel.on_punch,
	on_timer = node_timer,
	can_dig = fuel.can_dig,
})

local liquid_def = {
	fuel_cat = fuel.BT_GASOLINE,
	capa = fuel.CAPACITY,
	peek = function(pos)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		if techage.fuel.valid_fuel(name, fuel.BT_GASOLINE) then
			local nvm = techage.get_nvm(pos)
			local leftover = liquid.srv_put(nvm, name, amount, fuel.CAPACITY)
			if techage.is_activeformspec(pos) then
				local nvm = techage.get_nvm(pos)
				M(pos):set_string("formspec", formspec(State, pos, nvm))
			end
			return leftover
		end
		return amount
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local taken = liquid.srv_take(nvm, name, amount)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return taken
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		local leftover = liquid.srv_put(nvm, name, amount, fuel.CAPACITY)
		if techage.is_activeformspec(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		end
		return leftover
	end,
}

power.register_nodes({"techage:tiny_generator", "techage:tiny_generator_on"}, Cable, "gen", {"R"})
liquid.register_nodes({"techage:tiny_generator", "techage:tiny_generator_on"}, Pipe, "tank", nil, liquid_def)

techage.register_node({"techage:tiny_generator", "techage:tiny_generator_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "delivered" then
			return nvm.provided or 0
		elseif topic == "fuel" then
			return techage.fuel.get_fuel_amount(nvm)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 135 then
			return 0, {nvm.provided or 0}
		elseif topic == 132 then
			return 0, {techage.fuel.get_fuel_amount(nvm)}
		else
			return State:on_beduino_request_data(pos, topic, payload)
		end
	end,
	on_node_load = function(pos, node)
		State:on_node_load(pos)
		if node.name == "techage:tiny_generator_on" then
			play_sound(pos)
		end
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

minetest.register_craft({
	output = "techage:tiny_generator",
	recipe = {
		{'default:steel_ingot', 'techage:usmium_nuggets', 'default:steel_ingot'},
		{'dye:red', 'basic_materials:gear_steel', 'techage:electric_cableS'},
		{'default:steel_ingot', 'techage:vacuum_tube', 'default:steel_ingot'},
	},
})
