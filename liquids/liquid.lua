--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Liquid transportation API via Pipe(s) (peer, put, take)

]]--

local P2S = minetest.pos_to_string
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local LQD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).liquid end
local Pipe = techage.LiquidPipe
local S = techage.S

local net_def = techage.networks.net_def
local networks = techage.networks

techage.liquid = {}

local LiquidDef = {}
local ContainerDef = {}

--
-- Networks
--

-- determine network ID (largest hash number of all pumps)
local function determine_netID(pos, outdir)
	local netID = 0
	networks.connection_walk(pos, outdir, Pipe, function(pos, indir, node)
		local ntype = net_def(pos, "pipe").ntype
		if ntype and ntype == "pump" then
			local new = minetest.hash_node_position(pos) * 8 + outdir
			if netID <= new then
				netID = new
			end
		end
	end)
	return netID
end

-- store network ID on each pump like node
local function store_netID(pos, outdir, netID)
	networks.connection_walk(pos, outdir, Pipe, function(pos, indir, node)
		local ntype = net_def(pos, "pipe").ntype
		if ntype and ntype == "pump" then
			local mem = tubelib2.get_mem(pos)
			local outdir = networks.Flip[indir]
			mem.pipe = mem.pipe or {}
			mem.pipe.netIDs = mem.pipe.netIDs or {}
			mem.pipe.netIDs[outdir] = netID
		end
	end)
end

-- delete network and ID on each pump like node
local function delete_netID(pos, outdir)
	local netID = 0
	networks.connection_walk(pos, outdir, Pipe, function(pos, indir, node)
		local ntype = net_def(pos, "pipe").ntype
		if ntype and ntype == "pump" then
			local mem = tubelib2.get_mem(pos)
			local outdir = networks.Flip[indir]
			if mem.pipe and mem.pipe.netIDs and mem.pipe.netIDs[outdir] then
				netID = mem.pipe.netIDs[outdir]
				mem.pipe.netIDs[outdir] = nil
			end
		end
	end)
	networks.delete_network(netID, Pipe)
end

local function get_netID(pos, outdir)
	local mem = tubelib2.get_mem(pos)
	if not mem.pipe or not mem.pipe.netIDs or not mem.pipe.netIDs[outdir] then
		local netID = determine_netID(pos, outdir)
		store_netID(pos, outdir, netID)
	end
	return mem.pipe and mem.pipe.netIDs and mem.pipe.netIDs[outdir]
end

local function get_network_table(pos, outdir, ntype)
	local netID = get_netID(pos, outdir)
	if netID then
		local netw = networks.get_network(netID, Pipe)
		if not netw then
			netw = networks.collect_network_nodes(pos, outdir, Pipe)
			networks.set_network(netID, Pipe, netw)
		end
		local s = minetest.pos_to_string(minetest.get_position_from_hash(netID))
		--print("netw", string.format("%012X", netID),  s, dump(netw))
		return netw[ntype] or {}
	end
	return {}
end


--
-- Client remote functions
--

-- Determine and return liquid 'name' from the
-- remote inventory.
function techage.liquid.peek(pos, outdir)
	for _,item in ipairs(get_network_table(pos, outdir, "tank")) do
		local liquid = LQD(item.pos)
		if liquid and liquid.peek then
			return liquid.peek(item.pos, item.indir)
		end
	end
end

-- Add given amount of liquid to the remote inventory.
-- return leftover amount
function techage.liquid.put(pos, outdir, name, amount, player_name)
	for _,item in ipairs(get_network_table(pos, outdir, "tank")) do
		local liquid = LQD(item.pos)
		if liquid and liquid.put and liquid.peek then
			-- wrong items?
			local peek = liquid.peek(item.pos, item.indir)
			if peek and peek ~= name then return amount or 0 end
			if player_name then
				local num = techage.get_node_number(pos) or "000"
				techage.mark_position(player_name, item.pos, "("..num..") put", "", 1)
			end
			amount = liquid.put(item.pos, item.indir, name, amount)
			if not amount or amount == 0 then break end
		end
	end
	return amount or 0
end

-- Take given amount of liquid for the remote inventory.
-- return taken amount and item name
function techage.liquid.take(pos, outdir, name, amount, player_name)
	local taken = 0
	local item_name = nil
	for _,item in ipairs(get_network_table(pos, outdir, "tank")) do
		local liquid = LQD(item.pos)
		if liquid and liquid.take then
			if player_name then
				local num = techage.get_node_number(pos)
				techage.mark_position(player_name, item.pos, "("..num..") take", "", 1)
			end
			local val, name = liquid.take(item.pos, item.indir, name, amount - taken)
			if val and name then
				taken = taken + val
				item_name = name
				if amount - taken == 0 then break end
			end
		end
	end
	return taken, item_name
end

--
-- Server local functions
--

function techage.liquid.srv_peek(pos, indir)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	return mem.liquid.name
end

function techage.liquid.srv_put(pos, indir, name, amount)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	amount = amount or 0
	if not mem.liquid.name then
		mem.liquid.name = name
		mem.liquid.amount = amount
		return 0
	elseif mem.liquid.name == name then
		mem.liquid.amount = mem.liquid.amount or 0
		local capa = LQD(pos).capa
		if mem.liquid.amount + amount <= capa then
			mem.liquid.amount = mem.liquid.amount + amount
			return 0
		else
			local rest = mem.liquid.amount + amount - capa
			mem.liquid.amount = capa
			return rest
		end
	end
	return amount
end

function techage.liquid.srv_take(pos, indir, name, amount)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	amount = amount or 0
	if not name or mem.liquid.name == name then
		name = mem.liquid.name
		mem.liquid.amount = mem.liquid.amount or 0
		if mem.liquid.amount > amount then
			mem.liquid.amount = mem.liquid.amount - amount
			return amount, name
		else 
			local rest = mem.liquid.amount
			local name = mem.liquid.name
			mem.liquid.amount = 0
			mem.liquid.name = nil
			return rest, name
		end
	end
	return 0
end

--
-- Further API functions
-- 

-- like: register_liquid("techage:ta3_barrel_oil", "techage:ta3_barrel_empty", 10, "techage:oil")
function techage.register_liquid(full_container, empty_container, container_size, inv_item)
	LiquidDef[full_container] = {container = empty_container, size = container_size, inv_item = inv_item}
	ContainerDef[empty_container] = ContainerDef[empty_container] or {}
	ContainerDef[empty_container][inv_item] = full_container
end

function techage.liquid.get_liquid_def(full_container)
	return LiquidDef[full_container]
end
	
function techage.liquid.is_container_empty(container_name)
	return ContainerDef[container_name]
end

function techage.liquid.get_full_container(empty_container, inv_item)
	return ContainerDef[empty_container] and ContainerDef[empty_container][inv_item]
end

-- To be called from each node via 'tubelib2_on_update2'
-- 'output' is optional and only needed for nodes with dedicated
-- pipe sides (e.g. pumps).
function techage.liquid.update_network(pos, outdir)
	networks.node_connections(pos, Pipe)
	delete_netID(pos, outdir)
end
