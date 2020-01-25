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
		techage.mark_position("singleplayer", pos, "store", "", 2)-----------------------------------------
		--print(node.name, dump(net_def(pos, Cable.tube_type)))
		if net_def(pos, Cable.tube_type) then
			local nvm = techage.get_nvm(pos)
			nvm[Cable.tube_type.."_netID"] = netID
		end
	end)
end

-- delete network and ID on each node
local function delete_netID(pos, outdir, Cable)
	local netID = 0
	networks.connection_walk(pos, outdir, Cable, function(pos, indir, node)
		techage.mark_position("singleplayer", pos, "delete", "", 2)----------------------------------------
		if net_def(pos, Cable.tube_type) then
			local nvm = techage.get_nvm(pos)
			if nvm[Cable.tube_type.."_netID"] then
				netID = nvm[Cable.tube_type.."_netID"]
				nvm[Cable.tube_type.."_netID"] = nil
			end
		end
	end)
	networks.delete_network(netID, Cable)
end

-- Keep the network up and running
local function trigger_network(pos, outdir, Cable)
	local nvm = techage.get_nvm(pos)
	local netID = nvm[Cable.tube_type.."_netID"]
	if not netID then
		print("determine_netID !!!!!!!!!!!!!!!!!!!!")
		netID = determine_netID(pos, outdir, Cable)
		store_netID(pos, outdir, netID, Cable)
		networks.build_network(pos, outdir, Cable, netID)
	elseif not networks.has_network(Cable.tube_type, netID) then
		print("build_network !!!!!!!!!!!!!!!!!!!!")
		networks.build_network(pos, outdir, Cable, netID)
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
-- Consumer related functions
--

-- check if there is a living network
function techage.power.power_available(pos, Cable)
--	for _,outdir in ipairs(techage.networks.get_node_connections(pos, Cable.tube_type)) do
--		-- generator visible?
--		if determine_netID(pos, outdir, Cable) > 0 then return true end
--	end
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	return networks.has_network(tlib_type, nvm[tlib_type.."_netID"])
--	local mem = techage.get_mem(pos)
--	local tlib_type = Cable.tube_type
--	local netID = nvm[tlib_type.."_netID"]
--	local netw = techage.networks.get_network(tlib_type, netID)
--	if netw then -- network available
--		if not mem.new_ticker or mem.new_ticker ~= netw.ticker then
--			mem.new_ticker = netw.ticker
--			return true
--		end
--	return false
--	end
end

-- this is more a try to start, the start will be performed by on_power()
function techage.power.consumer_start(pos, Cable, cycle_time)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type.."_calive"] = (cycle_time / 2) + 1
	nvm[tlib_type.."_cstate"] = NOPOWER
	nvm[tlib_type.."_taken"] = 0
end

function techage.power.consumer_stop(pos, Cable)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type.."_calive"] = 0
	nvm[tlib_type.."_cstate"] = STOPPED
	nvm[tlib_type.."_taken"] = 0
end

function techage.power.consumer_alive(pos, Cable, cycle_time)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	if nvm[tlib_type.."_netID"] then -- network available
		nvm[tlib_type.."_calive"] = (cycle_time / 2) + 1
	elseif nvm[tlib_type.."_cstate"] == RUNNING then
		local ndef = net_def(pos, tlib_type)
		ndef.on_nopower(pos)
		nvm[tlib_type.."_cstate"] = NOPOWER
	end
	return nvm[tlib_type.."_taken"] or 0
end

--
-- Generator related functions
--
function techage.power.generator_start(pos, Cable, cycle_time, outdir)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type.."_galive"] = (cycle_time / 2) + 2
	nvm[tlib_type.."_gstate"] = RUNNING
	nvm[tlib_type.."_given"] = 0
	trigger_network(pos, outdir, Cable)
end

function techage.power.generator_stop(pos, Cable, outdir)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	nvm[tlib_type.."_galive"] = 0
	nvm[tlib_type.."_gstate"] = STOPPED
	nvm[tlib_type.."_given"] = 0
end

function techage.power.generator_alive(pos, Cable, cycle_time, outdir)
	local nvm = techage.get_nvm(pos)
	local tlib_type = Cable.tube_type
	trigger_network(pos, outdir, Cable)
	nvm[tlib_type.."_galive"] = (cycle_time / 2) + 2
	return nvm[tlib_type.."_given"] or 0
end

-- function delete_netID(pos, outdir, Cable)
techage.power.delete_netID = delete_netID
