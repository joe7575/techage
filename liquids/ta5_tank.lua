--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Hyperloop Tank

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.LiquidPipe
local liquid = networks.liquid
local hyperloop = techage.hyperloop
local remote_pos = techage.hyperloop.remote_pos
local shared_tank = techage.shared_tank
local menu = techage.menu

local CAPACITY = 1000
local EX_POINTS = 20

minetest.register_node("techage:ta5_hl_tank", {
	description = S("TA5 Hyperloop Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_tank.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		local number = techage.add_node(pos, "techage:ta5_hl_tank")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", shared_tank.formspec(pos))
		meta:set_string("infotext", S("TA5 Hyperloop Tank").." "..number)
		Pipe:after_place_node(pos)
		hyperloop.after_place_node(pos, placer, "tank")
	end,
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		if techage.get_expoints(player) >= EX_POINTS then
			if techage.menu.eval_input(pos, hyperloop.SUBMENU, fields) then
				hyperloop.after_formspec(pos, fields)
				shared_tank.on_rightclick(pos, nil, player)
				M(pos):set_string("formspec", shared_tank.formspec(pos))
			end
		end
	end,
	on_timer = shared_tank.node_timer,
	on_rightclick = shared_tank.on_rightclick,
	on_punch = function(pos, node, puncher)
		return techage.liquid.on_punch(remote_pos(pos), node, puncher)
	end,
	can_dig = shared_tank.can_dig,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		hyperloop.after_dig_node(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta5_hl_tank"},
	Pipe, "tank", nil, {
		capa = CAPACITY,
		peek = shared_tank.peek_liquid,
		put = shared_tank.put_liquid,
		take = shared_tank.take_liquid,
		untake = shared_tank.untake_liquid,
	}
)

techage.register_node({"techage:ta5_hl_tank"}, techage.liquid.recv_message)

minetest.register_craft({
	output = "techage:ta5_hl_tank",
	recipe = {
		{"", "techage:ta5_aichip", ""},
		{"", "techage:ta4_tank", ""},
		{"", "", ""},
	},
})
