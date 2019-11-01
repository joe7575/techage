--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA3 Akku Box

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2
local PWR_PERF = 10
local PWR_CAPA = 2000

local Power = techage.ElectricCable
local power = techage.power

local function in_range(val, min, max)
	if val < min then return min end
	if val > max then return max end
	return val
end

local function formspec(self, pos, mem)
	return "size[5,3]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"image[0,0.5;1,2;"..techage.power.formspec_power_bar(PWR_CAPA, mem.capa).."]"..
		"label[0.2,2.5;Load]"..
		"button[1.1,1;1.8,1;update;"..S("Update").."]"..
		"image_button[3,1;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"image[4,0.5;1,2;"..techage.power.formspec_load_bar(-(mem.delivered or 0), PWR_PERF).."]"..
		"label[4.2,2.5;Flow]"
end


local function start_node(pos, mem, state)
	mem.running = true
	mem.delivered = 0
	power.secondary_start(pos, mem, PWR_PERF, PWR_PERF)
end

local function stop_node(pos, mem, state)
	mem.running = false
	mem.delivered = 0
	power.secondary_stop(pos, mem)
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta3_akku",
	cycle_time = CYCLE_TIME,
	standby_ticks = 0,
	formspec_func = formspec,
	start_node = start_node,
	stop_node = stop_node,
})

local function node_timer(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	if mem.running then
		mem.delivered = power.secondary_alive(pos, mem, mem.capa, PWR_CAPA)
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
	State:state_button_event(pos, mem, fields)
	
	if fields.update then
		local mem = tubelib2.get_mem(pos)
		M(pos):set_string("formspec", formspec(State, pos, mem))
	end
end

local function on_rightclick(pos)
	local mem = tubelib2.get_mem(pos)
	M(pos):set_string("formspec", formspec(State, pos, mem))
end

local function get_capa(itemstack)
	local meta = itemstack:get_meta()
	if meta then
		return in_range(meta:get_int("capa") * (PWR_CAPA/100), 0, 3000)
	end
	return 0
end

local function set_capa(pos, oldnode, digger, capa)
	local node = ItemStack(oldnode.name)
	local meta = node:get_meta()
	capa = techage.power.percent(PWR_CAPA, capa)
	capa = (math.floor((capa or 0) / 5)) * 5
	meta:set_int("capa", capa)
	local text = S("TA3 Akku Box").." ("..capa.." %)"
	meta:set_string("description", text)
	local inv = minetest.get_inventory({type="player", name=digger:get_player_name()})
	local left_over = inv:add_item("main", node)
	if left_over:get_count() > 0 then
		minetest.add_item(pos, node)
	end
end

minetest.register_node("techage:ta3_akku", {
	description = S("TA3 Akku Box"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_electric.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
	},
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	drop = "", -- don't remove, item will be added via 'set_capa'
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

techage.power.register_node({"techage:ta3_akku"}, {
	conn_sides = {"R"},
	power_network  = Power,
	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		local mem = tubelib2.init_mem(pos)
		local own_num = techage.add_node(pos, "techage:ta3_akku")
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", S("TA3 Akku Box").." "..own_num)
		State:node_init(pos, mem, own_num)
		mem.capa = get_capa(itemstack)
		on_rightclick(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local mem = tubelib2.get_mem(pos)
		set_capa(pos, oldnode, digger, mem.capa)
	end,
})

-- for logical communication
techage.register_node({"techage:ta3_akku"}, {
	on_recv_message = function(pos, src, topic, payload)
		local mem = tubelib2.get_mem(pos)
		if topic == "capa" then
			return techage.power.percent(PWR_CAPA, mem.capa)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_node_load = function(pos)
		local meta = M(pos)
		if meta:get_string("node_number") == "" then
			local own_num = techage.add_node(pos, "techage:ta3_akku")
			meta:set_string("node_number", own_num)
			meta:set_string("infotext", S("TA3 Akku Box").." "..own_num)
		end
	end,
})

minetest.register_craft({
	output = "techage:ta3_akku",
	recipe = {
		{"default:tin_ingot", "default:tin_ingot", "default:wood"},
		{"default:copper_ingot", "default:copper_ingot", "techage:electric_cableS"},
		{"techage:iron_ingot", "techage:iron_ingot", "default:wood"},
	},
})
