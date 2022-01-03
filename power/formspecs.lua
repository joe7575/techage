--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Power Formspec Functions

]]--

--local P2S = minetest.pos_to_string
--local M = minetest.get_meta
--local N = function(pos) return minetest.get_node(pos).name end
local S = techage.S

local CYCLE_TIME = 2
local CYCLES_PER_DAY = 20 * 60 / CYCLE_TIME

local in_range = techage.in_range
local power = networks.power
techage.power = {}

-------------------------------------------------------------------------------
-- Helper function
-------------------------------------------------------------------------------
local function round(val)
	if val > 100 then
		return math.floor(val + 0.5)
	elseif val > 10 then
		return math.floor((val * 10) + 0.5) / 10
	else
		return math.floor((val * 100) + 0.5) / 100
	end
end

local function calc_percent(max_val, curr_val)
	return round(math.min(((curr_val or 0) * 100) / (max_val or 1.0), 100))
end

-------------------------------------------------------------------------------
-- Local bar functions
-------------------------------------------------------------------------------
-- charging > 0 ==> charging
-- charging < 0 ==> uncharging
-- charging = 0 ==> off
-- percent: 0..100
local function charging_bar(charging, percent)
	if charging > 0 then
		return "techage_form_level_off.png^[lowpart:" .. percent .. ":techage_form_level_charge.png"
	elseif charging < 0 then
		return "techage_form_level_unload.png^[lowpart:" .. percent .. ":techage_form_level_off.png"
	else
		return "techage_form_level_off.png"
	end
end

local function power_bar(current_power, max_power)
	local percent, ypos

	current_power = current_power or 0

	if current_power == 0 then
		percent = 0
		ypos = 2.8
	else
		percent = calc_percent(max_power, current_power)
		-- 0.4 to 2.8 = 2.4
		local offs = 2.4 - (current_power / max_power) * 2.4
		ypos = 0.4 + in_range(offs, 0.4, 2.4)
	end
	current_power = round(current_power)
	max_power = round(max_power)
	percent = (percent + 5) / 1.1  -- texture correction

	return "label[0.7,0.4;" .. max_power .. " ku]" ..
		"image[0,0.5;1,3;" ..
		"techage_form_level_bg.png^[lowpart:" .. percent ..
		":techage_form_level_fg.png]" ..
		"label[0.7," .. ypos .. ";" .. current_power .. " ku]"
end

local function storage_bar(current_power, max_power)
	local percent, ypos
	max_power = (max_power or 1) / CYCLES_PER_DAY
	current_power = (current_power or 0) / CYCLES_PER_DAY

	if current_power == 0 then
		percent = 0
		ypos = 2.8
	else
		percent = calc_percent(max_power, current_power)
		-- 0.4 to 2.8 = 2.4
		local offs = 2.4 - (current_power / max_power) * 2.4
		ypos = 0.4 + in_range(offs, 0.4, 2.4)
	end
	current_power = round(current_power)
	max_power = round(max_power)

	local percent2 = (percent + 5) / 1.1  -- texture correction
	return "label[0.7,0.4;" .. max_power .. " kud]" ..
		"image[0,0.5;1,3;"..
		"techage_form_level_bg.png^[lowpart:" .. percent2 ..
		":techage_form_level_fg.png]" ..
		"label[0.7," .. ypos .. ";" .. round(percent) .. " %]"
end

-------------------------------------------------------------------------------
-- API bar functions
-------------------------------------------------------------------------------
function techage.formspec_power_bar(pos, x, y, label, current_power, max_power)
	return "container["..x..","..y.."]"..
		"box[0,0;2.3,3.3;#395c74]"..
		"label[0.2,0;"..label.."]"..
		power_bar(current_power, max_power)..
		"container_end[]"
end

function techage.formspec_charging_bar(pos, x, y, label, data)
	local charging = 0
	local percent = 50
	local ypos = 1.6

	if data then
		charging = data.provided - data.consumed
		if charging > 0 then
			percent = 50 + (charging / data.available * 50)
			ypos = 1.6 - (charging / data.available * 1.2)
		elseif charging < 0 then
			percent = 50 + (charging / data.consumed * 50)
			ypos = 1.6 - (charging / data.consumed * 1.2)
		end
	end
	ypos = in_range(ypos, 0.4, 2.8)

	return "container[".. x .. "," .. y .. "]" ..
		"box[0,0;2.3,3.3;#395c74]" ..
		"label[0.2,0;" .. label .. "]" ..
		"image[0,0.5;1,3;" .. charging_bar(charging, percent) .. "]" ..
		"label[0.75," .. ypos .. ";" .. round(charging) .. " ku]" ..
		"container_end[]"
end

function techage.formspec_storage_bar(pos, x, y, label, curr_load, max_load)
	curr_load = curr_load or 0

	return "container[" .. x .. "," .. y .. "]" ..
		"box[0,0;2.3,3.3;#395c74]" ..
		"label[0.2,0;" .. label .. "]" ..
		storage_bar(curr_load, max_load) ..
		"container_end[]"
end

function techage.formspec_meter(pos, x, y, label, value, unit)
	return "container[" .. x .. "," .. y .. "]" ..
		"box[0,0;2.3,1.2;#395c74]" ..
		"label[0.2,0.0;" .. label .. ":]" ..
		"label[0.2,0.5;" .. round(value) .. " " .. unit .. "]" ..
		"container_end[]"
end

-------------------------------------------------------------------------------
-- API formspec functions
-------------------------------------------------------------------------------
function techage.wrench_image(x, y)
	return "image["..x.."," .. y .. ";0.5,0.5;techage_inv_wrench.png]" ..
		"tooltip["..x.."," .. y .. ";0.5,0.5;" .. S("Block has a wrench menu") .. ";#0C3D32;#FFFFFF]"
end

function techage.storage_formspec(self, pos, nvm, label, netw_data, curr_load, max_load)
	return "size[6.3,4]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"box[0,-0.1;6.1,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", label) .. "]" ..
		techage.formspec_charging_bar(pos, 0.0, 0.8, S("Charging"), netw_data) ..
		techage.formspec_storage_bar (pos, 3.8, 0.8, S("Storage"),  curr_load, max_load) ..
		"image_button[2.7,2;1,1;" .. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[2.7,2;1,1;" .. self:get_state_tooltip(nvm) .. "]"
end

function techage.generator_formspec(self, pos, nvm, label, provided, max_available, ta2)
	local tooltip = ""
	if not ta2 then
		tooltip = techage.wrench_tooltip(4.4, -0.1)
	end
	return "size[5,4]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"box[0,-0.1;4.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", label) .. "]" ..
		tooltip..
		techage.formspec_power_bar(pos, 0, 0.8, S("Power"), provided, max_available) ..
		"image_button[3.2,2.0;1,1;" .. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[3.2,2.0;1,1;" .. self:get_state_tooltip(nvm) .. "]"
end

function techage.generator_settings(tier, available)
	if tier == "ta3" then
		return {
			{
				type = "const",
				name = "available",
				label = S("Maximum output [ku]"),
				tooltip = S("The maximum power the generator can provide"),
				value = available,
			},
			{
				type = "output",
				name = "provided",
				label = S("Current output [ku]"),
				tooltip = S("The current power the generator provides"),
			},
			{
				type = "dropdown",
				choices = "0% - 20%,20% - 40%,40% - 60%,60% - 80%,80% - 100%,90% - 100%",
				name = "termpoint",
				label = S("Charge termination"),
				tooltip = S("Range in which the generator reduces its power"),
				default = "80% - 100%",
			},
		}
	else
		return {
			{
				type = "const",
				name = "available",
				label = S("Maximum output [ku]"),
				tooltip = S("The maximum power the generator can provide"),
				value = available,
			},
			{
				type = "output",
				name = "provided",
				label = S("Current output [ku]"),
				tooltip = S("The current power the generator provides"),
			},
			{
				type = "dropdown",
				choices = "0% - 20%,20% - 40%,40% - 60%,60% - 80%,80% - 100%,90% - 100%",
				name = "termpoint",
				label = S("Charge termination"),
				tooltip = S("Range in which the generator reduces its power"),
				default = "80% - 100%",
			},
		}
	end
end


function techage.evaluate_charge_termination(nvm, meta)
	local termpoint = meta:get_string("termpoint")
	if termpoint == "0% - 20%" then
		meta:set_string("termpoint1", 0.0)
		meta:set_string("termpoint2", 0.2)
	elseif termpoint == "20% - 40%" then
		meta:set_string("termpoint1", 0.2)
		meta:set_string("termpoint2", 0.4)
	elseif termpoint == "40% - 60%" then
		meta:set_string("termpoint1", 0.4)
		meta:set_string("termpoint2", 0.6)
	elseif termpoint == "60% - 80%" then
		meta:set_string("termpoint1", 0.6)
		meta:set_string("termpoint2", 0.8)
	elseif termpoint == "80% - 100%" then
		meta:set_string("termpoint1", 0.8)
		meta:set_string("termpoint2", 1.0)
	elseif termpoint == "90% - 100%" then
		meta:set_string("termpoint1", 0.9)
		meta:set_string("termpoint2", 1.0)
	else
		meta:set_string("termpoint", "80% - 100%")
		meta:set_string("termpoint1", 0.8)
		meta:set_string("termpoint2", 1.0)
	end
end

techage.power.percent =  calc_percent
techage.CYCLES_PER_DAY = CYCLES_PER_DAY
techage.round = round

-------------------------------------------------------------------------------
-- Still used legacy functions
-------------------------------------------------------------------------------
function techage.formspec_label_bar(pos, x, y, label, max_power, current_power, unit)
	local percent, ypos

	max_power = max_power or 1
	unit = unit or "ku"
	current_power = current_power or 0

	if current_power == 0 then
		percent = 0
		ypos = 2.8
	else
		percent = techage.power.percent(max_power, current_power)
		-- 0.4 to 2.8 = 2.4
		local offs = 2.4 - (current_power / max_power) * 2.4
		ypos = 0.4 + in_range(offs, 0.4, 2.4)
	end
	if current_power >= 100 then
		current_power = math.floor(current_power)
	end
	percent = (percent + 5) / 1.1  -- texture correction
	return "container["..x..","..y.."]"..
		"box[0,0;2.3,3.3;#395c74]"..
		"label[0.2,0;"..label.."]"..
		"label[0.7,0.4;"..max_power.." "..unit.."]"..
		"image[0,0.5;1,3;"..
		"techage_form_level_bg.png^[lowpart:"..percent..
		":techage_form_level_fg.png]"..
		"label[0.7,"..ypos..";"..current_power.." "..unit.."]"..
		"container_end[]"

end
