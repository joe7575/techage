--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Global power Job Scheduler

]]--

-- for lazy programmers
local P2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local HEX = function(val) return string.format("%XH", val) end

local power = techage.power
local networks = techage.networks

local CYCLE_TIME = 1

techage.schedule = {}

local JobTable = {}
local JobQueue = {}
local first = 0
local last = -1

techage.SystemTime = 0

local function push(item)
	last = last + 1
	item.time = techage.SystemTime + CYCLE_TIME
	JobQueue[last] = item
end

local function pop()
	if first > last then return end
	local item = JobQueue[first]
	if item.time <= techage.SystemTime then
		JobQueue[first] = nil -- to allow garbage collection
		first = first + 1
		return item
	end
end

-- Scheduler
minetest.register_globalstep(function(dtime)
	techage.SystemTime = techage.SystemTime + dtime
	local item = pop()
	local t = minetest.get_us_time()
	while item do
		local network = networks.peek_network(item.tube_type, item.netID)
		if network and network.alive and network.alive >= 0 then
			power.power_distribution(network, item.tube_type, item.netID, CYCLE_TIME)
			network.alive = network.alive - 1
			push(item)
		else
			JobTable[item.netID] = nil
			networks.delete_network(item.tube_type, item.netID)
		end
		item = pop()
	end
	t = minetest.get_us_time() - t
	if t > 10000 then
		minetest.log("action", "[TA Schedule] duration="..t.."us")
	end
end)

function techage.schedule.start(tube_type, netID)
	if not JobTable[netID] then
		local network = networks.peek_network(tube_type, netID)
		power.power_distribution(network, tube_type, netID, CYCLE_TIME/2)
		network.alive = network.alive - 1
		push({tube_type = tube_type, netID = netID})
		JobTable[netID] = true
	end
end
