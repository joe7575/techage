--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Helper functions for liquid transportation (peer, put, take)

]]--

local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local LQD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).liquid end
local Pipe = techage.BiogasPipe

techage.liquid = {}

local LiquidDefs = {}

local function get_dest_node(pos, outdir)
	local pos2, indir = Pipe:get_connected_node_pos(pos, outdir)
	local node = techage.get_node_lvm(pos2)
	local liquid = (minetest.registered_nodes[node.name] or {}).liquid
	if liquid then
		return pos2, indir, liquid
	end
end

local function peek(stack, liquid)
	liquid.amount = liquid.amount or 0
	return liquid.amount + stack:get_count() * 10
end

local function put(stack, liquid, amount)
	liquid.amount = liquid.amount or 0
	if liquid.amount + amount > 1 then
		local num = math.floor((liquid.amount + amount) / 10)
		if stack:get_free_space() >= num then
			stack:set_count(stack:get_count() + num)
			liquid.amount = liquid.amount + amount - num
			return 0
		else
			local res = liquid.amount + amount - 1
			liquid.amount = 1
			return res
		end
	else
		liquid.amount = liquid.amount + amount
		return 0
	end
end

local function take(stack, liquid, amount)
	local res
	liquid.amount = liquid.amount or 0
	if liquid.amount >= amount then
		liquid.amount = liquid.amount - amount
		res = amount
	elseif amount > 10 then
		local num = math.floor((liquid.amount + amount) / 10)
		if stack:get_count() >= num then
			stack:set_count(stack:get_count() - num)
			liquid.amount = num + liquid.amount - amount
			res = amount
		end
	elseif stack:get_count() > 0 then
		stack:set_count(stack:get_count() - 1)
		liquid.amount = 1 + liquid.amount - amount
		res = amount
	elseif liquid.amount > 0 then
		res = liquid.amount
		liquid.amount = 0
	else
		res = 0
	end
	return res
end

--
-- Client remote functions
--

-- Determine and return liquid 'name' and 'amount' from the
-- remote inventory.
function techage.liquid.peek(pos, outdir)
	local pos2, indir, liquid = get_dest_node(pos, outdir)
	print("peek", indir, liquid)
	if liquid and liquid.peek then
		return liquid.peek(pos2, indir)
	end
end

-- Add given amount of liquid to the remote inventory.
-- return leftover amount
function techage.liquid.put(pos, outdir, name, amount)
	local pos2, indir, liquid = get_dest_node(pos, outdir)
	if liquid and liquid.put then
		return liquid.put(pos2, indir, name, amount)
	end
	return amount
end

-- Take given amount of liquid for the remote inventory.
-- return taken amount
function techage.liquid.take(pos, outdir, name, amount)
	local pos2, indir, liquid = get_dest_node(pos, outdir)
	if liquid and liquid.take then
		return liquid.take(pos2, indir, name, amount)
	end
	return 0
end

--
-- Server local functions
--

function techage.liquid.srv_peek(pos, listname)
	local mem = tubelib2.get_mem(pos)
	if mem.liquid and mem.liquid.name then
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(listname, 1)
		return mem.liquid.name, peek(stack, mem.liquid)
	end
end

function techage.liquid.srv_put(pos, listname, name, amount)
	local mem = tubelib2.get_mem(pos)
	if mem.liquid and not mem.liquid.name or mem.liquid.name == name then
		mem.liquid.name = name
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(listname, 1)
		return put(stack, mem.liquid, amount)
	end
end

function techage.liquid.srv_take(pos, listname, name, amount)
	local mem = tubelib2.get_mem(pos)
	if mem.liquid and mem.liquid.name == name then
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(listname, 1)
		return take(stack, mem.liquid, amount)
	end
end



function techage.register_liquid(name, container, size, inv_item)
	LiquidDefs[name] = {container = container, size = size, inv_item = inv_item}
end

function techage.liquid.get_liquid_def(name)
	return LiquidDefs[name]
end
	