--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Distillation Tower

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid


local function orientation(pos, names)
	local node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
	for _,name in ipairs(names) do
		if node.name == name then
			local param2 = node.param2
			node = minetest.get_node(pos)
			node.param2 = param2
			minetest.swap_node(pos, node)
			return
		end
	end
	minetest.remove_node(pos)
	return true
end

local function after_place_node(pos, placer)
	Pipe:after_place_node(pos)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
end

minetest.register_node("techage:ta3_distiller_base", {
	description = S("TA3 Distillation Tower Base"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_concrete.png^techage_appl_arrowXL.png^techage_appl_hole_pipe.png",
		"techage_concrete.png",
		"techage_concrete.png",
		"techage_concrete.png",
		"techage_concrete.png^techage_appl_hole_pipe.png",
		"techage_concrete.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-6/8, -4/8, -6/8, 6/8, 4/8, 6/8},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

liquid.register_nodes({"techage:ta3_distiller_base"}, Pipe, "pump", {"B"}, {})

minetest.register_node("techage:ta3_distiller1", {
	description = S("TA3 Distillation Tower 1"),
	tiles = {"techage_distiller1.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_14.obj",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},

	after_place_node = function(pos, placer)
		local res = orientation(pos, {"techage:ta3_distiller_base"})
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "B"))
		after_place_node(pos, placer)
		return res
	end,
	after_dig_node = after_dig_node,

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta3_distiller1"}, Pipe, "pump", {"F"}, {})

minetest.register_node("techage:ta3_distiller2", {
	description = S("TA3 Distillation Tower 2"),
	tiles = {"techage_distiller2.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_14.obj",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},

	after_place_node = function(pos, placer)
		return orientation(pos, {"techage:ta3_distiller1", "techage:ta3_distiller3"})
	end,

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta3_distiller3", {
	description = S("TA3 Distillation Tower 3"),
	tiles = {"techage_distiller3.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_14.obj",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},

	after_place_node = function(pos, placer)
		local res = orientation(pos, {"techage:ta3_distiller2"})
		return res
	end,
	after_dig_node = after_dig_node,

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta3_distiller3"}, Pipe, "pump", {"B"}, {})

minetest.register_node("techage:ta3_distiller4", {
	description = S("TA3 Distillation Tower 4"),
	tiles = {"techage_distiller4.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_14.obj",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
	},

	after_place_node = function(pos, placer)
		local res = orientation(pos, {"techage:ta3_distiller3"})
		after_place_node(pos, placer)
		return res
	end,
	after_dig_node = after_dig_node,

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

liquid.register_nodes({"techage:ta3_distiller4"}, Pipe, "pump", {"U"}, {})

local Liquids = {"techage:bitumen", "techage:fueloil", "techage:naphtha", "techage:gasoline", "techage:gas"}
local YPos = {-1, 2, 4, 6, 7}

techage.register_node({"techage:ta3_distiller1"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "put" then
			local nvm = techage.get_nvm(pos)
			nvm.idx = nvm.idx or 1
			local outdir
			if nvm.idx == 5 then
				outdir = 6 -- up
			else
				outdir = M(pos):get_int("outdir")
			end
			local pos2 = {x = pos.x, y = pos.y + YPos[nvm.idx], z = pos.z}
			local leftover = liquid.put(pos2, Pipe, outdir, Liquids[nvm.idx], 1)
			if leftover == 0 then
				nvm.idx = (nvm.idx % 5) + 1
			end
			return leftover
		end
	end,
})

minetest.register_craft({
	output = 'techage:ta3_distiller2',
	recipe = {
		{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
		{'techage:iron_ingot', 'techage:ta3_barrel_empty', 'techage:iron_ingot'},
		{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'techage:ta3_distiller1',
	recipe = {
		{'', '', ''},
		{'techage:ta3_pipeS', 'techage:ta3_distiller2', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'techage:ta3_distiller3',
	recipe = {
		{'', '', ''},
		{'', 'techage:ta3_distiller2', 'techage:ta3_pipeS'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'techage:ta3_distiller4',
	recipe = {
		{'', 'techage:ta3_pipeS', ''},
		{'', 'techage:ta3_distiller2', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'techage:ta3_distiller_base',
	recipe = {
		{'basic_materials:concrete_block', 'techage:ta3_pipeS', 'basic_materials:concrete_block'},
		{'', 'techage:ta3_pipeS', 'techage:ta3_pipeS'},
		{'basic_materials:concrete_block', '', 'basic_materials:concrete_block'},
	}
})
