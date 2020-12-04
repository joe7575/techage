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
--local S = techage.S
local in_range = techage.in_range

function techage.power.percent(max_val, curr_val)
	return math.min(math.ceil(((curr_val or 0) * 100.0) / (max_val or 1.0)), 100)
end

function techage.power.formspec_load_bar(charging, max_val)
	local percent
	charging = charging or 0
	max_val = max_val or 1
	if charging ~= 0 then
		percent = 50 + math.ceil((charging * 50.0) / max_val)
	end

	if charging > 0 then
		return "techage_form_level_off.png^[lowpart:"..percent..":techage_form_level_charge.png"
	elseif charging < 0 then
		return "techage_form_level_unload.png^[lowpart:"..percent..":techage_form_level_off.png"
	else
		return "techage_form_level_off.png"
	end
end

function techage.power.formspec_power_bar(max_power, current_power)
	if (current_power or 0) == 0 then
		return "techage_form_level_bg.png"
	end
	local percent = techage.power.percent(max_power, current_power)
	percent = (percent + 5) / 1.22  -- texture correction
	return "techage_form_level_bg.png^[lowpart:"..percent..":techage_form_level_fg.png"
end

function techage.power.formspec_label_bar(pos, x, y, label, max_power, current_power, unit)
	local percent, ypos
	
	max_power = max_power or 1
	unit = unit or "ku"
	
	if current_power == 0 then
		-- check if power network is overloaded
		 if techage.power.network_overloaded(pos, techage.ElectricCable) then
			return "container["..x..","..y.."]"..
				"box[0,0;2.3,3.3;#395c74]"..
				"label[0.2,0;"..label.."]"..
				"label[0.7,0.4;"..max_power.." "..unit.."]"..
				"image[0,0.5;1,3;techage_form_level_red_fg.png]"..
				"container_end[]"
		end 
	end
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

