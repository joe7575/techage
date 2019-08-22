--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
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
	| BLOCKED    long           yes           yes
	| STANDBY    long           yes           no
	| NOPOWER    long           no            no
	| FAULT      none           no            no
	| STOPPED    none           no            no

Node mem data:
	"techage_state"      - node state, like "RUNNING"
	"techage_item_meter" - node item/runtime counter
	"techage_countdown"  - countdown to stadby mode
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

--
-- TechAge machine states
--

techage.RUNNING = 1	-- in normal operation/turned on
techage.BLOCKED = 2 -- a pushing node is blocked due to a full destination inventory
techage.STANDBY = 3	-- nothing to do (e.g. no input items), or node (world) not loaded
techage.NOPOWER = 4	-- only for power consuming nodes, no operation
techage.FAULT   = 5	-- any fault state (e.g. wrong source items), which can be fixed by the player
techage.STOPPED = 6	-- not operational/turned off

techage.StatesImg = {
	"techage_inv_button_on.png", 
	"techage_inv_button_warning.png",
	"techage_inv_button_standby.png", 
	"techage_inv_button_nopower.png", 
	"techage_inv_button_error.png",
	"techage_inv_button_off.png", 
}

-- Return state button image for the node inventory
function techage.state_button(state)
	if state and state < 7 and state > 0 then
		return techage.StatesImg[state]
	end
	return "techage_inv_button_off.png"
end

function techage.get_power_image(pos, mem)
	local node = minetest.get_node(pos)
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

local function can_start(pos, mem)
	return true
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

-- true if node_timer should be executed
function techage.is_operational(mem)
	local state = mem.techage_state or STOPPED
	return state < NOPOWER
end

-- consumes power
function techage.needs_power(mem)
	local state = mem.techage_state or STOPPED
	return state < STANDBY
end

-- is node alive (power related)
function techage.power_alive(mem)
	local state = mem.techage_state or STOPPED
	return state < FAULT
end

function NodeStates:new(attr)
	local o = {
		-- mandatory
		cycle_time = attr.cycle_time, -- for running state
		standby_ticks = attr.standby_ticks, -- for standby state
		-- optional
		node_name_passive = attr.node_name_passive,
		node_name_active = attr.node_name_active, 
		infotext_name = attr.infotext_name,
		can_start = attr.can_start or can_start,
		start_node = attr.start_node,
		stop_node = attr.stop_node,
		formspec_func = attr.formspec_func,
		on_state_change = attr.on_state_change,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function NodeStates:node_init(pos, mem, number)
	mem.techage_state = STOPPED
	M(pos):set_string("node_number", number)
	if self.infotext_name then
		M(pos):set_string("infotext", self.infotext_name.." "..number..": stopped")
	end
	mem.techage_item_meter = 0
	if self.formspec_func then
		M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
	end
end

function NodeStates:stop(pos, mem)
	local state = mem.techage_state or STOPPED
	mem.techage_state = STOPPED
	if self.stop_node then
		self.stop_node(pos, mem, state)
	end
	if self.node_name_passive then
		swap_node(pos, self.node_name_passive)
	end
	if self.infotext_name then
		local number = M(pos):get_string("node_number")
		M(pos):set_string("infotext", self.infotext_name.." "..number..": stopped")
	end
	if self.formspec_func then
		M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
	end
	if self.on_state_change then
		self.on_state_change(pos, state, STOPPED)
	end
	if minetest.get_node_timer(pos):is_started() then
		minetest.get_node_timer(pos):stop()
	end
	return true
end

function NodeStates:start(pos, mem)
	local state = mem.techage_state or STOPPED
	if state ~= RUNNING and state ~= FAULT then
		if not self.can_start(pos, mem, state) then
			self:fault(pos, mem)
			return false
		end
		mem.techage_state = RUNNING
		if self.start_node then
			self.start_node(pos, mem, state)
		end
		mem.techage_countdown = 1
		if self.node_name_active then
			swap_node(pos, self.node_name_active)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": running")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		if minetest.get_node_timer(pos):is_started() then
			minetest.get_node_timer(pos):stop()
		end
		if self.on_state_change then
			self.on_state_change(pos, state, RUNNING)
		end
		minetest.get_node_timer(pos):start(self.cycle_time)
		return true
	end
	return false
end

-- to be used from node timer functions
function NodeStates:start_from_timer(pos, mem)
	local state = mem.techage_state or STOPPED
	if state ~= RUNNING and state ~= FAULT then
		minetest.after(0.1, self.start, self, pos, mem)
	end
end

function NodeStates:standby(pos, mem)
	local state = mem.techage_state or STOPPED
	if state == RUNNING then
		mem.techage_state = STANDBY
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": standby")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		if minetest.get_node_timer(pos):is_started() then
			minetest.get_node_timer(pos):stop()
		end
		if self.on_state_change then
			self.on_state_change(pos, state, STANDBY)
		end
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end	

-- special case of standby for pushing nodes
function NodeStates:blocked(pos, mem)
	local state = mem.techage_state or STOPPED
	if state == RUNNING then
		mem.techage_state = BLOCKED
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": blocked")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		if minetest.get_node_timer(pos):is_started() then
			minetest.get_node_timer(pos):stop()
		end
		if self.on_state_change then
			self.on_state_change(pos, state, BLOCKED)
		end
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end	

function NodeStates:nopower(pos, mem)
	local state = mem.techage_state or RUNNING
	if state ~= STOPPED then
		mem.techage_state = NOPOWER
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": no power")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		if self.on_state_change then
			self.on_state_change(pos, state, NOPOWER)
		end
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end	

function NodeStates:fault(pos, mem)
	local state = mem.techage_state or STOPPED
	if state == RUNNING or state == STOPPED then
		mem.techage_state = FAULT
		if self.node_name_passive then
			swap_node(pos, self.node_name_passive)
		end
		if self.infotext_name then
			local number = M(pos):get_string("node_number")
			M(pos):set_string("infotext", self.infotext_name.." "..number..": fault")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		if self.on_state_change then
			self.on_state_change(pos, state, FAULT)
		end
		minetest.get_node_timer(pos):stop()
		return true
	end
	return false
end	

function NodeStates:get_state(mem)
	return mem.techage_state or techage.STOPPED
end

function NodeStates:get_state_string(mem)
	return techage.StateStrings[mem.techage_state or STOPPED]
end

-- keep the timer running?
function NodeStates:is_active(mem)
	local state = mem.techage_state or STOPPED
	return state < FAULT
end

function NodeStates:start_if_standby(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.techage_state == STANDBY then
		self:start(pos, mem)
	end
end

-- To be called if node is idle.
-- If countdown reaches zero, the node is set to STANDBY.
function NodeStates:idle(pos, mem)
	local countdown = (mem.techage_countdown or 0) - 1
	mem.techage_countdown = countdown
	if countdown <= 0 then
		self:standby(pos, mem)
	end
end

-- To be called after successful node action to raise the timer
-- and keep the node in state RUNNING
function NodeStates:keep_running(pos, mem, val, num_items)
	-- set to RUNNING if not already done
	self:start_from_timer(pos, mem)
	mem.techage_countdown = val or 4
	mem.techage_item_meter = (mem.techage_item_meter or 0) + (num_items or 1)
end

-- Start/stop node based on button events.
-- if function returns false, no button was pressed
function NodeStates:state_button_event(pos, mem, fields)
	if fields.state_button ~= nil then
		local state = mem.techage_state or STOPPED
		if state == STOPPED or state == STANDBY or state == BLOCKED then
			self:start(pos, mem)
		elseif state == RUNNING or state == FAULT or state == NOPOWER then
			self:stop(pos, mem)
		end
		return true
	end
	return false
end

function NodeStates:get_state_button_image(mem)
	local state = mem.techage_state or STOPPED
	return techage.state_button(state)
end

-- command interface
function NodeStates:on_receive_message(pos, topic, payload)
	local mem = tubelib2.get_mem(pos)
	if topic == "on" then
		self:start(pos, tubelib2.get_mem(pos))
		return true
	elseif topic == "off" then
		self:stop(pos, tubelib2.get_mem(pos))
		return true
	elseif topic == "state" then
		local node = minetest.get_node(pos)
		if node.name == "ignore" then  -- unloaded node?
			return "blocked"
		end
		return self:get_state_string(tubelib2.get_mem(pos))
	elseif topic == "counter" then
		return mem.techage_item_meter or 1
	elseif topic == "clear_counter" then
		mem.techage_item_meter = 0
		return true
	elseif topic == "fuel" then
		local inv = M(pos):get_inventory()
		if inv:get_size("fuel") == 1 then
			local stack = inv:get_stack("fuel", 1)
			return stack:get_count()
		end
		return
	else
		return "unsupported"
	end
end
	
-- repair corrupt node data
function NodeStates:on_node_load(pos, not_start_timer)
	local mem = tubelib2.get_mem(pos)
	
	-- Meta data corrupt?
	local number = M(pos):get_string("node_number")
	if number == "" then 
		minetest.log("warning", "[TA] Node at "..S(pos).." has no node_number")
		local name = minetest.get_node(pos).name
		local number = techage.add_node(pos, name)
		self:node_init(pos, mem, number)
		return
	end
	
	-- wrong number and no dummy number?
	if number ~= "-" then 
		local info = techage.get_node_info(number)
		if not info or not info.pos or not vector.equals(pos, info.pos) then
			if not info then
				minetest.log("warning", "[TA] Node at "..S(pos).." has no info")
			elseif not info.pos then
				minetest.log("warning", "[TA] Node at "..S(pos).." has no info.pos")
			elseif not vector.equals(pos, info.pos) then
				minetest.log("warning", "[TA] Node at "..S(pos).." is pos ~= info.pos")
			end
			swap_node(pos, "techage:defect_dummy")
			return
		end
	end
	
	-- state corrupt?
	local state = mem.techage_state or 0
	if state == 0 then
		if minetest.get_node_timer(pos):is_started() then
			mem.techage_state = RUNNING
		else
			mem.techage_state = STOPPED
		end
	elseif state == RUNNING and not not_start_timer then
		minetest.get_node_timer(pos):start(self.cycle_time)
	elseif state == STANDBY then
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
	elseif state == BLOCKED then
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
	end
	
	if self.formspec_func then
		M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
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
