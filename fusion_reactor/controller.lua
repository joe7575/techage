--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fusion Reactor Controller

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control

local CYCLE_TIME = 2
local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 3
local PWR_NEEDED = 4

local function concentrate(t)
	local yes = 0
	local no = 0
	for _,v in ipairs(t) do
		if v then
			yes = yes + 1
		else
			no = no + 1
		end
	end
	return yes .. " yes, " .. no .. " no"
end

local function nucleus(t)
	if #t == 4 then
		if vector.equals(t[1], t[2]) and vector.equals(t[3], t[4]) then
			return "ok"
		end
	end
	return "error"
	
end

local Commands = {
	function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "test_plasma")
		return "test_plasma: " .. concentrate(resp)
	end,
	function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "test_shell")
		return "test_shell: " .. concentrate(resp)
	end,
	function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "test_gas")
		return "test_gas: " .. concentrate(resp)
	end,
	function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "test_nucleus")
		return "test_nucleus: " .. nucleus(resp)
	end,
	function(pos, outdir)
		local resp = control.send(pos, Cable, outdir, "con", "on")
		return "on " .. resp
	end,
	function(pos, outdir)
		local resp = control.send(pos, Cable, outdir, "con", "off")
		return "off " .. resp
	end,
	function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "no_gas")
		return "no_gas: " .. concentrate(resp)
	end,
}

local function after_place_node(pos, placer, itemstack)
	local nvm = techage.get_nvm(pos)
	local meta = M(pos)
	local own_num = techage.add_node(pos, "techage:ta5_fr_controller_pas")
	meta:set_string("node_number", own_num)
	meta:set_string("owner", placer:get_player_name())
	meta:set_string("infotext", S("TA5 Fusion Reactor Controller") .. " " .. own_num)
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	Cable:after_place_node(pos)
end

local function node_timer(pos)
	local nvm = techage.get_nvm(pos)
	local outdir = networks.side_to_outdir(pos, "L")
	nvm.consumed = power.consume_power(pos, Cable, outdir, 1)

	local mem = techage.get_mem(pos)
	mem.idx = ((mem.idx or 0) % #Commands) + 1
	outdir = networks.Flip[outdir]
	local res = Commands[mem.idx](pos, outdir)
	print(res)
	return true
end

local function after_dig_node(pos, oldnode, oldmetadata)
	Cable:after_dig_node(pos)
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

minetest.register_node("techage:ta5_fr_controller_pas", {
	description = S("TA5 Fusion Reactor Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_plasma.png^techage_frame_ta5.png",
	},
	after_place_node = after_place_node,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta5_fr_controller_act", {
	description = S("TA5 Fusion Reactor Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		{
			image = "techage_filling4_ta4.png^techage_appl_plasma4.png^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.5,
			},
		},
	},
	after_place_node = after_place_node,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

power.register_nodes({"techage:ta5_fr_controller_pas", "techage:ta5_fr_controller_act"}, Cable, "con", {"L", "R"})

