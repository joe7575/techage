--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Liquid transportation API via Pipe(s) (peer, put, take)

]]--

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

-- determine network ID (largest hash number)
local function determine_netID(pos, outdir)
	local netID = 0
	networks.connection_walk(pos, outdir, Pipe, function(pos, indir, node)
		local ntype = net_def(pos, "pipe").ntype
		if ntype and ntype ~= "pump" then
			local new = minetest.hash_node_position(pos)
			if netID <= new then
				netID = new
			end
		end
	end)
	return netID
end

-- store network ID on each node
local function store_netID(pos, outdir, netID)
	networks.connection_walk(pos, outdir, Pipe, function(pos, indir, node)
		local ntype = net_def(pos, "pipe").ntype
		if ntype and ntype ~= "pump" then
			local mem = tubelib2.get_mem(pos)
			mem.pipe = mem.pipe or {}
			mem.pipe.netID = netID
		end
	end)
end

-- delete network and ID on each node
local function delete_netID(pos, outdir)
	local netID = 0
	networks.connection_walk(pos, outdir, Pipe, function(pos, indir, node)
		local ntype = net_def(pos, "pipe").ntype
		if ntype and ntype ~= "pump" then
			local mem = tubelib2.get_mem(pos)
			if mem.pipe and mem.pipe.netID then
				netID = mem.pipe.netID
				mem.pipe.netID = nil
			end
		end
	end)
	networks.delete_network(netID, Pipe)
end


local function get_network_table(pos, outdir, ntype)
	-- jump to the next node because pumps have to network
    -- interfaces and therefore can't have a netID
	local pos2 = Pipe:get_connected_node_pos(pos, outdir)
	local mem = tubelib2.get_mem(pos2)
	if not mem.pipe or not mem.pipe.netID then
		local netID = determine_netID(pos, outdir)
		store_netID(pos, outdir, netID)
		mem.pipe = mem.pipe or {}
		mem.pipe.netID = netID
	end
	local netw = networks.get_network(mem.pipe.netID, Pipe)
	if not netw then
		netw = networks.collect_network_nodes(pos, outdir, Pipe)
		networks.set_network(mem.pipe.netID, Pipe, netw)
	end
	return netw[ntype] or {}
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
function techage.liquid.put(pos, outdir, name, amount)
	for _,item in ipairs(get_network_table(pos, outdir, "tank")) do
		local liquid = LQD(item.pos)
		if liquid and liquid.put and liquid.peek then
			-- wrong items?
			local peek = liquid.peek(item.pos, item.indir)
			if peek and peek ~= name then return amount end
			--techage.mark_position("singleplayer", item.pos, "put", "", 1) ------------------- debug
			amount = liquid.put(item.pos, item.indir, name, amount)
			if amount == 0 then break end
		end
	end
	return amount
end

-- Take given amount of liquid for the remote inventory.
-- return taken amount and item name
function techage.liquid.take(pos, outdir, name, amount)
	local taken = 0
	local item_name = nil
	for _,item in ipairs(get_network_table(pos, outdir, "tank")) do
		local liquid = LQD(item.pos)
		if liquid and liquid.take then
			--techage.mark_position("singleplayer", item.pos, "take", "", 1) ------------------- debug
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
-- 'output' is optional and only needed for nodes with two
-- different networks.
function techage.liquid.update_network(pos, outdir)
	networks.node_connections(pos, Pipe)
	delete_netID(pos, outdir)
end

minetest.register_craftitem("techage:water", {
	description = S("Water"),
	inventory_image = "techage_water_inv.png",
	groups = {not_in_creative_inventory=1},
	
})

minetest.register_craftitem("techage:river_water", {
	description = S("Water"),
	inventory_image = "techage_water_inv.png",
	groups = {not_in_creative_inventory=1},
	
})

minetest.register_craftitem("techage:barrel_water", {
	description = S("Water Barrel"),
	inventory_image = "techage_barrel_water_inv.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:barrel_river_water", {
	description = S("River Water Barrel"),
	inventory_image = "techage_barrel_water_inv.png",
	stack_max = 1,
})

techage.register_liquid("bucket:bucket_water", "bucket:bucket_empty", 1, "techage:water")
techage.register_liquid("bucket:bucket_river_water", "bucket:bucket_empty", 1, "techage:river_water")

techage.register_liquid("techage:barrel_water", "techage:ta3_barrel_empty", 10, "techage:water")
techage.register_liquid("techage:barrel_river_water", "techage:ta3_barrel_empty", 10, "techage:river_water")

techage.register_liquid("bucket:bucket_lava", "bucket:bucket_empty", 1, "default:lava_source")

