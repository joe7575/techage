-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local CYCLE_TIME = 2
local PWR_CAPA = 15

local Cable = techage.ElectricCable
local provide_power = techage.power2.provide_power

local function node_timer(pos, elapsed)
	--print("node_timer source "..S(pos))
	local mem = tubelib2.get_mem(pos)
	if mem.generating then
		local delivered = provide_power(pos, PWR_CAPA)
		return true
	end
	return false
end

local function on_rightclick(pos, node, clicker)
	local mem = tubelib2.get_mem(pos)
	if not mem.generating then
		mem.generating = true
		node_timer(pos, 2)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	else
		minetest.get_node_timer(pos):stop()
		mem.generating = false
	end
	techage.power2.power_switched(pos)
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
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
})

techage.power2.register_node({"techage:source"}, {
	power_network  = Cable,
})
