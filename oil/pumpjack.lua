--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Pumpjack

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local P = minetest.string_to_pos
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end
local CRDN = function(node) return (minetest.registered_nodes[node.name] or {}).consumer end

local STANDBY_TICKS = 2
local COUNTDOWN_TICKS = 10
local CYCLE_TIME = 8

local function has_oil(pos, meta)
	local storage_pos = meta:get_string("storage_pos")
	if storage_pos ~= "" then
		local amount, initial_amount = techage.explore.get_oil_amount(P(storage_pos))
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

local function formspec(self, pos, nvm)
	local amount = 0
	local storage_pos = M(pos):get_string("storage_pos")
	if storage_pos ~= "" then
		amount = techage.explore.get_oil_amount(P(storage_pos))
	end
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;4.8,0.5;#c6e8ff]"..
		"label[1.5,-0.1;"..minetest.colorize( "#000000", S("Pumpjack")).."]"..
		"image[0.5,1.5;1,1;techage_liquid2_inv.png^[colorize:#000000^techage_liquid1_inv.png]"..
		"image[4,0.8;1,1;"..techage.get_power_image(pos, nvm).."]"..
		"tooltip[4,0.8;1,1;"..S("needs power").."]"..
		"label[0,0.8;"..S("Oil amount")..": "..amount.."]"..
		"image_button[2,2.2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2,2.2;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function play_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.handle or mem.handle == -1 then
		mem.handle = minetest.sound_play("techage_reboiler", {
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

local function on_node_state_change(pos, old_state, new_state)
	if new_state == techage.RUNNING then
		play_sound(pos)
	else
		stop_sound(pos)
	end
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
end

local function pumping(pos, crd, meta, nvm)
	if has_oil(pos, meta) then
		local leftover = liquid.put(pos, Pipe, 6, "techage:oil_source", 1)
		if leftover and leftover > 0 then
			crd.State:blocked(pos, nvm)
			stop_sound(pos)
			return
		end
		dec_oil_item(pos, meta)
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
		return
	end
	crd.State:fault(pos, nvm, S("no oil"))
end

local function keep_running(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	pumping(pos, crd, M(pos), nvm)
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(crd.State, pos, nvm))
	end
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	CRD(pos).State:state_button_event(pos, nvm, fields)
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
	on_recv_message = function(pos, src, topic, payload)
		if topic == "load" then
			local storage_pos = M(pos):get_string("storage_pos")
			if storage_pos ~= "" then
				local amount, capa = techage.explore.get_oil_amount(P(storage_pos))
				if amount and capa and capa > 0 then
					return techage.power.percent(capa or 0, amount or 0), amount or 0
				end
			end
		else
			return CRD(pos).State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 134 then  -- Load
			local storage_pos = M(pos):get_string("storage_pos")
			if storage_pos ~= "" then
				local amount, capa = techage.explore.get_oil_amount(P(storage_pos))
				if amount and capa and capa > 0 then
					if payload[1] == 1 then
						return 0, {techage.power.percent(capa or 0, amount or 0)}
					else
						return 0, {math.min(amount or 0, 65535)}
					end
				end
			end
			return 2
		else
			return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
		end
	end,
	on_node_load = function(pos, node)
		CRD(pos).State:on_node_load(pos)
		if node.name == "techage:ta3_pumpjack_act" then
			play_sound(pos)
		end
	end,
}

local _, node_name_ta3, _ =
	techage.register_consumer("pumpjack", S("Oil Pumpjack"), tiles, {
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		on_state_change = on_node_state_change,
		after_place_node = function(pos, placer)
			local node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
			if node.name == "techage:oil_drillbit2" then
				local info = techage.explore.get_oil_info(pos)
				if info then
					M(pos):set_string("storage_pos", P2S(info.storage_pos))
				end
			end
			Pipe:after_place_node(pos)
		end,
		power_sides = {F=1, B=1, L=1, R=1, D=1},
		on_rightclick = on_rightclick,
		on_receive_fields = on_receive_fields,
		node_timer = keep_running,
		on_rotate = screwdriver.disallow,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			Pipe:after_dig_node(pos)
		end,

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

liquid.register_nodes({"techage:ta3_pumpjack_pas", "techage:ta3_pumpjack_act"}, Pipe, "pump", {"U"}, {})
