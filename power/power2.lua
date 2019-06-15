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
local PWRN = function(node) return (minetest.registered_nodes[node.name] or {}).power end

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

local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}

local function side_to_dir(param2, side)
	local dir = SideToDir[side]
	if dir < 5 then
		dir = (((dir - 1) + (param2 % 4)) % 4) + 1
	end
	return dir
end

--function techage.get_pos(pos, side)
--	local node = minetest.get_node(pos)
--	local dir = nil
--	if node.name ~= "air" and node.name ~= "ignore" then
--		dir = side_to_dir(node.param2, side)
--	end
--	return tubelib2.get_pos(pos, dir)
--end	

local function set_conn_dirs(pos, sides)
	local tbl = {}
	local node = minetest.get_node(pos)
	if type(sides) == "function" then
		tbl = sides(pos, node)
	else
		for _,side in ipairs(sides) do
			tbl[#tbl+1] = tubelib2.Turn180Deg[side_to_dir(node.param2, side)]
		end
	end
	M(pos):set_string("power_dirs", minetest.serialize(tbl))
end
		
local function valid_indir(pos, in_dir)
	local s = M(pos):get_string("power_dirs")
	if s == "" then
		local pwr = PWR(pos)
		if pwr then
			set_conn_dirs(pos, pwr.conn_sides)
		end
	end
	if s ~= "" then
		for _,dir in ipairs(minetest.deserialize(s)) do
			if dir == in_dir then
				return true
			end
		end
	end
	return false
end

local function valid_outdir(pos, out_dir)
	return valid_indir(pos, tubelib2.Turn180Deg[out_dir])
end

-- Both nodes are from the same power network type?
local function matching_nodes(pos, peer_pos)
	local tube_type1 = pos and PWR(pos) and PWR(pos).power_network.tube_type
	local tube_type2 = peer_pos and PWR(peer_pos) and PWR(peer_pos).power_network.tube_type
	return not tube_type1 or not tube_type2 or tube_type1 == tube_type2
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


-- determine one "generating" node as master (largest hash number)
local function determine_master(pos)
	Route = {}
	pos_already_reached(pos) 
	local hash = 0
	local master = nil
	connection_walk(pos, function(pos, mem)
			if mem.generating then
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
			mem.master_pos = master_pos
			mem.is_master = false
		end)
end

-- called from master every 2 seconds
local function accounting(mem)
	mem.debit2 = mem.debit1 or 0
	mem.credit2 = mem.credit1 or 0
	mem.secondary = mem.secondary or 0
	
	mem.gap = mem.debit2 - mem.credit2
	mem.credit2 = mem.credit2 + mem.secondary
	--print("needed = "..(mem.debit2 or 0)..", available = "..(mem.credit2 or 0)..", gap = "..mem.gap..", secondary = "..mem.secondary)
	mem.debit1 = 0
	mem.credit1 = 0
	mem.secondary = 0
end

-- called from any generator
local function on_power_switch(pos)
	print("on_power_change"..S(pos))
	local mem = tubelib2.get_mem(pos)
	mem.master_pos = nil
	mem.is_master = nil
	
	local mpos = determine_master(pos)
	store_master(pos, mpos)
	if mpos then
		print("master = "..S(mpos))
		local mem = tubelib2.get_mem(mpos)
		mem.is_master = true
		return mem
	end
end

-- called from tubelib2.after_tube_update
local function on_network_change(pos)
	local mem = on_power_switch(pos)
	if mem then
		accounting(mem)
	end
end

--
-- Generic API functions
--
techage.power2 = {}

techage.power2.power_switched = on_power_switch
techage.power2.on_network_change = on_network_change

function techage.power2.register_node(names, pwr_def)
	for _,name in ipairs(names) do
		local ndef = minetest.registered_nodes[name]
		if ndef then
			minetest.override_item(name, {
				power = {
					conn_sides = pwr_def.conn_sides or {"L", "R", "U", "D", "F", "B"},
					power_network = pwr_def.power_network,
					after_place_node = ndef.after_place_node,
					after_dig_node = ndef.after_dig_node,
					after_tube_update = ndef.after_tube_update,
				},
				-- after_place_node decorator
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					local pwr = PWR(pos)
					set_conn_dirs(pos, pwr.conn_sides)
					pwr.power_network:after_place_node(pos)
					if pwr.after_place_node then
						return pwr.after_place_node(pos, placer, itemstack, pointed_thing)
					end
				end,
				-- after_dig_node decorator
				after_dig_node = function(pos, oldnode, oldmetadata, digger)
					local pwr = PWRN(oldnode)
					pwr.power_network:after_dig_node(pos)
					minetest.after(0.1, tubelib2.del_mem, pos)  -- At latest...
					if pwr.after_dig_node then
						return pwr.after_dig_node(pos, oldnode, oldmetadata, digger)
					end
				end,
				-- tubelib2 callback, called after any connection change
				after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
					local pwr = PWR(pos)
					local mem = tubelib2.get_mem(pos)
					mem.connections = mem.connections or {}
					if not peer_pos or not valid_indir(peer_pos, peer_in_dir)
							or not valid_outdir(pos, out_dir)
							or not matching_nodes(pos, peer_pos) then
						mem.connections[out_dir] = nil -- del connection
					else
						mem.connections[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}
					end
					-- To be called delayed, so that all network connections have been established
					minetest.after(0.2, on_network_change, pos)
					if pwr.after_tube_update then
						return pwr.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
					end
				end,
			})
			pwr_def.power_network:add_secondary_node_names({name})
		end
	end
end		

function techage.power2.consume_power(pos, needed)
	local master_pos = tubelib2.get_mem(pos).master_pos
	if master_pos then
		local mem = tubelib2.get_mem(master_pos)
		mem.debit1 = mem.debit1 or 0
		mem.credit2 = mem.credit2 or 0
		
		mem.debit1 = mem.debit1 + needed
		if mem.credit2 >= needed then
			mem.credit2 = mem.credit2 - needed
			return needed
		end
	end
	return 0
end

function techage.power2.provide_power(pos, available)
	local mem = tubelib2.get_mem(pos)
	if mem.is_master then
		accounting(mem)
	elseif mem.master_pos then
		mem = tubelib2.get_mem(mem.master_pos)
	else
		return 0
	end
		
	mem.credit1 = mem.credit1 or 0
	mem.debit2 = mem.debit2 or 0
	
	mem.credit1 = mem.credit1 + available
	if mem.debit2 > available then
		mem.debit2 = mem.debit2 - available
		return available
	else
		local rest = mem.debit2
		mem.debit2 = 0
		return rest
	end
end

function techage.power2.secondary_power(pos, provide, consume)
	local mem = tubelib2.get_mem(pos)
	if mem.is_master then
		accounting(mem)
	elseif mem.master_pos then
		mem = tubelib2.get_mem(mem.master_pos)
	else
		return 0
	end
		
	mem.gap = mem.gap or 0
	mem.secondary = (mem.secondary or 0) + provide
	if mem.gap > 0 then
		local val = math.min(mem.gap, provide)
		mem.gap = mem.gap - val
		return val
	elseif mem.gap < 0 then
		return math.max(mem.gap, -consume)
	end
	return 0
	
--	mem.debit2 = mem.debit2 or 0
	
--	mem.credit1 = mem.credit1 + available
--	if mem.debit2 > available then
--		mem.debit2 = mem.debit2 - available
--		return available
--	else
--		local rest = mem.debit2
--		mem.debit2 = 0
--		return rest
--	end
end

function techage.power2.formspec_load_bar(charging, max_val)
	local percent
	charging = charging or 0
	max_val = max_val or 1
	if charging ~= 0 then
		percent = 50 + math.ceil((charging * 50.0) / max_val)
	end

	if charging > 0 then
		return "techage_form_level_off.png^[lowpart:"..percent..":techage_form_level_charge.png"
	elseif charging < 0 then
		return "techage_form_level_unload.png^[lowpart:"..percent..":techage_form_level_off.png"
	else
		return "techage_form_level_off.png"
	end
end
