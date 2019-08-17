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

-------------------------------------------------- Migrate
local CRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).consumer end
local Consumer = {
	["techage:streetlamp_off"] = 0,
	["techage:streetlamp_on"] = 0.5,
	["techage:industriallamp1_off"] = 0,
	["techage:industriallamp1_on"] = 0.5,
	["techage:industriallamp2_off"] = 0,
	["techage:industriallamp2_on"] = 0.5,
	["techage:industriallamp3_off"] = 0,
	["techage:industriallamp3_on"] = 0.5,
	["techage:simplelamp_off"] = 0,
	["techage:simplelamp_on"] = 0.5,
	["techage:ceilinglamp_off"] = 0,
	["techage:ceilinglamp_on"] = 0.5,
	["techage:ta2_autocrafter_pas"] = 0,
	["techage:ta2_autocrafter_act"] = 4,
	["techage:ta3_autocrafter_pas"] = 0,
	["techage:ta3_autocrafter_act"] = 6,
	["techage:ta2_electronic_fab_pas"] = 0,
	["techage:ta2_electronic_fab_act"] = 8,
	["techage:ta3_electronic_fab_pas"] = 0,
	["techage:ta3_electronic_fab_act"] = 12,
	["techage:ta2_gravelsieve_pas"] = 0,
	["techage:ta2_gravelsieve_act"] = 3,
	["techage:ta3_gravelsieve_pas"] = 0,
	["techage:ta3_gravelsieve_act"] = 4,
	["techage:ta2_grinder_pas"] = 0,
	["techage:ta2_grinder_act"] = 4,
	["techage:ta3_grinder_pas"] = 0,
	["techage:ta3_grinder_act"] = 6,
	["techage:ta2_rinser_pas"] = 0,
	["techage:ta2_rinser_act"] = 3,
	["techage:ta3_booster"] = 0,
	["techage:ta3_booster_on"] = 3,
	["techage:ta3_drillbox_pas"] = 0,
	["techage:ta3_drillbox_act"] = 16,
	["techage:ta3_pumpjack_pas"] = 0,
	["techage:ta3_pumpjack_act"] = 16,
	["techage:gearbox"] = 0,
	["techage:gearbox_on"] = 1,
}
local Generator = {
	["techage:t2_source"] = 20,
	["techage:t3_source"] = 20,
	["techage:t4_source"] = 20,
	["techage:flywheel"] = 0,
	["techage:flywheel_on"] = 25,
	["techage:generator"] = 0,
	["techage:generator_on"] = 80,
	["techage:tiny_generator"] = 0,
	["techage:tiny_generator_on"] = 12,
}
local Akku = {
	["techage:ta3_akku"] = 10
}

local function migrate(pos, mem)
	if mem.master_pos or mem.is_master ~= nil then
		if mem.master_pos then
			mem.pwr_master_pos = table.copy(mem.master_pos)
			mem.master_pos = nil
		end
		mem.pwr_is_master = mem.is_master; mem.is_master = nil
		mem.available1 = nil
		mem.available2 = nil
		mem.supply1 = nil
		mem.supply2 = nil
		mem.needed1 = nil
		mem.needed2 = nil
		mem.demand1 = nil
		mem.demand2 = nil
		mem.reserve = nil
		mem.could_be_master = nil
		mem.node_loaded = nil
		
		mem.pwr_power_provided_cnt = 2
		mem.pwr_node_alive_cnt = 4
		
		local name = minetest.get_node(pos).name
		mem.pwr_needed = Consumer[name]
		mem.pwr_available = Generator[name]
		mem.pwr_could_provide = Akku[name]
		mem.pwr_could_need = Akku[name]
		
		if Consumer[name] then
			if mem.techage_state then
				if mem.techage_state == techage.STOPPED then
					mem.pwr_state = STOPPED
				elseif mem.techage_state == techage.NOPOWER or mem.techage_state == techage.RUNNING then
					local crd = CRD(pos)
					techage.power.consumer_start(pos, mem, crd.cycle_time, crd.power_consumption)
				end
			elseif mem.turned_on then
				mem.pwr_state = RUNNING
			elseif mem.pwr_needed then
				mem.pwr_state = RUNNING
			else
				mem.pwr_state = STOPPED
			end
			if techage.in_list({"techage:ta2_electronic_fab_pas", "techage:ta2_electronic_fab_act", "techage:ta3_electronic_fab_pas", "techage:ta3_electronic_fab_act"}, name) then
				mem.pwr_cycle_time = 6
			elseif techage.in_list({"techage:ta3_drillbox_pas", "techage:ta3_drillbox_act"}, name) then
				mem.pwr_cycle_time = 16
			elseif techage.in_list({"techage:ta3_pumpjack_pas", "techage:ta3_pumpjack_act"}, name) then
				mem.pwr_cycle_time = 8
			else
				mem.pwr_cycle_time = 4
			end
		elseif Generator[name] then
			if mem.generating then
				techage.power.generator_start(pos, mem, Generator[name])
			else
				techage.power.generator_stop(pos, mem)
			end
		end
		
		if not mem.pwr_needed and not mem.pwr_available and not mem.pwr_available2 then
			mydbg("dbg", name)
		end
	end
end

local Nodenames={}
local n=0

for k,v in pairs(Consumer) do
  n=n+1
  Nodenames[n]=k
end
for k,v in pairs(Generator) do
  n=n+1
  Nodenames[n]=k
end
for k,v in pairs(Akku) do
  n=n+1
  Nodenames[n]=k
end


minetest.register_lbm({
	label = "[techage] Power Conversion",
	name = "techage:power",
	nodenames = Nodenames,
	run_at_every_load = true,
	action = function(pos, node)
		local mem = tubelib2.get_mem(pos)
		print("migrate", S(pos), node.name)
		migrate(pos, mem)
	end
})

-------------------------------------------------- Migrate

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
	if mem.pwr_is_master then
		-- calculate the primary and secondary supply and demand
		mem.mst_supply1 = min(mem.mst_needed1 + mem.mst_needed2, mem.mst_available1)
		mem.mst_demand1 = min(mem.mst_needed1, mem.mst_available1 + mem.mst_available2)
		mem.mst_supply2 = min(mem.mst_demand1 - mem.mst_supply1, mem.mst_available2)
		mem.mst_demand2 = min(mem.mst_supply1 - mem.mst_demand1, mem.mst_available1)
		mem.mst_reserve = (mem.mst_available1 + mem.mst_available2) - mem.mst_needed1
		mydbg("sts", "needed = "..mem.mst_needed1.."/"..mem.mst_needed2..", available = "..mem.mst_available1.."/"..mem.mst_available2)
		mydbg("sts", "supply = "..mem.mst_supply1.."/"..mem.mst_supply2..", demand = "..mem.mst_demand1.."/"..mem.mst_demand2..", reserve = "..mem.mst_reserve)
	end
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

-- if no power available
local function consumer_turn_off(pos, mem)
	local pwr = PWR(pos)
	mydbg("pwr", "consumer_turn_off")
	if pwr and pwr.on_nopower then
		pwr.on_nopower(pos, mem)
	end
	mem.pwr_state = NOPOWER
	mem.pwr_power_provided_cnt = -1
end	

local function consumer_turn_on(pos, mem)
	local pwr = PWR(pos)
	mydbg("pwr", "consumer_turn_on")
	if pwr and pwr.on_power then
		pwr.on_power(pos, mem)
	end
	mem.pwr_state = RUNNING
	-- to avoid consumer starvation
	mem.pwr_node_alive_cnt = (mem.pwr_cycle_time or 2)/2 + 1
end	

-- determine one "generating" node as master (largest hash number)
local function determine_master(pos)
	Route = {}
	pos_already_reached(pos) 
	local hash = 0
	local master = nil
	connection_walk(pos, function(pos, mem)
		if (mem.pwr_node_alive_cnt or 0) >= 0 and 
				((mem.pwr_available or 0) > 0 or 
				(mem.pwr_available2 or 0) > 0) then  -- active generator?
					
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
	mst_mem.mst_available1 = (mst_mem.mst_available1 or 0) + power_available
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
	mydbg("pwr", "handle_consumer", mem.pwr_state)
	if mem.pwr_state == NOPOWER then
		mydbg("pwr", "power_needed", power_needed,"mst_mem.demand1", mst_mem.mst_demand1)
		-- for next cycle
		mst_mem.mst_needed1 = (mst_mem.mst_needed1 or 0) + power_needed
		-- current cycle
		if (mst_mem.mst_demand1 or 0) >= power_needed then
			mst_mem.mst_demand1 = (mst_mem.mst_demand1 or 0) - power_needed
			consumer_turn_on(pos, mem)
		end
	elseif mem.pwr_state == RUNNING then
		mydbg("pwr", "power_needed", power_needed,"mst_mem.demand1", mst_mem.mst_demand1)
		-- for next cycle
		mst_mem.mst_needed1 = mst_mem.mst_needed1 + power_needed
		-- current cycle
		if (mst_mem.mst_demand1 or 0) >= power_needed then
			mst_mem.mst_demand1 = (mst_mem.mst_demand1 or 0) - power_needed
		-- small consumer like lamps are allowed to "use" the reserve
		elseif power_needed <= 2 and (mst_mem.mst_reserve or 0) >= power_needed then
			mst_mem.mst_reserve = (mst_mem.mst_reserve or 0) - power_needed
		else -- no power available
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

local function trigger_nodes(mst_pos, mst_mem, dec)
	Route = {}
	pos_already_reached(mst_pos) 
	connection_walk(mst_pos, function(pos, mem)
		mem.pwr_node_alive_cnt = (mem.pwr_node_alive_cnt or 1) - dec
		mem.pwr_power_provided_cnt = 2
		mydbg("pwr", "trigger_nodes", minetest.get_node(pos).name, mem.pwr_node_alive_cnt, mem.pwr_available2 or mem.pwr_available or mem.pwr_needed)
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

local function turn_off_nodes(mst_pos)
	Route = {}
	pos_already_reached(mst_pos) 
	connection_walk(mst_pos, function(pos, mem)
		mydbg("pwr", "turn_off_nodes", minetest.get_node(pos).name)
		if (mem.pwr_node_alive_cnt or -1) >= 0 then
			if mem.pwr_needed then
				consumer_turn_off(pos, mem)
			end
		end
	end)
end

local function determine_new_master(pos, mem)
	local was_master = mem.pwr_is_master
	mem.pwr_is_master = false
	local mpos = determine_master(pos)
	mydbg("pwr", "determine_new_master", S(mpos))
	store_master(pos, mpos)
	if mpos then
		tubelib2.get_mem(mpos).pwr_is_master = true
	elseif was_master then -- no master any more
		-- delete data
		mem.mst_supply1 = 0
		mem.mst_supply2 = 0
		mem.mst_reserve = 0
	end
	return was_master or mem.pwr_is_master
end

-- called from master position
local function power_distribution(pos, mem, dec)
	mydbg("pwr", "power_distribution")
	if mem.pwr_is_master then
		mem.mst_needed1 = 0
		mem.mst_needed2 = 0
		mem.mst_available1 = 0
		mem.mst_available2 = 0
	end
	trigger_nodes(pos, mem, dec or 0)
	accounting(pos, mem)
end

--
-- Power API functions
--

-- To be called for each network change from any node
function techage.power.network_changed(pos, mem)
	mydbg("pwr", "network_changed")
	mem.pwr_node_alive_cnt = (mem.pwr_cycle_time or 2)/2 + 1
	if determine_new_master(pos, mem) then -- new master?
		power_distribution(pos, mem)
	elseif not mem.pwr_master_pos then -- no master?
		turn_off_nodes(pos)
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
		power_distribution(pos, mem, 1)
	end
	return mem.pwr_provided
end

--
-- Consumer related functions
--
-- this is more a try to start, the start will be performed by consumer_turn_on()
function techage.power.consumer_start(pos, mem, cycle_time, needed)
	mem.pwr_cycle_time = cycle_time
	mem.pwr_power_provided_cnt = 0 -- must be zero!
	mem.pwr_node_alive_cnt = 2
	mem.pwr_needed = needed
	mem.pwr_state = NOPOWER
end

function techage.power.consumer_stop(pos, mem)
	mem.pwr_node_alive_cnt = 0
	mem.pwr_needed = 0
	mem.pwr_state = STOPPED
end

function techage.power.consumer_alive(pos, mem)
	mydbg("pwr", "consumer_alive", mem.pwr_power_provided_cnt, mem.pwr_cycle_time)
	mem.pwr_node_alive_cnt = (mem.pwr_cycle_time or 2)/2 + 1
	mem.pwr_power_provided_cnt = (mem.pwr_power_provided_cnt or 0) - (mem.pwr_cycle_time or 2)/2
	if mem.pwr_power_provided_cnt < 0 and mem.pwr_state == RUNNING then
		consumer_turn_off(pos, mem)
	end
end

-- Lamp related function to speed up the turn on
function techage.power.power_available(pos, mem, needed)
	if mem.pwr_master_pos and (mem.pwr_power_provided_cnt or 0) > 0 then
		mem = tubelib2.get_mem(mem.pwr_master_pos)
		if (mem.mst_reserve or 0) >= needed then
			mem.mst_reserve = (mem.mst_reserve or 0) - needed
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
	mydbg("pwr", "secondary_alive")
	if capa_curr >= capa_max then
		mem.pwr_available2, mem.pwr_needed2 = mem.pwr_could_provide, 0 -- can provide only
	elseif capa_curr <= 0 then
		mem.pwr_available2, mem.pwr_needed2 = 0, mem.pwr_could_need  -- can deliver only
	else
		mem.pwr_available2, mem.pwr_needed2 = mem.pwr_could_provide, mem.pwr_could_need
	end
		
	mem.pwr_node_alive_cnt = 2
	if mem.pwr_is_master then
		mydbg("pwr", "secondary_alive is master")
		power_distribution(pos, mem, 1)
	end
	return mem.pwr_provided or 0
end