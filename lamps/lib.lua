-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local POWER_CONSUMPTION = 0.5

local Power = techage.ElectricCable

-- Input data to generate the Param2ToDir table
local Input = {
	8,9,10,11,    -- 1
	16,17,18,19,  -- 2
	4,5,6,7,      -- 3
	12,13,14,15,  -- 4
	0,1,2,3,      -- 5
	20,21,22,23,  -- 6
}

local Param2Dir = {}
for idx,val in ipairs(Input) do
	Param2Dir[val] = math.floor((idx - 1) / 4) + 1
end

local function rotate(param2)
	local offs = math.floor(param2 / 4) * 4
	local rot = ((param2 % 4) + 1) % 4
	return offs + rot
end

local function swap_node(pos, postfix)
	local node = techage.get_node_lvm(pos)
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

local function on_rotate(pos, node, user, mode, new_param2)
	if minetest.is_protected(pos, user:get_player_name()) then
		return false
	end
	node.param2 = rotate(node.param2)
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
	return {tubelib2.Turn180Deg[Param2Dir[node.param2] or 1]}
end

function techage.register_lamp(basename, ndef_off, ndef_on)
	ndef_off.on_construct = tubelib2.init_mem
	ndef_off.on_rightclick = lamp_on_rightclick
	ndef_off.on_rotate = on_rotate
	ndef_off.on_place = on_place
	ndef_off.paramtype = "light"
	ndef_off.light_source = 0
	ndef_off.sunlight_propagates = true
	ndef_off.paramtype2 = "facedir"
	ndef_off.groups = {choppy=2, cracky=2, crumbly=2}
	ndef_off.is_ground_content = false
	ndef_off.sounds = default.node_sound_glass_defaults()
	
	ndef_on.on_construct = tubelib2.init_mem
	ndef_on.on_rightclick = lamp_on_rightclick
	ndef_on.on_rotate = on_rotate
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
		on_power_pass1 = on_power_pass1,
		on_power_pass2 = on_power_pass2,
		power_network  = Power,
		conn_sides = determine_power_side,  -- will be handled by clbk function
	})
end
