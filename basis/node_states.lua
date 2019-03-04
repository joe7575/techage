--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
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
 repair |                      V              | button        |                                      
        |                 +---------+         |               | button                               
        |                 |         |---------+               |                                      
        |                 | RUNNING |                         |                                      
        |        +--------|         |---------+               |                                      
        |        |        +---------+         |               |                                      
        |        |           ^    |           |               |                                      
        |        |           |    |           |               |                                      
        |        V           |    V           V               |                                      
        |   +---------+   +----------+   +---------+          |                                      
        |   |         |   |          |   |         |          |                                      
        +---| DEFECT  |   | STANDBY/ |   |  FAULT  |----------+                                      
            |         |   | BLOCKED  |   |         |                                                 
            +---------+   +----------+   +---------+                                                 

Node metadata:
	"techage_number"     - string with tubelib number, like "123"
	"techage_state"      - node state, like "RUNNING"
	"techage_item_meter" - node item/runtime counter
	"techage_countdown"  - countdown to stadby mode
	"techage_aging"      - aging counter
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta


--
-- TechAge machine states
--

techage.STOPPED = 1	-- not operational/turned off
techage.RUNNING = 2	-- in normal operation/turned on
techage.STANDBY = 3	-- nothing to do (e.g. no input items), or blocked anyhow (output jammed),
                    -- or node (world) not loaded
techage.FAULT   = 4	-- any fault state (e.g. no power), which can be fixed by the player
techage.BLOCKED = 5 -- a pushing node is blocked due to a full destination inventory
techage.DEFECT  = 6	-- a defect (broken), which has to be repaired by the player

techage.StatesImg = {
	"techage_inv_button_off.png", 
	"techage_inv_button_on.png", 
	"techage_inv_button_standby.png", 
	"techage_inv_button_error.png",
	"techage_inv_button_warning.png",
	"techage_inv_button_off.png",
}

-- Return state button image for the node inventory
function techage.state_button(state)
	if state and state < 7 and state > 0 then
		return techage.StatesImg[state]
	end
	return "techage_inv_button_off.png"
end

-- State string based on button states
techage.StateStrings = {"stopped", "running", "standby", "fault", "blocked", "defect"}

--
-- Local States
--
local STOPPED = techage.STOPPED
local RUNNING = techage.RUNNING
local STANDBY = techage.STANDBY
local FAULT   = techage.FAULT
local BLOCKED = techage.BLOCKED
local DEFECT  = techage.DEFECT


local AGING_FACTOR = 4  -- defect random factor

--
-- NodeStates Class Functions
--
techage.NodeStates = {}
local NodeStates = techage.NodeStates

local function can_start(pos, mem)
	return true
end

function NodeStates:new(attr)
	local o = {
		-- mandatory
		cycle_time = attr.cycle_time, -- for running state
		standby_ticks = attr.standby_ticks, -- for standby state
		has_item_meter = attr.has_item_meter, -- true/false
		-- optional
		node_name_passive = attr.node_name_passive,
		node_name_active = attr.node_name_active, 
		node_name_defect = attr.node_name_defect,
		infotext_name = attr.infotext_name,
		can_start = attr.can_start or can_start,
		start_node = attr.start_node,
		stop_node = attr.stop_node,
		formspec_func = attr.formspec_func,
	}
	if attr.aging_factor then
		o.aging_level1 = attr.aging_factor * techage.machine_aging_value
		o.aging_level2 = attr.aging_factor * techage.machine_aging_value * AGING_FACTOR
	end
	setmetatable(o, self)
	self.__index = self
	return o
end

function NodeStates:node_init(pos, mem, number)
	mem.techage_state = STOPPED
	mem.techage_number = number
	if self.infotext_name then
		M(pos):set_string("infotext", self.infotext_name.." "..number..": stopped")
	end
	if self.has_item_meter then
		mem.techage_item_meter = 0
	end
	if self.aging_level1 then
		mem.techage_aging = 0
	end
	if self.formspec_func then
		M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
	end
end

function NodeStates:stop(pos, mem)
	local state = mem.techage_state
	if state ~= DEFECT then
		if self.stop_node then
			self.stop_node(pos, mem, state)
		end
		mem.techage_state = STOPPED
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = mem.techage_number
			M(pos):set_string("infotext", self.infotext_name.." "..number..": stopped")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		minetest.get_node_timer(pos):stop()
		return true
	end
	return false
end

function NodeStates:start(pos, mem, called_from_on_timer)
	local state = mem.techage_state
	if state == STOPPED or state == STANDBY or state == BLOCKED then
		if not self.can_start(pos, mem, state) then
			self:fault(pos, mem)
			return false
		end
		if self.start_node then
			self.start_node(pos, mem, state)
		end
		mem.techage_state = RUNNING
		mem.techage_countdown = 4
		if called_from_on_timer then
			-- timer has to be stopped once to be able to be restarted
			self.stop_timer = true
		end
		if self.node_name_active then
			local node = minetest.get_node(pos)
			node.name = self.node_name_active
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = mem.techage_number
			M(pos):set_string("infotext", self.infotext_name.." "..number..": running")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		minetest.get_node_timer(pos):start(self.cycle_time)
		return true
	end
	return false
end

function NodeStates:standby(pos, mem)
	if mem.techage_state == RUNNING then
		mem.techage_state = STANDBY
		-- timer has to be stopped once to be able to be restarted
		self.stop_timer = true
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = mem.techage_number
			M(pos):set_string("infotext", self.infotext_name.." "..number..": standby")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end	

-- special case of standby for pushing nodes
function NodeStates:blocked(pos, mem)
	if mem.techage_state == RUNNING then
		mem.techage_state = BLOCKED
		-- timer has to be stopped once to be able to be restarted
		self.stop_timer = true
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = mem.techage_number
			M(pos):set_string("infotext", self.infotext_name.." "..number..": blocked")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end	

function NodeStates:fault(pos, mem)
	if mem.techage_state == RUNNING then
		mem.techage_state = FAULT
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = mem.techage_number
			M(pos):set_string("infotext", self.infotext_name.." "..number..": fault")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		minetest.get_node_timer(pos):stop()
		return true
	end
	return false
end	

function NodeStates:defect(pos, mem)
	mem.techage_state = DEFECT
	if self.node_name_defect then
		local node = minetest.get_node(pos)
		node.name = self.node_name_defect
		minetest.swap_node(pos, node)
	end
	if self.infotext_name then
		local number = mem.techage_number
		M(pos):set_string("infotext", self.infotext_name.." "..number..": defect")
	end
	if self.formspec_func then
		M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
	end
	minetest.get_node_timer(pos):stop()
	return true
end	

function NodeStates:get_state(mem)
	return mem.techage_state
end

function NodeStates:get_state_string(mem)
	return techage.StateStrings[mem.techage_state]
end

function NodeStates:is_active(mem)
	local state = mem.techage_state
	if self.stop_timer == true then
		self.stop_timer = false
		return false
	end
	return state == RUNNING or state == STANDBY or state == BLOCKED
end

-- To be called if node is idle.
-- If countdown reaches zero, the node is set to STANDBY.
function NodeStates:idle(pos, mem)
	local countdown = mem.techage_countdown - 1
	mem.techage_countdown = countdown
	if countdown < 0 then
		self:standby(pos, mem)
	end
end

-- To be called after successful node action to raise the timer
-- and keep the node in state RUNNING
function NodeStates:keep_running(pos, mem, val, num_items)
	num_items = num_items or 1
	-- set to RUNNING if not already done
	self:start(pos, mem, true)
	mem.techage_countdown = val
	mem.techage_item_meter = mem.techage_item_meter + (num_items or 1)
	if self.aging_level1 then
		local cnt = mem.techage_aging + num_items
		mem.techage_aging = cnt
		if (cnt > (self.aging_level1) and math.random(self.aging_level2/num_items) == 1)
		or cnt >= 999999 then
			self:defect(pos, mem)
		end
	end
end

-- Start/stop node based on button events.
-- if function returns false, no button was pressed
function NodeStates:state_button_event(pos, mem, fields)
	if fields.state_button ~= nil then
		local state = mem.techage_state
		print("on_receive_fields", state)
		if state == STOPPED or state == STANDBY or state == BLOCKED then
			self:start(pos, mem)
		elseif state == RUNNING or state == FAULT then
			self:stop(pos, mem)
		end
		return true
	end
	return false
end

function NodeStates:get_state_button_image(mem)
	local state = mem.techage_state
	return techage.state_button(state)
end

-- command interface
function NodeStates:on_receive_message(pos, topic, payload)
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
	elseif self.has_item_meter and topic == "counter" then
		return mem.techage_item_meter
	elseif self.has_item_meter and topic == "clear_counter" then
		mem.techage_item_meter = 0
		return true
	elseif self.aging_level1 and topic == "aging" then
		return mem.techage_aging
	end
end
	
-- repair corrupt node data and/or migrate node to state2
function NodeStates:on_node_load(pos, not_start_timer)
	local mem = tubelib2.get_mem(pos)
	
	-- legacy node number/state/counter?
	local number = mem.number
	if number ~= "" and number ~= nil then
		mem.techage_number = number
		mem.techage_state = techage.state(mem.running)
		if self.has_item_meter then
			mem.techage_item_meter = mem.counter
		end
		if self.aging_level1 then
			mem.techage_aging = 0
		end
		mem.number = nil
		mem.running = 0
		mem.counter = 0
	end

	-- node number corrupt?
	number = mem.techage_number
	if number == "" then
		number = techage.get_new_number(pos, self.node_name_passive)
		mem.techage_number = number
	else
		local info = techage.get_node_info(number)
		if not info or info.pos ~= pos then
			number = techage.get_new_number(pos, self.node_name_passive)
			mem.techage_number = number
		end
	end
	
	-- state corrupt?
	local state = mem.techage_state
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

-- Repair of defect (feature!) nodes
function NodeStates:on_node_repair(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.techage_state == DEFECT then
		mem.techage_state = STOPPED
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.aging_level1 then
			mem.techage_aging = 0
		end
		if self.infotext_name then
			local number = mem.techage_number
			M(pos):set_string("infotext", self.infotext_name.." "..number..": stopped")
		end
		if self.formspec_func then
			M(pos):set_string("formspec", self.formspec_func(self, pos, mem))
		end
		return true
	end
	return false
end	

-- Return working or defect machine, depending on machine lifetime
function NodeStates:after_dig_node(pos, oldnode, oldmetadata, digger)
	local mem = tubelib2.get_mem(pos)
	local inv = minetest.get_inventory({type="player", name=digger:get_player_name()})
	local cnt = mem.techage_aging or 0
	local is_defect = cnt > self.aging_level1 and math.random(self.aging_level2 / cnt) == 1
	if self.node_name_defect and is_defect then
		inv:add_item("main", ItemStack(self.node_name_defect))
	else
		inv:add_item("main", ItemStack(self.node_name_passive))
	end
end

-- Return "full", "loaded", or "empty" depending
-- on the number of fuel stack items.
-- Function only works on fuel inventories with one stacks/99 items
function techage.fuelstate(meta, listname, item)
	if meta == nil or meta.get_inventory == nil then return nil end
	local inv = meta:get_inventory()
	if inv:is_empty(listname) then
		return "empty"
	end
	local list = inv:get_list(listname)
	if #list == 1 and list[1]:get_count() == 99 then
		return "full"
	else
		return "loaded"
	end
end
	
