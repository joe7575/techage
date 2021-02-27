--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA4 Water Inlet (replacement for the water pump)
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local function is_ocean(pos)
	if pos.y > 1 then 
		M(pos):set_string("infotext", S("Error: Not on sea level!"))
		return false 
	end
	local node = techage.get_node_lvm({x = pos.x, y = pos.y - 1, z = pos.z})
	if node.name ~= "default:water_source" then 
		M(pos):set_string("infotext", S("Error: No water available!"))
		return false 
	end
	if node.param2 == 1 then 
		M(pos):set_string("infotext", S("Error: No natural water!"))
		return false
	end
	return true
end

local function srv_peek(pos)
	local nvm = techage.get_nvm(pos)
	if is_ocean(pos) then
		nvm.liquid.name = "techage:water"
		nvm.liquid.amount = 1
	else
		nvm.liquid.name = nil
		nvm.liquid.amount = 0
	end
	return nvm.liquid.name
end

local function take_liquid(pos, indir, name, amount)
	local nvm = techage.get_nvm(pos)
	return nvm.liquid.amount, nvm.liquid.name
end
	
local function untake_liquid(pos, indir, name, amount)
	return 0
end

local netw_def = {
	pipe2 = {
		sides = {U = 1}, -- Pipe connection sides
		ntype = "tank",
	},
}

minetest.register_node("techage:ta4_waterinlet", {
	description = S("TA4 Water Inlet"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_waterpump_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		Pipe:after_place_node(pos)
		srv_peek(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	--on_timer = node_timer,
	--on_punch = liquid.on_punch,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,
	liquid = {
		capa = 1,
		peek = liquid.srv_peek,
		take = take_liquid,
		untake = untake_liquid, 
	},
	networks = netw_def,
	--on_rightclick = on_rightclick,
	--can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:ta4_waterinlet"})

minetest.register_craft({
	output = "techage:ta4_waterinlet",
	recipe = {
		{"techage:ta4_carbon_fiber", "techage:ta3_pipeS", "techage:ta4_carbon_fiber"},
		{"techage:iron_ingot", "techage:ta3_barrel_empty", "techage:iron_ingot"},
	},
})

