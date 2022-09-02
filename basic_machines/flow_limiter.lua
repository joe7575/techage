--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3/TA4 Item Flow Limiter

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end
local Tube = techage.Tube

local STANDBY_TICKS = 8
local CYCLE_TIME = 8

local function formspec(self, pos, nvm)
	return "size[6,3]" ..
		"box[0,-0.1;5.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize("#000000", S("Item Flow Limiter")) .. "]" ..
		"field[0.3,1.2;3.3,1;number;" .. S("Number of items") .. ";" .. (nvm.limit or 0) .. "]" ..
		"button[3.5,0.9;2.5,1;store;" .. S("Store") .. "]" ..
		"image_button[2.5,2;1,1;".. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[2.5,2;1,1;" .. self:get_state_tooltip(nvm) .. "]"
end

local function keep_running(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	CRD(pos).State:is_active(nvm)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	
	if fields.number and fields.store then
		nvm.limit = tonumber(fields.number) or 0
		nvm.num_items = 0
		CRD(pos).State:stop(pos, nvm)
	end
	CRD(pos).State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
end

local function can_start(pos, nvm, state)
	nvm.num_items = 0
	return true
end

local tiles = {}
-- '#' will be replaced by the stage number
-- '{power}' will be replaced by the power PNG
tiles.pas = {
	"techage_filling_ta#.png^techage_frame_ta#_top.png^techage_appl_arrow.png",
	"techage_filling_ta#.png^techage_frame_ta#_bottom.png^techage_appl_arrow.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_flow_limiter.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_flow_limiter.png^techage_frame_ta#.png",
}

tiles.act = tiles.pas

local tubing = {
	-- push item through until limit is reached
	on_push_item = function(pos, in_dir, stack)
		print("on_push_item", stack:get_name(), stack:get_count())
		local nvm = techage.get_nvm(pos)
		local count = math.min(stack:get_count(), (nvm.limit or 0) - (nvm.num_items or 0))
		if nvm.techage_state == techage.RUNNING and count > 0 and in_dir == M(pos):get_int("push_dir") then
			local leftover = techage.safe_push_items(pos, in_dir, ItemStack({name = stack:get_name(), count = count}))

			local num_pushed
			if not leftover then
				num_pushed = 0
			elseif leftover == true then
				num_pushed = count
			else
				num_pushed = count - leftover:get_count()
			end
			
			if num_pushed == 0 then
				return false
			else
				nvm.num_items = (nvm.num_items or 0) + num_pushed	
				if nvm.num_items == nvm.limit then
					CRD(pos).State:stop(pos, nvm)
				end
				stack:set_count(stack:get_count() - num_pushed)
				return stack
			end
		end
		return false
	end,
	is_pusher = true, -- is a pulling/pushing node

	on_recv_message = function(pos, src, topic, payload)
		if topic == "set" then -- set limit
			local nvm = techage.get_nvm(pos)
			CRD(pos).State:stop(pos, nvm)
			nvm.limit = tonumber(payload) or 0
			nvm.num_items = 0
			M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
			return true
		elseif topic == "count" then
			local nvm = techage.get_nvm(pos)
			return nvm.num_items or 0
		else
			return CRD(pos).State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 68 and payload then -- set limit
			local nvm = techage.get_nvm(pos)
			CRD(pos).State:stop(pos, nvm)
			nvm.limit = payload[1] or 0
			nvm.num_items = 0
			M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
			return 0
		else
			return CRD(pos).State:on_beduino_receive_cmnd(pos, topic, payload)
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 150 then -- Request count
			local nvm = techage.get_nvm(pos)
			return 0, {nvm.num_items or 0}
		else
			return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
		end
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 =
	techage.register_consumer("item_flow_limiter", S("Item Flow Limiter"), tiles, {
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		can_start = can_start,
		after_place_node = function(pos, placer)
			local meta = M(pos)
			local node = minetest.get_node(pos)
			meta:set_int("pull_dir", techage.side_to_outdir("L", node.param2))
			meta:set_int("push_dir", techage.side_to_outdir("R", node.param2))
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
		end,
		ta_rotate_node = function(pos, node, new_param2)
			Tube:after_dig_node(pos)
			minetest.swap_node(pos, {name = node.name, param2 = new_param2})
			Tube:after_place_node(pos)
			local meta = M(pos)
			meta:set_int("pull_dir", techage.side_to_outdir("L", new_param2))
			meta:set_int("push_dir", techage.side_to_outdir("R", new_param2))
		end,
		on_receive_fields = on_receive_fields,
		node_timer = keep_running,
		on_rotate = screwdriver.disallow,

		groups = {choppy=2, cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,2,6,12},
		tube_sides = {L=1, R=1},
	}, {false, false, true, true})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "techage:iron_ingot", ""},
		{"techage:baborium_ingot", node_name_ta2, "techage:usmium_nuggets"},
		{"", "techage:vacuum_tube", ""},
	},
})

minetest.register_craft({
	output = node_name_ta4,
	recipe = {
		{"", "techage:iron_ingot", ""},
		{"", node_name_ta3, ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})
