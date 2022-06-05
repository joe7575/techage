--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Pump

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid
local Flip = networks.Flip

local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local CAPA = 4

local WRENCH_MENU =	{{
	type = "output",
	name = "flowrate",
	label = S("Total flow rate"),
	tooltip = S("Total flow rate in liquid units"),
}}

local State3 = techage.NodeStates:new({
	node_name_passive = "techage:t3_pump",
	node_name_active = "techage:t3_pump_on",
	infotext_name = S("TA3 Pump"),
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
})

local State4 = techage.NodeStates:new({
	node_name_passive = "techage:t4_pump",
	node_name_active = "techage:t4_pump_on",
	infotext_name = S("TA4 Pump"),
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
})

local function pumping(pos, nvm, state, capa)
	local mem = techage.get_mem(pos)
	mem.dbg_cycles = (mem.dbg_cycles or 0) - 1
	local outdir = M(pos):get_int("outdir")
	local taken, name = liquid.take(pos, Pipe, Flip[outdir], nil, capa, mem.dbg_cycles > 0)
	if taken > 0 then
		local leftover = liquid.put(pos, Pipe, outdir, name, taken, mem.dbg_cycles > 0)
		if leftover and leftover > 0 then
			-- air needs no tank
			if name == "air" then
				state:keep_running(pos, nvm, COUNTDOWN_TICKS)
				return 0
			end
			liquid.untake(pos, Pipe, Flip[outdir], name, leftover)
			if leftover == taken then
				state:blocked(pos, nvm)
				return 0
			end
			state:keep_running(pos, nvm, COUNTDOWN_TICKS)
			return taken - leftover
		end
		state:keep_running(pos, nvm, COUNTDOWN_TICKS)
		return taken
	end
	state:idle(pos, nvm)
	return 0
end

local function after_place_node3(pos, placer)
	local nvm = techage.get_nvm(pos)
	local number = techage.add_node(pos, "techage:t3_pump")
	State3:node_init(pos, nvm, number)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	Pipe:after_place_node(pos)
end

local function after_place_node4(pos, placer)
	local nvm = techage.get_nvm(pos)
	local number = techage.add_node(pos, "techage:t4_pump")
	State4:node_init(pos, nvm, number)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	Pipe:after_place_node(pos)
end

local function node_timer3(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	pumping(pos, nvm, State3, CAPA)
	return State3:is_active(nvm)
end

local function node_timer4(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.flowrate = (nvm.flowrate or 0) + pumping(pos, nvm, State4, CAPA * 2)
	return State4:is_active(nvm)
end

local function on_rightclick(pos, node, clicker)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end

	local nvm = techage.get_nvm(pos)
	if node.name == "techage:t3_pump" then
		local mem = techage.get_mem(pos)
		mem.dbg_cycles = 5
		State3:start(pos, nvm)
	elseif node.name == "techage:t3_pump_on" then
		State3:stop(pos, nvm)
	elseif node.name == "techage:t4_pump" then
		local mem = techage.get_mem(pos)
		mem.dbg_cycles = 5
		State4:start(pos, nvm)
	elseif node.name == "techage:t4_pump_on" then
		State4:stop(pos, nvm)
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
	techage.del_mem(pos)
end

local ta3_tiles_pas = {
	-- up, down, right, left, back, front
	"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
	"techage_filling_ta3.png^techage_frame_ta3_bottom.png",
	"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
	"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
	"techage_filling_ta3.png^techage_appl_pump.png^techage_frame_ta3.png^[transformFX",
	"techage_filling_ta3.png^techage_appl_pump.png^techage_frame_ta3.png",
}

local ta4_tiles_pas = {
	-- up, down, right, left, back, front
	"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
	"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
	"techage_filling_ta4.png^techage_appl_hole_pipe.png^techage_frame_ta4.png",
	"techage_filling_ta4.png^techage_appl_hole_pipe.png^techage_frame_ta4.png",
	"techage_filling_ta4.png^techage_appl_pump.png^techage_frame_ta4.png^[transformFX",
	"techage_filling_ta4.png^techage_appl_pump.png^techage_frame_ta4.png",
}

local ta3_tiles_act = {
	-- up, down, right, left, back, front
	"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
	"techage_filling_ta3.png^techage_frame_ta3_bottom.png",
	"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
	"techage_filling_ta3.png^techage_appl_hole_pipe.png^techage_frame_ta3.png",
	{
		image = "techage_filling8_ta3.png^techage_appl_pump8.png^techage_frame8_ta3.png^[transformFX",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	{
		image = "techage_filling8_ta3.png^techage_appl_pump8.png^techage_frame8_ta3.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
}

local ta4_tiles_act = {
	-- up, down, right, left, back, front
	"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_arrow.png",
	"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
	"techage_filling_ta4.png^techage_appl_hole_pipe.png^techage_frame_ta4.png",
	"techage_filling_ta4.png^techage_appl_hole_pipe.png^techage_frame_ta4.png",
	{
		image = "techage_filling8_ta4.png^techage_appl_pump8.png^techage_frame8_ta4.png^[transformFX",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	{
		image = "techage_filling8_ta4.png^techage_appl_pump8.png^techage_frame8_ta4.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
}

minetest.register_node("techage:t3_pump", {
	description = S("TA3 Pump"),
	tiles = ta3_tiles_pas,
	after_place_node = after_place_node3,
	on_rightclick = on_rightclick,
	on_timer = node_timer3,
	after_dig_node = after_dig_node,
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:t3_pump_on", {
	description = S("TA3 Pump"),
	tiles = ta3_tiles_act,
	--after_place_node = after_place_node3,
	on_rightclick = on_rightclick,
	on_timer = node_timer3,
	after_dig_node = after_dig_node,
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:t4_pump", {
	description = S("TA4 Pump"),
	tiles = ta4_tiles_pas,
	after_place_node = after_place_node4,
	on_rightclick = on_rightclick,
	on_timer = node_timer4,
	after_dig_node = after_dig_node,
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	ta4_formspec = WRENCH_MENU,
})

minetest.register_node("techage:t4_pump_on", {
	description = S("TA4 Pump"),
	tiles = ta4_tiles_act,
	--after_place_node = after_place_node4,
	on_rightclick = on_rightclick,
	on_timer = node_timer4,
	after_dig_node = after_dig_node,
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

techage.register_node({"techage:t3_pump", "techage:t3_pump_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		return State3:on_receive_message(pos, topic, payload)
	end,
})

techage.register_node({"techage:t4_pump", "techage:t4_pump_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "flowrate" then
			local nvm = techage.get_nvm(pos)
			return nvm.flowrate or 0
		else
			return State4:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State4:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 137 then  -- Total Flow Rate
			local nvm = techage.get_nvm(pos)
			return 0, {nvm.flowrate or 0}
		else
			return State4:on_beduino_request_data(pos, topic, payload)
		end
	end,
})

-- Pumps have to provide one output and one input side
liquid.register_nodes({
	"techage:t3_pump", "techage:t3_pump_on",
	"techage:t4_pump", "techage:t4_pump_on",
}, Pipe, "pump", {"L", "R"}, {})

minetest.register_craft({
	output = "techage:t3_pump 2",
	recipe = {
		{"group:wood", "techage:iron_ingot", "group:wood"},
		{"techage:ta3_pipeS", "techage:usmium_nuggets", "techage:ta3_pipeS"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
	},
})

minetest.register_craft({
	output = "techage:t4_pump",
	recipe = {
		{"default:tin_ingot", "dye:blue", "default:steel_ingot"},
		{"", "techage:t3_pump", ""},
		{"", "", ""},
	},
})
