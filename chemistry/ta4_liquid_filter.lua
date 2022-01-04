--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg
	Copyright (C) 2020 Thomas S.

	AGPL v3
	See LICENSE.txt for more information

	TA4 Liquid Filter

]]--

-- For now, the Red Mud -> Lye/Desert Cobble recipe is hardcoded.
-- If necessary, this can be adjusted later.

local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

-- Checks if the filter structure is ok and returns the amount of gravel
local function checkStructure(pos)
	local pos1_outer = {x=pos.x-2,y=pos.y-7,z=pos.z-2}
	local pos2_outer = {x=pos.x+2,y=pos.y,z=pos.z+2}
	local pos1_inner = {x=pos.x-1,y=pos.y-1,z=pos.z-1}
	local pos2_inner = {x=pos.x+1,y=pos.y-7,z=pos.z+1}
	local pos1_top = {x=pos.x-1,y=pos.y,z=pos.z-1}
	local pos2_top = {x=pos.x+1,y=pos.y,z=pos.z+1}
	local pos1_bottom = {x=pos.x-2,y=pos.y-8,z=pos.z-2}
	local pos2_bottom = {x=pos.x+2,y=pos.y-8,z=pos.z+2}


	local gravel = minetest.find_nodes_in_area(pos1_inner, pos2_inner, {"default:gravel"})

	local _, inner = minetest.find_nodes_in_area(pos1_inner, pos2_inner, {
		"default:desert_cobble"
	})
	if #gravel + (inner["default:desert_cobble"] or 0) ~= 63 then -- 7x3x3=63
		return false, gravel
	end

	local _, outer = minetest.find_nodes_in_area(pos1_outer, pos2_outer, {
		"basic_materials:concrete_block",
		"default:obsidian_glass"
	})

	-- +      4x7=28 (corners)
	-- +  5x5-3x3=16 (top ring)
	-- ------------------------------
	-- =          44 (total concrete)
	if outer["basic_materials:concrete_block"] ~= 44 then
		return false, gravel
	end
	if outer["default:obsidian_glass"] ~= 84 then -- 4x7x3=84
		return false, gravel
	end

	local _,top = minetest.find_nodes_in_area(pos1_top, pos2_top, {"air"})
	if top["air"] ~= 8 then
		return false, gravel
	end

	local _,bottom = minetest.find_nodes_in_area(pos1_bottom, pos2_bottom, {
		"basic_materials:concrete_block",
		"techage:ta3_pipe_wall_entry"
	})
	if bottom["basic_materials:concrete_block"] ~= 22 or bottom["techage:ta3_pipe_wall_entry"] ~= 2 then
		return false, gravel
	end

	if minetest.get_node({x=pos.x,y=pos.y-8,z=pos.z}).name ~= "techage:ta4_liquid_filter_sink" then
		return false, gravel
	end

	return true, gravel
end

minetest.register_node("techage:ta4_liquid_filter_filler", {
	description = S("TA4 Liquid Filter Filler"),
	tiles = {
		-- up, down, right, left, back, front
		"basic_materials_concrete_block.png^techage_gaspipe_hole.png",
		"basic_materials_concrete_block.png^techage_liquid_filter_filler_bottom.png",
		"basic_materials_concrete_block.png^techage_liquid_filter_filler.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/8, -0.5, -6/8, 6/8, -0.25, 6/8},
			{-7/16, -0.25, -7/16, 7/16, 0, 7/16},
			{-1/8, 0, -1/8, 1/8, 13/32, 1/8},
			{-2/8, 13/32, -2/8, 2/8, 0.5, 2/8},
		},
	},
	after_place_node = function(pos)
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = techage.CLIP,
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta4_liquid_filter_filler"},
	Pipe, "tank", {"U"}, {
		capa = 1,
		peek = function(...) return nil end,
		put = function(pos, indir, name, amount)
			local structure_ok, gravel = checkStructure(pos)
			if name ~= "techage:redmud" then
				return amount
			end
			if not structure_ok then
				return amount
			end
			if #gravel < 33 then
				return amount
			end
			if math.random() < 0.5 then
				local out_pos = {x=pos.x,y=pos.y-8,z=pos.z}
				local leftover = liquid.put(out_pos, Pipe, networks.side_to_outdir(out_pos, "R"), "techage:lye", 1)
				if leftover > 0 then
					return amount
				end
			else
				minetest.swap_node(gravel[math.random(#gravel)], {name = "default:desert_cobble"})
			end
			return amount - 1
		end,
		take = function(...) return 0 end,
		untake = function(pos, outdir, name, amount, player_name)
			return amount
		end,
	}
)


minetest.register_node("techage:ta4_liquid_filter_sink", {
	description = S("TA4 Liquid Filter Sink"),
	tiles = {
		-- up, down, right, left, back, front
		"basic_materials_concrete_block.png^techage_appl_arrow.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png^techage_appl_hole_pipe.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 3/16, 0.5},
			{-0.5, 3/16, -0.5, 0.5, 5/16, -0.25},
			{0.25, 3/16, -0.5, 0.5, 5/16, 0.5},
			{-0.5, 3/16, 0.25, 0.5, 5/16, 0.5},
			{-0.5, 3/16, -0.5, -0.25, 5/16, 0.5}
		},
	},
	after_place_node = function(pos)
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta4_liquid_filter_sink"},
	Pipe, "pump", {"R"}, {}
)


minetest.register_craft({
	output = 'techage:ta4_liquid_filter_filler',
	recipe = {
		{'', 'techage:ta3_pipeS', ''},
		{'basic_materials:concrete_block', 'basic_materials:concrete_block', 'basic_materials:concrete_block'},
		{'', 'default:steel_ingot', ''},
	}
})

minetest.register_craft({
	output = 'techage:ta4_liquid_filter_sink 2',
	recipe = {
		{'basic_materials:concrete_block', '', 'basic_materials:concrete_block'},
		{'basic_materials:concrete_block', 'techage:ta3_pipeS', 'techage:ta3_pipeS'},
		{'basic_materials:concrete_block', 'basic_materials:concrete_block', 'basic_materials:concrete_block'},
	}
})
