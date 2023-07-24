--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2/TA3/TA4 Honey extractor, getting Honey and Beeswax from Filled Frames

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer or {} end

local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4

local function formspec(self, pos, nvm)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;3,3;]"..
	"item_image[0,0;1,1;bees:frame_full]"..
	"image[0,0;1,1;techage_form_mask.png]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;"..self:get_state_button_image(nvm)..";state_button;]"..
	"tooltip[3.5,2;1,1;"..self:get_state_tooltip(nvm).."]"..
	"list[context;dst;5,0;3,3;]"..
	"item_image[5,0;1,1;bees:bottle_honey]"..
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
		local state = CRD(pos).State
		if state then
			state:start_if_standby(pos)
		end
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

local function count_items(inv, list_name, item_name, max_count)
	local item_stack = ItemStack(item_name)
	item_stack:set_count(max_count)
	while item_stack:get_count() > 0 do
		if inv:contains_item(list_name, item_stack) then
			return item_stack:get_count()
		else
			item_stack:set_count(item_stack:get_count() - 1)
		end
	end
	return 0
end

local function extracting(pos, crd, nvm, inv)
	local item_count = count_items(inv, "src", "bees:frame_full", crd.num_items)
	item_count = count_items(inv, "src", "vessels:glass_bottle", item_count)

	if item_count == 0 then
		crd.State:idle(pos, nvm)
		return
	end

	local honey_stack = ItemStack("bees:bottle_honey")
	honey_stack:set_count(item_count)

	local wax_stack = ItemStack("bees:wax")
	wax_stack:set_count(item_count)

	local empty_frames_stack = ItemStack("bees:frame_empty")
	empty_frames_stack:set_count(item_count)

	if inv:room_for_item("dst", honey_stack)
		and inv:room_for_item("dst", wax_stack)
		and inv:room_for_item("dst", frames_stack) then

		local full_frames_stack = ItemStack("bees:frame_full")
		full_frames_stack:set_count(item_count)
		inv:remove_item("src", full_frames_stack)

		local bottles_stack = ItemStack("vessels:glass_bottle")
		bottles_stack:set_count(item_count)
		inv:remove_item("src", bottles_stack)

		inv:add_item("dst", honey_stack)
		inv:add_item("dst", wax_stack)
		inv:add_item("dst", empty_frames_stack)

		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	else
		crd.State:blocked(pos, nvm)
	end
end

local function keep_running(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	extracting(pos, crd, nvm, inv)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	CRD(pos).State:state_button_event(pos, nvm, fields)
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
	"techage_extractor_top_inactive.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_extractor.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_extractor_front_inactive.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	"techage_extractor_top_active.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_extractor.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_extractor_front_active.png^techage_frame_ta#.png",
}

local tubing = {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(pos, inv, "dst", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("push_dir") == in_dir or in_dir == 5 then
			local inv = M(pos):get_inventory()
			--CRD(pos).State:start_if_standby(pos) -- would need power!
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
	on_recv_message = function(pos, src, topic, payload)
		return CRD(pos).State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
	end,
	on_node_load = function(pos)
		CRD(pos).State:on_node_load(pos)
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 =
	techage.register_consumer("honey_extractor", S("Honey Extractor"), tiles, {
		drawtype = "nodebox",
		paramtype = "light",
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
		power_consumption = {0,3,5,7},
		tube_sides = {L=1, R=1, U=1},
	})

minetest.register_craft({
	output = node_name_ta2,
	recipe = {
		{"group:wood",    "basic_materials:plastic_sheet", "group:wood"},
		{"techage:tubeS", "bees:extractor",                "techage:tubeS"},
		{"group:wood",    "techage:iron_ingot",            "group:wood"},
	},
})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "basic_materials:motor", ""},
		{"", node_name_ta2, ""},
		{"", "techage:vacuum_tube", ""},
	},
})

minetest.register_craft({
	output = node_name_ta4,
	recipe = {
		{"", "techage:ta4_carbon_fiber", ""},
		{"", node_name_ta3, ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})


techage.recipes.register_craft_type("extracting", {
	description = S("Extracting"),
	icon = 'techage_extractor_front_active.png',
	width = 2,
	height = 1,
})

techage.recipes.register_craft({items={"bees:frame_full", "vessels:glass_bottle"}, type="extracting", output="bees:bottle_honey"})
techage.recipes.register_craft({items={"bees:frame_full", "vessels:glass_bottle"}, type="extracting", output="bees:wax"})
techage.recipes.register_craft({items={"bees:frame_full", "vessels:glass_bottle"}, type="extracting", output="bees:frame_empty"})

