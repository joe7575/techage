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
local LQD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).liquid end
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local CAPACITY = 500


local function formspec_tank(x, y, mem)
	local itemname = "techage:liquid"
	if mem.liquid and mem.liquid.amount and mem.liquid.amount > 0 and mem.liquid.name then
		itemname = mem.liquid.name.." "..mem.liquid.amount
	end
	return "container["..x..","..y.."]"..
		"background[0,0;3,2.05;techage_form_grey.png]"..
		"image[0,0;1,1;techage_form_input_arrow.png]"..
		techage.item_image(1, 0, itemname)..
		"image[2,0;1,1;techage_form_output_arrow.png]"..
		"image[1,1;1,1;techage_form_arrow.png]"..
		"list[context;src;0,1;1,1;]"..
		"list[context;dst;2,1;1,1;]"..
		--"listring[]"..
		"container_end[]"
end	

local function formspec(mem)
	local update = ((mem.countdown or 0) > 0 and mem.countdown) or S("Update")
	return "size[8,6]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	formspec_tank(2, 0, mem)..
	"button[5.5,0.5;2,1;update;"..update.."]"..
	"list[current_player;main;0,2.3;8,4;]"
end

local function fill_container(pos, inv)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	local empty_container = inv:get_stack("src", 1):get_name()
	local full_container = liquid.get_full_container(empty_container, mem.liquid.name)
	if empty_container and full_container then
		local ldef = liquid.get_liquid_def(full_container)
		if ldef and mem.liquid.amount - ldef.size >= 0 then 
			if inv:room_for_item("dst", ItemStack(full_container)) then
				inv:remove_item("src", ItemStack(empty_container))
				inv:add_item("dst", ItemStack(full_container))
				mem.liquid.amount = mem.liquid.amount - ldef.size
				if mem.liquid.amount == 0 then
					mem.liquid.name = nil
				end
			end
		end
	end
end

local function empty_container(pos, inv)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	local stack = inv:get_stack("src", 1)
	local ldef = liquid.get_liquid_def(stack:get_name())
	if ldef and (not mem.liquid.name or ldef.inv_item == mem.liquid.name) then
		local capa = LQD(pos).capa
		local amount = stack:get_count() * ldef.size
		if mem.liquid.amount + amount <= capa then 
			if inv:room_for_item("dst", ItemStack(ldef.container)) then
				inv:remove_item("src", stack)
				inv:add_item("dst", ItemStack(ldef.container))
				mem.liquid.amount = mem.liquid.amount + amount
				mem.liquid.name = ldef.inv_item
			end
		end
	end
end

local function move_item(pos, stack)
	local mem = tubelib2.get_mem(pos)
	local inv = M(pos):get_inventory()
	if liquid.is_container_empty(stack:get_name()) then
		fill_container(pos, inv)
	else
		empty_container(pos, inv)
	end
	M(pos):set_string("formspec", formspec(mem))
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
	minetest.after(0.5, move_item, pos, stack)
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	mem.countdown = 10
	M(pos):set_string("formspec", formspec(mem))
	minetest.get_node_timer(pos):start(2)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	mem.countdown = 10
	M(pos):set_string("formspec", formspec(mem))
	minetest.get_node_timer(pos):start(2)
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local mem = tubelib2.get_mem(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("src") and inv:is_empty("dst") and (not mem.liquid or (mem.liquid.amount or 0) == 0)
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
		meta:set_string("formspec", formspec(mem))
		meta:set_string("infotext", S("TA3 Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos)
	end,
	on_timer = function(pos, elapsed)
		local mem = tubelib2.get_mem(pos)
		if mem.countdown then
			mem.countdown = mem.countdown - 1
			M(pos):set_string("formspec", formspec(mem))
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
				fill_container(pos, inv)
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
		meta:set_string("formspec", formspec(mem))
		meta:set_string("infotext", S("Oil Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos)
	end,
	on_timer = function(pos, elapsed)
		local mem = tubelib2.get_mem(pos)
		if mem.countdown then
			mem.countdown = mem.countdown - 1
			M(pos):set_string("formspec", formspec(mem))
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
				fill_container(pos, inv)
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
		meta:set_string("formspec", formspec(mem))
		meta:set_string("infotext", S("TA4 Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, dir, tlib2, node)
		liquid.update_network(pos)
	end,
	on_timer = function(pos, elapsed)
		local mem = tubelib2.get_mem(pos)
		if mem.countdown then
			mem.countdown = mem.countdown - 1
			M(pos):set_string("formspec", formspec(mem))
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
				fill_container(pos, inv)
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

techage.register_node({"techage:ta3_tank", "techage:ta4_tank", "techage:oiltank"}, {
	on_pull_item = function(pos, in_dir, num)
		local inv = M(pos):get_inventory()
		if not inv:is_empty("dst") then
			local taken = techage.get_items(inv, "dst", num) 
			if not inv:is_empty("src") then
				fill_container(pos, inv)
			end
			return taken
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local inv = M(pos):get_inventory()
		if inv:room_for_item("src", stack) then
			inv:add_item("src", stack)
			if liquid.is_container_empty(stack:get_name()) then
				fill_container(pos, inv)
			else
				empty_container(pos, inv)
			end
			return true
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = M(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "dst", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local meta = M(pos)
			local inv = meta:get_inventory()
			return techage.get_inv_state(inv, "main")
		else
			return "unsupported"
		end
	end,
})	

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
