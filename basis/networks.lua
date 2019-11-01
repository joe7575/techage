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

local MAX_NUM_NODES = 500
local BEST_BEFORE = 5 * 60  -- 5 minutes
local Route = {} -- Used to determine the already passed nodes while walking
local NumNodes = 0
local DirToSide = {"B", "R", "F", "L", "D", "U"}
local Sides = {B = true, R = true, F = true, L = true, D = true, U = true}
local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}
local Flip = {[0]=0,3,4,1,2,6,5} -- 180 degree turn

local function error(pos, msg)
	minetest.log("error", msg.." at "..P2S(pos).." "..N(pos).name)
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

-- return the node definition local networks table
local function net_def(pos, net_name) 
	local ndef = minetest.registered_nodes[techage.get_node_lvm(pos).name]
	return ndef and ndef.networks and ndef.networks[net_name] or {} 
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
local function valid_indir(pos, indir, param2, net_name)
	local sides = net_def(pos, net_name).sides
	if not sides then return false end
	local side = DirToSide[indir_to_dir(indir, param2)]
	if not sides[side] then return false end
	return true
end

-- do the walk through the tubelib2 network
local function connection_walk(pos, node, tlib2, clbk)
	if clbk then clbk(pos, node) end
	for _,outdir in pairs(get_node_connections(pos, tlib2.tube_type)) do
		local pos2, indir2 = tlib2:get_connected_node_pos(pos, outdir)
		local node = techage.get_node_lvm(pos2)
		if pos2 and not pos_already_reached(pos2) and 
					valid_indir(pos2, indir2, node.param2, tlib2.tube_type) then
			connection_walk(pos2, node, tlib2, clbk)
		end
	end
end

-- determine all node sides with tube connections
local function node_connections(pos, tlib2)
	local node = techage.get_node_lvm(pos)
	local val = 0
	local sides = net_def(pos, tlib2.tube_type).sides
	
	if sides then
		for dir = 1,6 do
			val = val * 2
			local outdir = dir_to_outdir(dir, node.param2)
			--if sides[DirToSide[outdir]] then -------------------------------------- TODO
				local pos2 = tubelib2.get_pos(pos, dir)
				local node2 = techage.get_node_lvm(pos2)
				if tlib2.primary_node_names[node2.name] then
					val = val + 1
				end
			--end
		end
		M(pos):set_int(tlib2.tube_type.."_conn", val)
	else
		error(pos, "sides missing")
	end
end

-- determine network ID (largest hash number)
local function determine_netID(pos, tlib2)
	Route = {}
	NumNodes = 0
	pos_already_reached(pos) 
	local netID = minetest.hash_node_position(pos)
	local tNetwork = {}
	local node = techage.get_node_lvm(pos)
	connection_walk(pos, node, tlib2, function(pos, node)
		local new = minetest.hash_node_position(pos)
		if netID <= new then
			netID = new
		end
	end)
	return netID
end

-- store network ID on each node and build network tables
local function store_netID(pos, netID, tlib2)
	Route = {}
	NumNodes = 0
	pos_already_reached(pos) 
	local netw = {}
	local node = techage.get_node_lvm(pos)
	local net_name = tlib2.tube_type
	connection_walk(pos, node, tlib2, function(pos, node)
		local ntype = net_def(pos, net_name).ntype
		if ntype then
			if not netw[ntype] then netw[ntype] = {} end
			netw[ntype][#netw[ntype] + 1] = pos
			local mem = tubelib2.get_mem(pos)
			mem[net_name] = mem[net_name] or {}
			mem[net_name].netID = netID
		end
	end)
	netw.best_before = minetest.get_gametime() + BEST_BEFORE
	return netw
end

local function collect_network_nodes(pos, netID, tlib2)
	Route = {}
	NumNodes = 0
	pos_already_reached(pos) 
	local netw = {}
	local node = techage.get_node_lvm(pos)
	local net_name = tlib2.tube_type
	connection_walk(pos, node, tlib2, function(pos, node)
		local ntype = net_def(pos, net_name).ntype
		if ntype then
			if not netw[ntype] then netw[ntype] = {} end
			netw[ntype][#netw[ntype] + 1] = pos
		end
	end)
	netw.best_before = minetest.get_gametime() + BEST_BEFORE
	return netw
end

-- keep data base small and valid
local function remove_outdated_networks()
	local to_be_deleted = {}
	local t = minetest.get_gametime()
	for net_name,tbl in pairs(Networks) do
		for netID,network in pairs(tbl) do
			local valid = (network.best_before or 0) - t
			output(network, valid)
			if valid < 0 then
				to_be_deleted[#to_be_deleted+1] = {net_name, netID}
			end
		end
	end
	for _,item in ipairs(to_be_deleted) do
		local net_name, netID = unpack(item)
		print("delete", net_name, netID)
		Networks[net_name][netID] = nil
	end
	minetest.after(60, remove_outdated_networks)
end
minetest.after(60, remove_outdated_networks)

--
-- API Functions
--
techage.networks.AllSides = Sides -- table for all 6 node sides

-- techage.networks.side_to_outdir(pos, side)
techage.networks.side_to_outdir = side_to_outdir

-- check if the given pipe dir into the node is valid
-- valid_indir(pos, indir, param2, net_name)
techage.networks.valid_indir = valid_indir

-- Store tubelib2 connection dirs as node meta and
-- update network tables.
-- Function to be called from tubelib2_on_update2
-- tlib2 is the tubelib2 instance
function techage.networks.update_network(pos, tlib2)
	node_connections(pos, tlib2)
	local netID = determine_netID(pos, tlib2)
	if not Networks[tlib2.tube_type] then
		Networks[tlib2.tube_type] = {}
	end
	Networks[tlib2.tube_type][netID] = store_netID(pos, netID, tlib2)
end

function techage.networks.get_network(pos, tlib2)
	local mem = tubelib2.get_mem(pos)
	local netID = mem[tlib2.tube_type] and mem[tlib2.tube_type].netID
	if netID then
		if not Networks[tlib2.tube_type] then
			Networks[tlib2.tube_type] = {}
		end
		if not Networks[tlib2.tube_type][netID] then
			Networks[tlib2.tube_type][netID] = collect_network_nodes(pos, netID, tlib2) or {}
		end
		Networks[tlib2.tube_type][netID].best_before = minetest.get_gametime() + BEST_BEFORE
		return Networks[tlib2.tube_type][netID]
	end
end

function techage.networks.get_network_table(pos, tlib2, ntype)
	return techage.networks.get_network(pos, tlib2)[ntype] or {}
end

function techage.networks.connection_walk(pos, tlib2, clbk)
	Route = {}
	NumNodes = 0
	pos_already_reached(pos) -- don't consider the start pos
	local node = techage.get_node_lvm(pos)
	connection_walk(pos, node, tlib2, clbk)
	return NumNodes
end

function techage.networks.connections(pos, tlib2)
	for _,dir in ipairs(get_node_connections(pos, tlib2.tube_type)) do
		print(({"North", "East", "South", "West", "Down", "Up"})[dir])
	end
end

	