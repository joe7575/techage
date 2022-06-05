--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Pump

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe2 = techage.LiquidPipe
local Pipe3 = techage.GasPipe
local liquid = networks.liquid
local Flip = networks.Flip

local STANDBY_TICKS = 16
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local CAPA = 4

local WRENCH_MENU =	{{
	type = "output",
	name = "flowrate",
	label = S("Total flow rate"),
	tooltip = S("Total flow rate in liquid units"),
}}

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta5_pump",
	node_name_active = "techage:ta5_pump_on",
	infotext_name = S("TA5 Pump"),
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
})

local function pumping(pos, nvm)
	local outdir = M(pos):get_int("outdir")
	local taken, name = liquid.take(pos, Pipe2, Flip[outdir], nil, CAPA)
	if taken > 0 then
		local leftover = liquid.put(pos, Pipe3, outdir, name, taken)
		if leftover and leftover > 0 then
			liquid.untake(pos, Pipe2, Flip[outdir], name, leftover)
			if leftover == taken then
				State:blocked(pos, nvm)
				return 0
			end
			State:keep_running(pos, nvm, COUNTDOWN_TICKS)
			return taken - leftover
		end
		State:keep_running(pos, nvm, COUNTDOWN_TICKS)
		return taken
	end
	State:idle(pos, nvm)
	return 0
end

local function after_place_node(pos, placer)
	local nvm = techage.get_nvm(pos)
	local number = techage.add_node(pos, "techage:ta5_pump")
	State:node_init(pos, nvm, number)
	M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	Pipe2:after_place_node(pos)
	Pipe3:after_place_node(pos)
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.flowrate = (nvm.flowrate or 0) + pumping(pos, nvm)
	return State:is_active(nvm)
end

local function on_rightclick(pos, node, clicker)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end

	local nvm = techage.get_nvm(pos)
	if node.name == "techage:ta5_pump" then
		State:start(pos, nvm)
	elseif node.name == "techage:ta5_pump_on" then
		State:stop(pos, nvm)
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe2:after_dig_node(pos)
	Pipe3:after_dig_node(pos)
	techage.del_mem(pos)
end

local tiles_pas = {
	-- up, down, right, left, back, front
	"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
	"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
	"techage_filling_ta4.png^techage_appl_hole_ta5_pipe2.png^techage_frame_ta5.png",
	"techage_filling_ta4.png^techage_appl_hole_pipe.png^techage_frame_ta5.png",
	"techage_filling_ta4.png^techage_appl_pump.png^techage_frame_ta5.png^[transformFX",
	"techage_filling_ta4.png^techage_appl_pump.png^techage_frame_ta5.png",
}

local tiles_act = {
	-- up, down, right, left, back, front
	"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
	"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
	"techage_filling_ta4.png^techage_appl_hole_ta5_pipe2.png^techage_frame_ta5.png",
	"techage_filling_ta4.png^techage_appl_hole_pipe.png^techage_frame_ta5.png",
	{
		image = "techage_filling8_ta4.png^techage_appl_pump8.png^techage_frame8_ta5.png^[transformFX",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	{
		image = "techage_filling8_ta4.png^techage_appl_pump8.png^techage_frame8_ta5.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
}

minetest.register_node("techage:ta5_pump", {
	description = S("TA5 Pump"),
	tiles = tiles_pas,
	after_place_node = after_place_node,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	ta4_formspec = WRENCH_MENU,
})

minetest.register_node("techage:ta5_pump_on", {
	description = S("TA5 Pump"),
	tiles = tiles_act,
	--after_place_node = after_place_node4,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	diggable = false,
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

techage.register_node({"techage:ta5_pump", "techage:ta5_pump_on"}, {
	on_recv_message = function(pos, src, topic, payload)
		return State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return State:on_beduino_request_data(pos, topic, payload)
	end,
})

-- Pumps have to provide one output and one input side
liquid.register_nodes({
	"techage:ta5_pump", "techage:ta5_pump_on",
}, Pipe2, "pump", {"L"}, {})

liquid.register_nodes({
	"techage:ta5_pump", "techage:ta5_pump_on",
}, Pipe3, "pump", {"R"}, {})

minetest.register_craft({
	output = "techage:ta5_pump",
	recipe = {
		{"techage:aluminum", "dye:red", "default:steel_ingot"},
		{"techage:ta4_pipeS", "techage:ta5_ceramic_turbine", "techage:ta5_pipe1S"},
		{"default:steel_ingot", "basic_materials:motor", "techage:aluminum"},
	},
})
