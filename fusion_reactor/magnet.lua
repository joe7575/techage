--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fusion Reactor Magnet

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local Pipe = techage.GasPipe
local power = networks.power
local liquid = networks.liquid
local control = networks.control
local tubelib2_get_pos = tubelib2.get_pos
local tubelib2_side_to_dir = tubelib2.side_to_dir

local CAPACITY = 20
local SHELLBLOCKS = {"techage:ta5_fr_shell1", "techage:ta5_fr_shell2"}

local function get_pos(pos, sides, param2)
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	for side in sides:gmatch"." do
		pos1 = tubelib2_get_pos(pos1, tubelib2_side_to_dir(side, param2))
	end
	return pos1
end

minetest.register_node("techage:ta5_magnet1", {
	description = S("TA5 Fusion Reactor Magnet 1"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe.png^techage_steel_tiles_top.png^[transformR180]",
		"techage_collider_magnet.png^techage_steel_tiles_top.png",
		"techage_collider_magnet.png^techage_steel_tiles_side.png",
		"techage_collider_magnet.png^techage_appl_hole_electric.png^techage_steel_tiles_side.png^[transformR180]",
		"techage_collider_magnet.png^techage_appl_hole_electric.png",
		"techage_steel_tiles.png",
	},
	after_place_node = function(pos, placer, itemstack)
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,
	ta_rotate_node = function(pos, node, new_param2)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		minetest.swap_node(pos, {name = node.name, param2 = new_param2})
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta5_magnet2", {
	description = S("TA5 Fusion Reactor Magnet 2"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe.png^techage_steel_tiles_top2.png^[transformR180]",
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe.png^techage_steel_tiles_top2.png^[transformR270]",
		"techage_steel_tiles.png",
		"techage_collider_magnet.png^techage_appl_hole_electric.png^techage_steel_tiles_side.png^[transformR180]",
		"techage_collider_magnet.png^techage_appl_hole_electric.png^techage_steel_tiles_side.png",
		"techage_steel_tiles.png",
	},
	after_place_node = function(pos, placer, itemstack)
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,
	ta_rotate_node = function(pos, node, new_param2)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		minetest.swap_node(pos, {name = node.name, param2 = new_param2})
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta5_magnet3", {
	description = S("TA5 Fusion Reactor Magnet 3"),
	drawtype = "nodebox",
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe.png^techage_steel_tiles_top.png^[transformR180]",
		"techage_collider_magnet.png^techage_steel_tiles_top.png",
		"techage_collider_magnet.png^techage_appl_hole_electric.png^techage_steel_tiles_side.png",
		"techage_collider_magnet.png^techage_appl_hole_electric.png^techage_steel_tiles_side.png^[transformR180]",
		"techage_magnet_hole.png",
		"techage_steel_tiles.png",
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16,  8/16,  2/16},
			{-8/16, -8/16,  2/16, -2/16,  8/16,  8/16},
			{ 2/16, -8/16,  2/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16,  2/16,  8/16, -2/16,  8/16},
			{-8/16,  2/16,  2/16,  8/16,  8/16,  8/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},
	after_place_node = function(pos, placer, itemstack)
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,
	ta_rotate_node = function(pos, node, new_param2)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		minetest.swap_node(pos, {name = node.name, param2 = new_param2})
		Pipe:after_place_node(pos)
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = "blend",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

power.register_nodes({"techage:ta5_magnet1", "techage:ta5_magnet2"}, Cable, "con", {"L", "B"})
power.register_nodes({"techage:ta5_magnet3"}, Cable, "con", {"L", "R"})
liquid.register_nodes({"techage:ta5_magnet1", "techage:ta5_magnet2", "techage:ta5_magnet3"}, Pipe, "tank", {"U"}, {
	capa = CAPACITY,
	peek = function(pos, indir)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end,
	put = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_put(nvm, name, amount, CAPACITY)
	end,
	take = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_take(nvm, name, amount)
	end,
	untake = function(pos, indir, name, amount)
		local nvm = techage.get_nvm(pos)
		liquid.srv_put(nvm, name, amount, CAPACITY)
	end,
})

local function check_plasma(pos, param2)
	local pos1 = get_pos(pos, "F", param2)
	local node = minetest.get_node(pos1) or {}
	techage.mark_position("singleplayer", pos1, "pos1", nil, 2)
	return node.name == "techage:plasma1" or node.name == "techage:plasma2"
end

local function swap_plasma(pos, name, param2)
	local pos1 = get_pos(pos, "F", param2)
	minetest.swap_node(pos1, {name = name, param2 = param2})
end

local function check_steel(pos, param2)
	local pos1 = get_pos(pos, "D", param2)
	local pos2 = get_pos(pos, "BU", param2)
	local _,t = minetest.find_nodes_in_area(pos1, pos2, SHELLBLOCKS)
	local cnt = 0
	for k,v in pairs(t) do
		cnt = cnt + v
	end
	print("shell", cnt)
	return cnt == 5
end

local function on_receive(pos, tlib2, topic, payload)
	local nvm = techage.get_nvm(pos)
	if topic == "on" then
		nvm.running = true
	elseif topic == "off" then
		nvm.running = false
	end
end

local function on_receive3(pos, tlib2, topic, payload)
	local nvm = techage.get_nvm(pos)
	if topic == "on" then
		nvm.running = true
		local node = minetest.get_node(pos) or {}
		swap_plasma(pos, "techage:plasma2", node.param2)
	elseif topic == "off" then
		nvm.running = false
		local node = minetest.get_node(pos) or {}
		swap_plasma(pos, "techage:plasma1", node.param2)
	end
end

local function on_request(pos, tlib2, topic)
	local nvm = techage.get_nvm(pos)
	if topic == "state" then
		if not nvm.liquid or not nvm.liquid.amount or nvm.liquid.amount < CAPACITY then
			return false, "no gas"
		elseif nvm.liquid.name ~= "techage:isobutane" then
			return false, "wrong gas"
		elseif nvm.running then
			return false, "stopped"
		end
		return true, "running"
	elseif topic == "test_plasma" then
		local node = minetest.get_node(pos) or {}
		return check_plasma(pos, node.param2)
	elseif topic == "test_shell" then
		local node = minetest.get_node(pos) or {}
		return check_steel(pos, node.param2)
	end
	return false
end

control.register_nodes({"techage:ta5_magnet1", "techage:ta5_magnet2"}, {
		on_receive = on_receive,
		on_request = on_request,
	}
)

control.register_nodes({"techage:ta5_magnet3"}, {
		on_receive = on_receive3,
		on_request = on_request,
	}
)
