-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local CYCLE_TIME = 2
local PWR_PERF = 10
local PWR_CAPA = 300

local Cable = techage.ElectricCable
local power = techage.power

local function in_range(val, min, max)
	if val < min then return min end
	if val > max then return max end
	return val
end

local function formspec(pos, mem)
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[0,0.5;1,2;"..techage.power.formspec_power_bar(PWR_CAPA, mem.capa or 0).."]"..
		"label[0.2,2.5;Load]"..
		"button[1.1,1;1.8,1;update;Update]"..
		"image[4,0.5;1,2;"..techage.power.formspec_load_bar(-(mem.delivered or 0), PWR_PERF).."]"..
		"label[4.2,2.5;Flow]"
end

local function node_timer(pos, elapsed)
	--print("node_timer akku "..S(pos))
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		mem.delivered = power.secondary_alive(pos, mem, mem.capa, PWR_CAPA)
		--print("provided", mem.delivered)
		mem.capa = mem.capa - mem.delivered
		mem.capa = in_range(mem.capa, 0, PWR_CAPA)
	end
	return mem.running
end


local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	local mem = tubelib2.get_mem(pos)
	techage.power.network_changed(pos, mem)
	
	if fields.update then
		M(pos):set_string("formspec", formspec(pos, mem))
	end
end

local function after_place_node(pos, placer)
	local mem = tubelib2.get_mem(pos)
	mem.running = true
	mem.capa = 0
	minetest.get_node_timer(pos):start(CYCLE_TIME)
	power.secondary_start(pos, mem, PWR_PERF, PWR_PERF)
	M(pos):set_string("formspec", formspec(pos, mem))
end


minetest.register_node("techage:akku", {
	description = "Akku",
	tiles = {
		-- up, down, right, left, back, front
		'techage_electric_button.png^techage_appl_source.png',
		'techage_electric_button.png^techage_appl_source.png',
		'techage_electric_button.png^techage_appl_source.png^techage_electric_plug.png',
		'techage_electric_button.png^techage_appl_source.png',
		'techage_electric_button.png^techage_appl_source.png',
		'techage_electric_button.png^techage_appl_source.png',
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	after_place_node = after_place_node,
	on_receive_fields = on_receive_fields,
	on_timer = node_timer,
})

techage.power.register_node({"techage:akku"}, {
	power_network  = Cable,
})
