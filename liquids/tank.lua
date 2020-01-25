--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3/TA4 Tank, Oil Tank

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CAPACITY = 500

local function formspec(pos, mem)
	local update = ((mem.countdown or 0) > 0 and mem.countdown) or S("Update")
	return "size[8,6]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	liquid.formspec_liquid(2, 0, mem)..
	"button[5.5,0.5;2,1;update;"..update.."]"..
	"list[current_player;main;0,2.3;8,4;]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_move()
	return 0
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	minetest.after(0.5, liquid.move_item, pos, stack, CAPACITY, formspec)
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	mem.countdown = 10
	M(pos):set_string("formspec", formspec(pos, mem))
	minetest.get_node_timer(pos):start(2)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	mem.countdown = 10
	M(pos):set_string("formspec", formspec(pos, mem))
	minetest.get_node_timer(pos):start(2)
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	return liquid.is_empty(pos)
end


minetest.register_node("techage:ta3_tank", {
	description = S("TA3 Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_tank.png",
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('dst', 1)
	end,
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		mem.liquid = {}
		local number = techage.add_node(pos, "techage:ta3_tank")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec(pos, mem))
		meta:set_string("infotext", S("TA3 Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	on_timer = function(pos, elapsed)
		local mem = tubelib2.get_mem(pos)
		if mem.countdown then
			mem.countdown = mem.countdown - 1
			M(pos):set_string("formspec", formspec(pos, mem))
			return mem.countdown > 0
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos)
	end,
	liquid = {
		capa = CAPACITY,
		peek = liquid.srv_peek,
		put = function(pos, indir, name, amount)
			local leftover = liquid.srv_put(pos, indir, name, amount)
			local inv = M(pos):get_inventory()
			if not inv:is_empty("src") and inv:is_empty("dst") then
				liquid.fill_container(pos, inv)
			end
			return leftover
		end,
		take = liquid.srv_take,
	},
	networks = {
		pipe = {
			sides = techage.networks.AllSides, -- Pipe connection sides
			ntype = "tank",
		},
	},
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:oiltank", {
	description = S("Oil Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_metal.png^techage_framexl_ta3_top.png",
		"techage_filling_metal.png^techage_framexl_ta3_top.png",
		"techage_filling_metal.png^techage_framexl_ta3.png^techage_appl_explosive.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-6/8, -4/8, -6/8, 6/8, 6/8, 6/8},
	},
	selection_box = {
		type = "fixed",
		fixed = {-6/8, -4/8, -6/8, 6/8, 6/8, 6/8},
	},
	collision_box = {
		type = "fixed",
		fixed = {-6/8, -4/8, -6/8, 6/8, 6/8, 6/8},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('dst', 1)
	end,
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		mem.liquid = {}
		local number = techage.add_node(pos, "techage:oiltank")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec(pos, mem))
		meta:set_string("infotext", S("Oil Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	on_timer = function(pos, elapsed)
		local mem = tubelib2.get_mem(pos)
		if mem.countdown then
			mem.countdown = mem.countdown - 1
			M(pos):set_string("formspec", formspec(pos, mem))
			return mem.countdown > 0
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos)
	end,
	liquid = {
		capa = CAPACITY * 4,
		peek = liquid.srv_peek,
		put = function(pos, indir, name, amount)
			local leftover = liquid.srv_put(pos, indir, name, amount)
			local inv = M(pos):get_inventory()
			if not inv:is_empty("src") and inv:is_empty("dst") then
				liquid.fill_container(pos, inv)
			end
			return leftover
		end,
		take = liquid.srv_take,
	},
	networks = {
		pipe = {
			sides = techage.networks.AllSides, -- Pipe connection sides
			ntype = "tank",
		},
	},
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_tank", {
	description = S("TA4 Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('dst', 1)
	end,
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		mem.liquid = {}
		local number = techage.add_node(pos, "techage:ta4_tank")
		meta:set_string("node_number", number)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("formspec", formspec(pos, mem))
		meta:set_string("infotext", S("TA4 Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, outdir, tlib2, node)
		liquid.update_network(pos, outdir)
	end,
	on_timer = function(pos, elapsed)
		local mem = tubelib2.get_mem(pos)
		if mem.countdown then
			mem.countdown = mem.countdown - 1
			M(pos):set_string("formspec", formspec(pos, mem))
			return mem.countdown > 0
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos)
	end,
	liquid = {
		capa = CAPACITY * 2,
		peek = liquid.srv_peek,
		put = function(pos, indir, name, amount)
			local leftover = liquid.srv_put(pos, indir, name, amount)
			local inv = M(pos):get_inventory()
			if not inv:is_empty("src") and inv:is_empty("dst") then
				liquid.fill_container(pos, inv)
			end
			return leftover
		end,
		take = liquid.srv_take,
	},
	networks = {
		pipe = {
			sides = techage.networks.AllSides, -- Pipe connection sides
			ntype = "tank",
		},
	},
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

techage.register_node({"techage:ta3_tank", "techage:ta4_tank", "techage:oiltank"}, liquid.tubing)	

Pipe:add_secondary_node_names({"techage:ta3_tank", "techage:ta4_tank", "techage:oiltank"})

minetest.register_craft({
	output = "techage:ta3_tank 2",
	recipe = {
		{"techage:iron_ingot", "techage:ta3_barrel_empty", "group:wood"},
		{"techage:tubeS", "techage:ta3_barrel_empty", "techage:ta3_pipeS"},
		{"group:wood", "techage:ta3_barrel_empty", "techage:iron_ingot"},
	},
})

minetest.register_craft({
	output = "techage:oiltank",
	recipe = {
		{"", "", ""},
		{"techage:ta3_tank", "techage:iron_ingot", ""},
		{"techage:iron_ingot", "techage:ta3_tank", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_tank",
	recipe = {
		{"default:tin_ingot", "dye:blue", "default:steel_ingot"},
		{"", "techage:ta3_tank", ""},
		{"", "", ""},
	},
})
