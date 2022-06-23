--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Oil Drill Box

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local STANDBY_TICKS = 2
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 16

local formspec0 = "size[5,4]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"image[1,0;3.4,3.4;techage_ta3.png]"..
	"button_exit[1,3.2;3,1;build;"..S("Build derrick").."]"

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_oildrill", {
			pos = pos,
			gain = 1,
			max_hear_distance = 15,
			loop = true})
		if mem.handle == -1 then
			minetest.after(1, play_sound, pos)
		end
	end
end

local function stop_sound(pos)
	local mem = techage.get_mem(pos)
	if mem.handle then
		minetest.sound_stop(mem.handle)
		mem.handle = nil
	end
end

local function formspec(self, pos, nvm)
	if not nvm.assemble_build then
		return formspec0
	end
	local depth = M(pos):get_int("depth")
	local curr_depth = pos.y - (nvm.drill_pos or pos).y
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;1,1;1,1;]"..
	"label[1.3,0.5;IN]"..
	"item_image[1,1;1,1;techage:oil_drillbit]"..
	"label[1,2;"..S("Drill Bit").."]"..
	"label[0.5,3;"..S("Depth")..": "..curr_depth.."/"..depth.."]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
	"tooltip[3.5,2;1,1;"..self:get_state_tooltip(nvm).."]"..
	"label[6.2,0.5;OUT]"..
	"list[context;dst;6,1;1,1;]"..
	"button_exit[5,3;3,1;remove;"..S("Remove derrick").."]"..
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
	local crd = CRD(pos)
	if listname == "src" then
		crd.State:start_if_standby(pos)
		return stack:get_count()
	end
	return 0
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

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
end

local function on_node_state_change(pos, old_state, new_state)
	if new_state == techage.RUNNING then
		play_sound(pos)
	else
		stop_sound(pos)
	end
end

local function drilling(pos, crd, nvm, inv)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
	nvm.drill_pos = nvm.drill_pos or {x=pos.x, y=pos.y-1, z=pos.z}
	local owner = M(pos):get_string("owner")
	local depth = M(pos):get_int("depth")
	local curr_depth = pos.y - (nvm.drill_pos or pos).y
	local node = techage.get_node_lvm(nvm.drill_pos)
	local ndef = minetest.registered_nodes[node.name]

	if not inv:contains_item("src", ItemStack("techage:oil_drillbit")) then
		crd.State:idle(pos, nvm, S("Drill bits missing"))
	elseif curr_depth >= depth then
		M(pos):set_string("oil_found", "true")
		crd.State:stop(pos, nvm)
	elseif node.name == "techage:oilstorage" then -- old oil bubble node?
		nvm.drill_pos.y = nvm.drill_pos.y-1
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	elseif minetest.is_protected(nvm.drill_pos, owner) then
		crd.State:fault(pos, nvm, S("Drill area is protected"))
	elseif node.name == "techage:oil_drillbit2" then
		nvm.drill_pos.y = nvm.drill_pos.y-1
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	elseif minetest.get_item_group(node.name, "lava") >= 1 then
		minetest.swap_node(nvm.drill_pos, {name = "techage:oil_drillbit2"})
		inv:remove_item("src", ItemStack("techage:oil_drillbit"))
		nvm.drill_pos.y = nvm.drill_pos.y-1
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	elseif techage.can_dig_node(node.name, ndef) then
		local drop_name = techage.dropped_node(node, ndef)
		if drop_name then
			local item = ItemStack(drop_name)
			if not inv:room_for_item("dst", item) then
				crd.State:blocked(pos, nvm, S("item output blocked"))
				return
			end
			inv:add_item("dst", item)
		end
		minetest.swap_node(nvm.drill_pos, {name = "techage:oil_drillbit2"})
		inv:remove_item("src", ItemStack("techage:oil_drillbit"))
		nvm.drill_pos.y = nvm.drill_pos.y-1
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	elseif node.name == "ignore" then
		-- load world and pause the drilling for one step
		minetest.emerge_area(nvm.drill_pos, nvm.drill_pos)
	end
end

local function keep_running(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	if inv then
		drilling(pos, crd, nvm, inv)
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(crd.State, pos, nvm))
	end
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local nvm = techage.get_nvm(pos)
	if nvm.assemble_locked or nvm.assemble_build then
		return false
	end
	local inv = M(pos):get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	if fields.build then
		techage.oiltower.build(pos, player:get_player_name())
	elseif fields.remove then
		local inv = M(pos):get_inventory()
		if inv:is_empty("dst") and inv:is_empty("src") then
			techage.oiltower.remove(pos, player:get_player_name())
		end
	else
		local nvm = techage.get_nvm(pos)
		if not nvm.assemble_locked and M(pos):get_string("oil_found") ~= "true" then
			local nvm = techage.get_nvm(pos)
			CRD(pos).State:state_button_event(pos, nvm, fields)
		end
	end
end

local tiles = {}
-- '#' will be replaced by the stage number
tiles.pas = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_oildrill.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_oildrill.png^techage_frame_ta#.png",
}
tiles.act = tiles.pas

local tubing = {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(pos, inv, "dst", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local nvm = techage.get_nvm(pos)
		if not nvm.assemble_locked then
			local meta = minetest.get_meta(pos)
			if meta:get_int("push_dir") == in_dir then
				local inv = M(pos):get_inventory()
				CRD(pos).State:start_if_standby(pos)
				return techage.put_items(inv, "src", stack)
			end
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
	on_node_load = function(pos, node)
		CRD(pos).State:on_node_load(pos)
		local nvm = techage.get_nvm(pos)
		nvm.assemble_locked = false
		if nvm.techage_state == techage.RUNNING then
			play_sound(pos)
		end
	end,
}

local _, node_name_ta3, _ =
	techage.register_consumer("drillbox", S("Oil Drill Box"), tiles, {
		drawtype = "normal",
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		on_state_change = on_node_state_change,
		after_place_node = function(pos, placer)
			local inv = M(pos):get_inventory()
			inv:set_size("src", 1)
			inv:set_size("dst", 1)
			local info = techage.explore.get_oil_info(pos)
			M(pos):set_int("depth", info.depth - 5)  -- oil bubble
			M(pos):set_int("amount", info.amount)
			M(pos):set_string("oil_found", "false")
			M(pos):set_string("owner", placer:get_player_name())
		end,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			if oldmetadata.fields.oil_found == "true" then
				minetest.set_node(pos, {name = "techage:oil_source"})
			end
		end,
		can_dig = can_dig,
		node_timer = keep_running,
		on_receive_fields = on_receive_fields,
		on_rightclick = on_rightclick,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,1,1,1},
		power_consumption = {0,10,16,24},
		tube_sides = {L=1, R=1},
	},
	{false, false, true, false})  -- TA3 only

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"default:steel_ingot", "default:diamond", "default:steel_ingot"},
		{"techage:tubeS", "basic_materials:gear_steel", "techage:tubeS"},
		{"default:steel_ingot", "techage:vacuum_tube", "default:steel_ingot"},
	},
})
