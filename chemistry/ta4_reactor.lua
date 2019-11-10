--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Reactor

]]--

local S = techage.S
local Cable = techage.ElectricCable
local power = techage.power
local Pipe = techage.LiquidPipe
local networks = techage.networks
local liquid = techage.liquid

-- pos of the reactor stand
local function on_power(pos, mem)
	mem.running = true
end

local function on_nopower(pos, mem)
	mem.running = false
end

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

minetest.register_node("techage:ta4_reactor_stand", {
	description = S("TA4 Reactor"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_reactor_stand_top.png^[transformR90",
		"techage_reactor_stand_bottom.png^[transformFY^[transformR270",
		"techage_reactor_stand_front.png",
		"techage_reactor_stand_back.png",
		"techage_reactor_stand_side.png^[transformFX",
		"techage_reactor_stand_side.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16,  2/16, -8/16,   8/16, 4/16,   8/16 },
			
			{ -8/16, -8/16, -8/16,  -6/16,  8/16, -6/16 },
			{  6/16, -8/16, -8/16,   8/16,  8/16, -6/16 },
			{ -8/16, -8/16,  6/16,  -6/16,  8/16,  8/16 },
			{  6/16, -8/16,  6/16,   8/16,  8/16,  8/16 },
			
			{-1/8, -4/8, -1/8,   1/8, 4/8, 1/8},

			{-4/8, -1/8, -1/8,   4/8, 1/8,  1/8},
--			{-3/8, -1/8, -4/8,   3/8, 1/8, -3/8},
			{-4/8, -1/8, -3/8,  -3/8, 1/8,  3/8},

--			{-3/8, -1/8,  3/8,   3/8, 1/8,  4/8},
			{ 3/8, -1/8, -3/8,   4/8, 1/8,  3/8},
},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	networks = {
		pipe = {
			sides = {R=1}, -- Pipe connection sides
			ntype = "pump",
		},
	},
})

-- for electrical connections
techage.power.register_node({"techage:ta4_reactor_stand"}, {
	conn_sides = {"L"},
	power_network  = Cable,
})

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
		print(minetest.get_node(pos1).name)
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
		pipe = {
			sides = {U=1}, -- Pipe connection sides
			ntype = "tank",
		},
	},
})

-- controlled by the doser
techage.register_node({"techage:ta4_reactor_fillerpipe"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		-- pos of the reactor stand
		local pos2 = {x = pos.x, y = pos.y-2, z = pos.z}
		local mem = tubelib2.get_mem(pos2)
		if topic == "power" then
			power.consumer_alive(pos2, mem)
			return mem.running
		elseif topic == "can_start" then
			local pos1 = {x = pos.x, y = pos.y-1, z = pos.z}
			if minetest.get_node(pos1).name ~= "techage:ta4_reactor" then return false end
			if minetest.get_node(pos2).name ~= "techage:ta4_reactor_stand" then return false end
			return true
		elseif topic == "start" and payload then
			mem.running = true
			power.consumer_start(pos2, mem, payload.cycle_time or 0, payload.pwr_needed or 0)
			return true
		elseif topic == "stop" then
			mem.running = false
			power.consumer_stop(pos2, mem)
			return true
		end
	end,
})

minetest.register_node("techage:ta4_reactor_base", {
	description = S("TA4 Reactor Base"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_arrowXL.png^techage_appl_hole_pipe.png^[transformR270",
		"techage_concrete.png",
		"techage_concrete.png^techage_appl_hole_pipe.png",
		"techage_concrete.png",
		"techage_concrete.png",
		"techage_concrete.png",
	},
	
	after_place_node = function(pos, placer)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	networks = {
		pipe = {
			sides = {R=1}, -- Pipe connection sides
			ntype = "pump",
		},
	},
})

Pipe:add_secondary_node_names({
		"techage:ta4_reactor_base", 
		"techage:ta4_reactor_fillerpipe", 
		"techage:ta4_reactor_stand",
})
