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
local TP = function(pos) return minetest.registered_nodes[minetest.get_node(pos).name].techage end
local TN = function(node) return minetest.registered_nodes[node.name].techage end


-- Table to register the different power distribution network instances for global use
techage.Networks = {}

-- Used to determine the already passed nodes while power distribution
local Route = {}

local function pos_already_reached(pos)
	local key = minetest.hash_node_position(pos)
	if not Route[key] then
		Route[key] = true
		return false
	end
	return true
end
	
local DirToSide = {"B", "R", "F", "L", "D", "U"}

local function dir_to_side(pos, dir)
	local node = minetest.get_node(pos)
	if dir < 5 then
		dir = (((dir - 1) - (node.param2 % 4)) % 4) + 1
	end
	return DirToSide[dir]
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

function techage.next_pos(pos, side)
	local dir = side_to_dir(pos, side)
	return tubelib2.get_pos(pos, dir)
end	

-- Calculate the power consumption on the given network
local function power_consumption(pos, dir)
	if pos_already_reached(pos) then return 0 end
	local mem = tubelib2.get_mem(pos)
	local conn = mem.connections or {}
	local this = TP(pos)
	local val = this.power_consumption(pos, tubelib2.Turn180Deg[dir])
	for out_dir,item in pairs(conn) do
		-- Not in the opposite direction
		if out_dir ~= tubelib2.Turn180Deg[dir or 0] then
			if item.pos then
				this = TP(item.pos)
				if this and this.power_consumption then
					val = val + this.power_consumption(item.pos, item.in_dir)
				end
			end
		end
	end
	return val
end
			
local function turn_tube_on(pos, dir, network, on)
	if on then
		network:switch_tube_line(pos, dir, "on")
	else
		network:switch_tube_line(pos, dir, "off")
	end
end

local function turn_on(pos, dir, on)
	if pos_already_reached(pos) then return end
	local mem = tubelib2.get_mem(pos)
	local conn = mem.connections or {}
	local this = TP(pos)
	if this and this.turn_on then
		this.turn_on(pos, dir, on)
	end
	for out_dir,item in pairs(conn) do
		-- Not in the opposite direction
		if out_dir ~= tubelib2.Turn180Deg[dir or 0] then
			if item.pos then
				local this = TP(item.pos)
				if this and this.turn_on then
					this.turn_on(item.pos, item.in_dir, on)
				end
				if this and this.animated_power_network then
					turn_tube_on(item.pos, item.in_dir, this.power_network, on)
				end
				turn_on(item.pos, item.in_dir, on)
			end
		end
	end
end


-- To be called delayed from any node, after any change.
-- The result is stored in mem.power_result
local function calc_power_consumption(pos, dir)
	local mem = tubelib2.get_mem(pos)
	Route = {}
	local sum = power_consumption(pos, dir)
	Route = {}
	turn_on(pos, nil, sum > 0)
	
	mem.power_result = sum
	return sum
end

--
-- Generator with on power output side
--
function techage.generator_on(pos, max_power)
	local mem = tubelib2.get_mem(pos)
	mem.power_produce = max_power
	return calc_power_consumption(pos, mem.power_dir)
end

function techage.generator_off(pos)
	local mem = tubelib2.get_mem(pos)
	mem.power_produce = 0
	return calc_power_consumption(pos, mem.power_dir)
end

function techage.generator_power_consumption(pos, dir)
	local mem = tubelib2.get_mem(pos)
	if dir == tubelib2.Turn180Deg[mem.power_dir or 0] then
		return mem.power_produce or 0
	end
	return 0
end
	
function techage.generator_after_place_node(pos)
	local mem = tubelib2.init_mem(pos)
	mem.power_dir = side_to_dir(pos, TP(pos).power_side or 'R')
	mem.power_produce = 0 -- will be set via generator_on
	mem.power_result = 0
	TP(pos).power_network:after_place_node(pos)
	return mem
end
		
function techage.generator_after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	-- check if contact side is correct
	local mem = tubelib2.get_mem(pos)
	if out_dir == mem.power_dir then
		if not peer_in_dir then
			mem.connections = {} -- del connection
		else
			-- Generator accept one dir only
			mem.connections = {[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}}
		end
		minetest.after(0.2, calc_power_consumption, pos)
	end
end

function techage.generator_on_destruct(pos)
	techage.generator_off(pos)
end

function techage.generator_after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end

function techage.generator_formspec_level(mem)
	local percent = ((mem.power_result or 0) * 100) / (mem.power_produce or 1)
	return "techage_form_level_bg.png^[lowpart:"..percent..":techage_form_level_fg.png]"
end


--
-- Distributor with 6 power input/output sides
--
function techage.distributor_power_consumption(pos, dir)
	return power_consumption(pos, dir) - TP(pos).power_consume
end
	
function techage.distributor_after_place_node(pos, placer)
	local mem = tubelib2.init_mem(pos)
	TP(pos).power_network:after_place_node(pos)
	return mem
end
		
function techage.distributor_after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	mem.connections = mem.connections or {}
	if not peer_in_dir then
		mem.connections[out_dir] = nil -- del connection
	else
		mem.connections[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}
	end
	minetest.after(0.2, calc_power_consumption, pos)
end

function techage.distributor_after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end

--
-- Consumer with one power input side (default)
--
function techage.consumer_power_consumption(pos, dir)
	local mem = tubelib2.get_mem(pos)
	mem.power_consume = mem.power_consume or 0
	return -mem.power_consume
end
	
function techage.consumer_after_place_node(pos, placer)
	local mem = tubelib2.init_mem(pos)
	TP(pos).power_network:after_place_node(pos)
	return mem
end
		
function techage.consumer_after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	mem.connections = mem.connections or {}
	-- Only one connection is allowed, which can be overwritten, if necessary.
	if not peer_pos or not next(mem.connections) or mem.connections[out_dir] then
		if not peer_in_dir then
			mem.connections = {} -- del connection
		else
			mem.connections = {[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}}
		end
	end
	minetest.after(0.2, calc_power_consumption, pos)
end

function techage.consumer_after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end
