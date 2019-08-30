-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local CYCLE_TIME = 2
local PWR_CAPA = 15

local Cable = techage.ElectricCable
local power = techage.power

local function node_timer(pos, elapsed)
	--print("node_timer source "..S(pos))
	local mem = tubelib2.get_mem(pos)
	if mem.generating then
		local provided = power.generator_alive(pos, mem)
		--print("provided", provided)
	end
	return mem.generating
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.generating then
		mem.generating = true
		power.generator_start(pos, mem, PWR_CAPA)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
		M(pos):set_string("infotext", "on")
	else
		mem.generating = false
		power.generator_stop(pos, mem)
		minetest.get_node_timer(pos):stop()
		M(pos):set_string("infotext", "off")
	end
end

minetest.register_node("techage:source", {
	description = "Source",
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_button.png^techage_appl_electronic_fab.png',
		'techage_electric_button.png^techage_appl_electronic_fab.png',
		'techage_electric_button.png^techage_appl_electronic_fab.png^techage_electric_plug.png',
		'techage_electric_button.png^techage_appl_electronic_fab.png',
		'techage_electric_button.png^techage_appl_electronic_fab.png',
		'techage_electric_button.png^techage_appl_electronic_fab.png',
	},
	after_place_node = function(pos)
		-- secondary 'after_place_node', called by power. Don't use tubelib2.init_mem(pos)!!!
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("infotext", "off")
	end,
	
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
})

techage.power.register_node({"techage:source"}, {
	power_network  = Cable,
})
