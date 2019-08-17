-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local PWR_NEEDED = 5
local CYCLE_TIME = 4

local Cable = techage.ElectricCable
local power = techage.power

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function on_power(pos, mem)
	mydbg("dbg", "on_power")
	if mem.running then
		swap_node(pos, "techage:sink_on")
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		M(pos):set_string("infotext", "on")
	end
end

local function on_nopower(pos, mem)
	mydbg("dbg", "on_nopower")
	swap_node(pos, "techage:sink")
	M(pos):set_string("infotext", "nopower")
end

local function node_timer(pos, elapsed)
	--print("node_timer sink "..S(pos))
	local mem = tubelib2.get_mem(pos)
	power.consumer_alive(pos, mem)
	return mem.running
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.running and power.power_available(pos, mem, PWR_NEEDED) then
		mem.running = true
		mydbg("dbg", "turn on")
		--swap_node(pos, "techage:sink_on")
		power.consumer_start(pos, mem, CYCLE_TIME, PWR_NEEDED)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		M(pos):set_string("infotext", "on")
	else
		mem.running = false
		mydbg("dbg", "turn off")
		swap_node(pos, "techage:sink")
		power.consumer_stop(pos, mem)
		minetest.get_node_timer(pos):stop()
		M(pos):set_string("infotext", "off")
	end
end


minetest.register_node("techage:sink", {
	description = "Sink",
	tiles = {'techage_electric_button.png'},
	
	after_place_node = function(pos)
		M(pos):set_string("infotext", "off")
	end,
	
	on_timer = node_timer,
	on_rightclick = on_rightclick,

	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:sink_on", {
	description = "Sink",
	tiles = {'techage_electric_button.png'},
	on_timer = node_timer,
	on_rightclick = on_rightclick,

	paramtype = "light",
	light_source = minetest.LIGHT_MAX,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	diggable = false,
	drop = "",
	groups = {not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:sink", "techage:sink_on"}, {
	power_network  = Cable,
	on_power = on_power,
	on_nopower = on_nopower,
})
