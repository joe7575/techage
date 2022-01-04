--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg
	Copyright (C) 2020 Thomas S.

	AGPL v3
	See LICENSE.txt for more information

	Electricity powered battery for Digtron

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4
local INV_SIZE = 4
local FUEL = "default:coal_lump"
local FUEL_STACK_MAX = ItemStack(FUEL):get_stack_max()
local TOTAL_MAX = INV_SIZE * FUEL_STACK_MAX

local function count_coal(metadata)
	local total = 0
	for _,stack in pairs(metadata.inventory.fuel) do
		total = total + stack:get_count()
	end
	return total
end

local function formspec(self, pos, nvm)
	local meta = M(pos):to_table()
	local total = 0
	if meta.inventory then
		total = count_coal(meta)
	end
	return "size[5,4]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			"box[0,-0.1;4.8,0.5;#c6e8ff]"..
			"label[1,-0.1;"..minetest.colorize("#000000", S("Digtron Battery")).."]"..
			techage.formspec_label_bar(pos, 0, 0.8, S("Load"), TOTAL_MAX, total, S("Coal Equivalents"))..
			"image_button[2.6,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
			"tooltip[2.6,2;1,1;"..self:get_state_tooltip(nvm).."]"..
			"image[3.75,2;1,1;"..techage.get_power_image(pos, nvm).."]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	return 0
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	return 0
end

local function produce_coal(pos, crd, nvm, inv)
	local stack = ItemStack(FUEL)
	if inv:room_for_item("fuel", stack) then
		inv:add_item("fuel", stack)
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
	else
		crd.State:idle(pos, nvm)
	end
end

local function keep_running(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	produce_coal(pos, crd, nvm, inv)

	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
	end
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	CRD(pos).State:state_button_event(pos, nvm, fields)
end


local tiles = {}
-- '#' will be replaced by the stage number
-- '{power}' will be replaced by the power PNG

tiles = {
	-- up, down, right, left, back, front
	"digtron_plate.png^digtron_core.png",
	"digtron_plate.png^digtron_core.png",
	"digtron_plate.png^digtron_battery.png",
	"digtron_plate.png^digtron_battery.png",
	"digtron_plate.png^digtron_battery.png",
	"digtron_plate.png^digtron_battery.png",
}

local tubing = {
	on_recv_message = function(pos, src, topic, payload)
		return CRD(pos).State:on_receive_message(pos, topic, payload)
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 =
techage.register_consumer("digtron_battery", S("Digtron Battery"), { act = tiles, pas = tiles }, {
	drawtype = "normal",
	paramtype = "light",
	cycle_time = CYCLE_TIME,
	standby_ticks = STANDBY_TICKS,
	formspec = formspec,
	tubing = tubing,
	after_place_node = function(pos, placer, itemstack)
		local inv = M(pos):get_inventory()
		inv:set_size('fuel', INV_SIZE)
		if itemstack then
			local stack_meta = itemstack:get_meta()
			if stack_meta then
				local coal_amount = techage.in_range(stack_meta:get_int("coal"), 0, TOTAL_MAX)
				while coal_amount > 0 do
					local amount = math.min(coal_amount, FUEL_STACK_MAX)
					inv:add_item("fuel", ItemStack(FUEL.." "..amount))
					coal_amount = coal_amount - amount;
				end
			end
		end
	end,
	preserve_metadata = function(pos, oldnode, oldmetadata, drops)
		local metadata = M(pos):to_table()
		if metadata.inventory then
			local total = count_coal(metadata)
			local meta = drops[1]:get_meta()
			meta:set_int("coal", total)
			local text = S("Digtron Battery").." ("..math.floor(total/TOTAL_MAX * 100).." %)"
			meta:set_string("description", text)
		end
	end,
	on_rightclick = function(pos, node, clicker)
		techage.set_activeformspec(pos, clicker)
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", formspec(CRD(pos).State, pos, nvm))
	end,
	node_timer = keep_running,
	on_receive_fields = on_receive_fields,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	groups = {choppy=2, cracky=2, crumbly=2, digtron=5},
	sounds = default.node_sound_wood_defaults(),
	power_consumption = {0,25,25,25},
	power_sides = {L=1, R=1, U=1, D=1, F=1, B=1},
}, {false, false, true, false})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"group:wood", "default:copper_ingot", "group:wood"},
		{"techage:electric_cableS", "default:tin_ingot", "digtron:digtron_core"},
		{"group:wood", "default:copper_ingot", "group:wood"},
	},
})
