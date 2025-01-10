--[[

	TechAge
	=======

	Copyright (C) 2019-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Water Remover 

	The Water Remover removes water from an area of ​​up to 21 x 21 x 80 m.
	It is mainly used to drain caves. The water remover is placed at the highest 
	point of the cave and removes the water from the cave to the lowest point.
	It digs one water block every two seconds.

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local NDEF = function(pos) return minetest.registered_nodes[techage.get_node_lvm(pos).name] or {} end
-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid
local menu = techage.menu

local TITLE = S("Water Remover")
local CYCLE_TIME = 2
local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local Side2Facedir = {F=0, R=1, B=2, L=3, D=4, U=5}

local MENU = {
	{
		type = "dropdown",
		choices = "9x9,11x11,13x13,15x15,17x17,19x19,21x21",
		name = "area_size",
		label = S("Area size"),
		tooltip = S("Area where the water is to be removed"),
		default = "9",
		values = {9,11,13,15,17,19,21},
	},
	{
		type = "numbers",
		name = "area_depth",
		label = S("Area depth"),
		tooltip = S("Depth of the area where the water is to be removed (1-80)"),
		default = "10",
		check = function(value, player_name) return tonumber(value) >= 1 and tonumber(value) <= 80 end,
	},
	{
		type = "output",
		name = "curr_depth",
		label = S("Current depth"),
		tooltip = S("Current working depth of the water remover"),
 	},
}

local WaterNodes = {
	"default:water_source",
	"default:river_water_source",
	-- Add more water nodes here
}

core.register_node("techage:air", {
	description = "Techage Air",
	inventory_image = "air.png",
	wield_image = "air.png",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = false,  -- This is important!
	air_equivalent = true,
	drop = "",
	groups = {not_in_creative_inventory=1},
})

local function formspec(self, pos, nvm)
	return "size[8,4.4]" ..
		"box[0,-0.1;7.8,0.5;#c6e8ff]" ..
		"label[3.0,-0.1;" .. minetest.colorize( "#000000", TITLE) .. "]" ..
		"image[6.4,0.8;1,1;" .. techage.get_power_image(pos, nvm) .. "]" ..
		"image_button[6.4,2.2;1,1;".. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[6.4,2.2;1,1;" .. self:get_state_tooltip(nvm) .. "]" ..
		menu.generate_formspec_container(pos, NDEF(pos), MENU, 0.0, 5.8)
end

local function play_sound(pos)
	minetest.sound_play("techage_scoopwater", {
		pos = pos,
		gain = 1.5,
		max_hear_distance = 15})
end

local function on_node_state_change(pos, old_state, new_state)
	local mem = techage.get_mem(pos)
	local owner = M(pos):get_string("owner")
	mem.co = nil
	techage.unmark_position(owner)
end

local function get_pos(pos, facedir, side, steps)
	facedir = (facedir + Side2Facedir[side]) % 4
	local dir = vector.multiply(minetest.facedir_to_dir(facedir), steps or 1)
	return vector.add(pos, dir)
end

local function get_dig_pos(pos, xoffs, zoffs)
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

local function is_water(pos1, pos2)
	return #minetest.find_nodes_in_area(pos1, pos2, WaterNodes) > 0
end

local function mark_area(pos1, pos2, owner)
	pos1.y = pos1.y + 0.2
	techage.mark_cube(owner, pos1, pos2, TITLE, "#FF0000", 40)
	pos1.y = pos1.y - 0.2
end

local function dig_water_node(mypos, dig_pos)
	local outdir = M(mypos):get_int("outdir")
	local node = techage.get_node_lvm(dig_pos)
	if node.name == "default:water_source" then
		minetest.swap_node(dig_pos, {name = "techage:air", param2 = 0})
		local leftover = liquid.put(mypos, Pipe, outdir, "techage:water", 1)
		if leftover and leftover > 0 then
			return "tank full"
		end
		return "ok"
	end
	return "no_water"
end

local function drain_task(pos, crd, nvm)
	nvm.area_depth = M(pos):get_int("area_depth")
	nvm.area_size = M(pos):get_int("area_size")
	local y_first = pos.y
	local y_last  = y_first - nvm.area_depth + 1
	local facedir = minetest.get_node(pos).param2
	local owner = M(pos):get_string("owner")
	local cnt = 0

	local pos1, pos2 = get_corner_positions(pos, facedir, nvm.area_size)
	nvm.level = 1
	--print("drain_task", nvm.area_depth, nvm.area_size, y_first, y_last,  M(pos):get_int("area_depth")) 
	for y_curr = y_first, y_last, -1 do
		pos1.y = y_curr
		pos2.y = y_curr

		-- Restarting the server can detach the coroutine data.
		-- Therefore, read nvm again.
		nvm = techage.get_nvm(pos)
		nvm.level = y_first - y_curr + 1

		if minetest.is_area_protected(pos1, pos2, owner, 5) then
			crd.State:fault(pos, nvm, S("area is protected"))
			return
		end

		if is_water(pos1, pos2) then
			mark_area(pos1, pos2, owner)
			M(pos):set_string("curr_depth", nvm.level)
			coroutine.yield()

			for zoffs = 1, nvm.area_size do
				for xoffs = 1, nvm.area_size do
					local qpos = get_dig_pos(pos1, xoffs, zoffs)
					while true do
						local res = dig_water_node(pos, qpos)
						if res == "tank full" then
							crd.State:blocked(pos, nvm, S("tank full"))
							techage.unmark_position(owner)
							coroutine.yield()
						elseif res == "no_water" then
							break
						else
							crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
							if cnt % 4 == 0 then
								play_sound(pos)
							end
							cnt = cnt + 1
							coroutine.yield()
							break
						end
					end
				end
				coroutine.yield()
			end
			techage.unmark_position(owner)
		end
	end
	M(pos):set_string("curr_depth", nvm.level)
	crd.State:stop(pos, nvm, S("finished"))
end

local function keep_running(pos, elapsed)
	local mem = techage.get_mem(pos)
	if not mem.co then
		mem.co = coroutine.create(drain_task)
	end

	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	local _, err = coroutine.resume(mem.co, pos, crd, nvm)
	if err then
		minetest.log("error", "[" .. TITLE .. "] at pos " .. minetest.pos_to_string(pos) .. " " .. err)
	end
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local nvm = techage.get_nvm(pos)
	if menu.eval_input(pos, MENU, fields) then
		M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
	else
		CRD(pos).State:state_button_event(pos, nvm, fields)
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

local tiles = {}
-- '#' will be replaced by the stage number
tiles.pas = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#_bottom.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_hole_pipe.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_quarry_left.png",
	"techage_filling_ta#.png^techage_appl_liquidsampler.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_liquidsampler.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#_bottom.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_hole_pipe.png",
	{
		name = "techage_frame14_ta#.png^techage_quarry_left14.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	"techage_filling_ta#.png^techage_appl_liquidsampler.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_liquidsampler.png^techage_frame_ta#.png",
}

local tubing = {
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
		if topic == 153 then  -- Current Depth
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

local _, _, node_name_ta4 =
	techage.register_consumer("waterremover", TITLE, tiles, {
		drawtype = "normal",
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		on_state_change = on_node_state_change,
		after_place_node = function(pos, placer)
			M(pos):set_string("owner", placer:get_player_name())
			M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
			M(pos):set_int("area_depth", 10)
			M(pos):set_int("area_size", 9)
			Pipe:after_place_node(pos)
		end,
		node_timer = keep_running,
		on_receive_fields = on_receive_fields,
		on_rightclick = on_rightclick,
		after_dig_node = after_dig_node,
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,0,0,1},
		power_consumption = {0,0,0,10},
	}, {false, false, false, true}
)

liquid.register_nodes({
	"techage:ta4_waterremover_pas", "techage:ta4_waterremover_act",
}, Pipe, "pump", {"R"}, {})

minetest.register_craft({
	output = node_name_ta4,
	recipe = {
		{"", "default:mese_crystal", ""},
		{"", "techage:ta3_liquidsampler_pas", ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})
