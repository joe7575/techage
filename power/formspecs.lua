--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

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

-- Charge termination areas
local Cp2Idx = {["40% - 60%"] = 1, ["60% - 80%"] = 2, ["80% - 100%"] = 3}


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
	return math.min(((curr_val or 0) * 100) / (max_val or 1.0), 100)
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
	max_power = (max_power or 0) / CYCLES_PER_DAY
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
	local percent = 0
	local consumed = 0
	local available = 0
	
	if data then
		charging = data.provided - data.consumed
		consumed = data.consumed
		available = data.available
		if charging > 0 then
			percent = 50 + (charging / data.available * 50)
		elseif charging < 0 then
			percent = 50 + (charging / data.consumed * 50)
		end
	end
	
	return "container[".. x .. "," .. y .. "]" ..
		"box[0,0;2.3,3.3;#395c74]" ..
		"label[0.2,0;" .. label .. "]" ..
		"label[0.7,0.4;" .. available .. " ku]" ..
		"image[0,0.5;1,3;" .. charging_bar(charging, percent) .. "]" ..
		"label[0.7,2.8;" .. consumed .. " ku]" ..
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

function techage.formspec_charge_termination(pos, x, y, label, value, running)
	local idx = Cp2Idx[value] or 2
	value = value or 0
	
	if running then
		return "container[" .. x .. "," .. y .. "]" ..
			"box[0,0;3.2,1.5;#395c74]" ..
			"label[0.2,0;" .. label .. "]" ..
			"box[0.2,0.6;2.7,0.7;#000000]" ..
			"label[0.3,0.75;" .. value .. "]" ..
			"container_end[]"
	else
		return "container[" .. x .. "," .. y .. "]" ..
			"box[0,0;3.2,1.5;#395c74]" ..
			"label[0.2,0;" .. label .. "]" ..
			"dropdown[0.2,0.6;3.0;termpoint;40% - 60%,60% - 80%,80% - 100%;" .. idx .. "]" ..
			"container_end[]"
	end
end

-------------------------------------------------------------------------------
-- API formspec functions
-------------------------------------------------------------------------------
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

function techage.generator_formspec(self, pos, nvm, label, provided, max_available, running)
	return "size[6,4]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"box[0,-0.1;5.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", label) .. "]" ..
		techage.formspec_power_bar(pos, 0, 0.8, S("power"), provided, max_available) ..
		"image_button[3.8,2.9;1,1;" .. self:get_state_button_image(nvm) .. ";state_button;]" ..
		"tooltip[3.8,2.9;1,1;" .. self:get_state_tooltip(nvm) .. "]" ..
		techage.formspec_charge_termination(pos, 2.6, 0.8, S("Charge termination"), nvm.termpoint, running)
end

function techage.evaluate_charge_termination(nvm, fields)
	if fields.termpoint and not nvm.running then 
		nvm.termpoint = fields.termpoint
		if fields.termpoint == "40% - 60%" then 
			nvm.termpoint1 = 0.4
			nvm.termpoint2 = 0.6
		elseif fields.termpoint == "60% - 80%" then 
			nvm.termpoint1 = 0.6
			nvm.termpoint2 = 0.8
		elseif fields.termpoint == "80% - 100%" then 
			nvm.termpoint1 = 0.8
			nvm.termpoint2 = 1.0
		end
		return true
	end
end
	
techage.power.percent =  calc_percent
techage.CYCLES_PER_DAY = CYCLES_PER_DAY
techage.round = round