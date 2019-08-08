-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local PWR_NEEDED = 5
local CYCLE_TIME = 4

local Cable = techage.ElectricCable
local consume_power = techage.power.consume_power

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

	
local function on_power(pos)
	local mem = tubelib2.get_mem(pos)
	--print("sink on_power", mem.running)
	mem.timer_running = (mem.timer_running or 1) - 1
	if mem.running and mem.timer_running >= 0 then
		local got = consume_power(pos, PWR_NEEDED)
		if got < PWR_NEEDED then
			swap_node(pos, "techage:sink")
		else
			swap_node(pos, "techage:sink_on")
			mem.power_available = true
		end
	end
end

local function node_timer(pos, elapsed)
	--print("node_timer sink "..S(pos))
	local mem = tubelib2.get_mem(pos)
	if mem.running and not mem.power_available then
		--print("sink not triggered")
		swap_node(pos, "techage:sink")
	end
	mem.power_available = false
	mem.timer_running = CYCLE_TIME/2 + 1
	return true
end


local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.running then
		mem.running = true
		node_timer(pos, 2)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	else
		swap_node(pos, "techage:sink")
		minetest.get_node_timer(pos):stop()
		mem.running = false
	end
end


minetest.register_node("techage:sink", {
	description = "Sink",
	tiles = {'techage_electric_button.png'},
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
})
