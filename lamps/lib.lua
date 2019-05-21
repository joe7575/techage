-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local POWER_CONSUMPTION = 1

local Power = techage.ElectricCable

local function swap_node(pos, postfix)
	local node = Power:get_node_lvm(pos)
	local parts = string.split(node.name, "_")
	if postfix == parts[2] then
		return
	end
	node.name = parts[1].."_"..postfix
	minetest.swap_node(pos, node)
end

local function on_power_pass1(pos, mem)
	if mem.running then
		mem.correction = POWER_CONSUMPTION
	else
		mem.correction = 0
	end
	return mem.correction
end	
		
local function on_power_pass2(pos, mem, sum)
	local node = minetest
	if sum > 0 and mem.running then
		swap_node(pos, "on")
		return 0
	else
		swap_node(pos, "off")
		return -mem.correction
	end
end

local function lamp_on_rightclick(pos, node, clicker)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	if not mem.running then
		mem.running = true
	else
		mem.running = false
	end
	techage.power.power_distribution(pos)
end

function techage.register_lamp(basename, ndef_off, ndef_on)
	ndef_off.on_construct = tubelib2.init_mem
	ndef_off.on_rightclick = lamp_on_rightclick
	
	ndef_on.on_construct = tubelib2.init_mem
	ndef_on.on_rightclick = lamp_on_rightclick
	
	minetest.register_node(basename.."_off", ndef_off)
	minetest.register_node(basename.."_on", ndef_on)

	techage.power.register_node({basename.."_off", basename.."_on"}, {
		on_power_pass1 = on_power_pass1,
		on_power_pass2 = on_power_pass2,
		power_network  = Power,
	})
end
