--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Power distribution and consumption calculation
	for any kind of power distribution network

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local D = techage.Debug

-- Techage Related Data
local PWR = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).power end

-- Used to determine the already passed nodes while power distribution
local Route = {}
local NumNodes = 0

techage.power = {}

local MAX_NUM_NODES = 1000
techage.MAX_NUM_NODES = MAX_NUM_NODES

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

local function migrate(pos, mem, node)
	if mem.master_pos or mem.is_master ~= nil then
		print("migrate", S(pos), node.name)
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
			mem.pwr_cycle_time = 2
			if mem.generating then
				techage.power.generator_start(pos, mem, Generator[name])
			else
				techage.power.generator_stop(pos, mem)
			end
		elseif Akku[name] then
			mem.pwr_cycle_time = 2
			if mem.techage_state and mem.techage_state == techage.RUNNING then
				mem.running = true
				minetest.get_node_timer(pos):start(2)
				techage.power.secondary_start(pos, mem, mem.pwr_could_provide, mem.pwr_could_need)
			end
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
		migrate(pos, mem, node)
	end
})

-------------------------------------------------- Migrate

local function pos_already_reached(pos)
	local key = minetest.hash_node_position(pos)
	if not Route[key] and NumNodes < MAX_NUM_NODES then
		Route[key] = true
		NumNodes = NumNodes + 1
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
		if D.sts then D.dbg("needed = "..mem.mst_needed1.."/"..mem.mst_needed2..", available = "..mem.mst_available1.."/"..mem.mst_available2) end
		if D.sts then D.dbg("supply = "..mem.mst_supply1.."/"..mem.mst_supply2..", demand = "..mem.mst_demand1.."/"..mem.mst_demand2..", reserve = "..mem.mst_reserve) end
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

-- walk limited by number of nodes and hops
local function connection_walk2(pos, max_hops, max_nodes, clbk)
	local mem = tubelib2.get_mem(pos)
	mem.interrupted_dirs = mem.interrupted_dirs or {}
	if clbk then
		clbk(pos, mem, max_hops)
	end
	max_hops = max_hops - 1
	if max_hops < 0 then return end
	for out_dir,item in pairs(mem.connections or {}) do
		if item.pos and not pos_already_reached(item.pos) and
				not mem.interrupted_dirs[out_dir] then
			max_nodes = max_nodes - 1
			if max_nodes < 0 then return end
			connection_walk2(item.pos, max_hops, max_nodes, clbk)
		end
	end
end

-- if no power available
local function consumer_turn_off(pos, mem)
	local pwr = PWR(pos)
	if D.pwr then D.dbg("consumer_turn_off") end
	if pwr and pwr.on_nopower then
		pwr.on_nopower(pos, mem)
	end
	mem.pwr_state = NOPOWER
	mem.pwr_power_provided_cnt = -1
end	

local function consumer_turn_on(pos, mem)
	local pwr = PWR(pos)
	if D.pwr then D.dbg("consumer_turn_on") end
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
	NumNodes = 0
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
	NumNodes = 0
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
	if mem.pwr_state == NOPOWER then
		-- for next cycle
		mst_mem.mst_needed1 = (mst_mem.mst_needed1 or 0) + power_needed
		-- current cycle
		if (mst_mem.mst_demand1 or 0) >= power_needed then
			mst_mem.mst_demand1 = (mst_mem.mst_demand1 or 0) - power_needed
			if D.sts then D.dbg("consumer_turn_on: mst_demand = "..mst_mem.mst_demand1..", node = "..minetest.get_node(pos).name) end
			consumer_turn_on(pos, mem)
		end
	elseif mem.pwr_state == RUNNING then
		-- for next cycle
		mst_mem.mst_needed1 = (mst_mem.mst_needed1 or 0) + power_needed
		-- current cycle
		if (mst_mem.mst_demand1 or 0) >= power_needed then
			mst_mem.mst_demand1 = (mst_mem.mst_demand1 or 0) - power_needed
		-- small consumer like lamps are allowed to "use" the reserve
		elseif power_needed <= 2 and (mst_mem.mst_reserve or 0) >= power_needed then
			mst_mem.mst_reserve = (mst_mem.mst_reserve or 0) - power_needed
		else -- no power available
			mst_mem.mst_demand1 = 0
			if D.sts then D.dbg("consumer_turn_off: mst_demand = "..mst_mem.mst_demand1..", node = "..minetest.get_node(pos).name) end
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
	NumNodes = 0
	pos_already_reached(mst_pos) 
	connection_walk(mst_pos, function(pos, mem)
		mem.pwr_node_alive_cnt = (mem.pwr_node_alive_cnt or 1) - dec
		mem.pwr_power_provided_cnt = 2
		if D.pwr then D.dbg("trigger_nodes", minetest.get_node(pos).name, mem.pwr_node_alive_cnt, mem.pwr_available2 or mem.pwr_available or mem.pwr_needed) end
		if mem.pwr_node_alive_cnt >= 0 or mem.pwr_state == NOPOWER then
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
	NumNodes = 0
	pos_already_reached(mst_pos) 
	if D.pwr then D.dbg("turn_off_nodes") end
	connection_walk(mst_pos, function(pos, mem)
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
	store_master(pos, mpos)
	if mpos then
		local mmem = tubelib2.get_mem(mpos)
		mmem.pwr_is_master = true
		mmem.mst_num_nodes = NumNodes
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
	if D.pwr then D.dbg("power_distribution") end
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
	if D.pwr then D.dbg("network_changed") end
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
	return mem.pwr_provided or 0
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
	if D.pwr then D.dbg("consumer_alive", mem.pwr_power_provided_cnt, mem.pwr_cycle_time) end
	mem.pwr_node_alive_cnt = (mem.pwr_cycle_time or 2)/2 + 1
	mem.pwr_power_provided_cnt = (mem.pwr_power_provided_cnt or 0) - 1
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
	if mem.pwr_master_pos and (mem.pwr_power_provided_cnt or 0) > 0 then
		mem.pwr_power_provided_cnt = (mem.pwr_power_provided_cnt or 0) - 1
		mem = tubelib2.get_mem(mem.pwr_master_pos)
		return {
			prim_available = mem.mst_available1 or 0,
			sec_available = mem.mst_available2 or 0,
			prim_needed = mem.mst_needed1 or 0,
			sec_needed = mem.mst_needed2 or 0,
			num_nodes = mem.mst_num_nodes or 0,
		}
	end
	return {
		prim_available = 0,
		sec_available = 0,
		prim_needed = 0,
		sec_needed = 0,
		num_nodes = 0,
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
	if D.pwr then D.dbg("secondary_alive") end
	if capa_curr >= capa_max then
		mem.pwr_available2, mem.pwr_needed2 = mem.pwr_could_provide, 0 -- can provide only
	elseif capa_curr <= 0 then
		mem.pwr_available2, mem.pwr_needed2 = 0, mem.pwr_could_need  -- can deliver only
	else
		mem.pwr_available2, mem.pwr_needed2 = mem.pwr_could_provide, mem.pwr_could_need
	end
		
	mem.pwr_node_alive_cnt = 2
	if mem.pwr_is_master then
		if D.pwr then D.dbg("secondary_alive is master") end
		power_distribution(pos, mem, 1)
	end
	return mem.pwr_provided or 0
end

--
-- Read the current power value from all connected devices (used for solar cells)
--
function techage.power.get_power(start_pos)
	Route = {}
	NumNodes = 0
	pos_already_reached(start_pos) 
	local sum = 0
	connection_walk(start_pos, function(pos, mem)
		local pwr = PWR(pos)
		if pwr and pwr.on_getpower then
			sum = sum + pwr.on_getpower(pos, mem)
		end
	end)
	return sum
end	

function techage.power.power_network_available(start_pos)
	Route = {}
	NumNodes = 0
	pos_already_reached(start_pos) 
	local sum = 0
	connection_walk2(start_pos, 2, 3, function(pos, mem)
		sum = sum + 1
	end)
	return sum > 1
end	

function techage.power.mark_nodes(name, start_pos)
	Route = {}
	NumNodes = 0
	pos_already_reached(start_pos) 
	techage.unmark_position(name)
	connection_walk2(start_pos, 3, 100, function(pos, mem, max_hops)
		techage.mark_position(name, pos, S(pos).." : "..(4 - max_hops), "#60FF60")
	end)
end	
