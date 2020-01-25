--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Liquid lib

]]--

local M = minetest.get_meta
local S = techage.S
local liquid = techage.liquid
local LQD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).liquid end


function techage.liquid.formspec_liquid(x, y, mem)
	local itemname = "techage:liquid"
	if mem.liquid and mem.liquid.amount and mem.liquid.amount > 0 and mem.liquid.name then
		itemname = mem.liquid.name.." "..mem.liquid.amount
	end
	return "container["..x..","..y.."]"..
		"background[0,0;3,2.05;techage_form_grey.png]"..
		"image[0,0;1,1;techage_form_input_arrow.png]"..
		techage.item_image(1, 0, itemname)..
		"image[2,0;1,1;techage_form_output_arrow.png]"..
		"image[1,1;1,1;techage_form_arrow.png]"..
		"list[context;src;0,1;1,1;]"..
		"list[context;dst;2,1;1,1;]"..
		"listring[current_player;main]"..
		"listring[context;src]" ..
		"listring[current_player;main]"..
		"listring[context;dst]" ..
		"listring[current_player;main]"..
		"container_end[]"
end	

local function fill_container(pos, inv)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	local empty_container = inv:get_stack("src", 1):get_name()
	local full_container = liquid.get_full_container(empty_container, mem.liquid.name)
	if empty_container and full_container then
		local ldef = liquid.get_liquid_def(full_container)
		if ldef and mem.liquid.amount - ldef.size >= 0 then 
			if inv:room_for_item("dst", ItemStack(full_container)) then
				inv:remove_item("src", ItemStack(empty_container))
				inv:add_item("dst", ItemStack(full_container))
				mem.liquid.amount = mem.liquid.amount - ldef.size
				if mem.liquid.amount == 0 then
					mem.liquid.name = nil
				end
			end
		end
	end
end

local function empty_container(pos, inv, size)
	local mem = tubelib2.get_mem(pos)
	mem.liquid = mem.liquid or {}
	mem.liquid.amount = mem.liquid.amount or 0
	local stack = inv:get_stack("src", 1)
	local ldef = liquid.get_liquid_def(stack:get_name())
	if ldef and (not mem.liquid.name or ldef.inv_item == mem.liquid.name) then
		local amount = stack:get_count() * ldef.size
		if mem.liquid.amount + amount <= size then 
			if inv:room_for_item("dst", ItemStack(ldef.container)) then
				inv:remove_item("src", stack)
				inv:add_item("dst", ItemStack(ldef.container))
				mem.liquid.amount = mem.liquid.amount + amount
				mem.liquid.name = ldef.inv_item
			end
		end
	end
end

function techage.liquid.move_item(pos, stack, size, formspec)
	local mem = tubelib2.get_mem(pos)
	local inv = M(pos):get_inventory()
	if liquid.is_container_empty(stack:get_name()) then
		fill_container(pos, inv)
	else
		empty_container(pos, inv, size)
	end
	M(pos):set_string("formspec", formspec(pos, mem))
end
	
function techage.liquid.is_empty(pos)
	local mem = tubelib2.get_mem(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("src") and inv:is_empty("dst") and (not mem.liquid or (mem.liquid.amount or 0) == 0)
end

techage.liquid.tubing = {
	on_pull_item = function(pos, in_dir, num)
		local inv = M(pos):get_inventory()
		if not inv:is_empty("dst") then
			local taken = techage.get_items(inv, "dst", num) 
			if not inv:is_empty("src") then
				fill_container(pos, inv)
			end
			return taken
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local inv = M(pos):get_inventory()
		if inv:room_for_item("src", stack) then
			inv:add_item("src", stack)
			if liquid.is_container_empty(stack:get_name()) then
				fill_container(pos, inv)
			else
				empty_container(pos, inv)
			end
			return true
		end
		return false
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = M(pos)
		local inv = meta:get_inventory()
		return techage.put_items(inv, "dst", stack)
	end,
	on_recv_message = function(pos, src, topic, payload)
		if topic == "load" then
			local mem = tubelib2.get_mem(pos)
			return techage.power.percent(LQD(pos).capa, (mem.liquid and mem.liquid.amount) or 0)
		elseif topic == "size" then
			return LQD(pos).capa
		else
			return "unsupported"
		end
	end,
}	


techage.liquid.fill_container = fill_container
techage.liquid.empty_container = empty_container