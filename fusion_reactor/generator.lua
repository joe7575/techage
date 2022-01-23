--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fusion Reactor Generator
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control

local CYCLE_TIME = 2
local PWR_PERF = 800

local function swap_node(pos, name)
	local node = techage.get_node_lvm(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function start_node(pos, nvm)
	local meta = M(pos)
	nvm.provided = 0
	nvm.alive_cnt = 5
	techage.evaluate_charge_termination(nvm, meta)
	local outdir = meta:get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
	swap_node(pos, "techage:ta5_generator_on")
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

local function stop_node(pos, nvm)
	nvm.provided = 0
	nvm.alive_cnt = 0
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
	swap_node(pos, "techage:ta5_generator")
end

local function get_generator_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if (nvm.alive_cnt or 0) > 0 then
		return {level = (nvm.load or 0) / PWR_PERF, perf = PWR_PERF, capa = PWR_PERF * 2}
	end
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	nvm.alive_cnt = (nvm.alive_cnt or 0) - 1
	if nvm.alive_cnt > 0 then
		local meta = M(pos)
		local outdir = meta:get_int("outdir")
		local tp1 = tonumber(meta:get_string("termpoint1"))
		local tp2 = tonumber(meta:get_string("termpoint2"))
		nvm.provided = power.provide_power(pos, Cable, outdir, PWR_PERF, tp1, tp2)
		local val = power.get_storage_load(pos, Cable, outdir, PWR_PERF)
		if val > 0 then
			nvm.load = val
		end
		return true
	else
		swap_node(pos, "techage:ta5_generator")
		stop_node(pos, nvm)
		return false
	end
end

minetest.register_node("techage:ta5_generator", {
	description = S("TA5 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
		"techage_filling_ta4.png^techage_appl_hole_electric.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_generator.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_generator.png^[transformFX]",
	},

	after_place_node = function(pos, placer)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	get_generator_data = get_generator_data,
	ta4_formspec = techage.generator_settings("ta4", PWR_PERF),
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta5_generator_on", {
	description = S("TA5 Generator"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
		"techage_filling_ta4.png^techage_appl_hole_electric.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_open.png^techage_frame_ta5.png",
		{
			image = "techage_filling4_ta4.png^techage_appl_generator4.png^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_appl_generator4.png^[transformFX]^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.3,
			},
		},
	},

	get_generator_data = get_generator_data,
	ta4_formspec = techage.generator_settings("ta4", PWR_PERF),
	on_timer = node_timer,
	paramtype2 = "facedir",
	drop = "",
	groups = {not_in_creative_inventory=1},
	diggable = false,
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

power.register_nodes({"techage:ta5_generator", "techage:ta5_generator_on"}, Cable, "gen", {"R"})

-- controlled by the turbine
techage.register_node({"techage:ta5_generator", "techage:ta5_generator_on"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "trigger" then
			nvm.alive_cnt = 5
		elseif topic == "start" then
			start_node(pos, nvm)
		elseif topic == "stop" then
			stop_node(pos, nvm)
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		return "unsupported"
	end,
	on_node_load = function(pos)
		-- remove legacy formspec
		M(pos):set_string("formspec", "")
	end,
})

control.register_nodes({"techage:ta5_generator", "techage:ta5_generator_on"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				local meta = M(pos)
				return {
					type = S("TA5 Generator"),
					number = "-",
					running = (nvm.alive_cnt or 0) > 0,
					available = PWR_PERF,
					provided = nvm.provided or 0,
					termpoint = meta:get_string("termpoint"),
				}
			end
			return false
		end,
	}
)

minetest.register_craft({
	output = "techage:ta5_generator",
	recipe = {
		{"", "dye:red", ""},
		{"", "techage:ta4_generator", ""},
		{"", "techage:baborium_ingot", ""},
	},
})
