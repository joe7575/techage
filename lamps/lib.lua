--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Lamp library

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local PWR_NEEDED = 0.5
local CYCLE_TIME = 2

local Cable = techage.ElectricCable
local power = networks.power

local function swap_node(pos, postfix)
	local node = techage.get_node_lvm(pos)
	local parts = string.split(node.name, "_")
	if postfix == parts[2] then
		return
	end
	node.name = parts[1].."_"..postfix
	minetest.swap_node(pos, node)
	local ndef = minetest.registered_nodes[node.name]
	if ndef.on_switch_lamp then
		ndef.on_switch_lamp(pos, postfix == "on")
	end
end

local function on_power(pos)
	swap_node(pos, "on")
	local nvm = techage.get_nvm(pos)
	nvm.turned_on = true
end

local function on_nopower(pos)
	swap_node(pos, "off")
	local nvm = techage.get_nvm(pos)
	nvm.turned_on = false
end

local function is_running(pos, nvm)
	return nvm.turned_on
end

local function node_timer_off1(pos, elapsed)
	local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
	if consumed == PWR_NEEDED then
		on_power(pos)
	end
	return true
end

local function node_timer_off2(pos, elapsed)
	local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED * 2)
	if consumed == PWR_NEEDED * 2 then
		on_power(pos)
	end
	return true
end

local function node_timer_on1(pos, elapsed)
	local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
	if consumed < PWR_NEEDED then
		on_nopower(pos)
	end
	return true
end

local function node_timer_on2(pos, elapsed)
	local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED * 2)
	if consumed < PWR_NEEDED * 2 then
		on_nopower(pos)
	end
	return true
end

local function lamp_on_rightclick(pos, node, clicker)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end

	local nvm = techage.get_nvm(pos)
	if not nvm.turned_on and power.power_available(pos, Cable) then
		nvm.turned_on = true
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		swap_node(pos, "on")
	else
		nvm.turned_on = false
		minetest.get_node_timer(pos):stop()
		swap_node(pos, "off")
	end
end

local function on_rotate(pos, node, user, mode, new_param2)
	if minetest.is_protected(pos, user:get_player_name()) then
		return false
	end
	node.param2 = techage.rotate_wallmounted(node.param2)
	minetest.swap_node(pos, node)
	return true
end

local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	return minetest.rotate_and_place(itemstack, placer, pointed_thing)
end

local function after_place_node(pos)
	local nvm = techage.get_nvm(pos)
	Cable:after_place_node(pos)
end

local function after_dig_node(pos, oldnode)
	Cable:after_dig_node(pos)
	techage.del_mem(pos)
end

local function tubelib2_on_update2(pos, outdir, tlib2, node)
	power.update_network(pos, outdir, tlib2)
end

function techage.register_lamp(basename, ndef_off, ndef_on)
	if ndef_off.high_power then
		ndef_off.on_timer = ndef_off.on_timer or node_timer_off2
	else
		ndef_off.on_timer = ndef_off.on_timer or node_timer_off1
	end
	ndef_off.after_place_node = after_place_node
	ndef_off.after_dig_node = after_dig_node
	ndef_off.on_rightclick = lamp_on_rightclick
	if not ndef_off.on_rotate then
		ndef_off.on_place = on_place
	end
	ndef_off.on_rotate = ndef_off.on_rotate or on_rotate
	ndef_off.paramtype = "light"
	ndef_off.use_texture_alpha = techage.CLIP
	ndef_off.light_source = 0
	ndef_off.sunlight_propagates = true
	ndef_off.paramtype2 = "facedir"
	ndef_off.groups = {choppy=2, cracky=2, crumbly=2}
	ndef_off.is_ground_content = false
	ndef_off.sounds = default.node_sound_glass_defaults()

	if ndef_on.high_power then
		ndef_on.on_timer = ndef_on.on_timer or node_timer_on2
	else
		ndef_on.on_timer = ndef_on.on_timer or node_timer_on1
	end
	ndef_on.after_place_node = after_place_node
	ndef_on.after_dig_node = after_dig_node
	ndef_on.on_rightclick = lamp_on_rightclick
	ndef_on.on_rotate = ndef_on.on_rotate or on_rotate
	ndef_on.paramtype = "light"
	ndef_on.use_texture_alpha = techage.CLIP
	ndef_on.light_source = minetest.LIGHT_MAX
	ndef_on.sunlight_propagates = true
	ndef_on.paramtype2 = "facedir"
	ndef_on.diggable = false
	ndef_on.groups = {not_in_creative_inventory=1}
	ndef_on.is_ground_content = false
	ndef_on.sounds = default.node_sound_glass_defaults()

	minetest.register_node(basename.."_off", ndef_off)
	minetest.register_node(basename.."_on", ndef_on)

	power.register_nodes({basename.."_off", basename.."_on"}, Cable, "con")
	techage.register_node_for_v1_transition({basename.."_off", basename.."_on"}, function(pos, node)
		power.update_network(pos, nil, Cable)
	end)
end
