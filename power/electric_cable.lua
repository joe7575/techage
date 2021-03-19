--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA3 Electric Cables (AC)

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local power = techage.power

local ELE1_MAX_CABLE_LENGHT = 1000

local Cable = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = ELE1_MAX_CABLE_LENGHT, 
	show_infotext = false,
	tube_type = "ele1",
	primary_node_names = {"techage:electric_cableS", "techage:electric_cableA",
		"techage:power_line", "techage:power_lineS", "techage:power_lineA", 
		"techage:power_pole2", "techage:powerswitch_box"},
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		-- Handle "power line" nodes
		local name = minetest.get_node(pos).name
		if name == "techage:power_pole2" then
			M(pos):set_int("tl2_param2", param2)
			return
		elseif name == "techage:powerswitch_box" then
			minetest.swap_node(pos, {name = "techage:powerswitch_box", param2 = param2 % 32})
			M(pos):set_int("tl2_param2", param2)
			return
		elseif name == "techage:power_line" or name == "techage:power_lineS" or name == "techage:power_lineA" then
			minetest.swap_node(pos, {name = "techage:power_line"..tube_type, param2 = param2 % 32})
			M(pos):set_int("tl2_param2", param2)
			return
		end
		-- Don't replace "hidden" cable
		if M(pos):get_string("techage_hidden_nodename") == "" then
			minetest.swap_node(pos, {name = "techage:electric_cable"..tube_type, param2 = param2 % 32})
		end
		M(pos):set_int("tl2_param2", param2)
	end,
})


-- Overridden method of tubelib2!
function Cable:get_primary_node_param2(pos, dir) 
	return techage.get_primary_node_param2(pos, dir)
end

function Cable:is_primary_node(pos, dir)
	return techage.is_primary_node(pos, dir)
end

function Cable:get_secondary_node(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	if self.secondary_node_names[node.name] or 
			self.secondary_node_names[M(npos):get_string("techage_hidden_nodename")] then
		return node, npos, true
	end
end

function Cable:is_secondary_node(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	return self.secondary_node_names[node.name] or 
			self.secondary_node_names[M(npos):get_string("techage_hidden_nodename")]
end

minetest.register_node("techage:electric_cableS", {
	description = S("TA Electric Cable"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable_end.png",
		"techage_electric_cable_end.png",
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Cable:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/32, -3/32, -4/8,  3/32, 3/32, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("techage:electric_cableA", {
	description = S("TA Electric Cable"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_electric_cable.png",
		"techage_electric_cable_end.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable_end.png",
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.tl2_param2 then
			oldnode.param2 = oldmetadata.fields.tl2_param2
			Cable:after_dig_tube(pos, oldnode)
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/32, -4/8, -3/32,  3/32, 3/32,  3/32},
			{-3/32, -3/32, -4/8,  3/32, 3/32, -3/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, 
			techage_trowel = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
	drop = "techage:electric_cableS",
})

-- only needed for hidden nodes, cause they don't have a tubelib2_on_update2 callback
Cable:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
	power.update_network(pos, nil, Cable)
end)

minetest.register_craft({
	output = "techage:electric_cableS 6",
	recipe = {
		{"basic_materials:plastic_sheet", "", ""},
		{"", "default:copper_ingot", ""},
		{"", "", "basic_materials:plastic_sheet"},
	},
})

techage.ElectricCable = Cable
techage.ELE1_MAX_CABLE_LENGHT = ELE1_MAX_CABLE_LENGHT
