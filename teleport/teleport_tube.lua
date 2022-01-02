--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 teleport nodes

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local Tube = techage.Tube
local teleport = techage.teleport
local Cable = techage.ElectricCable
--local Cable = techage.Axle
local power = networks.power

local STANDBY_TICKS = 4
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 2
local PWR_NEEDED = 12
local EX_POINTS = 60
local DESCRIPTION = S("TA5 Teleport Tube")

-- 2 Blöcke on/off
-- Strom von 7 Seiten
-- Pipe/Tube nur von einer Seite
-- TA5 Design
-- Consumer block mit on/off
-- Inventory mit 4 stacks
-- wrench menü?
-- normales Menü wenn connected

local WRENCH_MENU = {
	{
		type = "dropdown",
		choices = "1,2,4,6,8,12,16",
		name = "ontime",
		label = S("On Time") .. " [s]",
		tooltip = S("The time between the 'on' and 'off' commands."),
		default = "1",
	},
	{
		type = "dropdown",
		choices = "2,4,6,8,12,16,20",
		name = "blockingtime",
		label = S("Blocking Time") .. " [s]",
		tooltip = S("The time after the 'off' command\nuntil the next 'on' command is accepted."),
		default = "8",
	},
	{
		type = "items",
		name = "config",
		label = S("Configured Items"),
		tooltip = S("Items which generate an 'on' command.\nIf empty, all passed items generate an 'on' command."),
		size = 4,
	}
}

local function formspec(self, pos, nvm)
	local title = DESCRIPTION .. " " .. M(pos):get_string("tele_status")
	return "size[8,2]"..
		"box[0,-0.1;7.8,0.5;#c6e8ff]" ..
		"label[0.5,-0.1;" .. minetest.colorize( "#000000", title) .. "]" ..
		"image_button[3.5,1;1,1;" .. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[3.5,1;1,1;" .. self:get_state_tooltip(nvm) .. "]"
end

local function can_start(pos, nvm, state)
	return teleport.is_connected(pos)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta5_tele_tube",
	infotext_name = DESCRIPTION,
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	countdown_ticks = COUNTDOWN_TICKS,
	formspec_func = formspec,
	can_start = can_start,
})

local function consume_power(pos, nvm)
	if techage.needs_power(nvm) then
		local taken = power.consume_power(pos, Cable, nil, PWR_NEEDED)
		if techage.is_running(nvm) then
			if taken < PWR_NEEDED then
				State:nopower(pos, nvm)
			else
				return true  -- keep running
			end
		elseif taken == PWR_NEEDED then
			State:start(pos, nvm)
		end
	end
end

minetest.register_node("techage:ta5_tele_tube", {
	description = DESCRIPTION,
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5_top.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_wifi.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_tube.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_wifi.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_wifi.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local node = minetest.get_node(pos)
		local tube_dir = techage.side_to_outdir("L", node.param2)
		local number = techage.add_node(pos, "techage:ta5_tele_tube")
		nvm.running = false
		State:node_init(pos, nvm, number)
		meta:set_int("tube_dir", tube_dir)
		meta:set_string("owner", placer:get_player_name())
		Tube:after_place_node(pos, {tube_dir})
		Cable:after_place_node(pos)
		teleport.prepare_pairing(pos, "ta5_tele_tube")
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		if teleport.is_connected(pos) then
			local nvm = techage.get_nvm(pos)
			State:state_button_event(pos, nvm, fields)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		else
			if techage.get_expoints(player) >= EX_POINTS then
				teleport.after_formspec(pos, fields)
			end
		end
	end,

	on_rightclick = function(pos, clicker, listname)
		if teleport.is_connected(pos) then
			local nvm = techage.get_nvm(pos)
			M(pos):set_string("formspec", formspec(State, pos, nvm))
		else
			M(pos):set_string("formspec", teleport.formspec(pos))
		end	
	end,
	
	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		consume_power(pos, nvm)
		-- the state has to be triggered by on_push_item
		State:idle(pos, nvm)
		return State:is_active(nvm)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		teleport.stop_pairing(pos, oldmetadata)
		Tube:after_dig_node(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,

	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	is_ground_content = false,
	groups = {choppy=2, cracky=2, crumbly=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:ta5_tele_tube",
	recipe = {
		{"", "dye:red", ""},
		{"techage:ta4_tubeS", "techage:ta5_aichip", ""},
		{"", "group:wood", ""},
	},
})

techage.register_node({"techage:ta5_tele_tube"}, {
	on_push_item = function(pos, in_dir, stack)
		local nvm = techage.get_nvm(pos)
		if techage.is_operational(nvm) then
			local rmt_pos = teleport.get_remote_pos(pos)
			local rmt_nvm = techage.get_nvm(rmt_pos)
			if techage.is_operational(rmt_nvm) then
				local tube_dir = M(rmt_pos):get_int("tube_dir")
				if techage.push_items(rmt_pos, tube_dir, stack) then
					State:keep_running(pos, nvm, COUNTDOWN_TICKS)
					State:keep_running(rmt_pos, rmt_nvm, COUNTDOWN_TICKS)
					return true
				end
			else
				State:blocked(pos, nvm, S("Remote node error"))
			end
		end
		return false
	end,
	is_pusher = true,  -- is a pulling/pushing node

	on_recv_message = function(pos, src, topic, payload)
		if topic == "count" then
			local nvm = techage.get_nvm(pos)
			return nvm.counter or 0
		elseif topic == "reset" then
			local nvm = techage.get_nvm(pos)
			nvm.counter = 0
			return true
		else
			return "unsupported"
		end
	end,
})

power.register_nodes({"techage:ta5_tele_tube"}, Cable, "con", {"B", "R", "F", "D", "U"})
Tube:set_valid_sides("techage:ta5_tele_tube", {"L"})

