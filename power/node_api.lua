--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	API for Power Nodes

]]--

--local P2S = minetest.pos_to_string
--local M = minetest.get_meta
--local N = function(pos) return minetest.get_node(pos).name end
--local S = techage.S

local net_def = techage.networks.net_def
local networks = techage.networks

-- Consumer States
local STOPPED = 1
local NOPOWER = 2
local RUNNING = 3

techage.power = {}

techage.power.STOPPED = STOPPED
techage.power.NOPOWER = NOPOWER
techage.power.RUNNING = RUNNING

-- determine network ID (largest hash number of all generators)
local function determine_netID(pos, outdir, Cable)
	local netID = 0
	networks.connection_walk(pos, outdir, Cable, function(pos, indir, node)
		local ntype = net_def(pos, Cable.tube_type).ntype
		if ntype ~= "junc" then
			local new = minetest.hash_node_position(pos)
			if netID <= new then
				netID = new
			end
		end
	end)
	return netID
end

-- store network ID on each node
local function store_netID(pos, outdir, netID, Cable)
	networks.connection_walk(pos, outdir, Cable, function(pos, indir, node)
		--techage.mark_position("singleplayer", pos, "store", "", 2)-----------------------------------------
		--print(node.name, dump(net_def(pos, Cable.tube_type)))
		if net_def(pos, Cable.tube_type) then
			local nvm = techage.get_nvm(pos)
			nvm[Cable.tube_type] = nvm[Cable.tube_type] or {}
			nvm[Cable.tube_type]["netID"] = netID
		end
	end)
end

-- delete network and ID on each node
local function delete_netID(pos, outdir, Cable)
	local netID = 0
	networks.connection_walk(pos, outdir, Cable, function(pos, indir, node)
		--techage.mark_position("singleplayer", pos, "delete", "", 2)----------------------------------------
		if net_def(pos, Cable.tube_type) then
			local nvm = techage.get_nvm(pos)
			if nvm[Cable.tube_type] and nvm[Cable.tube_type]["netID"] then
				netID = nvm[Cable.tube_type]["netID"]
				nvm[Cable.tube_type]["netID"] = nil
			end
		end
	end)
	networks.delete_network(Cable.tube_type, netID)
end

-- Keep the network up and running
local function trigger_network(pos, outdir, Cable)
	local nvm = techage.get_nvm(pos)
	local netID = nvm[Cable.tube_type] and nvm[Cable.tube_type]["netID"]
	if not netID then
		--print("determine_netID !!!!!!!!!!!!!!!!!!!!")
		netID = determine_netID(pos, outdir, Cable)
		store_netID(pos, outdir, netID, Cable)
		networks.build_network(pos, outdir, Cable, netID)
	elseif not networks.get_network(Cable.tube_type, netID) then
		--print("build_network !!!!!!!!!!!!!!!!!!!!")
		netID = determine_netID(pos, outdir, Cable)
		store_netID(pos, outdir, netID, Cable)
		networks.build_network(pos, outdir, Cable, netID)
	end
end

local function build_network_consumer(pos, Cable)
	local outdirs = techage.networks.get_node_connections(pos, Cable.tube_type)
	if #outdirs == 1 then
		local netID = determine_netID(pos, outdirs[1], Cable)
		store_netID(pos, outdirs[1], netID, Cable)
		networks.build_network(pos, outdirs[1], Cable, netID)
	end
end

-- To be called from each node via 'tubelib2_on_update2'
-- 'output' is optional and only needed for nodes with dedicated
-- pipe sides (e.g. pumps).
function techage.power.update_network(pos, outdir, Cable)
	networks.node_connections(pos, Cable) -- update node internal data
	delete_netID(pos, outdir, Cable) -- network walk to delete all IDs
end

--
-- Read the current power value from all connected devices (used for solar cells)
-- Only used by the solar inverter to collect the power of all solar cells.
-- Only one inverter per network is allowed. Therefore, we have to check,
-- if additional inverters are in the network.
-- Function returns in addition the number of found inverters.
function techage.power.get_power(pos, outdir, Cable, inverter)
	local sum = 0
	local num_inverter = 0
	networks.connection_walk(pos, outdir, Cable, function(pos, indir, node)
		--techage.mark_position("singleplayer", pos, "get_power", "", 2)-----------------------------------------
		local def = net_def(pos, Cable.tube_type)
		if def and def.on_getpower then
			sum = sum + def.on_getpower(pos)
		else
			local node = techage.get_node_lvm(pos)
			if node.name == inverter then
				num_inverter = num_inverter + 1
			end
		end
	end)
	return sum, num_inverter
end	



--
-- Consumer related functions
--

-- check if there is a living network
function techage.power.power_available(pos, Cable)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	local netID = nvm[Cable.tube_type] and nvm[Cable.tube_type]["netID"]
	return networks.has_network(tlib_type, netID)
end

-- this is more a try to start, the start will be performed by on_power()
function techage.power.consumer_start(pos, Cable, cycle_time)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type] = nvm[tlib_type] or {}
	nvm[tlib_type]["calive"] = (cycle_time / 2) + 1
	nvm[tlib_type]["cstate"] = NOPOWER
	nvm[tlib_type]["taken"] = 0
end

function techage.power.consumer_stop(pos, Cable)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type] = nvm[tlib_type] or {}
	nvm[tlib_type]["calive"] = -1
	nvm[tlib_type]["cstate"] = STOPPED
	nvm[tlib_type]["taken"] = 0
end

function techage.power.consumer_alive(pos, Cable, cycle_time)
	local nvm = techage.get_nvm(pos)
	local def = nvm[Cable.tube_type] -- power related network data
	if def then
		-- if network is deleted (cable removed/placed) rebuild it to prevent flickering lights
		if not def["netID"] or not networks.get_network(Cable.tube_type, def["netID"]) then
			build_network_consumer(pos, Cable)
		end
		local rv = (cycle_time / 2) + 1
		if def["netID"] and def["calive"] and def["calive"] < rv then -- network available
			def["calive"] = rv
			return def["taken"] or 0
		elseif not def["cstate"] or def["cstate"] == RUNNING then
			local ndef = net_def(pos, Cable.tube_type)
			ndef.on_nopower(pos, Cable.tube_type)
			def["cstate"] = NOPOWER
		end
	else
		local ndef = net_def(pos, Cable.tube_type)
		ndef.on_nopower(pos, Cable.tube_type)
	end
	return 0
end

--
-- Generator related functions
--
-- curr_power is optional, only needed for generators with variable output power
function techage.power.generator_start(pos, Cable, cycle_time, outdir, curr_power)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type] = nvm[tlib_type] or {}
	nvm[tlib_type]["galive"] = (cycle_time / 2) + 2
	nvm[tlib_type]["gstate"] = RUNNING
	nvm[tlib_type]["given"] = 0
	nvm[tlib_type]["curr_power"] = curr_power
	trigger_network(pos, outdir, Cable)
end

function techage.power.generator_stop(pos, Cable, outdir)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type] = nvm[tlib_type] or {}
	nvm[tlib_type]["galive"] = -1
	nvm[tlib_type]["gstate"] = STOPPED
	nvm[tlib_type]["given"] = 0
end

-- curr_power is optional, only needed for generators with variable output power
function techage.power.generator_alive(pos, Cable, cycle_time, outdir, curr_power)
	local nvm = techage.get_nvm(pos)
	local def = nvm[Cable.tube_type] -- power related network data
	if def then
		trigger_network(pos, outdir, Cable)
		def["galive"] = (cycle_time / 2) + 2
		def["curr_power"] = curr_power
		return def["given"] or 0
	end
	return 0
end

-- function delete_netID(pos, outdir, Cable)
techage.power.delete_netID = delete_netID
