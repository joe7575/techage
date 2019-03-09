--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Power consumption for any kind of power distribution network

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local TP = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end
local TN = function(node) return (minetest.registered_nodes[node.name] or {}).techage end

-- Used to determine the already passed nodes while power distribution
local Route = {}
-- Used to store the power input direction of each node
local PowerInDir = {}

local function pos_already_reached(pos)
	local key = minetest.hash_node_position(pos)
	if not Route[key] then
		Route[key] = true
		return false
	end
	return true
end
	
local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}

local function side_to_dir(pos, side)
	local node = minetest.get_node(pos)
	local dir = SideToDir[side]
	if dir < 5 then
		dir = (((dir - 1) + (node.param2 % 4)) % 4) + 1
	end
	return dir
end

function techage.get_pos(pos, side)
	local dir = side_to_dir(pos, side)
	return tubelib2.get_pos(pos, dir)
end	

local function get_power_dir(pos)
	local key = minetest.hash_node_position(pos)
	if not PowerInDir[key] then
		PowerInDir[key] = tubelib2.Turn180Deg[side_to_dir(pos, TP(pos).power_side or 'L')]
	end
	return PowerInDir[key]
end

local power_consumption = nil

local function call_read_power_consumption(pos, in_dir)
	if not pos_already_reached(pos) then
		local this = TP(pos)
		if this and this.read_power_consumption then
			return this.read_power_consumption(pos, in_dir)
		else
			return power_consumption(pos, in_dir)
		end
	end
	return 0
end

-- Calculate the power consumption on the given network
power_consumption = function(pos, in_dir)
	local sum = call_read_power_consumption(pos, in_dir)
	--local sum = 0
	local mem = tubelib2.get_mem(pos)
	local conn = mem.connections or {}
	for _,item in pairs(conn) do
		if item.pos then
			sum = sum + call_read_power_consumption(item.pos, item.in_dir)
		end
	end
	return sum
end
			
-- Switch active/passive tube nodes 
local function turn_tube_on(pos, in_dir, network, on)
	local out_dir = tubelib2.Turn180Deg[in_dir]
	if on then
		network:switch_tube_line(pos, out_dir, "on")
	else
		network:switch_tube_line(pos, out_dir, "off")
	end
end


local turn_on = nil

local function call_turn_on(pos, in_dir, sum)
	if not pos_already_reached(pos) then
		local this = TP(pos)
		if this and (not this.valid_power_dir or this.valid_power_dir(pos, get_power_dir(pos), in_dir)) then
			if this.turn_on then
				this.turn_on(pos, in_dir, sum)
			end
		end
		if this and this.animated_power_network then
			turn_tube_on(pos, in_dir, this.power_network, sum > 0)
		end
		-- Needed for junctions which could have a local "turn_on" in addition
		turn_on(pos, in_dir, sum)
	end
end

-- turn nodes on if sum > 0
turn_on = function(pos, in_dir, sum)
	call_turn_on(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	local conn = mem.connections or {}
	for _,item in pairs(conn) do
		if item.pos then
			call_turn_on(item.pos, item.in_dir, sum)
		end
	end
end


-- Starts the overall power consumption and depending on that turns all nodes on/off
local function start_network_power_consumption(pos, in_dir)
	print("start_network_power_consumption")
	Route = {}
	local sum = power_consumption(pos, in_dir)
	Route = {}
	turn_on(pos, in_dir, sum)
	print("consumption = "..sum)
end

--
-- Generator functions for nodes with one power side (view from the outside)
--
techage.generator = {}

function techage.generator.after_place_node(pos)
	local mem = tubelib2.init_mem(pos)
	mem.power_produce = 0
	TP(pos).power_network:after_place_node(pos)
	return mem
end
		
function techage.generator.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	-- check if contact side is correct
	local mem = tubelib2.get_mem(pos)
	local pwr_dir = get_power_dir(pos)
	if tubelib2.Turn180Deg[out_dir] == pwr_dir then
		if not peer_in_dir then
			mem.connections = {} -- del connection
		else
			-- Generator accept one dir only
			mem.connections = {[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}}
		end
		-- To be called delayed, so that all network connections have been established
		minetest.after(0.2, start_network_power_consumption, pos, pwr_dir)
	end
end

function techage.generator.turn_power_on(pos, power_capacity)
	local mem = tubelib2.get_mem(pos)
	mem.power_capacity = power_capacity
	-- Starts the overall power consumption and depending on that turns all nodes on/off
	-- To be called delayed, so that the generator state machine can be handled before
	minetest.after(0.2, start_network_power_consumption, pos, get_power_dir(pos))
end

-- Power network callback function
function techage.generator.read_power_consumption(pos, in_dir)
	local mem = tubelib2.get_mem(pos)
	if in_dir == get_power_dir(pos) then
		return mem.power_capacity or 0
	end
	return 0
end

function techage.generator.after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end

function techage.generator.formspec_level(mem, sum)
	local percent = ((sum or 0) * 100) / (mem.power_capacity or 1)
	return "techage_form_level_bg.png^[lowpart:"..percent..":techage_form_level_fg.png]"
end


--
-- Distributor functions for nodes with 6 power sides (view from the outside)
--
techage.distributor = {}

function techage.distributor.after_place_node(pos, placer)
	local mem = tubelib2.init_mem(pos)
	TP(pos).power_network:after_place_node(pos)
	return mem
end
		
function techage.distributor.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	mem.connections = mem.connections or {}
	if not peer_in_dir then
		mem.connections[out_dir] = nil -- del connection
	else
		mem.connections[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}
	end
	-- To be called delayed, so that all network connections have been established
	minetest.after(0.2, start_network_power_consumption, pos)
end

-- Needed if the junction consumes power in addition
function techage.distributor.read_power_consumption(pos, in_dir)
	return power_consumption(pos, in_dir) - TP(pos).power_consumption or 0
end
	
function techage.distributor.after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end

--
-- Consumer functions with variable number of power sides (view from the outside)
--
techage.consumer = {}

function techage.consumer.after_place_node(pos, placer)
	local mem = tubelib2.init_mem(pos)
	-- Power_dir is in-dir
	mem.power_consumption = 0
	TP(pos).power_network:after_place_node(pos)
	return mem
end
		
function techage.consumer.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	local pwr_dir = get_power_dir(pos)
	mem.connections = mem.connections or {}
	-- Check direction
	--if not TP(pos).valid_power_dir(pos, pwr_dir, tubelib2.Turn180Deg[out_dir]) then return end
	-- Only one connection is allowed, which can be overwritten, if necessary.
	if not peer_pos or not next(mem.connections) or mem.connections[out_dir] then
		if not peer_in_dir then
			mem.connections = {} -- del connection
		else
			mem.connections = {[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}}
		end
	end
	-- To be called delayed, so that all network connections have been established
	minetest.after(0.2, start_network_power_consumption, pos, pwr_dir)
end

function techage.consumer.turn_power_on(pos, power_consumption)
	local mem = tubelib2.get_mem(pos)
	mem.power_consumption = power_consumption
	-- Starts the overall power consumption and depending on that turns all nodes on/off
	-- To be called delayed, so that the consumer state machine can be handled before
	minetest.after(0.2, start_network_power_consumption, pos, get_power_dir(pos))
end
	
-- Power network callback function
function techage.consumer.read_power_consumption(pos, in_dir)
	local mem = tubelib2.get_mem(pos)
	-- Check direction
	if not TP(pos).valid_power_dir(pos, get_power_dir(pos), in_dir) then return 0 end
	return -(mem.power_consumption or 0)
end

function techage.consumer.after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end
