--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Power distribution and consumption calculation
	for any kind of power distribution network

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local PWR = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).power end

-- Used to determine the already passed nodes while power distribution
local Route = {}

techage.power = {}

-- Consumer States
local STOPPED = 1
local NOPOWER = 2
local RUNNING = 3


local function pos_already_reached(pos)
	local key = minetest.hash_node_position(pos)
	if not Route[key] then
		Route[key] = true
		return false
	end
	return true
end

local function min(val, max)
	if val < 0 then return 0 end
	if val > max then return max end
	return val
end

local function accounting(pos, mem)
	-- calculate the primary and secondary supply and demand
	mem.mst_supply1 = min(mem.mst_needed1 + mem.mst_needed2, mem.mst_available1)
	mem.mst_demand1 = min(mem.mst_needed1, mem.mst_available1 + mem.mst_available2)
	mem.mst_supply2 = min(mem.mst_demand1 - mem.mst_supply1, mem.mst_available2)
	mem.mst_demand2 = min(mem.mst_supply1 - mem.mst_demand1, mem.mst_available1)
	mem.mst_reserve = (mem.mst_available1 + mem.mst_available2) - mem.mst_needed1
	--print("needed = "..mem.mst_needed1.."/"..mem.mst_needed2..", available = "..mem.mst_available1.."/"..mem.mst_available2)
	--print("supply = "..mem.mst_supply1.."/"..mem.mst_supply2..", demand = "..mem.mst_demand1.."/"..mem.mst_demand2..", reserve = "..mem.mst_reserve)
end

local function connection_walk(pos, clbk)
	local mem = tubelib2.get_mem(pos)
	mem.interrupted_dirs = mem.interrupted_dirs or {}
	if clbk then
		clbk(pos, mem)
	end
	for out_dir,item in pairs(mem.connections or {}) do
		if item.pos and not pos_already_reached(item.pos) and
				not mem.interrupted_dirs[out_dir] then
			connection_walk(item.pos, clbk)
		end
	end
end

local function consumer_turn_off(pos, mem)
	local pwr = PWR(pos)
	print("consumer_turn_off")
	if pwr and pwr.on_nopower then
		pwr.on_nopower(pos, mem)
	end
	mem.pwr_node_alive_cnt = 0
	mem.pwr_state = NOPOWER
end	

local function consumer_turn_on(pos, mem)
	local pwr = PWR(pos)
	print("consumer_turn_on")
	if pwr and pwr.on_power then
		pwr.on_power(pos, mem)
	end
	mem.pwr_state = RUNNING
end	

-- determine one "generating" node as master (largest hash number)
local function determine_master(pos)
	Route = {}
	pos_already_reached(pos) 
	local hash = 0
	local master = nil
	connection_walk(pos, function(pos, mem)
		if (mem.pwr_node_alive_cnt or 0) >= 0 and 
				(mem.pwr_available or 0) > 0 or 
				(mem.pwr_available2 or 0) > 0 then  -- active generator?
					
			local new = minetest.hash_node_position(pos)
			if hash <= new then
				hash = new
				master = pos
			end
		end
	end)
	return master
end

-- store master position on all network nodes
local function store_master(pos, master_pos)
	Route = {}
	pos_already_reached(pos) 
	connection_walk(pos, function(pos, mem)
			mem.pwr_master_pos = master_pos
			mem.pwr_is_master = false
		end)
end

local function handle_generator(mst_mem, mem, pos, power_available)
	-- for next cycle
	mst_mem.mst_available1 = mst_mem.mst_available1 + power_available
	-- current cycle
	mst_mem.mst_supply1 = mst_mem.mst_supply1 or 0
	if mst_mem.mst_supply1 < power_available then
		mem.pwr_provided = mst_mem.mst_supply1
		mst_mem.mst_supply1 = 0
	else
		mst_mem.mst_supply1 = mst_mem.mst_supply1 - power_available
		mem.pwr_provided = power_available
	end
end

local function handle_consumer(mst_mem, mem, pos, power_needed)
	print("handle_consumer", mem.pwr_state)
	if mem.pwr_state == NOPOWER then
		--print("power_needed", power_needed,"mst_mem.demand1", mst_mem.mst_demand1)
		-- for next cycle
		mst_mem.mst_needed1 = mst_mem.mst_needed1 + power_needed
		-- current cycle
		if (mst_mem.mst_demand1 or 0) - power_needed >= 0 then
			mst_mem.mst_demand1 = (mst_mem.mst_demand1 or 0) - power_needed
			consumer_turn_on(pos, mem)
		end
	elseif mem.pwr_state == RUNNING then
		-- for next cycle
		mst_mem.mst_needed1 = mst_mem.mst_needed1 + power_needed
		-- current cycle
		mst_mem.mst_demand1 = (mst_mem.mst_demand1 or 0) - power_needed
		if mst_mem.mst_demand1 < 0 then
			mst_mem.mst_demand1 = 0
			consumer_turn_off(pos, mem)
		end
	end
end

local function handle_secondary(mst_mem, mem, pos, provides, needed)
	-- for next cycle
	mst_mem.mst_available2 = (mst_mem.mst_available2 or 0) + provides
	mst_mem.mst_needed2 = (mst_mem.mst_needed2 or 0) + needed
	-- check as generator
	mst_mem.mst_supply2 = mst_mem.mst_supply2 or 0
	mst_mem.mst_demand2 = mst_mem.mst_demand2 or 0
	if mst_mem.mst_supply2 > 0 then
		local val = math.min(provides, mst_mem.mst_supply2)
		mst_mem.mst_supply2 = mst_mem.mst_supply2 - val
		mem.pwr_provided = val
	-- check as consumer
	elseif mst_mem.mst_demand2 > 0 then
		local val = math.min(needed, mst_mem.mst_demand2)
		mst_mem.mst_demand2 = mst_mem.mst_demand2 - val
		mem.pwr_provided = -val
	else
		mem.pwr_provided = 0
	end
	
end

local function trigger_nodes(mst_pos, mst_mem)
	Route = {}
	pos_already_reached(mst_pos) 
	connection_walk(mst_pos, function(pos, mem)
		mem.pwr_node_alive_cnt = (mem.pwr_node_alive_cnt or 1) - 1
		mem.pwr_power_provided_cnt = 2
		--print("trigger_nodes", mem.pwr_node_alive_cnt, mem.pwr_available2 or mem.pwr_available or mem.pwr_needed)
		if mem.pwr_node_alive_cnt >= 0 then
			if mem.pwr_available then
				handle_generator(mst_mem, mem, pos, mem.pwr_available)
			elseif mem.pwr_needed then
				handle_consumer(mst_mem, mem, pos, mem.pwr_needed)
			elseif mem.pwr_available2 then
				handle_secondary(mst_mem, mem, pos, mem.pwr_available2, mem.pwr_needed2)
			end
		end
	end)
end

local function determine_new_master(pos, mem)
	local was_master = mem.pwr_is_master
	mem.pwr_is_master = false
	local mpos = determine_master(pos)
	--print("determine_new_master", S(mpos))
	store_master(pos, mpos)
	if mpos then
		tubelib2.get_mem(mpos).pwr_is_master = true
	elseif was_master then -- no master any more
		-- delete data
		local mmem = tubelib2.get_mem(mpos)
		mmem.mst_supply1 = 0
		mmem.mst_supply2 = 0
		mmem.mst_reserve = 0
	end
	return was_master or mem.pwr_is_master
end

-- called from master position
local function power_distribution(pos, mem)
	mem.mst_needed1 = 0
	mem.mst_needed2 = 0
	mem.mst_available1 = 0
	mem.mst_available2 = 0
	trigger_nodes(pos, mem)
	accounting(pos, mem)
end

--
-- Power API functions
--

-- To be called for each network change from any node
function techage.power.network_changed(pos, mem)
	print("network_changed")
	mem.pwr_node_alive_cnt = (mem.pwr_cycle_time or 2)/2 + 1
	if determine_new_master(pos, mem) then -- new master?
		power_distribution(pos, mem)
	elseif not next(mem.connections) then -- isolated?
		if mem.pwr_needed then -- consumer?
			consumer_turn_off(pos, mem)
		end
	end
end

--
-- Generator related functions
--
function techage.power.generator_start(pos, mem, available)
	mem.pwr_node_alive_cnt = 2
	mem.pwr_cycle_time = 2
	mem.pwr_available = available
	if determine_new_master(pos, mem) then -- new master
		power_distribution(pos, mem)
	end
end

function techage.power.generator_stop(pos, mem)
	mem.pwr_node_alive_cnt = 0
	mem.pwr_available = 0
	if determine_new_master(pos, mem) then -- last available master
		power_distribution(pos, mem)
	end
end

function techage.power.generator_alive(pos, mem)
	mem.pwr_node_alive_cnt = 2
	if mem.pwr_is_master then
		power_distribution(pos, mem)
	end
	return mem.pwr_provided
end

--
-- Consumer related functions
--
function techage.power.consumer_alive(pos, mem)
	print("consumer_alive", mem.pwr_power_provided_cnt)
	mem.pwr_power_provided_cnt = (mem.pwr_power_provided_cnt or 0) - (mem.pwr_cycle_time or 2)/2
	if mem.pwr_power_provided_cnt >= 0 then
		mem.pwr_node_alive_cnt = (mem.pwr_cycle_time or 2)/2 + 1
	else
		consumer_turn_off(pos, mem)
	end
end

function techage.power.consumer_start(pos, mem, cycle_time, needed)
	mem.pwr_cycle_time = cycle_time
	mem.pwr_power_provided_cnt = 0
	mem.pwr_node_alive_cnt = 2
	mem.pwr_needed = needed
	mem.pwr_state = NOPOWER
end

function techage.power.consumer_stop(pos, mem)
	mem.pwr_power_provided_cnt = 0
	mem.pwr_node_alive_cnt = 0
	mem.pwr_needed = 0
	mem.pwr_state = STOPPED
end

-- Lamp related function to speed up the turn on
function techage.power.power_available(pos, mem, needed)
	if mem.pwr_master_pos and (mem.pwr_power_provided_cnt or 0) > 0 then
		mem = tubelib2.get_mem(mem.pwr_master_pos)
		if (mem.mst_reserve or 0) - needed >= 0 then
			mem.mst_reserve = mem.mst_reserve - needed
			return true
		end
	end
	return false
end		

-- Power terminal function
function techage.power.power_accounting(pos, mem)
	if mem.pwr_master_pos then
		mem = tubelib2.get_mem(mem.pwr_master_pos)
		return {
			prim_available = mem.mst_available1,
			sec_available = mem.mst_available2,
			prim_needed = mem.mst_needed1,
			sec_needed = mem.mst_needed2,
		}
	end
	return {
		prim_available = 0,
		sec_available = 0,
		prim_needed = 0,
		sec_needed = 0,
	}
end		

--
-- Akku related functions
--
function techage.power.secondary_start(pos, mem, available, needed)
	mem.pwr_node_alive_cnt = 2
	mem.pwr_could_provide = available
	mem.pwr_could_need = needed
	if determine_new_master(pos, mem) then -- new master
		power_distribution(pos, mem)
	end
end

function techage.power.secondary_stop(pos, mem)
	mem.pwr_node_alive_cnt = 0
	mem.pwr_could_provide = 0
	mem.pwr_could_need = 0
	if determine_new_master(pos, mem) then -- last available master
		power_distribution(pos, mem)
	end
end

function techage.power.secondary_alive(pos, mem, capa_curr, capa_max)
	--print("secondary_alive")
	if capa_curr >= capa_max then
		mem.pwr_available2, mem.pwr_needed2 = mem.pwr_could_provide, 0 -- can provide only
	elseif capa_curr <= 0 then
		mem.pwr_available2, mem.pwr_needed2 = 0, mem.pwr_could_need  -- can deliver only
	else
		mem.pwr_available2, mem.pwr_needed2 = mem.pwr_could_provide, mem.pwr_could_need
	end
		
	mem.pwr_node_alive_cnt = 2
	if mem.pwr_is_master then
		--print("secondary_alive is master")
		power_distribution(pos, mem)
	end
	return mem.pwr_provided
end