--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Oil Reboiler

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Flip = networks.Flip
local Pipe = techage.LiquidPipe
local Cable = techage.ElectricCable
local liquid = networks.liquid
local power = networks.power

local CYCLE_TIME = 2
local WAITING_CYCLES = 5  -- in case BLOCKED
local PWR_NEEDED = 14

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_reboiler", {
			pos = pos,
			gain = 1,
			max_hear_distance = 15,
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

local function swap_node(pos, on)
	local nvm = techage.get_nvm(pos)
	local node = techage.get_node_lvm(pos)
	if on and node.name == "techage:ta3_reboiler" then
		node.name = "techage:ta3_reboiler_on"
		minetest.swap_node(pos, node)
		play_sound(pos)
	elseif not on and node.name == "techage:ta3_reboiler_on" then
		node.name = "techage:ta3_reboiler"
		minetest.swap_node(pos, node)
		stop_sound(pos)
	end
end

local function pump_cmnd(pos)
	local leftover = techage.transfer(
		pos,
		"R",  -- outdir
		"put",  -- topic
		nil,  -- payload
		Pipe,  -- Pipe
		{"techage:ta3_distiller1"})

	-- number of processed oil items
	return  1 - (tonumber(leftover) or 1)
end

local function new_state(pos, nvm, state)
	if nvm.state ~= state then
		nvm.state = state
		M(pos):set_string("infotext", S("TA3 Oil Reboiler") .. ": " .. techage.StateStrings[state])
		swap_node(pos, state == techage.RUNNING)
	end
end

local function on_timer(pos)
	local nvm = techage.get_nvm(pos)
	nvm.oil_amount = nvm.oil_amount or 0

	-- Power handling
	if nvm.state == techage.STOPPED then
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed == PWR_NEEDED then
			new_state(pos, nvm, techage.RUNNING)
			return true
		end
	elseif nvm.state == techage.RUNNING then
		local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if consumed < PWR_NEEDED then
			local nvm = techage.get_nvm(pos)
			new_state(pos, nvm, techage.STOPPED)
			return true
		end
	elseif nvm.state == techage.BLOCKED or nvm.state == techage.STANDBY then
		if not power.power_available(pos, Cable) then
			local nvm = techage.get_nvm(pos)
			new_state(pos, nvm, techage.STOPPED)
			return true
		end
	end

	-- Oil handling
	if nvm.state == techage.RUNNING then
		if nvm.oil_amount >= 1 then
			local processed = pump_cmnd(pos)
			nvm.oil_amount = nvm.oil_amount - processed
			nvm.waiting_cycles = WAITING_CYCLES
			if processed == 0 then
				new_state(pos, nvm, techage.BLOCKED)
			else
				new_state(pos, nvm, techage.RUNNING)
			end
		else
			nvm.waiting_cycles = (nvm.waiting_cycles or 0) - 1
			if nvm.waiting_cycles <= 0 then
				new_state(pos, nvm, techage.STANDBY)
			end
		end
	elseif nvm.state == techage.BLOCKED then
		nvm.waiting_cycles = nvm.waiting_cycles - 1
		if nvm.waiting_cycles <= 0 then
			new_state(pos, nvm, techage.RUNNING)
		end
	else
		-- STANDBY: 'put' will trigger the state change
	end
	return true
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	new_state(pos, nvm, techage.STOPPED)
	Pipe:after_place_node(pos)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Pipe:after_dig_node(pos)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	nvm.oil_amount = 0
	new_state(pos, nvm, techage.STOPPED)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

minetest.register_node("techage:ta3_reboiler", {
	description = S("TA3 Oil Reboiler"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_reboiler.png^techage_frame_ta3.png^[transformFX",
		"techage_filling_ta3.png^techage_appl_reboiler.png^techage_frame_ta3.png",
	},

	on_timer = on_timer,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_rightclick = on_rightclick,

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta3_reboiler_on", {
	description = S("TA3 Oil Reboiler"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_reboiler4.png^techage_frame4_ta3.png^[transformFX",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_reboiler4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},

	on_timer = on_timer,
	on_rightclick = on_rightclick,

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

local liquid_def = {
	peek = function(pos)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		nvm.oil_amount = nvm.oil_amount or 0

		if nvm.state == techage.STANDBY or nvm.state == techage.RUNNING then
			if name == "techage:oil_source" and amount > 0 then
				if nvm.state == techage.STANDBY then
					new_state(pos, nvm, techage.RUNNING)
				end
				-- Take one oil item every 2 cycles
				-- Hint: We have to take two items, because the pump will pause for 4 cycles,
				-- if nothing is taken.
				nvm.take = nvm.take ~= true
				if nvm.take and nvm.oil_amount < 5 then
					nvm.oil_amount = nvm.oil_amount + 2
					return amount - 2
				end
			end
		end
		return amount
	end
}

liquid.register_nodes({"techage:ta3_reboiler", "techage:ta3_reboiler_on"}, Pipe, "tank", {"L", "R"}, liquid_def)
power.register_nodes({"techage:ta3_reboiler", "techage:ta3_reboiler_on"}, Cable, "con")

techage.register_node({"techage:ta3_reboiler", "techage:ta3_reboiler_on"}, {
	on_node_load = function(pos, node)
		if node.name == "techage:ta3_reboiler_on" then
			play_sound(pos)
		end
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})

minetest.register_craft({
	output = "techage:ta3_reboiler",
	recipe = {
		{"", "basic_materials:heating_element", ""},
		{"default:mese_crystal_fragment", "techage:t3_pump", "default:mese_crystal_fragment"},
		{"", "basic_materials:heating_element", ""},
	},
})
