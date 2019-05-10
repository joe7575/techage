--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2/TA3/TA4 Gravel Rinser, washing sieved gravel to find more ores
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 10
local COUNTDOWN_TICKS = 10
local CYCLE_TIME = 4

local function formspec(self, pos, mem)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;3,3;]"..
	"item_image[0,0;1,1;default:gravel]"..
	"image[0,0;1,1;techage_form_mask.png]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, mem).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
	"list[context;dst;5,0;3,3;]"..
	"list[current_player;main;0,4;8,4;]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "src" then
		TRD(pos).State:start_if_standby(pos)
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end


local function determine_water_dir(pos)
	local pos1 = {x=pos.x+1, y=pos.y, z=pos.z}
	local pos2 = {x=pos.x-1, y=pos.y, z=pos.z}
	local pos3 = {x=pos.x, y=pos.y, z=pos.z+1}
	local pos4 = {x=pos.x, y=pos.y, z=pos.z-1}
	local node1 = minetest.get_node(pos1)
	local node2 = minetest.get_node(pos2)
	local node3 = minetest.get_node(pos3)
	local node4 = minetest.get_node(pos4)
	local ndef1 = minetest.registered_nodes[node1.name]
	local ndef2 = minetest.registered_nodes[node2.name]
	local ndef3 = minetest.registered_nodes[node3.name]
	local ndef4 = minetest.registered_nodes[node4.name]
	
	if ndef1 and ndef1.liquidtype == "flowing" and ndef2 and ndef2.liquidtype == "flowing" then
		if node1.param2 > node2.param2 then
			return 4
		elseif node1.param2 < node2.param2 then
			return 2
		end
	elseif ndef3 and ndef3.liquidtype == "flowing" and ndef4 and ndef4.liquidtype == "flowing" then
		if node3.param2 > node4.param2 then
			return 3
		elseif node3.param2 < node4.param2 then
			return 1
		end
	end
end

local function remove_obj(obj)
	if obj then
		obj:remove()
	end
end

local function set_velocity(obj, pos, vel)
	if obj then
		obj:set_velocity(vel)
	end
end

local function add_object(pos, name)
	local dir = determine_water_dir(pos)
	if dir then
		local obj = minetest.add_item(pos, ItemStack(name))
		local vel = vector.multiply(tubelib2.Dir6dToVector[dir], 0.3)
		minetest.after(0.8, set_velocity, obj, pos, vel)
		minetest.after(20, remove_obj, obj)
	end
end

local function washing(pos, trd, mem, inv)
	local src = ItemStack("techage:sieved_gravel")
	local dst = ItemStack("default:sand")
	if inv:contains_item("src", src) then
		if math.random(40) == 1 then
			add_object({x=pos.x, y=pos.y+1, z=pos.z}, "techage:usmium_nuggets")
		end
	else
		trd.State:idle(pos, mem)
		return
	end
	if not inv:room_for_item("dst", dst) then
		trd.State:idle(pos, mem)
		return
	end
	inv:add_item("dst", dst)
	inv:remove_item("src", src)
	trd.State:keep_running(pos, mem, COUNTDOWN_TICKS)
end

local function keep_running(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local trd = TRD(pos)
	local inv = M(pos):get_inventory()
	washing(pos, trd, mem, inv)
	return trd.State:is_active(mem)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	TRD(pos).State:state_button_event(pos, mem, fields)
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = M(pos):get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end


local tiles = {}
-- '#' will be replaced by the stage number
-- '{power}' will be replaced by the power PNG
tiles.pas = {
	-- up, down, right, left, back, front
	"techage_appl_rinser_top.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	{
		image = "techage_appl_rinser4_top.png^techage_frame4_ta#_top.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
}
tiles.def = {
	-- up, down, right, left, back, front
	"techage_appl_rinser_top.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png^techage_appl_defect.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png^techage_appl_defect.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png^techage_appl_defect.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png^techage_appl_defect.png",
}

local tubing = {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(inv, "dst", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("push_dir") == in_dir  or in_dir == 5 then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "src", stack)
		end
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "dst", stack)
		end
	end,
	on_recv_message = function(pos, topic, payload)
		local resp = TRD(pos).State:on_receive_message(pos, topic, payload)
		if resp then
			return resp
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		TRD(pos).State:on_node_load(pos)
	end,
	on_node_repair = function(pos)
		return TRD(pos).State:on_node_repair(pos)
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 = 
	techage.register_consumer("rinser", I("Gravel Rinser"), tiles, {
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-8/16, -8/16, -8/16,  8/16, 8/16, -6/16},
				{-8/16, -8/16,  6/16,  8/16, 8/16,  8/16},
				{-8/16, -8/16, -8/16, -6/16, 8/16,  8/16},
				{ 6/16, -8/16, -8/16,  8/16, 8/16,  8/16},
				{-6/16, -8/16, -6/16,  6/16, 6/16,  6/16},
				{-6/16,  6/16, -1/16,  6/16, 8/16,  1/16},
				{-1/16,  6/16, -6/16,  1/16, 8/16,  6/16},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-8/16, -8/16, -8/16,   8/16, 8/16, 8/16},
		},
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		has_item_meter = true,
		aging_factor = 10,
		formspec = formspec,
		tubing = tubing,
		after_place_node = function(pos, placer)
			local inv = M(pos):get_inventory()
			inv:set_size('src', 9)
			inv:set_size('dst', 9)
		end,
		can_dig = can_dig,
		node_timer = keep_running,
		on_receive_fields = on_receive_fields,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,1,2,4},
		power_consumption = {0,3,4,5},
	})

minetest.register_craft({
	output = node_name_ta2,
	recipe = {
		{"group:wood", "default:mese_crystal", "group:wood"},
		{"techage:tubeS", "techage:sieve", "techage:tubeS"},
		{"group:wood", "default:tin_ingot", "group:wood"},
	},
})


if minetest.global_exists("unified_inventory") then
	unified_inventory.register_craft_type("rinsing", {
		description = I("Rinsing"),
		icon = "techage_appl_rinser_top.png^techage_frame_ta2_top.png",
		width = 2,
		height = 2,
	})
end

function techage.add_rinser_recipe(recipe)
	if minetest.global_exists("unified_inventory") then
		recipe.items = {recipe.input}
		recipe.type = "rinsing"
		unified_inventory.register_craft(recipe)
	end
end	


techage.add_rinser_recipe({input="techage:sieved_gravel", output="techage:usmium_nuggets"})

techage.register_help_page(I("TA2 Gravel Rinser"), 
I([[Used to wash Sieved Gravel to get Usmium Nuggets.
The block has to be placed under flowing water.
The washed-out nuggets must be 
sucked in with a Hopper.]]), "techage:ta2_rinser_pas")