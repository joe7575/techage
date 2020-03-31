--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Quarry machine to dig stones and other ground blocks.
	
	The Quarry digs a hole 5x5 blocks large and up to 80 blocks deep.
	It starts at the given level (0 is same level as the quarry block,
	1 is one level higher and so on)) and goes down to the given depth number.
	It digs one block every 4 seconds.

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local S = techage.S

local CYCLE_TIME = 4
local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4

local Side2Facedir = {F=0, R=1, B=2, L=3, D=4, U=5}
local Depth2Idx = {[1]=1 ,[2]=2, [3]=3, [5]=4, [10]=5, [15]=6, [20]=7, [25]=8, [40]=9, [60]=10, [80]=11}
local Level2Idx = {[2]=1, [1]=2, [0]=3, [-1]=4, [-2]=5, [-3]=6, 
				   [-5]=7, [-10]=8, [-15]=9, [-20]=10}

local function formspec(self, pos, nvm)
	local tooltip = S("Start level = 0\nmeans the same Y-level\nas the quarry is placed")
	local level = nvm.level or "-"
	local index = nvm.index or "-"
	local depth_list = "1,2,3,5,10,15,20,25,40,60,80"
	if CRD(pos).stage == 3 then
		depth_list = "1,2,3,5,10,15,20,25,40"
	elseif CRD(pos).stage == 2 then
		depth_list = "1,2,3,5,10,15,20"
	end
	nvm.quarry_depth = nvm.quarry_depth or 1
	nvm.start_level = nvm.start_level or -1

	return "size[8,8]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;7.8,0.5;#c6e8ff]"..
		"label[3.5,-0.1;"..minetest.colorize( "#000000", S("Quarry")).."]"..
		techage.question_mark_help(8, tooltip)..
		"dropdown[0,0.8;1.5;level;2,1,0,-1,-2,-3,-5,-10,-15,-20;"..Level2Idx[nvm.start_level].."]".. 
		"label[1.6,0.9;"..S("Start level").."]"..
		"dropdown[0,1.8;1.5;depth;"..depth_list..";"..Depth2Idx[nvm.quarry_depth].."]".. 
		"label[1.6,1.9;"..S("Digging depth").."]"..
		"label[0,2.9;"..S("level").."="..level..",  "..S("pos=")..index.."/25]"..
		"list[context;main;5,0.8;3,3;]"..
		"image[4,0.8;1,1;"..techage.get_power_image(pos, nvm).."]"..
		"image_button[4,2.8;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[4,2.8;1,1;"..self:get_state_tooltip(nvm).."]"..
		"list[current_player;main;0,4.3;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
end

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_quarry", {
			pos = pos, 
			gain = 1.5,
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

local function on_node_state_change(pos, old_state, new_state)
	local mem = techage.get_mem(pos)
	local owner = M(pos):get_string("owner")
	mem.co = nil
	techage.unmark_position(owner)
	if new_state == techage.RUNNING then
		play_sound(pos)
	else
		stop_sound(pos)
	end
end

local function get_pos(pos, facedir, side, steps)
	facedir = (facedir + Side2Facedir[side]) % 4
	local dir = vector.multiply(minetest.facedir_to_dir(facedir), steps or 1)
	return vector.add(pos, dir)
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

local QuarryPath = {
	3,3,3,3,2,
	1,1,1,1,2,
	3,3,3,3,2,
	1,1,1,1,2,
	3,3,3,3,2,
}

local function get_next_pos(pos, facedir, idx)
	facedir = (facedir + QuarryPath[idx]) % 4
	return vector.add(pos, core.facedir_to_dir(facedir))
end

-- pos is the quarry pos, y_pos the current dug level
local function get_corner_positions(pos, facedir, y_pos)
	local start_pos = get_pos(pos, facedir, "L")
	local pos1 = get_pos(start_pos, facedir, "F", 2)
	local pos2 = get_pos(start_pos, facedir, "B", 2)
	pos2 = get_pos(pos2, facedir, "L", 4)
	pos1.y = y_pos
	pos2.y = y_pos
	return pos1, pos2
end

local function is_air_level(pos1, pos2) 
	return #minetest.find_nodes_in_area(pos1, pos2, {"air"}) == 25
end

local function mark_area(pos1, pos2, owner)
	pos1.y = pos1.y + 0.2
	techage.mark_cube(owner, pos1, pos2, "quarry", "#FF0000", 20)
	pos1.y = pos1.y - 0.2
end

local function peek_node(qpos)
	local node = techage.get_node_lvm(qpos)
	local ndef = minetest.registered_nodes[node.name]
	if techage.can_node_dig(node, ndef) then
		return techage.dropped_node(node, ndef)
	end
end

local function add_to_inv(pos, item_name)
	local inv = M(pos):get_inventory()
	if inv:room_for_item("main", {name = item_name}) then
		inv:add_item("main", {name = item_name})
		return true
	end
	return false
end

local function quarry_task(pos, crd, nvm)
	nvm.start_level = nvm.start_level or 0
	nvm.quarry_depth = nvm.quarry_depth or 1
	local y_first = pos.y + nvm.start_level
	local y_last  = y_first - nvm.quarry_depth + 1
	local facedir = minetest.get_node(pos).param2
	local owner = M(pos):get_string("owner")
	
	nvm.level = 1
	for y_curr = y_first, y_last, -1 do
		local pos1, pos2 = get_corner_positions(pos, facedir, y_curr)
		local qpos = {x = pos1.x, y = pos1.y, z = pos1.z}

		if minetest.is_area_protected(pos1, pos2, owner, 5) then
			crd.State:fault(pos, nvm, S("area is protected"))
			return
		end
		
		if not is_air_level(pos1, pos2) then
			mark_area(pos1, pos2, owner)
			coroutine.yield()
			
			nvm.index = 1
			for i = 1, 25 do
				local item_name = peek_node(qpos)
				if item_name then
					if add_to_inv(pos, item_name) then
						minetest.remove_node(qpos)
						crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS, 1)
					else
						crd.State:blocked(pos, nvm, S("inventory full"))
					end
					coroutine.yield()
				end
				qpos = get_next_pos(qpos, facedir, i)
				nvm.index = nvm.index + 1
			end
			techage.unmark_position(owner)
		end
		nvm.level = nvm.level + 1
	end
	crd.State:stop(pos, nvm, S("finished"))
end
	
local function keep_running(pos, elapsed)
	local mem = techage.get_mem(pos)
	if not mem.co then
		mem.co = coroutine.create(quarry_task)
	end
	
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	coroutine.resume(mem.co, pos, crd, nvm)
		
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(crd.State, pos, nvm))
	end
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = M(pos):get_inventory()
	return inv:is_empty("main")
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	
	if fields.depth then
		if tonumber(fields.depth) ~= nvm.quarry_depth then
			nvm.quarry_depth = tonumber(fields.depth)
			mem.co = nil
			CRD(pos).State:stop(pos, nvm)
		end
	end
	
	if fields.level then
		if tonumber(fields.level) ~= nvm.start_level then
			nvm.start_level = tonumber(fields.level)
			mem.co = nil
			CRD(pos).State:stop(pos, nvm)
		end
	end

	CRD(pos).State:state_button_event(pos, nvm, fields)
end

local tiles = {}
-- '#' will be replaced by the stage number
tiles.pas = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_quarry_left.png",
	"techage_filling_ta#.png^techage_appl_quarry.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_quarry.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	{
		image = "techage_frame14_ta#.png^techage_quarry_left14.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	"techage_filling_ta#.png^techage_appl_quarry.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_quarry.png^techage_frame_ta#.png",
}

local tubing = {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(inv, "main", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("push_dir") == in_dir  or in_dir == 5 then
			local inv = M(pos):get_inventory()
			CRD(pos).State:start_if_standby(pos)
			return techage.put_items(inv, "main", stack)
		end
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "main", stack)
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		return CRD(pos).State:on_receive_message(pos, topic, payload)
	end,
	on_node_load = function(pos, node)
		local nvm = techage.get_nvm(pos)
		if nvm.techage_state == techage.RUNNING then
			play_sound(pos)
		end
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 = 
	techage.register_consumer("quarry", S("Quarry"), tiles, {
		drawtype = "normal",
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		on_state_change = on_node_state_change,
		after_place_node = function(pos, placer)
			local inv = M(pos):get_inventory()
			local nvm = techage.get_nvm(pos)
			inv:set_size('main', 9)
			M(pos):set_string("owner", placer:get_player_name())
		end,
		can_dig = can_dig,
		node_timer = keep_running,
		on_receive_fields = on_receive_fields,
		on_rightclick = on_rightclick,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,1,1,1},
		power_consumption = {0,10,12,12},
	}
)

minetest.register_craft({
	output = node_name_ta2,
	recipe = {
		{"group:wood", "default:mese_crystal", "group:wood"},
		{"techage:tubeS", "default:pick_diamond", "techage:iron_ingot"},
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

minetest.register_craft({
	output = node_name_ta4,
	recipe = {
		{"", "default:mese_crystal", ""},
		{"", node_name_ta3, ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})
