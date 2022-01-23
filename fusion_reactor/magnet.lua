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

local CAPACITY = 6
local SHELLBLOCKS = {"techage:ta5_fr_shell", "techage:ta5_fr_nucleus", "techage:ta5_magnet1", "techage:ta5_magnet2"}

minetest.register_node("techage:ta5_magnet1", {
	description = S("TA5 Fusion Reactor Magnet 1"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe1.png^techage_steel_tiles_top.png^[transformR180]",
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe2.png^techage_steel_tiles_top.png",
		"techage_collider_magnet.png^techage_steel_tiles_side.png",
		"techage_collider_magnet.png^techage_steel_tiles_side.png^[transformR180]",
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
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe1.png^techage_steel_tiles_top2.png^[transformR180]",
		"techage_collider_magnet.png^techage_appl_hole_ta5_pipe2.png^techage_steel_tiles_top2.png^[transformR270]",
		"techage_steel_tiles.png",
		"techage_collider_magnet.png^techage_steel_tiles_side.png^[transformR180]",
		"techage_collider_magnet.png^techage_steel_tiles_side.png",
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

power.register_nodes({"techage:ta5_magnet1"}, Cable, "con", {"B"})
liquid.register_nodes({"techage:ta5_magnet1", "techage:ta5_magnet2"}, Pipe, "tank", {"U", "D"}, {
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
	local pos1 = networks.get_relpos(pos, "F", param2)
	local node = minetest.get_node(pos1) or {}
	return node.name == "air"
end

local function swap_plasma(pos, name, param2)
	local pos1 = networks.get_relpos(pos, "F", param2)
	minetest.swap_node(pos1, {name = name, param2 = param2})
end

local function check_shell(pos, param2)
	local pos1 = networks.get_relpos(pos, "D", param2)
	local pos2 = networks.get_relpos(pos, "BU", param2)
	local _,t = minetest.find_nodes_in_area(pos1, pos2, SHELLBLOCKS)
	local cnt = 0
	for k,v in pairs(t) do
		cnt = cnt + v
	end
	return cnt == 6
end

local function check_nucleus(pos, param2)
	local pos1 = networks.get_relpos(pos, "B", param2)
	local node = minetest.get_node(pos1) or {}
	if node.name == "techage:ta5_fr_nucleus" then
		return pos1
	end
end

local function on_receive(pos, tlib2, topic, payload)
	--print("on_receive", topic)
	local nvm = techage.get_nvm(pos)
	if topic == "on" then
		nvm.running = true
	elseif topic == "off" then
		nvm.running = false
	end
end

local function rst_power(nvm)
	nvm.power = 0
	return true
end

local function inc_power(nvm)
	nvm.power = nvm.power or 0
	if nvm.power < 0 then nvm.power = 0 end
	nvm.power = nvm.power + 1
	return nvm.power <= 2
end

local function dec_power(nvm)
	nvm.power = nvm.power or 0
	if nvm.power > 0 then nvm.power = 0 end
	nvm.power = nvm.power - 1
	return nvm.power >= -2
end

local function on_request(pos, tlib2, topic)
	local nvm = techage.get_nvm(pos)
	nvm.liquid = nvm.liquid or {}
	nvm.liquid.amount = nvm.liquid.amount or 0
	if tlib2 == Cable then
		if topic == "connect" then
			return true
		elseif topic == "inc_power" then
			return inc_power(nvm)
		elseif topic == "test_plasma" then
			local node = minetest.get_node(pos) or {}
			return check_plasma(pos, node.param2)
		elseif topic == "test_shell" then
			local node = minetest.get_node(pos) or {}
			return check_shell(pos, node.param2)
		elseif topic == "test_nucleus" then
			local node = minetest.get_node(pos) or {}
			return check_nucleus(pos, node.param2)
		elseif topic == "no_gas" then
			nvm.liquid.amount = 0
			return true
		end
	else  -- Pipe
		if topic == "dec_power" then
			return dec_power(nvm)
		elseif topic == "test_gas_blue" then
			nvm.has_gas = true
			return nvm.liquid.amount == CAPACITY
		elseif topic == "test_gas_green" then
			local res = nvm.has_gas
			nvm.has_gas = false
			return res
		end
	end
	if topic == "rst_power" then
		return rst_power(nvm)
	end
	return false
end

control.register_nodes({"techage:ta5_magnet1", "techage:ta5_magnet2"}, {
		on_receive = on_receive,
		on_request = on_request,
	}
)

minetest.register_craftitem("techage:ta5_magnet_blank", {
	description = S("TA5 Fusion Reactor Magnet Blank"),
	inventory_image = "techage_collider_magnet.png^techage_appl_hole_electric.png",
})

minetest.register_craftitem("techage:ta5_magnet_shield", {
	description = S("TA5 Fusion Reactor Magnet Shield"),
	inventory_image = "techage_steel_tiles.png",
})

techage.furnace.register_recipe({
	output = "techage:ta5_magnet_shield 2",
	recipe = {"default:steel_ingot", "techage:usmium_powder", "techage:graphite_powder"},
	time = 2,

})

minetest.register_craft({
	output = "techage:ta5_magnet_blank 2",
	recipe = {
		{'default:steel_ingot', 'techage:electric_cableS', 'techage:aluminum'},
		{'techage:ta5_pipe1S', 'basic_materials:gold_wire', 'techage:ta5_pipe2S'},
		{'techage:aluminum', 'dye:brown', 'default:steel_ingot'},
	},
})

minetest.register_craft({
	output = "techage:ta5_magnet1",
	recipe = {
		{'', 'techage:ta5_magnet_shield', 'techage:ta5_magnet_blank'},
		{'', '', ''},
		{'', '', ''},
	},
})

minetest.register_craft({
	output = "techage:ta5_magnet2",
	recipe = {
		{'', 'techage:ta5_magnet_shield', 'techage:ta5_magnet_blank'},
		{'', '', 'techage:ta5_magnet_shield'},
		{'', '', ''},
	},
})
