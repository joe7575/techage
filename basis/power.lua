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
	local val = 0
	for fdir,fpos in pairs(conn) do
		if fdir ~= tubelib2.Turn180Deg[dir or 0] then
			local this = TP(fpos)
			if this and this.power_consumption then
				--print("power_consumption", S(fpos), dump(val), dump(this.power_consumption(fpos, fdir)))
				val = val + this.power_consumption(fpos, fdir)
			else
				val = val + power_consumption(fpos, fdir)
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
	--print("turn_on", dump(conn))
	for fdir,fpos in pairs(conn) do
		if fdir ~= tubelib2.Turn180Deg[dir or 0] then
			local this = TP(fpos)
			if this and this.turn_on then
				this.turn_on(fpos, fdir, on)
			end
			if this and this.animated_power_network then
				turn_tube_on(pos, fdir, this.power_network, on)
			end
			turn_on(fpos, fdir, on)
		end
	end
end

-- power source: power > 0
-- power sink: power < 0
-- switched off: power = 0
local function sink_power_consumption(pos, power)
	Route = {}
	local sum = power + power_consumption(pos)
	Route = {}
	print("sink_power_consumption", sum)
	turn_on(pos, nil, sum > 0)
	return sum
end

-- To be called from any generator
local function source_power_consumption(pos, mem)
	local power = mem.power_produce or 0
	mem.power_result = sink_power_consumption(pos, power)
	return mem.power_result > 0
end

techage.sink_power_consumption = sink_power_consumption
techage.source_power_consumption = source_power_consumption


--
-- Generator with on power output side
--
function techage.generator_on(pos, power)
	local mem = tubelib2.get_mem(pos)
	mem.power_produce = power
	return source_power_consumption(pos, mem)
end

function techage.generator_off(pos)
	local mem = tubelib2.get_mem(pos)
	mem.power_produce = 0
	return source_power_consumption(pos, mem)
end

function techage.generator_power_consumption(pos, dir)
	local mem = tubelib2.get_mem(pos)
	--print("generator_power_consumption", dir, mem.power_dir)
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
end
		
function techage.generator_after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	-- check if contact side is correct
	local mem = tubelib2.get_mem(pos)
	if out_dir == mem.power_dir then
		-- store connection for 'source_power_consumption()'
		mem.connections = {[out_dir] = peer_pos}
		source_power_consumption(pos, mem)
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
	--print("generator_formspec_level", mem.power_result, mem.power_produce)
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
	local this = TP(pos)
	this.power_network:after_place_node(pos)
	sink_power_consumption(pos, -this.power_consume)
end
		
function techage.distributor_after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	print("Distributor", node, S(pos), out_dir, S(peer_pos), peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	mem.connections = mem.connections or {}
	mem.connections[out_dir] = peer_pos
	local sum = sink_power_consumption(pos, -TP(pos).power_consume) 
end

function techage.distributor_on_destruct(pos)
	sink_power_consumption(pos, -TP(pos).power_consume)
end

function techage.distributor_after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end

--
-- Consumer with one power input side (default)
--
function techage.consumer_power_consumption(pos, dir)
	print("consumer_power_consumption")
	return -TP(pos).power_consume
end
	
function techage.consumer_after_place_node(pos, placer)
	print("consumer_after_place_node")
	local mem = tubelib2.init_mem(pos)
	local this = TP(pos)
	mem.power_dir = tubelib2.Turn180Deg[side_to_dir(pos, this.power_side or 'L')]
	this.power_network:after_place_node(pos)
	--sink_power_consumption(pos, -this.power_consume)
end
		
function techage.consumer_after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	local mem = tubelib2.get_mem(pos)
	mem.connections = {[out_dir] = peer_pos}
	print("consumer_after_tube_update", out_dir, S(peer_pos))
	local sum = sink_power_consumption(pos, -TP(pos).power_consume) 
	-- Needed to be able to turn off the consumer itself
	TP(pos).turn_on(pos, nil, sum > 0)
end

function techage.consumer_on_destruct(pos)
	sink_power_consumption(pos, -TP(pos).power_consume)
end

function techage.consumer_after_dig_node(pos, oldnode)
	TN(oldnode).power_network:after_dig_node(pos)
	tubelib2.del_mem(pos)
end
