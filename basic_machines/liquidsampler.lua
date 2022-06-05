--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2/TA3 Bucket based Liquid Sampler

]]--

-- for lazy programmers
local M = minetest.get_meta
-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local S = techage.S

local STANDBY_TICKS = 2
local COUNTDOWN_TICKS = 3
local CYCLE_TIME = 8

local function formspec(self, pos, nvm)
	return "size[9,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;1,4;]"..
	"image[0,0;1,1;bucket.png]"..
	"image[1,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[1,1.5;1,1;techage_form_arrow.png]"..
	"image_button[1,3;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
	"tooltip[1,3;1,1;"..self:get_state_tooltip(nvm).."]"..
	"list[context;dst;2,0;7,4;]"..
	"list[current_player;main;0.5,4.5;8,4;]"..
	"listring[current_player;main]"..
	"listring[context;src]" ..
	"listring[current_player;main]"..
	"listring[context;dst]" ..
	"listring[current_player;main]"
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

local function is_water(pos)
	local node = minetest.get_node(pos)
	local liquiddef = bucket.liquids[node.name]
	if liquiddef ~= nil	and liquiddef.itemname ~= nil and node.name == liquiddef.source then
		return true
	end
end

local function can_start(pos, nvm, state)
	local water_pos = minetest.string_to_pos(M(pos):get_string("water_pos"))
	if not is_water(water_pos) then
		return S("no usable water")
	end
	return true
end

local function sample_liquid(pos, crd, nvm, inv)
	if inv:room_for_item("dst", {name = "bucket:bucket_water"}) and
			inv:contains_item("src", {name = "bucket:bucket_empty"}) then
		inv:remove_item("src", {name = "bucket:bucket_empty"})
		inv:add_item("dst", {name = "bucket:bucket_water"})
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	else
		crd.State:idle(pos, nvm)
	end
end

local function keep_running(pos, elapsed)
	--if tubelib.data_not_corrupted(pos) then
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	sample_liquid(pos, crd, nvm, inv)
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
	"techage_filling_ta#.png^{power}^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_liquidsampler.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_liquidsampler.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^{power}^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	{
		image = "techage_filling4_ta#.png^techage_liquidsampler4.png^techage_frame4_ta#.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 1.0,
		},
	},
	"techage_filling_ta#.png^techage_appl_liquidsampler.png^techage_frame_ta#.png",
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
		if meta:get_int("push_dir") == in_dir then
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
	on_recv_message = function(pos, src, topic, payload)
		return CRD(pos).State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
	end,
}

local node_name_ta2, node_name_ta3, _ =
	techage.register_consumer("liquidsampler", S("Liquid Sampler"), tiles, {
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		can_start = can_start,
		after_place_node = function(pos, placer)
			local inv = M(pos):get_inventory()
			inv:set_size("src", 4)
			inv:set_size("dst", 28)
			local water_pos = techage.get_pos(pos, "B")
			M(pos):set_string("water_pos", minetest.pos_to_string(water_pos))
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
		power_consumption = {0,3,5,8},
		power_sides = {U=1},
	},
	{false, true, true, false})  -- TA2/A3

minetest.register_craft({
	output = node_name_ta2,
	recipe = {
		{"group:wood", "default:mese_crystal", "group:wood"},
		{"techage:tubeS", "bucket:bucket_empty", "techage:tubeS"},
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
