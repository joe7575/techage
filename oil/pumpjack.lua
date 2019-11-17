--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Pumpjack

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local P = minetest.string_to_pos
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end
local CRDN = function(node) return (minetest.registered_nodes[node.name] or {}).consumer end

local STANDBY_TICKS = 10
local COUNTDOWN_TICKS = 10
local CYCLE_TIME = 8

local function has_oil(pos, meta)
	local storage_pos = meta:get_string("storage_pos")
	if storage_pos ~= "" then
		local amount = techage.explore.get_oil_amount(P(storage_pos))
		if amount > 0 then
			return true
		end
	end
end

local function dec_oil_item(pos, meta)
	local storage_pos = meta:get_string("storage_pos")
	if storage_pos ~= "" then
		techage.explore.dec_oil_amount(P(storage_pos))
	end
end

local function formspec(self, pos, mem)
	local amount = 0
	local storage_pos = M(pos):get_string("storage_pos")
	if storage_pos ~= "" then
		amount = techage.explore.get_oil_amount(P(storage_pos))
	end
	return "size[5,3]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"image[0.5,0;1,1;techage_liquid2_inv.png^[colorize:#000000^techage_liquid1_inv.png]"..
	"image[2,0;1,1;"..techage.get_power_image(pos, mem).."]"..
	"label[0,1.3;"..S("Oil amount:")..": "..amount.."]"..
	"button[3,1.1;2,1;update;"..S("Update").."]"..
	"image_button[2,2.2;1,1;".. self:get_state_button_image(mem) ..";state_button;]"
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, mem))
end

local function pumping(pos, crd, meta, mem)
	if has_oil(pos, meta) then
		--if techage.push_items(pos, 6, items) ~= true then
		if liquid.put(pos, 6, "techage:oil_source", 1) > 0 then
			crd.State:blocked(pos, mem)
			return
		end
		dec_oil_item(pos, meta)
		crd.State:keep_running(pos, mem, COUNTDOWN_TICKS)
		return
	end
	crd.State:fault(pos, mem)
end

local function keep_running(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local crd = CRD(pos)
	pumping(pos, crd, M(pos), mem)
	return crd.State:is_active(mem)
end	

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	if fields.update then
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("formspec", formspec(CRD(pos).State, pos, mem))
	else
		local mem = tubelib2.get_mem(pos)
		CRD(pos).State:state_button_event(pos, mem, fields)
	end
end

local tiles = {}

-- '#' will be replaced by the stage number
tiles.pas = {
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_hole_pipe.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_hole_pipe.png",
	"techage_appl_pumpjack.png^techage_frame_ta#.png",
	"techage_appl_pumpjack.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png^[transformR90]",
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png^[transformR90]",
}
tiles.act = {
	-- up, down, right, left, back, front
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_hole_pipe.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_hole_pipe.png",
	{
		image = "techage_appl_pumpjack14.png^techage_frame14_ta#.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	{
		image = "techage_appl_pumpjack14.png^techage_frame14_ta#.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png^[transformR90]",
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png^[transformR90]",
}
	
local tubing = {
	is_pusher = true, -- is a pulling/pushing node
	
	on_recv_message = function(pos, src, topic, payload)
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
	
local _, node_name_ta3, _ = 
	techage.register_consumer("pumpjack", S("Oil Pumpjack"), tiles, {
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		after_place_node = function(pos, placer)
			local node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
			if node.name == "techage:oil_drillbit2" then
				local info = techage.explore.get_oil_info(pos)
				if info then
					M(pos):set_string("storage_pos", P2S(info.storage_pos)) 
				end
			end
		end,
		networks = {
			pipe = {
				sides = {U = 1}, -- Pipe connection side
				ntype = "pump",
			},
		},
		tubelib2_on_update2 = function(pos, outdir, tlib2, node)
			liquid.update_network(pos, outdir)
		end,
		on_rightclick = on_rightclick,
		on_receive_fields = on_receive_fields,
		node_timer = keep_running,
		on_rotate = screwdriver.disallow,
		
		groups = {choppy=2, cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,1,1,1},
		power_consumption = {0,16,16,16},
	},
	{false, false, true, false})  -- TA3 only

minetest.register_craft({
	output = "techage:ta3_pumpjack_pas",
	recipe = {
		{"", "techage:usmium_nuggets", ""},
		{"dye:red", "techage:ta3_pusher_pas", "dye:red"},
		{"", "techage:oil_drillbit", ""},
	},
})

Pipe:add_secondary_node_names({"techage:ta3_pumpjack_pas", "techage:ta3_pumpjack_act"})

