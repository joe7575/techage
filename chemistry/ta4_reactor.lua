--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Reactor

]]--

local S = techage.S
local M = minetest.get_meta
local Pipe = techage.LiquidPipe
local Cable = techage.ElectricCable
local liquid = networks.liquid

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
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
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
	return liquid.put(pos2, Pipe, outdir, payload.name, payload.amount, payload.player_name)
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
		elseif topic == "catalyst" then
			local pos2,node = Pipe:get_node(pos, 5)
			if not node or node.name ~= "techage:ta4_reactor" then
				return
			end
			local inv =  M(pos2):get_inventory()
			local stack = inv:get_stack("main", 1)
			return stack and stack:get_name()
		else
			return stand_cmnd(pos, topic, payload or {})
		end
	end,
})

liquid.register_nodes({"techage:ta4_reactor_fillerpipe"}, Pipe, "tank", {"U"}, {})

local function formspec()
	local title = S("TA4 Reactor")
	return "size[8,6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;7.8,0.5;#c6e8ff]"..
		"label[3,-0.1;"..minetest.colorize("#000000", title).."]"..
		"label[4.5,1.2;"..S("Catalyst").."]"..
		"list[context;main;3.5,1;1,1;]"..
		"list[current_player;main;0,2.3;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return 1
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
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
	after_place_node = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('main', 1)
		M(pos):set_string("formspec", formspec())
	end,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

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

minetest.register_lbm({
    label = "Upgrade reactor",
    name = "techage:update_reactor",

    nodenames = {
		"techage:ta4_reactor",
	},

    run_at_every_load = true,

    action = function(pos, node)
		local inv = M(pos):get_inventory()
		inv:set_size('main', 1)
		M(pos):set_string("formspec", formspec())
	end,
})
