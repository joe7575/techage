--[[

	TechAge
	=======

	Copyright (C) 2019-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Energy storage charge detector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local Cable = techage.ElectricCable
local power = networks.power

local logic = techage.logic
local CYCLE_TIME = 8
local DESCR = S("TA4 Energy Storage Charge Detector")

local WRENCH_MENU = {
	{
		type = "numbers",
		name = "numbers",
		label = S("Number"),
		tooltip = S("Destination block number"),
		default = "",
		check = techage.check_numbers,
	},
	{
		type = "dropdown",
		choices = "10%,20%,30%,40%,50%,60%,70%,80%,90%",
		name = "switch_point",
		label = S("Switch point"),
		tooltip = S("Storage charge level switch point"),
		default = "50",
		values = {10, 20, 30, 40, 50, 60, 70, 80, 90}
	},
	{
		type = "ascii",
		name = "command1",
		label = '"<" ' .. S("Command"),
		tooltip = S("Command to send when the energy storage charge\nlevel falls below the specified switch point"),
		default = "off",
	},
	{
		type = "ascii",
		name = "command2",
		label = '">" ' .. S("Command"),
		tooltip = S("Command to send when the energy storage charge\nlevel rises above the specified switch point"),
		default = "on",
	},
}

local function switch_on(pos)
	if logic.swap_node(pos, "techage:ta4_chargedetector_on") then
		logic.send_cmnd(pos, "command2", "on")
	end
end

local function switch_off(pos)
	if logic.swap_node(pos, "techage:ta4_chargedetector_off") then
		logic.send_cmnd(pos, "command1", "off")
	end
end

local function switch_point(pos)
	local mem = techage.get_mem(pos)
	if not mem.switch_point then
		mem.switch_point = tonumber(M(pos):get_string("switch_point")) or 50
	end
	return mem.switch_point
end

local function above_switch_point(pos)
	local outdir = M(pos):get_int("outdir")
	local value = networks.power.get_storage_percent(pos, Cable, outdir)
	return value > switch_point(pos)
end

local function techage_set_numbers(pos, numbers, player_name)
	local res = logic.set_numbers(pos, numbers, player_name, DESCR)
	return res
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Cable:after_dig_node(pos)
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

local function ta_after_formspec(pos, fields, playername)
	local mem = techage.get_mem(pos)
	mem.switch_point = nil
end

minetest.register_node("techage:ta4_chargedetector_off", {
	description = DESCR,
	inventory_image = 'techage_charge_detector_inv.png',
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_charge_detector_off.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},
	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta4_chargedetector_off", DESCR)
		logic.infotext(meta, DESCR)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "B"))
		Cable:after_place_node(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_timer = function (pos, elapsed)
		if not above_switch_point(pos) then
			switch_on(pos)
		end
		return true
	end,

	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	ta_after_formspec = ta_after_formspec,
	ta4_formspec = WRENCH_MENU,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_chargedetector_on", {
	description = DESCR,
	inventory_image = 'techage_charge_detector_inv.png',
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_charge_detector_on.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},
	on_timer = function (pos, elapsed)
		if above_switch_point(pos) then
			switch_off(pos)
		end
		return true
	end,

	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,
	ta_after_formspec = ta_after_formspec,
	ta4_formspec = WRENCH_MENU,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta4_chargedetector_off"
})

minetest.register_craft({
	output = "techage:ta4_chargedetector_off",
	recipe = {
		{"", "", ""},
		{"basic_materials:plastic_sheet", "dye:blue", "techage:aluminum"},
		{"techage:ta4_wlanchip", "techage:electric_cableS", "default:copper_ingot"},
	},
})

techage.register_node({
		"techage:ta4_chargedetector_off", "techage:ta4_chargedetector_on"
	}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "state" then
				local node = techage.get_node_lvm(pos)
				if node.name == "techage:ta4_chargedetector_on" then
					return "on"
				else
					return "off"
				end
			else
				return "unsupported"
			end
		end,
		on_beduino_request_data = function(pos, src, topic, payload)
			if topic == 142 then  -- Binary State
				local node = techage.get_node_lvm(pos)
				if node.name == "techage:ta4_chargedetector_on" then
					return 0, {1}
				else
					return 0, {0}
				end
			else
				return 2, ""
			end
		end,
		on_node_load = function(pos)
			minetest.get_node_timer(pos):start(CYCLE_TIME)
		end,
	}
)

power.register_nodes({"techage:ta4_chargedetector_off", "techage:ta4_chargedetector_on"}, Cable, "con", {"B"})

