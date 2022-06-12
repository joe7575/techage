--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	A state model/class for TechAge nodes.

]]--


--[[

Node states:

        +-----------------------------------+    +------------+
        |                                   |    |            |
        |                                   V    V            |
        |                                +---------+          |
        |                                |         |          |
        |                      +---------| STOPPED |          |
        |                      |         |         |          |
        |               button |         +---------+          |
        |                      |              ^               |
 button |                      V              | button        |
        |                 +---------+         |               | button
        |      +--------->|         |---------+               |
        |      | power    | RUNNING |                         |
        |      |   +------|         |---------+               |
        |      |   |      +---------+         |               |
        |      |   |         ^    |           |               |
        |      |   |         |    |           |               |
        |      |   V         |    V           V               |
        |   +---------+   +----------+   +---------+          |
        |   |         |   |          |   |         |          |
        +---| NOPOWER |   | STANDBY/ |   |  FAULT  |----------+
            |         |   | BLOCKED  |   |         |
            +---------+   +----------+   +---------+


	|           cycle time   operational   needs power
	+---------+------------+-------------+-------------
	| RUNNING    normal         yes           yes
	| BLOCKED    long           yes           no
	| STANDBY    long           yes           no
	| NOPOWER    long           no            no
	| FAULT      none           no            no
	| STOPPED    none           no            no

Node nvm data:
	"techage_state"      - node state, like "RUNNING"
	"techage_countdown"  - countdown to standby mode
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local N = techage.get_node_lvm

--
-- TechAge machine states
--

techage.RUNNING  = 1  -- in normal operation/turned on
techage.BLOCKED  = 2  -- a pushing node is blocked due to a full destination inventory
techage.STANDBY  = 3  -- nothing to do (e.g. no input items), or node (world) not loaded
techage.NOPOWER  = 4  -- only for power consuming nodes, no operation
techage.FAULT    = 5  -- any fault state (e.g. wrong source items), which can be fixed by the player
techage.STOPPED  = 6  -- not operational/turned off
techage.UNLOADED = 7  -- Map block unloaded
techage.INACTIVE = 8  -- Map block loaded but node is not actively working

techage.StatesImg = {
	"techage_inv_button_on.png",
	"techage_inv_button_warning.png",
	"techage_inv_button_standby.png",
	"techage_inv_button_nopower.png",
	"techage_inv_button_error.png",
	"techage_inv_button_off.png",
}

local function error(pos, msg)
	minetest.log("error", "[TA states] "..msg.." at "..S(pos).." "..N(pos).name)
end

-- Return state button image for the node inventory
function techage.state_button(state)
	if state and state < 7 and state > 0 then
		return techage.StatesImg[state]
	end
	return "techage_inv_button_off.png"
end

function techage.get_power_image(pos, nvm)
	local node = techage.get_node_lvm(pos)
	local s = "3" -- electrical power
	if string.find(node.name, "techage:ta2") then
		s = "2"  -- axles power
	end
	return "techage_inv_powerT"..s..".png"
end

-- State string based on button states
techage.StateStrings = {"running", "blocked", "standby", "nopower", "fault", "stopped"}

--
-- Local States
--
local RUNNING = techage.RUNNING
local BLOCKED = techage.BLOCKED
local STANDBY = techage.STANDBY
local NOPOWER = techage.NOPOWER
local FAULT   = techage.FAULT
local STOPPED = techage.STOPPED


--
-- NodeStates Class Functions
--
techage.NodeStates = {}
local NodeStates = techage.NodeStates

local function can_start(pos, nvm)
	--if false, node goes in FAULT
	return true
end

local function has_power(pos, nvm)
	--if false, node goes in NOPOWER
	return true
end

local function swap_node(pos, new_name, old_name)
	local node = techage.get_node_lvm(pos)
	if node.name == new_name then
		return
	end
	if node.name == old_name then
		node.name = new_name
		minetest.swap_node(pos, node)
	end
end

-- true if node_timer should be executed
function techage.is_operational(nvm)
	local state = nvm.techage_state or STOPPED
	return state < NOPOWER
end

function techage.is_running(nvm)
	return (nvm.techage_state or STOPPED) == RUNNING
end

-- consumes power
function techage.needs_power(nvm)
	local state = nvm.techage_state or STOPPED
	return state == RUNNING or state == NOPOWER
end

-- consumes power
function techage.needs_power2(state)
	state = state or STOPPED
	return state == RUNNING or state == NOPOWER
end

function techage.get_state_string(nvm)
	return techage.StateStrings[nvm.techage_state or STOPPED]
end

function NodeStates:new(attr)
	local o = {
		-- mandatory
		cycle_time = attr.cycle_time, -- for running state
		standby_ticks = attr.standby_ticks, -- for standby state
		-- optional
		countdown_ticks = attr.countdown_ticks or 1,
		node_name_passive = attr.node_name_passive,
		node_name_active = attr.node_name_active,
		infotext_name = attr.infotext_name,
		has_power =  attr.has_power or has_power,
		can_start = attr.can_start or can_start,
		start_node = attr.start_node,
		stop_node = attr.stop_node,
		formspec_func = attr.formspec_func,
		on_state_change = attr.on_state_change,
		quick_start = attr.quick_start,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function NodeStates:node_init(pos, nvm, number)
	nvm.techage_state = STOPPED
	M(pos):set_string("node_number", number)
	if self.infotext_name then
		M(pos):set_string("infotext", self.infotext_name.." "..number..": stopped")
	end
	if self.formspec_func then
		M(pos):set_string("formspec", self.formspec_func(self, pos, nvm))
	end
end

-- to be used to re-start the timer outside of node_timer()
local function start_timer_delayed(pos, cycle_time)
	local t = minetest.get_node_timer(pos)
	t:stop()
	if cycle_time > 0.9 then
		minetest.after(0.1, t.start, t, cycle_time)
	else
		error(pos, "invalid cycle_time")
	end
end

function NodeStates:stop(pos, nvm)
	local state = nvm.techage_state or STOPPED
	nvm.techage_state = STOPPED
	if self.stop_node then
		self.stop_node(pos, nvm, state)
	end
	if self.node_name_passive then
		swap_node(pos, self.node_name_passive, self.node_name_active)
	end
	if self.infotext_name then
		local number = M(pos):get_string("node_number")
		M(pos):set_string("infotext", self.infotext_name.." "..number..": stopped")
	end
	if self.formspec_func then
		nvm.ta_state_tooltip = "stopped"
		M(pos):set_string("formspec", self.formspec_func(self, pos, nvm))
	end
	if self.on_state_change then
		self.on_state_change(pos, state, STOPPED)
	end
	if minetest.get_node_timer(pos):is_started() then
		minetest.get_node_timer(pos):stop()
	end
	return true
end

function NodeStates:start(pos, nvm)
	local state = nvm.techage_state or STOPPED
	if state ~= RUNNING and state ~= FAULT then
		local res = self.can_start(pos, nvm, state)
		if res ~= true then
			self:fault(pos, nvm, res)
			return false
		end
		if not self.has_power(pos, nvm, state) then
			self:nopower(pos, nvm)
			return false
		end
		nvm.techage_state = RUNNING
		if self.start_node then
			self.start_node(pos, nvm, state)
		end
		nvm.techage_countdown = self.countdown_ticks
		if self.node_name_active then
			swap_node(pos, self.node_name_active, self.node_name_passive)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": running")
		end
		if self.formspec_func then
			nvm.ta_state_tooltip = "running"
			M(pos):set_string("formspec", self.formspec_func(self, pos, nvm))
		end
		if minetest.get_node_timer(pos):is_started() then
			minetest.get_node_timer(pos):stop()
		end
		if self.on_state_change then
			self.on_state_change(pos, state, RUNNING)
		end
		start_timer_delayed(pos, self.cycle_time)

		if self.quick_start and state == STOPPED then
			self.quick_start(pos, 0)
		end
		return true
	end
	return false
end

function NodeStates:standby(pos, nvm, err_string)
	local state = nvm.techage_state or STOPPED
	if state == RUNNING or state == BLOCKED then
		nvm.techage_state = STANDBY
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive, self.node_name_active)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": "..(err_string or "standby"))
		end
		if self.formspec_func then
			nvm.ta_state_tooltip = err_string or "standby"
			M(pos):set_string("formspec", self.formspec_func(self, pos, nvm))
		end
		if self.on_state_change then
			self.on_state_change(pos, state, STANDBY)
		end
		start_timer_delayed(pos, self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end

-- special case of standby for pushing nodes
function NodeStates:blocked(pos, nvm, err_string)
	local state = nvm.techage_state or STOPPED
	if state == RUNNING then
		nvm.techage_state = BLOCKED
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive, self.node_name_active)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": "..(err_string or "blocked"))
		end
		if self.formspec_func then
			nvm.ta_state_tooltip = err_string or "blocked"
			M(pos):set_string("formspec", self.formspec_func(self, pos, nvm))
		end
		if self.on_state_change then
			self.on_state_change(pos, state, BLOCKED)
		end
		start_timer_delayed(pos, self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end

function NodeStates:nopower(pos, nvm, err_string)
	local state = nvm.techage_state or RUNNING
	if state ~= NOPOWER then
		nvm.techage_state = NOPOWER
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive, self.node_name_active)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": "..(err_string or "no power"))
		end
		if self.formspec_func then
			nvm.ta_state_tooltip = err_string or "no power"
			M(pos):set_string("formspec", self.formspec_func(self, pos, nvm))
		end
		if self.on_state_change then
			self.on_state_change(pos, state, NOPOWER)
		end
		start_timer_delayed(pos, self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end

function NodeStates:fault(pos, nvm, err_string)
	local state = nvm.techage_state or STOPPED
	err_string = err_string or "fault"
	if state == RUNNING or state == STOPPED then
		nvm.techage_state = FAULT
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive, self.node_name_active)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": "..err_string)
		end
		if self.formspec_func then
			nvm.ta_state_tooltip = err_string or "fault"
			M(pos):set_string("formspec", self.formspec_func(self, pos, nvm))
		end
		if self.on_state_change then
			self.on_state_change(pos, state, FAULT)
		end
		minetest.get_node_timer(pos):stop()
		return true
	end
	return false
end

function NodeStates:get_state(nvm)
	return nvm.techage_state or techage.STOPPED
end

-- keep the timer running?
function NodeStates:is_active(nvm)
	local state = nvm.techage_state or STOPPED
	return state < FAULT
end

function NodeStates:start_if_standby(pos)
	local nvm = techage.get_nvm(pos)
	if nvm.techage_state == STANDBY then
		self:start(pos, nvm)
	end
end

-- To be called if node is idle.
-- If countdown reaches zero, the node is set to STANDBY.
function NodeStates:idle(pos, nvm)
	local countdown = (nvm.techage_countdown or 0) - 1
	nvm.techage_countdown = countdown
	if countdown <= 0 then
		self:standby(pos, nvm)
	end
end

-- To be called after successful node action to raise the timer
-- and keep the node in state RUNNING
function NodeStates:keep_running(pos, nvm, val)
	-- set to RUNNING if not already done
	if nvm.techage_state ~= RUNNING then
		self:start(pos, nvm)
	end
	nvm.techage_countdown = val or 4
	nvm.last_active = minetest.get_gametime()
end

function NodeStates:trigger_state(pos, nvm)
	nvm.last_active = minetest.get_gametime()
end

-- Start/stop node based on button events.
-- if function returns false, no button was pressed
function NodeStates:state_button_event(pos, nvm, fields)
	if fields.state_button ~= nil then
		local state = nvm.techage_state or STOPPED
		if state == STOPPED or state == STANDBY or state == BLOCKED then
			if not self:start(pos, nvm) and (state == STANDBY or state == BLOCKED) then
				self:stop(pos, nvm)
			end
		elseif state == RUNNING or state == FAULT or state == NOPOWER then
			self:stop(pos, nvm)
		end
		return true
	end
	return false
end

function NodeStates:get_state_button_image(nvm)
	local state = nvm.techage_state or STOPPED
	return techage.state_button(state)
end

function NodeStates:get_state_tooltip(nvm)
	local tp = nvm.ta_state_tooltip or ""
	return tp..";#0C3D32;#FFFFFF"
end

-- command interface
function NodeStates:on_receive_message(pos, topic, payload)
	local nvm = techage.get_nvm(pos)
	if topic == "on" then
		self:start(pos, techage.get_nvm(pos))
		return true
	elseif topic == "off" then
		self:stop(pos, techage.get_nvm(pos))
		return true
	elseif topic == "state" then
		local node = minetest.get_node(pos)
		if node.name == "ignore" then  -- unloaded node?
			return "unloaded"
		elseif nvm.techage_state == RUNNING then
			local ttl = (nvm.last_active or 0) + 2 * (self.cycle_time or 0)
			if ttl < minetest.get_gametime() then
				return "inactive"
			end
		end
		return techage.get_state_string(techage.get_nvm(pos))
	elseif topic == "fuel" then
		return techage.fuel.get_fuel_amount(nvm)
	elseif topic == "load" then
		return techage.liquid.get_liquid_amount(nvm)
	else
		return "unsupported"
	end
end

function NodeStates:on_beduino_receive_cmnd(pos, topic, payload)
	if topic == 1 then
		if payload[1] == 0 then
			self:stop(pos, techage.get_nvm(pos))
			return 0
		else
			self:start(pos, techage.get_nvm(pos))
			return 0
		end
	else
		return 2  -- unknown or invalid topic
	end
end

function NodeStates:on_beduino_request_data(pos, topic, payload)
	local nvm = techage.get_nvm(pos)
	if topic == 128 then
		return 0, techage.get_node_lvm(pos).name
	elseif topic == 129 then
		local node = minetest.get_node(pos)
		if node.name == "ignore" then  -- unloaded node?
			return 0, {techage.UNLOADED}
		elseif nvm.techage_state == RUNNING then
			local ttl = (nvm.last_active or 0) + 2 * (self.cycle_time or 0)
			if ttl < minetest.get_gametime() then
				return 0, {techage.INACTIVE}
			end
		end
		return 0, {nvm.techage_state or STOPPED}
	else
		return 2, ""  -- topic is unknown or invalid
	end
end

-- restart timer
function NodeStates:on_node_load(pos)
	local nvm = techage.get_nvm(pos)
	local state = nvm.techage_state or STOPPED
	if state == RUNNING then
		minetest.get_node_timer(pos):start(self.cycle_time)
	elseif state < FAULT then
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
	end
end

minetest.register_node("techage:defect_dummy", {
	description = "Corrupted Node (to be replaced)",
	tiles = {
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_defect.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_defect.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_defect.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_defect.png",
	},
	drop = "",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	is_ground_content = false,
})
