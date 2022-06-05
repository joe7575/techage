--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Water Pump

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local Pipe = techage.LiquidPipe
local power = networks.power
local liquid = networks.liquid

local CYCLE_TIME = 2
local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 3
local PWR_NEEDED = 4

local function formspec(self, pos, nvm)
	return "size[3,2]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;2.8,0.5;#c6e8ff]"..
		"label[0.5,-0.1;"..minetest.colorize( "#000000", S("Water Pump")).."]"..
		"image_button[1,1;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[1,1;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function can_start(pos, nvm, state)
	local outdir = M(pos):get_int("waterdir")
	local pos1 = vector.add(pos, tubelib2.Dir6dToVector[outdir or 0])
	if not techage.is_ocean(pos1) then
		return S("no usable water")
	end
	if not power.power_available(pos, Cable) then
		return S("no power")
	end
	return true
end

local function start_node(pos, nvm, state)
	nvm.running = true
end

local function stop_node(pos, nvm, state)
	nvm.running = false
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:t4_waterpump",
	infotext_name = S("TA4 Water Pump"),
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec_func = formspec,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
})

local function has_power(pos, nvm)
    local outdir = networks.Flip[M(pos):get_int("waterdir")]
    local taken = power.consume_power(pos, Cable, outdir, PWR_NEEDED)
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

local function pumping(pos, nvm)
	if has_power(pos, nvm) then
		nvm.ticks = (nvm.ticks or 0) + 1
		if nvm.ticks % 4 == 0 then
			local leftover = liquid.put(pos, Pipe, 6, "techage:water", 1)
			if leftover and leftover > 0 then
				State:blocked(pos, nvm)
				return
			end
		end
		State:keep_running(pos, nvm, 1)
	end
end

-- converts power into hydrogen
local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	pumping(pos, nvm)
	return State:is_active(nvm)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	nvm.running = false
	local number = techage.add_node(pos, "techage:t4_waterpump")
	State:node_init(pos, nvm, number)
	M(pos):set_int("waterdir", networks.side_to_outdir(pos, "R"))
	Pipe:after_place_node(pos)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

minetest.register_node("techage:t4_waterpump", {
	description = S("TA4 Water Pump"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_waterpump_top.png^techage_appl_hole_pipe.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
		"techage_filling_ta4.png^techage_frame_waterpump.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,

	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory = 1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
})

power.register_nodes({"techage:t4_waterpump"}, Cable, "con", {"L"})
liquid.register_nodes({"techage:t4_waterpump"}, Pipe, "pump", {"U"}, {})

techage.register_node({"techage:t4_waterpump"}, {
	on_recv_message = function(pos, src, topic, payload)
		return State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return State:on_beduino_request_data(pos, topic, payload)
	end,
})
