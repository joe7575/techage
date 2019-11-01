--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3/TA4 Tank

]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = techage.liquid
local networks = techage.networks

local function formspec_tank(x, y, liquid)
	local itemname = "techage:liquid"
	if liquid.amount and liquid.amount > 0 and liquid.name then
		itemname = liquid.name.." "..liquid.amount
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

local function formspec(liquid)
	return "size[8,6]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	formspec_tank(2.5, 0, liquid)..
	"list[current_player;main;0,2.3;8,4;]"
end

local function liquid_item(mem, stack)
	if mem.liquid and stack:get_count() == 1 then
		if not mem.liquid.name or mem.liquid.name == stack:get_name() then
			local def = techage.liquid.get_liquid_def(stack:get_name())
			if def then
				return def.size, def.container, def.inv_item
			end
		end
	end
end

local function move_item(mem, inv, stack)
	local amount, giving_back, inv_item = liquid_item(mem, stack)
	if amount and inv:room_for_item("dst", ItemStack(giving_back)) then
		mem.liquid.name = inv_item
		mem.liquid.amount = (mem.liquid.amount or 0) + amount
		inv:remove_item("src", stack)
		inv:add_item("dst", ItemStack(giving_back))	
		M(pos):set_string("formspec", formspec(mem.liquid))
		return true
	end
	return false
end

local function move_item2(pos, itemname, amount, giving_back, formspec)
	local mem = tubelib2.get_mem(pos)
	local inv = M(pos):get_inventory()
	if inv:room_for_item("dst", ItemStack(giving_back)) then
		mem.liquid.name = itemname
		mem.liquid.amount = (mem.liquid.amount or 0) + amount
		inv:remove_item("src", ItemStack(itemname))
		inv:add_item("dst", ItemStack(giving_back))	
		M(pos):set_string("formspec", formspec(mem.liquid))
	end
end
	
local function add_barrel(pos, stack, formspec)
	local mem = tubelib2.get_mem(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	if inv:room_for_item("src", stack) then
		--minetest.after(0.5, move_item, pos, stack:get_name(), amount, giving_back, formspec)
		return stack:get_count()
	end
	return 0
end

local function empty_barrel(pos, inv, stack)
	local mem = tubelib2.get_mem(pos)
	if inv:room_for_item("src", stack) then
		return move_item(mem, inv, stack)
	end
	return false
end
 
local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return add_barrel(pos, stack, formspec)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(mem.liquid))
	techage.networks.connections(pos, Pipe)
	print(mem.pipe.netID)
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("main")
end


minetest.register_node("techage:ta3_tank", {
	description = S("TA3 Tank"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_biogas.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_tube.png",
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
		local node = minetest.get_node(pos)
		local indir = techage.side_to_indir("R", node.param2)
		meta:set_int("indir", indir) -- from liquid point of view
		meta:set_string("formspec", formspec(mem.liquid))
		meta:set_string("infotext", S("TA3 Tank").." "..number)
		Pipe:after_place_node(pos)
	end,
	tubelib2_on_update2 = function(pos, node, tlib2)
		networks.update_network(pos, tlib2)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
		techage.remove_node(pos)
	end,
	liquid = {
		peek = function(pos, indir)
			print("ta3_tank.peek", indir, M(pos):get_int("indir"))
			if indir == M(pos):get_int("indir") then
				return liquid.srv_peek(pos, "main")
			end
		end,
		put = function(pos, indir, name, amount)
			if indir == M(pos):get_int("indir") then
				return liquid.srv_put(pos, "main", name, amount)
			end
		end,
		take = function(pos, indir, name, amount)
			if indir == M(pos):get_int("indir") then
				return liquid.srv_take(pos, "main", name, amount)
			end
		end,
	
	},
	networks = {
		pipe = {
			sides = {R = 1}, -- Pipe connection side
			ntype = "tank",
		},
	},
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:ta3_tank"})

--minetest.register_node("techage:ta4_tank", {
--	description = S("TA4 Tank"),
--	tiles = {
--		-- up, down, right, left, back, front
--		"techage_filling_ta4.png^techage_frame_ta4_top.png",
--		"techage_filling_ta4.png^techage_frame_ta4.png",
--		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_biogas.png",
--		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_tube.png",
--		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
--		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_tank.png",
--	},

--	on_construct = function(pos)
--		local meta = minetest.get_meta(pos)
--		local inv = meta:get_inventory()
--		inv:set_size('src', 1)
--		inv:set_size('dst', 1)
--	end,
	
--	liquid = {
--		peek = function(pos, indir)
--			if indir == M(pos):get_int("indir") then
--				return liquid.srv_peek(pos, "main")
--			end
--		end,
--		put = function(pos, indir, name, amount)
--			if indir == M(pos):get_int("indir") then
--				return liquid.srv_put(pos, "main", name, amount)
--			end
--		end,
--		take = function(pos, indir, name, amount)
--			if indir == M(pos):get_int("indir") then
--				return liquid.srv_take(pos, "main", name, amount)
--			end
--		end,
	
--	},
--	on_rightclick = on_rightclick,
--	can_dig = can_dig,
--	allow_metadata_inventory_put = allow_metadata_inventory_put,
--	allow_metadata_inventory_take = allow_metadata_inventory_take,
--	paramtype2 = "facedir",
--	on_rotate = screwdriver.disallow,
--	groups = {cracky=2},
--	is_ground_content = false,
--	sounds = default.node_sound_metal_defaults(),
--})

---- for mechanical pipe connections
--techage.power.register_node({"techage:ta4_tank"}, {
--	conn_sides = {"R"},
--	power_network  = Pipe,
--	after_place_node = function(pos, placer)
--		local meta = M(pos)
--		local mem = tubelib2.init_mem(pos)
--		mem.liquid = mem.liquid or {}
--		local number = techage.add_node(pos, "techage:ta4_tank")
--		meta:set_string("node_number", number)
--		meta:set_string("owner", placer:get_player_name())
--		local node = minetest.get_node(pos)
--		local indir = techage.side_to_indir("R", node.param2)
--		meta:set_int("indir", indir) -- from liquid point of view
--		meta:set_string("formspec", formspec(mem.liquid))
--		meta:set_string("infotext", S("TA4 Tank").." "..number)
--	end,
--	after_dig_node = function(pos, oldnode, oldmetadata, digger)
--		techage.remove_node(pos)
--	end,
--})

local function valid_indir(meta, indir)
	return tubelib2.Turn180Deg[meta:get_int("indir")] == indir
end

techage.register_node({"techage:ta3_tank", "techage:ta4_tank"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = M(pos)
		if valid_indir(meta, in_dir) then
			local inv = meta:get_inventory()
			return techage.get_items(inv, "dst", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = M(pos)
		if valid_indir(meta, in_dir) then
			local inv = meta:get_inventory()
			return empty_barrel(pos, inv, stack)
		end
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = M(pos)
		if valid_indir(meta, in_dir) then
			local inv = meta:get_inventory()
			return techage.put_items(inv, "dst", stack)
		end
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
