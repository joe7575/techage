--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Networks - the connection of tubelib2 tube/pipe/cable lines to networks
]]--

local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local N = techage.get_node_lvm
local S = techage.S
local hex = function(val) return string.format("%x", val) end

local Networks = {} -- cache for networks

techage.networks = {}  -- name space

local MAX_NUM_NODES = 1000
local BEST_BEFORE = 5 * 60  -- 5 minutes
local Route = {} -- Used to determine the already passed nodes while walking
local NumNodes = 0
local DirToSide = {"B", "R", "F", "L", "D", "U"}
local Sides = {B = true, R = true, F = true, L = true, D = true, U = true}
local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}
local Flip = {[0]=0,3,4,1,2,6,5} -- 180 degree turn

local function error(pos, msg)
	minetest.log("error", "[techage] "..msg.." at "..P2S(pos).." "..N(pos).name)
end

local function count_nodes(ntype, nodes)
	local num = 0
	for _,pos in ipairs(nodes or {}) do
		num = num + 1
	end
	return ntype.."="..num
end

local function output(network, valid)
	local tbl = {}
	for ntype,table in pairs(network) do
		if type(table) == "table" then
			tbl[#tbl+1] = count_nodes(ntype, table)
		end
	end
	print("Network ("..valid.."): "..table.concat(tbl, ", "))
end

local function debug(ntype)
	local tbl = {}
	for netID,netw in pairs(Networks[ntype] or {}) do
		if type(netw) == "table" then
			tbl[#tbl+1] = string.format("%X", netID)
		end
	end
	return "Networks: "..table.concat(tbl, ", ")
end

local function hidden_node(pos, net_name)
	local name = M(pos):get_string("techage_hidden_nodename")
	local ndef = minetest.registered_nodes[name]
	if ndef and ndef.networks then
		return ndef.networks[net_name] or {} 
	end
	return {}
end

-- return the node definition local networks table
local function net_def(pos, net_name) 
	local ndef = minetest.registered_nodes[techage.get_node_lvm(pos).name]
	if ndef and ndef.networks then
		return ndef.networks[net_name] or {} 
	else  -- hidden junction
		return hidden_node(pos, net_name)
	end
end

local function net_def2(pos, node_name, net_name) 
	local ndef = minetest.registered_nodes[node_name]
	if ndef and ndef.networks then
		return ndef.networks[net_name] or {} 
	else  -- hidden junction
		return hidden_node(pos, net_name)
	end
end

local function connected(tlib2, pos, dir)
	local param2, npos = tlib2:get_primary_node_param2(pos, dir)
	if param2 then
		local d1, d2, num = tlib2:decode_param2(npos, param2)
		if not num then return end
		return Flip[dir] == d1 or Flip[dir] == d2
	end
	-- secondary nodes allowed?
	if tlib2.force_to_use_tubes then
		return tlib2:is_special_node(pos, dir)
	else
		return tlib2:is_secondary_node(pos, dir)
	end
	return false
end

-- Calculate the node outdir based on node.param2 and nominal dir (according to side)
local function dir_to_outdir(dir, param2)
	if dir < 5 then
		return ((dir + param2 - 1) % 4) + 1
	end
	return dir
end

local function indir_to_dir(indir, param2)
	if indir < 5 then
		return ((indir - param2 + 5) % 4) + 1
	end
	return Flip[indir]
end

local function outdir_to_dir(outdir, param2)
	if outdir < 5 then
		return ((outdir - param2 + 3) % 4) + 1
	end
	return outdir
end

local function side_to_outdir(pos, side)
	return dir_to_outdir(SideToDir[side], techage.get_node_lvm(pos).param2)
end

-- Get tlib2 connection dirs as table
-- used e.g. for the connection walk
local function get_node_connections(pos, net_name)
	local val = M(pos):get_int(net_name.."_conn")
    local tbl = {}
    if val % 0x40 >= 0x20 then tbl[#tbl+1] = 1 end
    if val % 0x20 >= 0x10 then tbl[#tbl+1] = 2 end
    if val % 0x10 >= 0x08 then tbl[#tbl+1] = 3 end
    if val % 0x08 >= 0x04 then tbl[#tbl+1] = 4 end
    if val % 0x04 >= 0x02 then tbl[#tbl+1] = 5 end
    if val % 0x02 >= 0x01 then tbl[#tbl+1] = 6 end
    return tbl
end

-- store all node sides with tube connections as nodemeta
local function node_connections(pos, tlib2)
	local node = techage.get_node_lvm(pos)
	local val = 0
	local ndef = net_def2(pos, node.name, tlib2.tube_type)
	local sides = ndef.sides or ndef.get_sides and ndef.get_sides(pos, node)
	if sides then
		for dir = 1,6 do
			val = val * 2
			local side = DirToSide[outdir_to_dir(dir, node.param2)]
			if sides[side] then
				if connected(tlib2, pos, dir) then
					--techage.mark_side("singleplayer", pos, dir, "node_connections", "", 1)--------------------
					val = val + 1
				end
			end
		end
		M(pos):set_int(tlib2.tube_type.."_conn", val)
	else
		--error(pos, "sides missing")
	end
end

local function pos_already_reached(pos)
	local key = minetest.hash_node_position(pos)
	if not Route[key] and NumNodes < MAX_NUM_NODES then
		Route[key] = true
		NumNodes = NumNodes + 1
		return false
	end
	return true
end

-- check if the given pipe dir into the node is valid
local function valid_indir(pos, indir, node, net_name)
	local ndef = net_def2(pos, node.name, net_name)
	local sides = ndef.sides or ndef.get_sides and ndef.get_sides(pos, node)
	local side = DirToSide[indir_to_dir(indir, node.param2)]
	if not sides or sides and not sides[side] then return false end
	return true
end

local function is_junction(pos, name, tube_type)
	local ndef = net_def2(pos, name, tube_type)
	-- ntype can be a string or an array of strings or nil
	if ndef.ntype == "junc" then
		return true
	end
	if type(ndef.ntype) == "table" then
		for _,ntype in ipairs(ndef.ntype) do
			if ntype == "junc" then 
				return true 
			end
		end
	end
	return false
end

-- do the walk through the tubelib2 network
-- indir is the direction which should not be covered by the walk
-- (coming from there)
-- if outdirs is given, only this dirs are used
local function connection_walk(pos, outdirs, indir, node, tlib2, clbk)
	if clbk then clbk(pos, indir, node) end
	--techage.mark_position("singleplayer", pos, "walk", "", 1)
	--print("connection_walk", node.name, outdirs or is_junction(pos, node.name, tlib2.tube_type))
	if outdirs or is_junction(pos, node.name, tlib2.tube_type) then
		for _,outdir in pairs(outdirs or get_node_connections(pos, tlib2.tube_type)) do
			--techage.mark_side("singleplayer", pos, outdir, "connection_walk", "", 3)--------------------
			--print("get_node_connections", node.name, outdir)
			local pos2, indir2 = tlib2:get_connected_node_pos(pos, outdir)
			local node = techage.get_node_lvm(pos2)
			if pos2 and not pos_already_reached(pos2) and valid_indir(pos2, indir2, node, tlib2.tube_type) then
				connection_walk(pos2, nil, indir2, node, tlib2, clbk)
			end
		end
	end
end

local function collect_network_nodes(pos, outdir, tlib2)
	Route = {}
	NumNodes = 0
	pos_already_reached(pos) 
	local netw = {}
	local node = techage.get_node_lvm(pos)
	local net_name = tlib2.tube_type
	-- outdir corresponds to the indir coming from
	connection_walk(pos, outdir and {outdir}, nil, node, tlib2, function(pos, indir, node)
		local ndef = net_def2(pos, node.name, net_name)
		-- ntype can be a string or an array of strings or nil
		local ntypes = ndef.ntype or {}
		if type(ntypes) == "string" then
			ntypes = {ntypes}
		end
		for _,ntype in ipairs(ntypes) do
			if not netw[ntype] then netw[ntype] = {} end
			netw[ntype][#netw[ntype] + 1] = {pos = pos, indir = indir, nominal = ndef.nominal or 0}
		end
	end)
	netw.best_before = minetest.get_gametime() + BEST_BEFORE
	netw.num_nodes = NumNodes
	return netw
end

-- keep data base small and valid
-- needed for networks without scheduler
local function remove_outdated_networks()
	local to_be_deleted = {}
	local t = minetest.get_gametime()
	for net_name,tbl in pairs(Networks) do
		for netID,network in pairs(tbl) do
			local valid = (network.best_before or 0) - t
			--output(network, valid)
			if valid < 0 then
				to_be_deleted[#to_be_deleted+1] = {net_name, netID}
			end
		end
	end
	for _,item in ipairs(to_be_deleted) do
		local net_name, netID = unpack(item)
		Networks[net_name][netID] = nil
	end
	minetest.after(60, remove_outdated_networks)
end
minetest.after(60, remove_outdated_networks)

--
-- API Functions
--

-- Table fo a 180 degree turn
techage.networks.Flip = Flip

-- techage.networks.net_def(pos, net_name)
techage.networks.net_def = net_def

techage.networks.AllSides = Sides -- table for all 6 node sides

-- techage.networks.side_to_outdir(pos, side)
techage.networks.side_to_outdir = side_to_outdir

-- techage.networks.node_connections(pos, tlib2)
techage.networks.node_connections = node_connections

-- techage.networks.collect_network_nodes(pos, outdir, tlib2)
techage.networks.collect_network_nodes = collect_network_nodes

function techage.networks.connection_walk(pos, outdir, tlib2, clbk)
	Route = {}
	NumNodes = 0
	pos_already_reached(pos) -- don't consider the start pos
	local node = techage.get_node_lvm(pos)
	connection_walk(pos, outdir and {outdir}, Flip[outdir], node, tlib2, clbk)
	return NumNodes
end

-- return network without maintainting the "alive" data
function techage.networks.peek_network(tube_type, netID)
	--print("peek_network", debug(tube_type))
	return Networks[tube_type] and Networks[tube_type][netID]
end

function techage.networks.set_network(tube_type, netID, network)
	if netID then
		if not Networks[tube_type] then
			Networks[tube_type] = {}
		end
		Networks[tube_type][netID] = network
		Networks[tube_type][netID].best_before = minetest.get_gametime() + BEST_BEFORE
	end
end


--
-- Power API
--
function techage.networks.has_network(tube_type, netID)
	return Networks[tube_type] and Networks[tube_type][netID]
end

function techage.networks.build_network(pos, outdir, tlib2, netID)
	local netw = collect_network_nodes(pos, outdir, tlib2)
	Networks[tlib2.tube_type] = Networks[tlib2.tube_type] or {}
	Networks[tlib2.tube_type][netID] = netw
	netw.alive = 3
	techage.schedule.start(tlib2.tube_type, netID)
end
	
function techage.networks.get_network(tube_type, netID)
	--print("get_network", string.format("%X", netID), debug(tube_type))
	local netw = Networks[tube_type] and Networks[tube_type][netID]
	if netw then
		netw.alive = 3 -- monitored by scheduler (power)
		netw.best_before = minetest.get_gametime() + BEST_BEFORE  -- monitored by networks (liquids)
		return netw
	end
end

function techage.networks.delete_network(tube_type, netID)
	if Networks[tube_type] and Networks[tube_type][netID] then
		Networks[tube_type][netID] = nil
	end
end

-- Get node tubelib2 connections as table of outdirs
-- techage.networks.get_node_connections(pos, net_name)
techage.networks.get_node_connections = get_node_connections

techage.networks.MAX_NUM_NODES = MAX_NUM_NODES
