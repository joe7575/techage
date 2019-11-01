--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Global power Job Scheduler

]]--

-- for lazy programmers
local P2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end

local CYCLE_TIME = 2.0

techage.schedule = {}

local NetList = {}
local JobQueue = {}
local first = 0
local last = -1
local LocalTime = 0

local function push(item)
	last = last + 1
	item.time = LocalTime + CYCLE_TIME
	JobQueue[last] = item
end

local function pop()
	if first > last then return end
	local item = JobQueue[first]
	if item.time <= LocalTime then
		JobQueue[first] = nil -- to allow garbage collection
		first = first + 1
		return item
	end
end

-- Scheduler
minetest.register_globalstep(function(dtime)
	LocalTime = LocalTime + dtime
	local item = pop()
	while item do
		local network = NetList[item.netkey]
		if network and network.alive and network.alive >= 0 then
			--techage.distribute.power_distribution(LocalTime, network)
			techage.power.power_distribution(LocalTime, network.mst_pos, network)
			network.alive = network.alive - 1
			push(item)
		else
			NetList[item.netkey] = nil
		end
		item = pop()
	end
end)

function techage.schedule.add_network(netkey, network)
	if netkey then
		if NetList[netkey] then -- already scheduled
			NetList[netkey] = network
		else
			NetList[netkey] = network
			push({netkey = netkey})
		end
		return NetList[netkey]
	end
end

function techage.schedule.has_network(netkey)
	if netkey then
		return NetList[netkey] ~= nil
	end
end

function techage.schedule.get_network(netkey)
	if netkey then
		return NetList[netkey]
	end
end
