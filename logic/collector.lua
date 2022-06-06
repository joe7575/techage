--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Collector
	Collects states from other nodes, acting as a state concentrator.

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local NDEF = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}) end
local logic = techage.logic

local CYCLE_TIME = 1

local tStates = {stopped = 0, running = 0, standby = 1, blocked = 2, nopower = 3, fault = 4}
local tDropdownPos = {["1 standby"] = 1, ["2 blocked"] = 2, ["3 nopower"] = 3, ["4 fault"] = 4}
local lStates = {[0] = "stopped", "standby", "blocked", "nopower", "fault"}
local TaStates = {running = 1, blocked = 2, standby = 3, nopower = 4, fault = 5, stopped = 6}

local function formspec(nvm, meta)
	nvm.poll_numbers = nvm.poll_numbers or {}
	local poll_numbers = table.concat(nvm.poll_numbers, " ")
	local event_number = meta:get_string("event_number")
	local dropdown_pos = meta:get_int("dropdown_pos")
	if dropdown_pos == 0 then dropdown_pos = 1 end

	return "size[9,6]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"field[0.3,0.6;9,1;poll_numbers;"..S("Node numbers to read the states from")..":;"..poll_numbers.."]" ..
		"field[0.3,2;9,1;event_number;"..S("Node number to send the events to")..":;"..event_number.."]" ..
		"label[1.3,2.8;"..S("Send an event if state is equal or larger than")..":]"..
		"dropdown[1.2,3.4;7,4;severity;1 standby,2 blocked,3 nopower,4 fault;"..dropdown_pos.."]"..
		"button_exit[3,5;2,1;exit;Save]"
end


local function send_event(nvm, meta)
	local event_number = meta:get_string("event_number")
	if event_number ~= "" then
		local severity = meta:get_int("dropdown_pos")
		local own_number = meta:get_string("own_number")
		if nvm.common_state >= severity then
			techage.send_multi(own_number, event_number, "on")
		else
			techage.send_multi(own_number, event_number, "off")
		end
	end
end

local function request_state(nvm, meta)
	local number = nvm.poll_numbers and nvm.poll_numbers[nvm.idx]
	if number then
		local own_number = meta:get_string("own_number")
		local state = techage.send_single(own_number, number, "state", nil)
		if state then
			state = tStates[state] or 0
			nvm.common_state = math.max(nvm.common_state, state)
		end
	end
end


local function on_timer(pos,elapsed)
	local nvm = techage.get_nvm(pos)
	local meta = minetest.get_meta(pos)
	nvm.idx = (nvm.idx or 0) + 1
	nvm.common_state = nvm.common_state or 0

	if not nvm.poll_numbers then
		local own_number = meta:get_string("own_number")
		meta:set_string("infotext", S("TA4 State Collector").." "..own_number..": stopped")
		nvm.common_state = 0
		nvm.idx = 1
		return false
	end

	if nvm.idx > #nvm.poll_numbers then
		nvm.idx = 1
		if nvm.stored_state ~= nvm.common_state then
			send_event(nvm, meta)
			local own_number = meta:get_string("own_number")
			meta:set_string("infotext", S("TA4 State Collector").." "..own_number..': "'..lStates[nvm.common_state]..'"')
			nvm.stored_state = nvm.common_state
		end
		nvm.common_state = 0  -- reset for the next round
	end

	request_state(nvm, meta)
	return true
end

minetest.register_node("techage:ta4_collector", {
	description = S("TA4 State Collector"),
	inventory_image = "techage_smartline_collector_inv.png",
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_smartline_collector.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},

	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		local meta = minetest.get_meta(pos)
		local own_number = techage.add_node(pos, "techage:ta4_collector")
		meta:set_string("own_number", own_number)
		meta:set_string("formspec", formspec(nvm, meta))
		meta:set_string("infotext", S("TA4 State Collector").." "..own_number)
		meta:set_string("owner", placer:get_player_name())
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner ~= player:get_player_name() then
			return
		end

		local nvm = techage.get_nvm(pos)
		local timer = minetest.get_node_timer(pos)
		local own_number = meta:get_string("own_number")

		if fields.quit == "true" and fields.poll_numbers then
			if techage.check_numbers(fields.event_number, player:get_player_name()) then
				meta:set_string("event_number", fields.event_number)
			end
			if techage.check_numbers(fields.poll_numbers, player:get_player_name()) then
				nvm.poll_numbers = string.split(fields.poll_numbers, " ")
				nvm.idx = 0
				if not timer:is_started() then
					timer:start(CYCLE_TIME)
				end
				meta:set_string("infotext", S("TA4 State Collector").." "..own_number..": running")
			else
				if timer:is_started() then
					timer:stop()
				end
				meta:set_string("infotext", S("TA4 State Collector").." "..own_number..": stopped")
				nvm.common_state = 0
				nvm.stored_state = 0
			end
			if fields.severity then
				meta:set_int("dropdown_pos", tDropdownPos[fields.severity])
			end
			meta:set_string("formspec", formspec(nvm, meta))
		end
	end,

	techage_set_numbers = function(pos, numbers, player_name)
		local nvm = techage.get_nvm(pos)
		local meta = M(pos)
		local res = logic.set_numbers(pos, numbers, player_name, NDEF(pos).description)
		meta:set_string("formspec", formspec(nvm, meta))
		return res
	end,

	on_timer = on_timer,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})


minetest.register_craft({
	output = "techage:ta4_collector",
	recipe = {
		{"", "techage:aluminum", "dye:blue"},
		{"", "default:mese_crystal_fragment", "techage:ta4_wlanchip"},
	},
})

techage.register_node({"techage:ta4_collector"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "state" then
			local nvm = techage.get_nvm(pos)
			return lStates[nvm.stored_state or 0]
		else
			return "unsupported"
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 129 then
			local nvm = techage.get_nvm(pos)
			return 0, {TaStates[lStates[nvm.stored_state or 0]]}
		else
			return 2, ""
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})
