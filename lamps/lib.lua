-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local PWR_NEEDED = 0.5
local CYCLE_TIME = 4

local Cable = techage.ElectricCable
local consume_power = techage.power.consume_power
local power_available = techage.power.power_available

local function swap_node(pos, postfix)
	local node = techage.get_node_lvm(pos)
	local parts = string.split(node.name, "_")
	if postfix == parts[2] then
		return
	end
	node.name = parts[1].."_"..postfix
	minetest.swap_node(pos, node)
end

local function on_power(pos)
	local mem = tubelib2.get_mem(pos)
	if mem.turned_on then
		local got = consume_power(pos, PWR_NEEDED)
		if got < PWR_NEEDED and mem.node_on then
			swap_node(pos, "off")
			mem.node_on = false
		elseif not mem.node_on then
			swap_node(pos, "on")
			mem.node_on = true
		end
		mem.trigger = true
	end
end

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.node_on and not mem.trigger then
		mem.node_on = false
		swap_node(pos, "off")
	end
	mem.trigger = false
	return mem.turned_on
end

local function lamp_on_rightclick(pos, node, clicker)
	if minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	mem.turned_on = not mem.turned_on 
	if mem.turned_on and power_available(pos, PWR_NEEDED) then
		mem.node_on = true
		swap_node(pos, "on")
		mem.trigger = true
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	elseif mem.turned_on then
		mem.node_on = false
		swap_node(pos, "off")
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	else
		mem.node_on = false
		swap_node(pos, "off")
		minetest.get_node_timer(pos):stop()
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

local function determine_power_side(pos, node)
	return {techage.determine_node_bottom_as_dir(node)}
end

function techage.register_lamp(basename, ndef_off, ndef_on)
	ndef_off.on_construct = tubelib2.init_mem
	ndef_off.on_rightclick = lamp_on_rightclick
	if not ndef_off.on_rotate then
		ndef_off.on_place = on_place
	end
	ndef_off.on_rotate = ndef_off.on_rotate or on_rotate
	ndef_off.on_timer = node_timer
	ndef_off.paramtype = "light"
	ndef_off.light_source = 0
	ndef_off.sunlight_propagates = true
	ndef_off.paramtype2 = "facedir"
	ndef_off.groups = {choppy=2, cracky=2, crumbly=2}
	ndef_off.is_ground_content = false
	ndef_off.sounds = default.node_sound_glass_defaults()
	
	ndef_on.on_construct = tubelib2.init_mem
	ndef_on.on_rightclick = lamp_on_rightclick
	ndef_on.on_rotate = ndef_on.on_rotate or on_rotate
	ndef_on.on_timer = node_timer
	ndef_on.paramtype = "light"
	ndef_on.light_source = minetest.LIGHT_MAX
	ndef_on.sunlight_propagates = true
	ndef_on.paramtype2 = "facedir"
	ndef_on.diggable = false
	ndef_on.groups = {not_in_creative_inventory=1}
	ndef_on.is_ground_content = false
	ndef_on.sounds = default.node_sound_glass_defaults()
	
	minetest.register_node(basename.."_off", ndef_off)
	minetest.register_node(basename.."_on", ndef_on)

	techage.power.register_node({basename.."_off", basename.."_on"}, {
		power_network  = Cable,
		conn_sides = ndef_off.conn_sides or determine_power_side,  -- will be handled by clbk function
		on_power = on_power,
	})
end
