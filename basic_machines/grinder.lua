--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2/TA3/TA4 Grinder, grinding Cobble/Basalt to Gravel
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).consumer end

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 6
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4


-- Grinder recipes
local Recipes = {}

local function formspec(self, pos, mem)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;3,3;]"..
	"item_image[0,0;1,1;default:cobble]"..
	"image[0,0;1,1;techage_form_mask.png]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, mem).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;"..self:get_state_button_image(mem)..";state_button;]"..
	"list[context;dst;5,0;3,3;]"..
	"item_image[5,0;1,1;default:gravel]"..
	"image[5,0;1,1;techage_form_mask.png]"..
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
		CRD(pos).State:start_if_standby(pos)
	end
	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = M(pos):get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function src_to_dst(src_stack, idx, num_items, inv, dst_name) 
	local taken = src_stack:take_item(num_items)
	local output = ItemStack(dst_name)
	output:set_count(output:get_count() * taken:get_count())
	if inv:room_for_item("dst", output) then
		inv:set_stack("src", idx, src_stack)
		inv:add_item("dst", output)
		return true
	end
	return false
end
			
local function grinding(pos, crd, mem, inv)
	local num_items = 0
	for idx,stack in ipairs(inv:get_list("src")) do
		if not stack:is_empty() then
			local name = stack:get_name()
			if Recipes[name] then
				if src_to_dst(stack, idx, crd.num_items, inv, Recipes[name]) then
					crd.State:keep_running(pos, mem, COUNTDOWN_TICKS)
				else
					crd.State:blocked(pos, mem)
				end
			else
				crd.State:fault(pos, mem)
			end
			return
		end
	end
	crd.State:idle(pos, mem)
end

local function keep_running(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	grinding(pos, crd, mem, inv)
	return crd.State:is_active(mem)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	CRD(pos).State:state_button_event(pos, mem, fields)
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
	"techage_appl_grinder.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_grinder2.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_grinder2.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	{
		image = "techage_appl_grinder4.png^techage_frame4_ta#_top.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 1.0,
		},
	},
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_grinder2.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_grinder2.png^techage_frame_ta#.png",
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
		if meta:get_int("push_dir") == in_dir or in_dir == 5 then
			local inv = M(pos):get_inventory()
			CRD(pos).State:start_if_standby(pos)
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
		local resp = CRD(pos).State:on_receive_message(pos, topic, payload)
		if resp then
			return resp
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		CRD(pos).State:on_node_load(pos)
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 = 
	techage.register_consumer("grinder", I("Grinder"), tiles, {
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-8/16, -8/16, -8/16,  8/16, 8/16, -6/16},
				{-8/16, -8/16,  6/16,  8/16, 8/16,  8/16},
				{-8/16, -8/16, -8/16, -6/16, 8/16,  8/16},
				{ 6/16, -8/16, -8/16,  8/16, 8/16,  8/16},
				{-6/16, -8/16, -6/16,  6/16, 6/16,  6/16},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-8/16, -8/16, -8/16,   8/16, 8/16, 8/16},
		},
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
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
		power_consumption = {0,4,6,9},
	})

minetest.register_craft({
	output = node_name_ta2,
	recipe = {
		{"group:wood", "default:mese_crystal", "group:wood"},
		{"techage:tubeS", "techage:hammer_steel", "techage:tubeS"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
	},
})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "default:mese_crystal", ""},
		{"", node_name_ta2, ""},
		{"", "techage:vacuum_tube", ""},
	},
})

if minetest.global_exists("unified_inventory") then
	unified_inventory.register_craft_type("grinding", {
		description = I("Grinding"),
		icon = 'techage_appl_grinder.png',
		width = 2,
		height = 2,
	})
end

function techage.add_grinder_recipe(recipe)
	Recipes[recipe.input] =  recipe.output
	if minetest.global_exists("unified_inventory") then
		recipe.items = {recipe.input}
		recipe.type = "grinding"
		unified_inventory.register_craft(recipe)
	end
end	


techage.add_grinder_recipe({input="default:cobble", output="default:gravel"})
techage.add_grinder_recipe({input="default:desert_cobble", output="default:gravel"})
techage.add_grinder_recipe({input="default:mossycobble", output="default:gravel"})
techage.add_grinder_recipe({input="default:gravel", output="default:sand"})
techage.add_grinder_recipe({input="techage:sieved_gravel", output="default:sand"})
techage.add_grinder_recipe({input="default:coral_skeleton", output="default:silver_sand"})

if minetest.global_exists("skytest") then
	techage.add_grinder_recipe({input="default:desert_sand", output="skytest:dust"})
	techage.add_grinder_recipe({input="default:silver_sand", output="skytest:dust"})
	techage.add_grinder_recipe({input="default:sand", output="skytest:dust"})
else
	techage.add_grinder_recipe({input="default:desert_sand", output="default:clay"})
	techage.add_grinder_recipe({input="default:silver_sand", output="default:clay"})
	techage.add_grinder_recipe({input="default:sand", output="default:clay"})
end

techage.add_grinder_recipe({input="default:sandstone", output="default:sand 4"})
techage.add_grinder_recipe({input="default:desert_sandstone", output="default:desert_sand 4"})
techage.add_grinder_recipe({input="default:silver_sandstone", output="default:silver_sand 4"})

techage.add_grinder_recipe({input="default:tree", output="default:leaves 8"})
techage.add_grinder_recipe({input="default:jungletree", output="default:jungleleaves 8"})
techage.add_grinder_recipe({input="default:pine_tree", output="default:pine_needles 8"})
techage.add_grinder_recipe({input="default:acacia_tree", output="default:acacia_leaves 8"})
techage.add_grinder_recipe({input="default:aspen_tree", output="default:aspen_leaves 8"})
