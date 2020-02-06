--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Reactor

]]--

local S = techage.S
local M = minetest.get_meta
local Pipe = techage.LiquidPipe
local networks = techage.networks
local liquid = techage.liquid

minetest.register_node("techage:ta4_reactor_fillerpipe", {
	description = S("TA4 Reactor Filler Pipe"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_reactor_filler_top.png",
		"techage_reactor_filler_top.png",
		"techage_reactor_filler_side.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-2/8, 13/32, -2/8, 2/8, 4/8, 2/8},
			{-1/8,  0/8, -1/8, 1/8, 4/8, 1/8},
			{-5/16, 0/8, -5/16, 5/16, 2/8, 5/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/8, 0/8, -2/8, 2/8, 4/8, 2/8},
	},
	after_place_node = function(pos)
		local pos1 = {x = pos.x, y = pos.y-1, z = pos.z}
		if minetest.get_node(pos1).name == "air" then
			local node = minetest.get_node(pos)
			minetest.remove_node(pos)
			minetest.set_node(pos1, node)
			Pipe:after_place_node(pos1)
		end
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	
	paramtype = "light",
	sunlight_propagates = true,	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	networks = {
		pipe2 = {
			sides = {U = 1}, -- Pipe connection sides
			ntype = "tank",
		},
	},
})

local function stand_cmnd(pos, cmnd, payload)
	return techage.transfer(
		{x = pos.x, y = pos.y-1, z = pos.z}, 
		5,  -- outdir
		cmnd,  -- topic
		payload,  -- payload
		nil,  -- network
		{"techage:ta4_reactor_stand"})
end

local function base_waste(pos, payload)
	local pos2 = {x = pos.x, y = pos.y-3, z = pos.z}
	local outdir = M(pos2):get_int("outdir")
	return liquid.put(pos2, outdir, payload.name, payload.amount, payload.player_name)
end

-- controlled by the doser
techage.register_node({"techage:ta4_reactor_fillerpipe"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "check" then
			local pos2,node = Pipe:get_node(pos, 5)
			if not node or node.name ~= "techage:ta4_reactor" then 
				return false
			end
			pos2,node = Pipe:get_node(pos2, 5)
			if not node or node.name ~= "techage:ta4_reactor_stand" then 
				return false
			end
			return true
		elseif topic == "waste" then
			return base_waste(pos, payload or {})
		else
			return stand_cmnd(pos, topic, payload or {})
		end
	end,
})

minetest.register_node("techage:ta4_reactor", {
	description = S("TA4 Reactor"),
	tiles = {"techage_reactor_side.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_12h.obj",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -23/32, -1/2, 1/2, 32/32, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -23/32, -1/2, 1/2, 32/32, 1/2},
	},

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:ta4_reactor_fillerpipe"})

minetest.register_craft({
	output = 'techage:ta4_reactor',
	recipe = {
		{'default:steel_ingot', 'techage:ta3_pipeS', 'default:steel_ingot'},
		{'techage:iron_ingot', '', 'techage:iron_ingot'},
		{'default:steel_ingot', 'techage:ta3_pipeS', 'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'techage:ta4_reactor_fillerpipe',
	recipe = {
		{'', '', ''},
		{'', 'techage:ta3_pipeS', ''},
		{'default:steel_ingot', 'basic_materials:motor', 'default:steel_ingot'},
	}
})
