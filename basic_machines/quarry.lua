--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Quarry machine to dig stones and other ground blocks.

	The Quarry digs a hole (default) 5x5 blocks large and up to 80 blocks deep.
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

local CYCLE_TIME = 3
local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4

local Side2Facedir = {F=0, R=1, B=2, L=3, D=4, U=5}
local Depth2Idx = {[1]=1 ,[2]=2, [3]=3, [5]=4, [10]=5, [15]=6, [20]=7, [25]=8, [40]=9, [60]=10, [80]=11}
local Holesize2Idx = {["3x3"] = 1, ["5x5"] = 2, ["7x7"] = 3, ["9x9"] = 4, ["11x11"] = 5}
local Holesize2Diameter = {["3x3"] = 3, ["5x5"] = 5, ["7x7"] = 7, ["9x9"] = 9, ["11x11"] = 11}
local Level2Idx = {[2]=1, [1]=2, [0]=3, [-1]=4, [-2]=5, [-3]=6,
				   [-5]=7, [-10]=8, [-15]=9, [-20]=10}

local function formspec(self, pos, nvm)
	local tooltip = S("Start level = 0\nmeans the same level\nas the quarry is placed")
	local level_idx = Level2Idx[nvm.start_level or 1] or 2
	local depth_idx = Depth2Idx[nvm.quarry_depth or 1] or 1
	local hsize_idx = Holesize2Idx[nvm.hole_size or "5x5"] or 2
	local level = nvm.level or "-"
	local hsize_list = "5x5"
	if CRD(pos).stage == 4 then
		hsize_list = "3x3,5x5,7x7,9x9,11x11"
	end
	local depth_list = "1,2,3,5,10,15,20,25,40,60,80"
	if CRD(pos).stage == 3 then
		depth_list = "1,2,3,5,10,15,20,25,40"
	elseif CRD(pos).stage == 2 then
		depth_list = "1,2,3,5,10,15,20"
	end

	return "size[8,8]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;7.8,0.5;#c6e8ff]"..
		"label[3.5,-0.1;"..minetest.colorize( "#000000", S("Quarry")).."]"..
		techage.question_mark_help(8, tooltip)..
		"dropdown[0,0.8;1.5;level;2,1,0,-1,-2,-3,-5,-10,-15,-20;"..level_idx.."]"..
		"label[1.6,0.9;"..S("Start level").."]"..
		"dropdown[0,1.8;1.5;depth;"..depth_list..";"..depth_idx.."]"..
		"label[1.6,1.9;"..S("Digging depth").." ("..level..")]"..
		"dropdown[0,2.8;1.5;hole_size;"..hsize_list..";"..hsize_idx.."]"..
		"label[1.6,2.9;"..S("Hole size").."]"..
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


local function get_quarry_pos(pos, xoffs, zoffs)
	return {x = pos.x + xoffs - 1, y = pos.y, z = pos.z + zoffs - 1}
end

-- pos is the quarry pos
local function get_corner_positions(pos, facedir, hole_diameter)
	local _pos = get_pos(pos, facedir, "L")
	local pos1 = get_pos(_pos, facedir, "F", math.floor((hole_diameter - 1) / 2))
	local pos2 = get_pos(_pos, facedir, "B", math.floor((hole_diameter - 1) / 2))
	pos2 = get_pos(pos2, facedir, "L", hole_diameter - 1)
	if pos1.x > pos2.x then pos1.x, pos2.x = pos2.x, pos1.x end
	if pos1.y > pos2.y then pos1.y, pos2.y = pos2.y, pos1.y end
	if pos1.z > pos2.z then pos1.z, pos2.z = pos2.z, pos1.z end
	return pos1, pos2
end

local function is_air_level(pos1, pos2, hole_diameter)
	return #minetest.find_nodes_in_area(pos1, pos2, {"air"}) == hole_diameter * hole_diameter
end

local function mark_area(pos1, pos2, owner)
	pos1.y = pos1.y + 0.2
	techage.mark_cube(owner, pos1, pos2, "quarry", "#FF0000", 20)
	pos1.y = pos1.y - 0.2
end

local function quarry_task(pos, crd, nvm)
	nvm.start_level = nvm.start_level or 0
	nvm.quarry_depth = nvm.quarry_depth or 1
	nvm.hole_diameter = nvm.hole_diameter or 5
	local y_first = pos.y + nvm.start_level
	local y_last  = y_first - nvm.quarry_depth + 1
	local facedir = minetest.get_node(pos).param2
	local owner = M(pos):get_string("owner")
	local fake_player = techage.Fake_player:new()
	fake_player.get_pos = function (...)
		return pos
	end
	fake_player.get_inventory = function(...)
		return M(pos):get_inventory()
	end

	local add_to_inv = function(itemstacks)
		local at_least_one_added = false
		local inv = M(pos):get_inventory()
		if #itemstacks == 0 then
			return true
		end
		for _,stack in ipairs(itemstacks) do
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
				at_least_one_added = true
			elseif at_least_one_added then
				minetest.add_item({x=pos.x,y=pos.y+1,z=pos.z}, stack)
			end
		end
		return at_least_one_added
	end

	local pos1, pos2 = get_corner_positions(pos, facedir, nvm.hole_diameter)
	nvm.level = 1
	for y_curr = y_first, y_last, -1 do
		pos1.y = y_curr
		pos2.y = y_curr

		nvm.level = y_first - y_curr

		if minetest.is_area_protected(pos1, pos2, owner, 5) then
			crd.State:fault(pos, nvm, S("area is protected"))
			return
		end

		if not is_air_level(pos1, pos2, nvm.hole_diameter) then
			mark_area(pos1, pos2, owner)
			coroutine.yield()

			for zoffs = 1, nvm.hole_diameter do
				for xoffs = 1, nvm.hole_diameter do
					local qpos = get_quarry_pos(pos1, xoffs, zoffs)
					local dig_state = techage.dig_like_player(qpos, fake_player, add_to_inv)

					if dig_state == techage.dig_states.INV_FULL then
						crd.State:blocked(pos, nvm, S("inventory full"))
						coroutine.yield()
					elseif dig_state == techage.dig_states.DUG then
						crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
						coroutine.yield()
					end
				end
			end
			techage.unmark_position(owner)
		end
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
	local _, err = coroutine.resume(mem.co, pos, crd, nvm)
	if err then
		minetest.log("error", "[TA4 Quarry Coroutine Error]" .. err)
	end

	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(crd.State, pos, nvm))
	end
	if nvm.techage_state ~= techage.RUNNING then
		stop_sound(pos)
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
			if CRD(pos).stage == 2 then
				nvm.quarry_depth = math.min(nvm.quarry_depth, 20)
			elseif CRD(pos).stage == 3 then
				nvm.quarry_depth = math.min(nvm.quarry_depth, 40)
			end
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

	if fields.hole_size then
		if CRD(pos).stage == 4 then
			if fields.hole_size ~= nvm.hole_size then
				nvm.hole_size = fields.hole_size
				nvm.hole_diameter = Holesize2Diameter[fields.hole_size or "5x5"] or 5
				mem.co = nil
				CRD(pos).State:stop(pos, nvm)
			end
		else
			nvm.hole_size = "5x5"
			nvm.hole_diameter = 5
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
			return techage.get_items(pos, inv, "main", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("push_dir") == in_dir or in_dir == 5 then
			local inv = M(pos):get_inventory()
			--CRD(pos).State:start_if_standby(pos) -- would need power!
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
		if topic == "depth" then
			local nvm = techage.get_nvm(pos)
			return nvm.level or 0
		else
			return CRD(pos).State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 133 then  -- Quarry Depth
			local nvm = techage.get_nvm(pos)
			return 0, {nvm.level or 0}
		else
			return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
		end
	end,
	on_node_load = function(pos)
		CRD(pos).State:on_node_load(pos)
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
		power_consumption = {0,10,12,14},
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
