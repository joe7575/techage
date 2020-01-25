--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Power Switch Box
]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local S = techage.S

local Cable = techage.ElectricCable
local power = techage.power
local networks = techage.networks

-- simpe rotation of a facedir node through all 3 axis positions
local Rotation = {[0]=
	11,8,12,10,14,13,16,15,18,15,5,19,21,20,23,22,1,0,3,2,7,4,9,6
}

local function get_conn_dirs(pos, node)
	local tbl = {[0]=
		{R=2,L=4}, {R=1,L=3}, {R=2,L=4}, {R=1,L=3},
		{R=2,L=4}, {D=5,U=6}, {R=2,L=4}, {D=5,U=6},
		{R=2,L=4}, {D=5,U=6}, {R=2,L=4}, {D=5,U=6},
		{D=5,U=6}, {R=1,L=3}, {D=5,U=6}, {R=1,L=3},
		{D=5,U=6}, {R=1,L=3}, {D=5,U=6}, {R=1,L=3},
		{R=2,L=4}, {R=1,L=3}, {R=2,L=4}, {R=1,L=3},
	}
	if M(pos):get_int("turned_off") == 1 then
		return {}
	end
	return tbl[node.param2]
end

local function update_network(pos, node)
--	power.update_network(pos, nil, Cable)
	for _,outdir in pairs(get_conn_dirs(pos, node)) do
		power.update_network(pos, outdir, Cable)
	end
end

local function on_rotate(pos, node, user, mode, new_param2)
	if minetest.is_protected(pos, user:get_player_name()) then
		return false
	end
	update_network(pos, node)
	node.param2 = Rotation[node.param2]
	minetest.swap_node(pos, node)
	return true
end

minetest.register_node("techage:powerswitch_box", {
	description = S("TA Power Switch Box"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_switch.png',
		'techage_electric_switch.png',
		'techage_electric_junction.png',
		'techage_electric_junction.png',
		'techage_electric_switch.png',
		'techage_electric_switch.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -2/4, -1/4, -1/4,  2/4, 1/4, 1/4},
		},
	},
	
	after_place_node = function(pos)
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos)
		Cable:after_dig_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node) 
		--print("powerswitch_box tubelib2_on_update2")
		update_network(pos, node)
	end,
	on_rightclick = function(pos, node, clicker)
		node.name = "techage:powerswitch_box_off"
		minetest.swap_node(pos, node)
		M(pos):set_int("turned_off", 1)
		minetest.sound_play("techage_button", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 5,
			})
		Cable:after_dig_node(pos)
		update_network(pos, node)
	end,
	
	networks = {
		ele1 = {
			get_sides = get_conn_dirs,
			--sides = networks.AllSides,
			ntype = "junc",
		},
	},
	
	paramtype = "light",
	sunlight_propagates = true,
	on_rotate = on_rotate,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, techage_trowel = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:powerswitch_box_off", {
	description = S("TA Power Switch Box"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_switch.png',
		'techage_electric_switch.png',
		'techage_electric_junction.png',
		'techage_electric_junction.png',
		'techage_electric_switch.png',
		'techage_electric_switch.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -2/4, -1/4, -1/4,  2/4, 1/4, 1/4},
		},
	},
	
	after_place_node = function(pos)
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos)
		Cable:after_dig_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node) 
		update_network(pos, node)
	end,
	on_rightclick = function(pos, node, clicker)
		node.name = "techage:powerswitch_box"
		minetest.swap_node(pos, node)
		M(pos):set_int("turned_off", 0)
		minetest.sound_play("techage_button", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 5,
			})
		Cable:after_dig_node(pos)
		update_network(pos, node)
	end,
	
	networks = {
		ele1 = {
			--sides = {},
			--sides = networks.AllSides,
			get_sides = get_conn_dirs,
			ntype = "", -- unknown type, acting as switch off
		},
	},
	
	paramtype = "light",
	sunlight_propagates = true,
	on_rotate = on_rotate,
	paramtype2 = "facedir",
	drop = "techage:powerswitch_box",
	groups = {choppy=2, cracky=2, crumbly=2, techage_trowel = 1, not_in_creative_inventory = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

Cable:add_secondary_node_names({"techage:powerswitch_box"})
