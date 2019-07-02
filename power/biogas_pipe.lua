--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA4 Biogas pipes

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 1000, 
	show_infotext = false,
	tube_type = "biogas_pipe",
	primary_node_names = {"techage:biogas_pipeS", "techage:biogas_pipeA"}, 
	secondary_node_names = {"techage:gasflare", "techage:compressor"},
	after_place_tube = function(pos, param2, tube_type, num_tubes, tbl)
		minetest.swap_node(pos, {name = "techage:biogas_pipe"..tube_type, param2 = param2})
		M(pos):set_int("tl2_param2", param2)
	end,
})

Pipe:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	minetest.registered_nodes[node.name].after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
end)

techage.BiogasPipe = Pipe


-- Overridden method of tubelib2!
function Pipe:get_primary_node_param2(pos, dir) 
	return techage.get_primary_node_param2(pos, dir)
end

function Pipe:is_primary_node(pos, dir)
	return techage.is_primary_node(pos, dir)
end

Pipe:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	local clbk = minetest.registered_nodes[node.name].after_tube_update
	if clbk then
		clbk(node, pos, out_dir, peer_pos, peer_in_dir)
	else
		techage.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	end
end)



minetest.register_node("techage:biogas_pipeS", {
	description = S("TA3 Biogas Pipe"),
	tiles = {
		"techage_gaspipe.png^[transformR90",
		"techage_gaspipe.png^[transformR90",
		"techage_gaspipe.png",
		"techage_gaspipe.png",
		"techage_gaspipe_hole2.png",
		"techage_gaspipe_hole2.png",
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Pipe:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Pipe:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -1/8, -4/8,  1/8, 1/8, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3, techage_trowel = 1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("techage:biogas_pipeA", {
	description = S("TA3 Biogas Pipe"),
	tiles = {
		"techage_gaspipe_knee2.png",
		"techage_gaspipe_hole2.png^[transformR180",
		"techage_gaspipe_knee.png^[transformR270",
		"techage_gaspipe_knee.png",
		"techage_gaspipe_knee2.png",
		"techage_gaspipe_hole2.png",
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Pipe:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -4/8, -1/8, 1/8, 1/8,    1/8},
			{-2/8, -0.5, -2/8, 2/8, -13/32, 2/8},
			{-1/8, -1/8, -4/8, 1/8, 1/8,    -1/8},
			{-2/8, -2/8, -0.5, 2/8, 2/8,    -13/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3, techage_trowel = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	drop = "techage:biogas_pipeS",
})


local size1 = 1/8
local size2 = 2/8
local size3 = 13/32
local Boxes = {
	{
		{-size1, -size1,  size1, size1,  size1, 0.5 }, -- z+
		{-size2, -size2,  size3, size2,  size2, 0.5 }, -- z+
	},
	{
		{-size1, -size1, -size1, 0.5, size1, size1}, -- x+
		{ size3, -size2, -size2, 0.5, size2,  size2}, -- x+
	},
	{
		{-size1, -size1, -0.5,  size1,  size1,  size1}, -- z-
		{-size2, -size2, -0.5,  size2,  size2, -size3}, -- z-
	},
	{
		{-0.5,  -size1, -size1,  size1,  size1, size1}, -- x-
		{-0.5,  -size2, -size2, -size3,  size2, size2}, -- x-
	},
	{
		{-size1, -0.5,  -size1, size1,  size1, size1}, -- y-
		{-size2, -0.5,  -size2, size2, -size3, size2}, -- y-
	},
	{
		{-size1, -size1, -size1, size1,  0.5,  size1}, -- y+
		{-size2, size3,  -size2, size2,  0.5,  size2}, -- y+
	}
}

--techage.register_junction("techage:biogas_junction", 1/8, Boxes, Pipe, {
--	description = "TA3 Biogas Junction",
--	tiles = {"techage_gaspipe_junction.png"},
--	groups = {crumbly = 3, cracky = 3, snappy = 3, techage_trowel = 1},
--	sounds = default.node_sound_metal_defaults(),

--	after_place_node = function(pos, placer, itemstack, pointed_thing)
--		local meta = minetest.get_meta(pos)
--		meta:set_string("infotext", "Position "..S(pos))
--		Pipe:after_place_node(pos)
--		techage.sink_power_consumption(pos, 0)
--	end,

--	after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
--		local conn = minetest.deserialize(M(pos):get_string("connections")) or {}
--		conn[out_dir] = peer_pos
--		M(pos):set_string("connections", minetest.serialize(conn))
--		local name = "techage:biogas_junction"..techage.junction_type(conn)
--		minetest.swap_node(pos, {name = name, param2 = 0})
--		techage.sink_power_consumption(pos, 0)
--	end,
	
--	on_destruct = function(pos)
--		techage.sink_power_consumption(pos, 0)
--	end,

--	after_dig_node = function(pos, oldnode, oldmetadata, digger)
--		Pipe:after_dig_node(pos)
--	end,
--})

