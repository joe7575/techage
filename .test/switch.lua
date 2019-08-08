-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local Cable = techage.ElectricCable
local power_switched = techage.power.power_switched
	
local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	
	mem.interrupted_dirs = mem.interrupted_dirs or {}
	mem.interrupted = not mem.interrupted
	--print("switch", mem.interrupted)
	if mem.interrupted then 
		mem.interrupted_dirs = {true, true, true, true, true, true}
		for dir,_ in pairs(mem.connections) do
			mem.interrupted_dirs[dir] = false
			power_switched(pos)
			mem.interrupted_dirs[dir] = true
		end
	else
		mem.interrupted_dirs = {}
		power_switched(pos)
	end
end


minetest.register_node("techage:switch", {
	description = "Switch",
	tiles = {'techage_appl_switch_inv.png'},
	--on_timer = node_timer,
	on_rightclick = on_rightclick,

	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power2.register_node({"techage:switch"}, {
	power_network  = Cable,
})
