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
	"tubelib_number"     - string with tubelib number, like "123"
	"tubelib_state"      - node state, like "RUNNING"
	"tubelib_item_meter" - node item/runtime counter
	"tubelib_countdown"  - countdown to stadby mode
	"tubelib_aging"      - aging counter
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
techage.FAULT   = 4	-- any fault state (e.g. no fuel), which can be fixed by the player
techage.BLOCKED = 5 -- a pushing node is blocked due to a full destination inventory
techage.DEFECT  = 6	-- a defect (broken), which has to be repaired by the player

techage.StatesImg = {
	"tubelib_inv_button_off.png", 
	"tubelib_inv_button_on.png", 
	"tubelib_inv_button_standby.png", 
	"tubelib_inv_button_error.png",
	"tubelib_inv_button_warning.png",
	"tubelib_inv_button_off.png",
}

-- Return state button image for the node inventory
function techage.state_button(state)
	if state and state < 7 and state > 0 then
		return techage.StatesImg[state]
	end
	return "tubelib_inv_button_off.png"
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

local function start_condition_fullfilled(pos, meta)
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
		start_condition_fullfilled = attr.start_condition_fullfilled or start_condition_fullfilled,
		on_start = attr.on_start,
		on_stop = attr.on_stop,
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

function NodeStates:node_init(pos, number)
	local meta = M(pos)
	meta:set_int("tubelib_state", STOPPED)
	meta:set_string("tubelib_number", number)
	if self.infotext_name then
		meta:set_string("infotext", self.infotext_name.." "..number..": stopped")
	end
	if self.has_item_meter then
		meta:set_int("tubelib_item_meter", 0)
	end
	if self.aging_level1 then
		meta:set_int("tubelib_aging", 0)
	end
	if self.formspec_func then
		meta:set_string("formspec", self.formspec_func(self, pos, meta))
	end
end

function NodeStates:stop(pos, meta)
	local state = meta:get_int("tubelib_state")
	if state ~= DEFECT then
		if self.on_stop then
			self.on_stop(pos, meta, state)
		end
		meta:set_int("tubelib_state", STOPPED)
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = meta:get_string("tubelib_number")
			meta:set_string("infotext", self.infotext_name.." "..number..": stopped")
		end
		if self.formspec_func then
			meta:set_string("formspec", self.formspec_func(self, pos, meta))
		end
		minetest.get_node_timer(pos):stop()
		return true
	end
	return false
end

function NodeStates:start(pos, meta, called_from_on_timer)
	local state = meta:get_int("tubelib_state")
	if state == STOPPED or state == STANDBY or state == BLOCKED then
		if not self.start_condition_fullfilled(pos, meta) then
			return false
		end
		if self.on_start then
			self.on_start(pos, meta, state)
		end
		meta:set_int("tubelib_state", RUNNING)
		meta:set_int("tubelib_countdown", 4)
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
			local number = meta:get_string("tubelib_number")
			meta:set_string("infotext", self.infotext_name.." "..number..": running")
		end
		if self.formspec_func then
			meta:set_string("formspec", self.formspec_func(self, pos, meta))
		end
		minetest.get_node_timer(pos):start(self.cycle_time)
		return true
	end
	return false
end

function NodeStates:standby(pos, meta)
	if meta:get_int("tubelib_state") == RUNNING then
		meta:set_int("tubelib_state", STANDBY)
		-- timer has to be stopped once to be able to be restarted
		self.stop_timer = true
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = meta:get_string("tubelib_number")
			meta:set_string("infotext", self.infotext_name.." "..number..": standby")
		end
		if self.formspec_func then
			meta:set_string("formspec", self.formspec_func(self, pos, meta))
		end
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end	

-- special case of standby for pushing nodes
function NodeStates:blocked(pos, meta)
	if meta:get_int("tubelib_state") == RUNNING then
		meta:set_int("tubelib_state", BLOCKED)
		-- timer has to be stopped once to be able to be restarted
		self.stop_timer = true
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = meta:get_string("tubelib_number")
			meta:set_string("infotext", self.infotext_name.." "..number..": blocked")
		end
		if self.formspec_func then
			meta:set_string("formspec", self.formspec_func(self, pos, meta))
		end
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
		return true
	end
	return false
end	

function NodeStates:fault(pos, meta)
	if meta:get_int("tubelib_state") == RUNNING then
		meta:set_int("tubelib_state", FAULT)
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.infotext_name then
			local number = meta:get_string("tubelib_number")
			meta:set_string("infotext", self.infotext_name.." "..number..": fault")
		end
		if self.formspec_func then
			meta:set_string("formspec", self.formspec_func(self, pos, meta))
		end
		minetest.get_node_timer(pos):stop()
		return true
	end
	return false
end	

function NodeStates:defect(pos, meta)
	meta:set_int("tubelib_state", DEFECT)
	if self.node_name_defect then
		local node = minetest.get_node(pos)
		node.name = self.node_name_defect
		minetest.swap_node(pos, node)
	end
	if self.infotext_name then
		local number = meta:get_string("tubelib_number")
		meta:set_string("infotext", self.infotext_name.." "..number..": defect")
	end
	if self.formspec_func then
		meta:set_string("formspec", self.formspec_func(self, pos, meta))
	end
	minetest.get_node_timer(pos):stop()
	return true
end	

function NodeStates:get_state(meta)
	return meta:get_int("tubelib_state")
end

function NodeStates:get_state_string(meta)
	return techage.StateStrings[meta:get_int("tubelib_state")]
end

function NodeStates:is_active(meta)
	local state = meta:get_int("tubelib_state")
	if self.stop_timer == true then
		self.stop_timer = false
		return false
	end
	return state == RUNNING or state == STANDBY or state == BLOCKED
end

-- To be called if node is idle.
-- If countdown reaches zero, the node is set to STANDBY.
function NodeStates:idle(pos, meta)
	local countdown = meta:get_int("tubelib_countdown") - 1
	meta:set_int("tubelib_countdown", countdown)
	if countdown < 0 then
		self:standby(pos, meta)
	end
end

-- To be called after successful node action to raise the timer
-- and keep the node in state RUNNING
function NodeStates:keep_running(pos, meta, val, num_items)
	num_items = num_items or 1
	-- set to RUNNING if not already done
	self:start(pos, meta, true)
	meta:set_int("tubelib_countdown", val)
	meta:set_int("tubelib_item_meter", meta:get_int("tubelib_item_meter") + (num_items or 1))
	if self.aging_level1 then
		local cnt = meta:get_int("tubelib_aging") + num_items
		meta:set_int("tubelib_aging", cnt)
		if (cnt > (self.aging_level1) and math.random(self.aging_level2/num_items) == 1)
		or cnt >= 999999 then
			self:defect(pos, meta)
		end
	end
end

-- Start/stop node based on button events.
-- if function returns false, no button was pressed
function NodeStates:state_button_event(pos, fields)
	if fields.state_button ~= nil then
		local state = self:get_state(M(pos))
		if state == STOPPED or state == STANDBY or state == BLOCKED then
			self:start(pos, M(pos))
		elseif state == RUNNING or state == FAULT then
			self:stop(pos, M(pos))
		end
		return true
	end
	return false
end

function NodeStates:get_state_button_image(meta)
	local state = meta:get_int("tubelib_state")
	return techage.state_button(state)
end

-- command interface
function NodeStates:on_receive_message(pos, topic, payload)
	if topic == "on" then
		self:start(pos, M(pos))
		return true
	elseif topic == "off" then
		self:stop(pos, M(pos))
		return true
	elseif topic == "state" then
		local node = minetest.get_node(pos)
		if node.name == "ignore" then  -- unloaded node?
			return "blocked"
		end
		return self:get_state_string(M(pos))
	elseif self.has_item_meter and topic == "counter" then
		return M(pos):get_int("tubelib_item_meter")
	elseif self.has_item_meter and topic == "clear_counter" then
		M(pos):set_int("tubelib_item_meter", 0)
		return true
	elseif self.aging_level1 and topic == "aging" then
		return M(pos):get_int("tubelib_aging")
	end
end
	
-- repair corrupt node data and/or migrate node to state2
function NodeStates:on_node_load(pos, not_start_timer)
	local meta = minetest.get_meta(pos)
	
	-- legacy node number/state/counter?
	local number = meta:get_string("number")
	if number ~= "" and number ~= nil then
		meta:set_string("tubelib_number", number)
		meta:set_int("tubelib_state", techage.state(meta:get_int("running")))
		if self.has_item_meter then
			meta:set_int("tubelib_item_meter", meta:get_int("counter"))
		end
		if self.aging_level1 then
			meta:set_int("tubelib_aging", 0)
		end
		meta:set_string("number", nil)
		meta:set_int("running", 0)
		meta:set_int("counter", 0)
	end

	-- node number corrupt?
	number = meta:get_string("tubelib_number")
	if number == "" then
		number = techage.get_new_number(pos, self.node_name_passive)
		meta:set_string("tubelib_number", number)
	else
		local info = techage.get_node_info(number)
		if not info or info.pos ~= pos then
			number = techage.get_new_number(pos, self.node_name_passive)
			meta:set_string("tubelib_number", number)
		end
	end
	
	-- state corrupt?
	local state = meta:get_int("tubelib_state")
	if state == 0 then
		if minetest.get_node_timer(pos):is_started() then
			meta:set_int("tubelib_state", RUNNING)
		else
			meta:set_int("tubelib_state", STOPPED)
		end
	elseif state == RUNNING and not not_start_timer then
		minetest.get_node_timer(pos):start(self.cycle_time)
	elseif state == STANDBY then
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
	elseif state == BLOCKED then
		minetest.get_node_timer(pos):start(self.cycle_time * self.standby_ticks)
	end
	
	if self.formspec_func then
		meta:set_string("formspec", self.formspec_func(self, pos, meta))
	end
end

-- Repair of defect (feature!) nodes
function NodeStates:on_node_repair(pos)
	local meta = M(pos)
	if meta:get_int("tubelib_state") == DEFECT then
		meta:set_int("tubelib_state", STOPPED)
		if self.node_name_passive then
			local node = minetest.get_node(pos)
			node.name = self.node_name_passive
			minetest.swap_node(pos, node)
		end
		if self.aging_level1 then
			meta:set_int("tubelib_aging", 0)
		end
		if self.infotext_name then
			local number = meta:get_string("tubelib_number")
			meta:set_string("infotext", self.infotext_name.." "..number..": stopped")
		end
		if self.formspec_func then
			meta:set_string("formspec", self.formspec_func(self, pos, meta))
		end
		return true
	end
	return false
end	

-- Return working or defect machine, depending on machine lifetime
function NodeStates:after_dig_node(pos, oldnode, oldmetadata, digger)
	local inv = minetest.get_inventory({type="player", name=digger:get_player_name()})
	local cnt = oldmetadata.fields.tubelib_aging and tonumber(oldmetadata.fields.tubelib_aging) or 0
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
	
