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
local liquid = networks.liquid

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
	M(pos):set_string("infotext", S("Operational"))
	return true
end

local function peek_liquid(pos)
	local mem = techage.get_mem(pos)
	if is_ocean(pos) then
		mem.liquid_name = "techage:water"
		mem.liquid_amount = 1
	else
		mem.liquid_name = "techage:water"
		mem.liquid_amount = 0
	end
	return mem.liquid_name
end

local function take_liquid(pos, indir, name, amount)
	local mem = techage.get_mem(pos)
	if not mem.liquid_name then
		peek_liquid(pos)
	end
	return mem.liquid_amount or 0, mem.liquid_name
end


local function untake_liquid(pos, indir, name, amount)
	return 0
end

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
		Pipe:after_place_node(pos)
		is_ocean(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta4_waterinlet"},
	Pipe, "tank", {"U"}, {
		capa = 1,
		peek = peek_liquid,
		take = take_liquid,
		untake = untake_liquid,
	}
)

minetest.register_craft({
	output = "techage:ta4_waterinlet",
	recipe = {
		{"techage:ta4_carbon_fiber", "techage:ta3_pipeS", "techage:ta4_carbon_fiber"},
		{"techage:iron_ingot", "techage:ta3_barrel_empty", "techage:iron_ingot"},
	},
})
