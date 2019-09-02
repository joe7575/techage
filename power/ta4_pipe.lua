--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Biogas/Stream/oil pipes

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Pipe = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = 1000, 
	show_infotext = false,
	tube_type = "ta4_pipe",
	primary_node_names = {"techage:ta4_pipeS", "techage:ta4_pipeA"}, 
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		-- Don't replace "hidden" cable
		if M(pos):get_string("techage_hidden_nodename") == "" then
			minetest.swap_node(pos, {name = "techage:ta4_pipe"..tube_type, param2 = param2 % 32})
		end
		M(pos):set_int("tl2_param2", param2)
	end,
})

techage.BiogasPipe = Pipe


-- Overridden method of tubelib2!
function Pipe:get_primary_node_param2(pos, dir) 
	return techage.get_primary_node_param2(pos, dir)
end

function Pipe:is_primary_node(pos, dir)
	return techage.is_primary_node(pos, dir)
end

function Pipe:get_secondary_node(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	if self.secondary_node_names[node.name] or 
			self.secondary_node_names[M(npos):get_string("techage_hidden_nodename")] then
		return node, npos
	end
end

function Pipe:is_secondary_node(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	return self.secondary_node_names[node.name] or 
			self.secondary_node_names[M(npos):get_string("techage_hidden_nodename")]
end

minetest.register_node("techage:ta4_pipeS", {
	description = S("TA4 Pipe"),
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
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_pipeA", {
	description = S("TA4 Pipe"),
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
	groups = {crumbly = 2, cracky = 2, snappy = 2, techage_trowel = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta4_pipeS",
})

Pipe:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	if minetest.registered_nodes[node.name].after_tube_update then
		minetest.registered_nodes[node.name].after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	else
		techage.power.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir, Cable)
	end
end)

minetest.register_craft({
	output = "techage:ta4_pipeS 3",
	recipe = {
		{'', '', "default:steel_ingot"},
		{'dye:yellow', 'techage:meridium_ingot', ''},
		{"default:steel_ingot", '', ''},
	},
})

