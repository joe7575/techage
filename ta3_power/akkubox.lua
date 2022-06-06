--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Accu Box

]]--

-- for lazy programmers
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 2
local PWR_CAPA = 2000

local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control
local in_range = techage.in_range


local function formspec(self, pos, nvm)
	local data

	if nvm.running then
		local outdir = M(pos):get_int("outdir")
		data = power.get_network_data(pos, Cable, outdir)
	end
	return techage.storage_formspec(self, pos, nvm, S("TA3 Akku Box"), data, nvm.capa, PWR_CAPA)
end

local function start_node(pos, nvm, state)
	nvm.running = true
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
end

local function stop_node(pos, nvm, state)
	nvm.running = false
	local outdir = M(pos):get_int("outdir")
	power.start_storage_calc(pos, Cable, outdir)
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
	local nvm = techage.get_nvm(pos)
	if nvm.running then
		local outdir = M(pos):get_int("outdir")
		local capa = power.get_storage_load(pos, Cable, outdir, PWR_CAPA) or 0
		if capa > 0 then
			nvm.capa = capa
		end
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
	return true
end

local function on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

local function get_storage_data(pos, outdir, tlib2)
	local nvm = techage.get_nvm(pos)
	if nvm.running then
		return {level = (nvm.capa or 0) / PWR_CAPA, capa = PWR_CAPA}
	end
end

local function get_capa(itemstack)
	local meta = itemstack:get_meta()
	if meta then
		return in_range(meta:get_int("capa") * (PWR_CAPA/100), 0, 3000)
	end
	return 0
end

local function set_capa(pos, oldnode, oldmetadata, drops)
	local nvm = techage.get_nvm(pos)
	local capa = nvm.capa
	local meta = drops[1]:get_meta()
	capa = techage.power.percent(PWR_CAPA, capa)
	capa = (math.floor((capa or 0) / 5)) * 5
	meta:set_int("capa", capa)
	local text = S("TA3 Accu Box").." ("..capa.." %)"
	meta:set_string("description", text)
end

local function after_place_node(pos, placer, itemstack)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local own_num = techage.add_node(pos, "techage:ta3_akku")
	meta:set_string("owner", placer:get_player_name())
	meta:set_string("infotext", S("TA3 Accu Box").." "..own_num)
	local outdir = networks.side_to_outdir(pos, "R")
	meta:set_int("outdir", outdir)
	meta:set_string("formspec", formspec(State, pos, nvm))
	Cable:after_place_node(pos, {outdir})
	State:node_init(pos, nvm, own_num)
	nvm.capa = get_capa(itemstack)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	local outdir = tonumber(oldmetadata.fields.outdir or 0)
	Cable:after_dig_node(pos, {outdir})
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

minetest.register_node("techage:ta3_akku", {
	description = S("TA3 Accu Box"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole_electric.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_source.png",
	},

	on_timer = node_timer,
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	get_storage_data = get_storage_data,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	preserve_metadata = set_capa,
})

power.register_nodes({"techage:ta3_akku"}, Cable, "sto", {"R"})

-- for logical communication
techage.register_node({"techage:ta3_akku"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "load" then
			return techage.power.percent(PWR_CAPA, nvm.capa)
		else
			return State:on_receive_message(pos, topic, payload)
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 134 then  -- load
			return 0, {math.floor(techage.power.percent(PWR_CAPA, nvm.capa) + 0.5)}
		else
			return State:on_beduino_request_data(pos, topic, payload)
		end
	end,
})

control.register_nodes({"techage:ta3_akku"}, {
		on_receive = function(pos, tlib2, topic, payload)
		end,
		on_request = function(pos, tlib2, topic)
			if topic == "info" then
				local nvm = techage.get_nvm(pos)
				return {
					type = S("TA3 Accu Box"),
					number = M(pos):get_string("node_number") or "",
					running = nvm.running or false,
					capa = PWR_CAPA ,
					load = nvm.capa or 0,
				}
			end
			return false
		end,
	}
)

minetest.register_craft({
	output = "techage:ta3_akku",
	recipe = {
		{"default:tin_ingot", "default:tin_ingot", "default:wood"},
		{"default:copper_ingot", "default:copper_ingot", "techage:electric_cableS"},
		{"techage:iron_ingot", "techage:iron_ingot", "default:wood"},
	},
})
