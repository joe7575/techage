--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Injector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end
local tooltip = S("Switch to pull mode \nto pull items out of inventory slots \naccording the injector configuration")

local STANDBY_TICKS = 2
local COUNTDOWN_TICKS = 3
local CYCLE_TIME = 4

local function formspec(self, pos, nvm)
	local pull_mode = dump(nvm.pull_mode or false)
	return "size[8,7.2]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;7.8,0.5;#c6e8ff]"..
		"label[3,-0.1;"..minetest.colorize("#000000", S("Injector")).."]"..
		techage.question_mark_help(8, S("Configure up to 8 items \nto be pushed by the injector"))..
		"list[context;filter;0,0.8;8,1;]"..
		"image_button[2,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2,2;1,1;"..self:get_state_tooltip(nvm).."]"..
		"checkbox[3.5,1.9;pull_mode;"..S("pull mode")..";"..pull_mode.."]"..
		"tooltip[3.5,1.9;2,0.8;"..tooltip..";#0C3D32;#FFFFFF]"..
		"list[current_player;main;0,3.5;8,4;]"..
		"listring[context;filter]"..
		"listring[current_player;main]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	local nvm = techage.get_nvm(pos)
	if CRD(pos).State:get_state(nvm) ~= techage.STOPPED then
		return 0
	end

	local inv = M(pos):get_inventory()
	local list = inv:get_list(listname)
	local cdr = CRD(pos)
	if list[index]:get_count() < cdr.num_items then
		local num = math.min(cdr.num_items - list[index]:get_count(), stack:get_count()) + list[index]:get_count()
		stack:set_count(num)
		inv:set_stack(listname, index, stack)
		return 0
	end
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	local nvm = techage.get_nvm(pos)
	if CRD(pos).State:get_state(nvm) ~= techage.STOPPED then
		return 0
	end

	local inv = M(pos):get_inventory()
	inv:set_stack(listname, index, nil)
	return 0
end

local function pull_items(pos, out_dir, idx, name, num)
	local inv, listname = techage.get_inv_access(pos, out_dir, "pull")
	if inv and listname then
		if idx and idx ~= 0 then
			local stack = inv:get_stack(listname, idx)
			if stack and not stack:is_empty() and stack:get_name() == name then
				local taken = stack:take_item(num)
				inv:set_stack(listname, idx, stack)
				return (taken:get_count() > 0) and taken or nil
			end
		else
			local taken = inv:remove_item(listname, {name = name, count = num})
			return (taken:get_count() > 0) and taken or nil
		end
	else
		return techage.pull_items(pos, out_dir, num, name)
	end
end

local function push_items(pos, out_dir, idx, items)
	local inv, listname, callafter, dpos = techage.get_inv_access(pos, out_dir, "push")
	if inv and listname then
		if idx and idx ~= 0 then
			local stack = inv:get_stack(listname, idx)
			if stack:item_fits(items) then
				stack:add_item(items)
				inv:set_stack(listname, idx, stack)
				if callafter then
					callafter(dpos)
				end
				return true
			end
		else
			if inv:room_for_item(listname, items) then
				inv:add_item(listname, items)
				if callafter then
					callafter(dpos)
				end
				return true
			end
		end
	else
		return techage.push_items(pos, out_dir, items, idx)
	end
end

local function unpull_items(pos, out_dir, idx, items)
	local inv, listname = techage.get_inv_access(pos, out_dir, "unpull")
	if inv and listname then
		if idx and idx ~= 0 then
			local stack = inv:get_stack(listname, idx)
			stack:add_item(items)
			inv:set_stack(listname, idx, stack)
		else
			inv:add_item(listname, items)
		end
	else
		techage.unpull_items(pos, out_dir, items)
	end
end

local function pushing(pos, crd, meta, nvm)
	local pull_dir = meta:get_int("pull_dir")
	local push_dir = meta:get_int("push_dir")
	local inv = M(pos):get_inventory()
	local filter = inv:get_list("filter")
	local pushed = false
	local pulled = false

	for idx, item in ipairs(filter) do
		local name = item:get_name()
		local num = math.min(item:get_count(), crd.num_items)
		if name ~= "" and num > 0 then
			local items = pull_items(pos, pull_dir, nvm.pull_mode and idx, name, num)
			if items ~= nil then
				pulled = true
				if push_items(pos, push_dir, not nvm.pull_mode and idx, items) then
					pushed = true
				else -- place item back
					unpull_items(pos, pull_dir, nvm.pull_mode and idx, items)
					pulled = false
				end
			end
		end
	end

	if not pulled then
		crd.State:idle(pos, nvm)
	elseif not pushed then
		crd.State:blocked(pos, nvm)
	else
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	end
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	pushing(pos, crd, M(pos), nvm)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	if fields.pull_mode then
		nvm.pull_mode = fields.pull_mode == "true"
	end
	CRD(pos).State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
end

local tiles = {}
-- '#' will be replaced by the stage number
-- '{power}' will be replaced by the power PNG
tiles.pas = {
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_appl_pusher.png^[transformR180]^techage_frame_ta#.png^techage_appl_injector.png",
	"techage_appl_pusher.png^techage_frame_ta#.png^techage_appl_injector.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	{
		image = "techage_appl_pusher14.png^[transformR180]^techage_frame14_ta#.png^techage_appl_injector14.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	{
		image = "techage_appl_pusher14.png^techage_frame14_ta#.png^techage_appl_injector14.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
}

local tubing = {
	-- push item through the injector in opposit direction
	on_push_item = function(pos, in_dir, stack)
		return in_dir == M(pos):get_int("pull_dir") and techage.safe_push_items(pos, in_dir, stack)
	end,
	is_pusher = true, -- is a pulling/pushing node

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

local _, node_name_ta3, node_name_ta4 =
	techage.register_consumer("injector", S("Injector"), tiles, {
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		quick_start = node_timer,
		after_place_node = function(pos, placer)
			local meta = M(pos)
			local node = minetest.get_node(pos)
			meta:set_int("pull_dir", techage.side_to_outdir("L", node.param2))
			meta:set_int("push_dir", techage.side_to_outdir("R", node.param2))
			local inv = M(pos):get_inventory()
			inv:set_size('filter', 8)
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
		end,

		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		allow_metadata_inventory_move = function() return 0 end,
		on_receive_fields = on_receive_fields,
		node_timer = node_timer,
		on_rotate = screwdriver.disallow,

		groups = {choppy=2, cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,0,1,4},
	}, {false, false, true, true})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "techage:ta3_pusher_pas", ""},
		{"", "basic_materials:ic", ""},
	},
})

minetest.register_craft({
	output = node_name_ta4,
	recipe = {
		{"", "techage:aluminum", ""},
		{"", "techage:ta4_pusher_pas", ""},
		{"", "basic_materials:ic", ""},
	},
})
