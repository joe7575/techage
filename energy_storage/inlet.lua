--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Pipe Inlet

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local D = techage.Debug
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.BiogasPipe

minetest.register_node("techage:ta4_pipe_inlet", {
	description = S("TA4 Pipe Inlet"),
	tiles = {
		-- up, down, right, left, back, front
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png^techage_tes_inlet.png",
		"basic_materials_concrete_block.png^techage_tes_inlet.png",
	},
	
	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

-- for mechanical pipe connections
techage.power.register_node({"techage:ta4_pipe_inlet"}, {
	conn_sides = {"F", "B"},
	power_network  = Pipe,
})

local function volume(pos, in_dir)
	local mem = tubelib2.get_mem(pos)
	if not mem.pos1 or not mem.pos2 or not mem.volume then
		local dir = tubelib2.Dir6dToVector[in_dir]
		local pos2 = vector.add(pos, vector.multiply(dir, 8))
		local poses = minetest.find_nodes_in_area(pos, pos2, {"techage:ta4_pipe_inlet"})
		if #poses == 2 then
			mem.pos1 = poses[1]
			mem.pos2 = poses[2]
			local _, node_tbl = minetest.find_nodes_in_area(mem.pos1, mem.pos2, 
				{"default:gravel", "techage:ta4_pipe_inlet", 
				"basic_materials:concrete_block", "default:obsidian_glass",
				"techage:glow_gravel"})
			print(dump(node_tbl))
			return true
		end
	end
	return false
end

-- for logical communication
techage.register_node({"techage:ta4_pipe_inlet"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		print(P2S(pos), in_dir, topic, payload)
		if topic == "increment" then
			if transfer(pos, in_dir, topic, nil) then
				swap_node(pos, "techage:cooler_on")
				return true
			end
		elseif topic == "decrement" then
			swap_node(pos, "techage:cooler")
			return transfer(pos, in_dir, topic, nil)
		elseif topic == "volume" then
			return volume(pos, in_dir)
		end
		return false
	end
})

minetest.register_craft({
	type = 'shapeless',
	output = "techage:ta4_pipe_inlet",
	recipe = {"basic_materials:concrete_block", "techage:ta4_pipeS"},
})
