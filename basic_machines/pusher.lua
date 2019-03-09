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
local MEM = tubelib2.get_mem
local RND = function(meta) return RegNodeData[meta:get_int('ta_stage')]] end

-- Load support for intllib.
local MP = minetest.get_modpath("tubelib2")
local I,_ = dofile(MP.."/intllib.lua")

local STANDBY_TICKS = 10
local COUNTDOWN_TICKS = 10
local CYCLE_TIME = 2

local RegNodeData = {}

local function register_pusher(idx)
	RegNodeData[idx] = {}
	RegNodeData[idx].State = techage.NodeStates:new({
		node_name_passive= "techage:ta"..idx.."_pusher",
		node_name_active = "techage:ta"..idx.."_pusher_active",
		node_name_defect = "techage:ta"..idx.."_pusher_defect",
		infotext_name = "TA"..idx.." Pusher",
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		has_item_meter = true,
		aging_factor = 10,
	})

	local function pushing(pos, rnd, mem)
		local items = techage.pull_items(pos, mem.pull_dir, rnd.num_items)
		if items ~= nil then
			if techage.push_items(pos, mem.push_dir, items) == false then
				-- place item back
				techage.unpull_items(pos, mem.pull_dir, items)
				rnd.State:blocked(pos, mem)
				return
			end
			rnd.State:keep_running(pos, mem, COUNTDOWN_TICKS)
			return
		end
		rnd.State:idle(pos, mem)
	end

	local function keep_running(pos, elapsed)
		local meta = M(pos)
		pushing(pos, meta)
		return State:is_active(meta)
	end	

	minetest.register_node("tubelib:pusher", {
		description = "Tubelib Pusher",
		tiles = {
			-- up, down, right, left, back, front
			'tubelib_pusher1.png',
			'tubelib_pusher1.png',
			'tubelib_outp.png',
			'tubelib_inp.png',
			"tubelib_pusher1.png^[transformR180]",
			"tubelib_pusher1.png",
		},

		after_place_node = function(pos, placer)
			
			local meta = minetest.get_meta(pos)
			meta:set_string("player_name", placer:get_player_name())
			local number = tubelib.add_node(pos, "tubelib:pusher") -- <<=== tubelib
			
			this:node_init(pos, number)
		end,

		on_rightclick = function(pos, node, clicker)
			if not minetest.is_protected(pos, clicker:get_player_name()) then
				State:start(pos, M(pos))
			end
		end,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			tubelib.remove_node(pos) -- <<=== tubelib
			State:after_dig_node(pos, oldnode, oldmetadata, digger)
		end,
		
		on_timer = keep_running,
		on_rotate = screwdriver.disallow,

		drop = "",
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {choppy=2, cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
	})


	minetest.register_node("tubelib:pusher_active", {
		description = "Tubelib Pusher",
		tiles = {
			-- up, down, right, left, back, front
			{
				image = "tubelib_pusher.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0,
				},
			},
			{
				image = "tubelib_pusher.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0,
				},
			},
			'tubelib_outp.png',
			'tubelib_inp.png',
			{
				image = "tubelib_pusher.png^[transformR180]",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0,
				},
			},
			{
				image = "tubelib_pusher.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0,
				},
			},
		},

		on_rightclick = function(pos, node, clicker)
			if not minetest.is_protected(pos, clicker:get_player_name()) then
				State:stop(pos, M(pos))
			end
		end,
		
		on_timer = keep_running,
		on_rotate = screwdriver.disallow,
		
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {crumbly=0, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("tubelib:pusher_defect", {
		description = "Tubelib Pusher",
		tiles = {
			-- up, down, right, left, back, front
			'tubelib_pusher1.png',
			'tubelib_pusher1.png',
			'tubelib_outp.png^tubelib_defect.png',
			'tubelib_inp.png^tubelib_defect.png',
			"tubelib_pusher1.png^[transformR180]^tubelib_defect.png",
			"tubelib_pusher1.png^tubelib_defect.png",
		},

		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("player_name", placer:get_player_name())
			local number = tubelib.add_node(pos, "tubelib:pusher") -- <<=== tubelib
			State:node_init(pos, number)
			State:defect(pos, meta)
		end,

		after_dig_node = function(pos)
			tubelib.remove_node(pos) -- <<=== tubelib
		end,
		
		on_timer = keep_running,
		on_rotate = screwdriver.disallow,

		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
	})


	minetest.register_craft({
		output = "tubelib:pusher 2",
		recipe = {
			{"group:wood", 		"wool:dark_green",   	"group:wood"},
			{"tubelib:tubeS", 	"default:mese_crystal",	"tubelib:tubeS"},
			{"group:wood", 		"wool:dark_green",   	"group:wood"},
		},
	})

	--------------------------------------------------------------- tubelib
	tubelib.register_node("tubelib:pusher", 
		{"tubelib:pusher_active", "tubelib:pusher_defect"}, {
		on_pull_item = nil,  		-- pusher has no inventory
		on_push_item = nil,			-- pusher has no inventory
		on_unpull_item = nil,		-- pusher has no inventory
		is_pusher = true,           -- is a pulling/pushing node
		
		on_recv_message = function(pos, topic, payload)
			local resp = State:on_receive_message(pos, topic, payload)
			if resp then
				return resp
			else
				return "unsupported"
			end
		end,
		on_node_load = function(pos)
			State:on_node_load(pos)
		end,
		on_node_repair = function(pos)
			return State:on_node_repair(pos)
		end,
	})	
	--------------------------------------------------------------- tubelib
end

