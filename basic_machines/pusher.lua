--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
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
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).consumer end

local STANDBY_TICKS = 10
local COUNTDOWN_TICKS = 10
local CYCLE_TIME = 2

local function pushing(pos, crd, meta, mem)
	local pull_dir = meta:get_int("pull_dir")
	local push_dir = meta:get_int("push_dir")
	local items = techage.pull_items(pos, pull_dir, crd.num_items)
	if items ~= nil then
		if techage.push_items(pos, push_dir, items) ~= true then
			-- place item back
			techage.unpull_items(pos, pull_dir, items)
			crd.State:blocked(pos, mem)
			return
		end
		crd.State:keep_running(pos, mem, COUNTDOWN_TICKS)
		return
	end
	crd.State:idle(pos, mem)
end

local function keep_running(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local crd = CRD(pos)
	pushing(pos, crd, M(pos), mem)
	return crd.State:is_active(mem)
end	

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not minetest.is_protected(pos, clicker:get_player_name()) then
		if CRD(pos).State:get_state(mem) == techage.STOPPED then
			CRD(pos).State:start(pos, mem)
		else
			CRD(pos).State:stop(pos, mem)
		end
	end
end

local tiles = {}
-- '#' will be replaced by the stage number
-- '{power}' will be replaced by the power PNG
tiles.pas = {
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_appl_pusher.png^[transformR180]^techage_frame_ta#.png",
	"techage_appl_pusher.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	{
		image = "techage_appl_pusher14.png^[transformR180]^techage_frame14_ta#.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	{
		image = "techage_appl_pusher14.png^techage_frame14_ta#.png",
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
	is_pusher = true, -- is a pulling/pushing node
	
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
	techage.register_consumer("pusher", S("Pusher"), tiles, {
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		tubing = tubing,
		after_place_node = function(pos, placer)
			local mem = tubelib2.get_mem(pos)
			local meta = M(pos)
			local node = minetest.get_node(pos)
			meta:set_int("pull_dir", techage.side_to_outdir("L", node.param2))
			meta:set_int("push_dir", techage.side_to_outdir("R", node.param2))
		end,

		on_rightclick = on_rightclick,
		node_timer = keep_running,
		on_rotate = screwdriver.disallow,
		
		groups = {choppy=2, cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,2,6,18},
	})

minetest.register_craft({
	output = node_name_ta2.." 2",
	recipe = {
		{"group:wood", "wool:dark_green", "group:wood"},
		{"techage:tubeS", "default:mese_crystal", "techage:tubeS"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
	},
})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "techage:iron_ingot", ""},
		{"", node_name_ta2, ""},
		{"", "techage:vacuum_tube", ""},
	},
})

techage.register_entry_page("ta2", "pusher",
	S("TA2 Pusher"), 
	S("The Pusher is a pulling/pushing block, moving items from one inventory block to another (e.g. chests). "..
	"Start the Pusher with a right-click. It shows the state 'running' as infotext. "..
	"The Pusher moves items from left to right (IN to OUT).@n"..
	"If the source chest is empty, the Pusher goes into 'standby' state for some seconds. If the destination "..
	"chest is full, the Pusher goes into 'blocked' state.@n"..
	"The TA2 Pusher moves two items every 2 seconds."),
	"techage:ta2_pusher_pas")

techage.register_entry_page("ta3m", "pusher",
	S("TA3 Pusher"), 
	S("The Pusher is a pulling/pushing block, moving items from one inventory block to another (e.g. chests). "..
	"Start the Pusher with a right-click. It shows the state 'running' as infotext. "..
	"The Pusher moves items from left to right (IN to OUT).@n"..
	"If the source chest is empty, the Pusher goes into 'standby' state for some seconds. If the destination "..
	"chest is full, the Pusher goes into 'blocked' state.@n"..
	"The TA3 Pusher moves 6 items every 2 seconds."),
	"techage:ta3_pusher_pas")


