--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	TA2/TA3/TA4 Pusher
	Simple node for push/pull operation of StackItems from chests or other
	inventory/server nodes to tubes or other inventory/server nodes.

                 +--------+
                /        /|
               +--------+ |
     IN (L) -->|        |X--> OUT (R)
               | PUSHER | +
               |        |/
               +--------+

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end
local TRDN = function(node) return (minetest.registered_nodes[node.name] or {}).techage end
-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 10
local COUNTDOWN_TICKS = 10
local CYCLE_TIME = 2

local function pushing(pos, trd, meta, mem)
	local pull_dir = meta:get_int("pull_dir")
	local push_dir = meta:get_int("push_dir")
	local items = techage.pull_items(pos, pull_dir, trd.num_items)
	if items ~= nil then
		if techage.push_items(pos, push_dir, items) == false then
			-- place item back
			techage.unpull_items(pos, pull_dir, items)
			trd.State:blocked(pos, mem)
			return
		end
		trd.State:keep_running(pos, mem, COUNTDOWN_TICKS)
		return
	end
	trd.State:idle(pos, mem)
end

local function keep_running(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local trd = TRD(pos)
	pushing(pos, trd, M(pos), mem)
	return trd.State:is_active(mem)
end	

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not minetest.is_protected(pos, clicker:get_player_name()) then
		if TRD(pos).State:is_active(mem) then
			TRD(pos).State:stop(pos, mem)
		else
			TRD(pos).State:start(pos, mem)
		end
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos)
	TRDN(oldnode).State:after_dig_node(pos, oldnode, oldmetadata, digger)
end

local function register_pusher(stage, num_items)
	local State = techage.NodeStates:new({
		node_name_passive= "techage:ta"..stage.."_pusher",
		node_name_active = "techage:ta"..stage.."_pusher_active",
		node_name_defect = "techage:ta"..stage.."_pusher_defect",
		infotext_name = "TA"..stage..I(" Pusher"),
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		has_item_meter = true,
		aging_factor = 10,
	})

	minetest.register_node("techage:ta"..stage.."_pusher", {
		description = "TA"..stage..I(" Pusher"),
		tiles = {
			-- up, down, right, left, back, front
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage.."_top.png^techage_appl_arrow.png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png^techage_appl_outp.png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png^techage_appl_inp.png",
			"techage_appl_pusher.png^[transformR180]^techage_frame_ta"..stage..".png",
			"techage_appl_pusher.png^techage_frame_ta"..stage..".png",
		},

		techage = {
			State = State,
			num_items = num_items,
		},
		
		after_place_node = function(pos, placer)
			local mem = tubelib2.init_mem(pos)
			local meta = M(pos)
			local node = minetest.get_node(pos)
			meta:set_int("pull_dir", techage.side_to_outdir("L", node.param2))
			meta:set_int("push_dir", techage.side_to_outdir("R", node.param2))
			local number = "-"
			if stage > 2 then
				number = techage.add_node(pos, "techage:ta"..stage.."_pusher")
			end
			TRD(pos).State:node_init(pos, mem, number)
		end,

		on_rightclick = on_rightclick,
		after_dig_node = after_dig_node,
		on_timer = keep_running,
		on_rotate = screwdriver.disallow,

		drop = "",
		paramtype2 = "facedir",
		groups = {choppy=2, cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("techage:ta"..stage.."_pusher_active", {
		description = "TA"..stage..I(" Pusher"),
		tiles = {
			-- up, down, right, left, back, front
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage.."_top.png^techage_appl_arrow.png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png^techage_appl_outp.png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png^techage_appl_inp.png",
			{
				image = "techage_appl_pusher14.png^[transformR180]^techage_frame14_ta"..stage..".png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0,
				},
			},
			{
				image = "techage_appl_pusher14.png^techage_frame14_ta"..stage..".png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0,
				},
			},
		},

		techage = {
			State = State,
			num_items = num_items,
		},
		
		on_rightclick = on_rightclick,
		after_dig_node = after_dig_node,
		on_timer = keep_running,
		on_rotate = screwdriver.disallow,
		on_timer = keep_running,
		
		paramtype2 = "facedir",
		diggable = false,
		groups = {crumbly=0, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("techage:ta"..stage.."_pusher_defect", {
		description = "TA"..stage.." Pusher",
		tiles = {
			-- up, down, right, left, back, front
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage.."_top.png^techage_appl_arrow.png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png^techage_appl_outp.png^tubelib_defect.png",
			"techage_filling_ta"..stage..".png^techage_frame_ta"..stage..".png^techage_appl_inp.png^tubelib_defect.png",
			"techage_appl_pusher.png^[transformR180]^techage_frame_ta"..stage..".png^tubelib_defect.png",
			"techage_appl_pusher.png^techage_frame_ta"..stage..".png^tubelib_defect.png",
		},

		techage = {
			State = State,
		},
		
		after_place_node = function(pos, placer)
			local mem = tubelib2.get_init(pos)
			local number = "-"
			if stage > 2 then
				number = techage.add_node(pos, "techage:ta"..stage.."_pusher")
			end
			TRD(pos).State:node_init(pos, mem, number)
			TRD(pos).State:defect(pos, mem)
		end,

		after_dig_node = function(pos)
			techage.remove_node(pos)
		end,
		
		on_rotate = screwdriver.disallow,

		paramtype2 = "facedir",
		groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
	})

	if stage == 2 then
		techage.register_node("techage:ta"..stage.."_pusher", 
			{"techage:ta"..stage.."_pusher_active", "techage:ta"..stage.."_pusher_defect"}, {
			is_pusher = true, -- is a pulling/pushing node
			
			on_recv_message = function(pos, topic, payload)
				return "unsupported"
			end,
			on_node_load = function(pos)
				TRD(pos).State:on_node_load(pos)
			end,
			on_node_repair = function(pos)
				return TRD(pos).State:on_node_repair(pos)
			end,
		})	
	else
		techage.register_node("techage:ta"..stage.."_pusher", 
			{"techage:ta"..stage.."_pusher_active", "techage:ta"..stage.."_pusher_defect"}, {
			is_pusher = true, -- is a pulling/pushing node
			
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
		})	
	end
end

register_pusher(2, 2)
register_pusher(3, 6)
register_pusher(4, 18)

minetest.register_craft({
	output = "techage:ta2_pusher 2",
	recipe = {
		{"group:wood", 		"wool:dark_green",   	"group:wood"},
		{"tubelib:tubeS", 	"default:mese_crystal",	"tubelib:tubeS"},
		{"group:wood", 		"wool:dark_green",   	"group:wood"},
	},
})
