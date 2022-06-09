--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Coal Power Station Firebox

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local firebox = techage.firebox

local CYCLE_TIME = 2
local BURN_CYCLE_FACTOR = 0.5

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local power = techage.transfer(
		{x=pos.x, y=pos.y+2, z=pos.z},
		nil,  -- outdir
		"trigger",  -- topic
		nil,  -- payload
		nil,  -- network
		{"techage:coalboiler_top"}  -- nodenames
	)
	nvm.burn_cycles = (nvm.burn_cycles or 0) - math.max((power or 0.02), 0.02)
	if nvm.burn_cycles <= 0 then
		local taken = firebox.get_fuel(pos)
		if taken then
			nvm.burn_cycles = (firebox.Burntime[taken:get_name()] or 1) / CYCLE_TIME * BURN_CYCLE_FACTOR
			nvm.burn_cycles_total = nvm.burn_cycles
		else
			nvm.running = false
			firebox.set_firehole(pos, false)
			M(pos):set_string("formspec", firebox.formspec(nvm))
			return false
		end
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", firebox.formspec(nvm))
	end
	return true
end

local function start_firebox(pos, nvm)
	if not nvm.running then
		nvm.running = true
		node_timer(pos, 0)
		firebox.set_firehole(pos, true)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

minetest.register_node("techage:coalfirebox", {
	description = S("TA3 Power Station Firebox"),
	inventory_image = "techage_coal_boiler_inv.png",
	tiles = {"techage_coal_boiler_mesh_top.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_12.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -16/32, -13/32, 13/32, 16/32, 13/32},
	},

	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),

	on_timer = node_timer,
	can_dig = firebox.can_dig,
	allow_metadata_inventory_put = firebox.allow_metadata_inventory_put,
	allow_metadata_inventory_take = firebox.allow_metadata_inventory_take,
	on_rightclick = firebox.on_rightclick,

	after_place_node = function(pos, placer)
		if firebox.is_free_position(pos, placer:get_player_name()) then
			techage.add_node(pos, "techage:coalfirebox")
			local nvm = techage.get_nvm(pos)
			nvm.running = false
			nvm.burn_cycles = 0
			local meta = M(pos)
			meta:set_string("formspec", firebox.formspec(nvm))
			local inv = meta:get_inventory()
			inv:set_size('fuel', 1)
			firebox.set_firehole(pos, false)
		else
			minetest.remove_node(pos)
			return true
		end
	end,

	on_destruct = function(pos)
		firebox.set_firehole(pos, nil)
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local nvm = techage.get_nvm(pos)
		start_firebox(pos, nvm)
		M(pos):set_string("formspec", firebox.formspec(nvm))
	end,
})

minetest.register_node("techage:coalfirehole", {
	description = S("TA3 Coal Power Station Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png",
		"techage_coal_boiler.png^techage_appl_firehole.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16,  6/16,  6/16, 6/16,  12/16},
		},
	},

	paramtype = "light",
	paramtype2 = "facedir",
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("techage:coalfirehole_on", {
	description = S("TA3 Coal Power Station Firebox"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		"techage_coal_boiler.png^[colorize:black:80",
		{
			image = "techage_coal_boiler4.png^[colorize:black:80^techage_appl_firehole4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.4,
			},
		},
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -6/16,  6/16,  6/16, 6/16,  12/16},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 8,
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})


techage.register_node({"techage:coalfirebox"}, {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.get_items(pos, inv, "fuel", num)
	end,
	on_push_item = function(pos, in_dir, stack)
		if firebox.Burntime[stack:get_name()] then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local nvm = techage.get_nvm(pos)
			start_firebox(pos, nvm)
			return techage.put_items(inv, "fuel", stack)
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "fuel", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "state" then
			return nvm.running and "running" or "stopped"
		elseif topic == "fuel" then
			return techage.fuel.get_fuel_amount(nvm)
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 128 then
			return 0, techage.get_node_lvm(pos).name
		elseif topic == 129 then
			return 0, {nvm.running and techage.RUNNING or techage.STOPPED}
		elseif topic == 132 then
			return 0, {techage.fuel.get_fuel_amount(nvm)}
		else
			return 2, ""
		end
	end,
})

minetest.register_craft({
	output = "techage:coalfirebox",
	recipe = {
		{'default:stone', 'default:stone', 'default:stone'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:stone', 'default:stone', 'default:stone'},
	},
})
