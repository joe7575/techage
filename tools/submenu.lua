--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
    A formspec control to generate formspec strings for machine settings and monitoring
]]--

local S = techage.S

local menu = {}

local function index(list, x)
	for idx, v in ipairs(list) do
		if v == x then return idx end
	end
	return nil
end


-- generate the formspec string to be placed into a container frame
local function generate_formspec_substring(pos, meta, form_def)
	local tbl = {}
	if meta and form_def then
		local nvm = techage.get_nvm(pos)
		
		for i,elem in ipairs(form_def) do
			local offs = (i - 1) * 0.9 - 0.2
			tbl[#tbl+1] = "label[0," .. offs .. ";" .. minetest.formspec_escape(elem.label) .. ":]"
			tbl[#tbl+1] = "tooltip[0," .. offs .. ";4,1;" .. elem.tooltip .. "]"
			if elem.type == "number" then
				local val = elem.default
				if meta:contains(elem.name) then
					val = meta:get_int(elem.name)
				end
				if nvm.running or techage.is_running(nvm) then
					tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. val .. "]"
				else
					tbl[#tbl+1] = "field[5," .. (offs+0.2) .. ";5.3,1;" .. elem.name .. ";;" .. val .. "]"
				end
			elseif elem.type == "numbers" then
				local val = elem.default
				if meta:contains(elem.name) then
					val = meta:get_string(elem.name)
				end
				if nvm.running or techage.is_running(nvm) then
					tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. val .. "]"
				else
					tbl[#tbl+1] = "field[5," .. (offs+0.2) .. ";5.3,1;" .. elem.name .. ";;" .. val .. "]"
				end
			elseif elem.type == "float" then
				local val = elem.default
				if meta:contains(elem.name) then
					val = tonumber(meta:get_string(elem.name)) or 0
				end
				if nvm.running or techage.is_running(nvm) then
					tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. val .. "]"
				else
					tbl[#tbl+1] = "field[5," .. (offs+0.2) .. ";5.3,1;" .. elem.name .. ";;" .. val .. "]"
				end
			elseif elem.type == "ascii" then
				local val = elem.default
				if meta:contains(elem.name) then
					val = meta:get_string(elem.name)
				end
				if nvm.running or techage.is_running(nvm) then
					tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. minetest.formspec_escape(val) .. "]"
				else
					tbl[#tbl+1] = "field[5," .. (offs+0.2) .. ";5.3,1;" .. elem.name .. ";;" .. minetest.formspec_escape(val) .. "]"
				end
			elseif elem.type == "const" then
				tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. elem.value .. "]"
			elseif elem.type == "output" then
				local val = nvm[elem.name] or ""
				if tonumber(val) then
					val = techage.round(val)
				end
				tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. val .. "]"
			elseif elem.type == "dropdown" then
				local l = elem.choices:split(",")
				if nvm.running or techage.is_running(nvm) then
					local val = elem.default
					if meta:contains(elem.name) then
						val = meta:get_string(elem.name) or ""
					end
					tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. val .. "]"
				else
					local val = elem.default
					if meta:contains(elem.name) then
						val = meta:get_string(elem.name) or ""
					end
					local idx = index(l, val) or 1
					tbl[#tbl+1] = "dropdown[4.72," .. (offs) .. ";5.5,1.4;" .. elem.name .. ";" .. elem.choices .. ";" .. idx .. "]"
				end
			end
		end
		if nvm.running or techage.is_running(nvm) then
			local offs = #form_def * 0.9 - 0.2
			tbl[#tbl+1] = "label[0," .. offs .. ";" .. S("Note: You can't change any values while the block is running!") .. "]"
		end
	end
	return table.concat(tbl, "")
end

local function value_check(elem, value)
	if elem.check then
		return elem.check(value)
	end
	return true
end
	
local function evaluate_data(pos, meta, form_def, fields)
	local res = true
	
	if meta and form_def then
		local nvm = techage.get_nvm(pos)
		if nvm.running or techage.is_running(nvm) then
			return res
		end
		for idx,elem in ipairs(form_def) do
			if elem.type == "number" then	
				if fields[elem.name] then
					if fields[elem.name]:find("^[%d ]+$") then
						local val = tonumber(fields[elem.name])
						if value_check(elem, val) then 
							meta:set_int(elem.name, val)
							--print("set_int", elem.name, val)
						else
							res = false
						end
					else
						res = false
					end
				end
			elseif elem.type == "numbers" then	
				if fields[elem.name] then
					if fields[elem.name]:find("^[%d ]+$") and value_check(elem, fields[elem.name]) then 
						meta:set_string(elem.name, fields[elem.name])
					else
						res = false
					end
				end
			elseif elem.type == "float" then
				if fields[elem.name] then
					local val = tonumber(fields[elem.name])
					if val and value_check(elem, val) then 
						meta:set_string(elem.name, val)
					else
						res = false
					end
				end
			elseif elem.type == "ascii" then	
				if fields[elem.name] then
					if value_check(elem, fields[elem.name]) then
						meta:set_string(elem.name, fields[elem.name])
					else
						res = false
					end
				end
			elseif elem.type == "dropdown" then	
				if fields[elem.name] ~= nil then
					meta:set_string(elem.name, fields[elem.name])
				end
			end
		end
	end
	return res
end

function menu.generate_formspec(pos, ndef, form_def)
	local meta = minetest.get_meta(pos)
	local number = techage.get_node_number(pos)
	local mem = techage.get_mem(pos)
	mem.star = ((mem.star or 0) + 1) % 2
	local star = mem.star == 1 and "*" or ""
	
	if meta and number and ndef and form_def then
		local title = ndef.description .. " (" .. number .. ")"
	
		return "size[10,9]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			default.gui_slots ..
			"box[0,-0.1;9.8,0.5;#c6e8ff]" ..
			"label[0.2,-0.1;" .. minetest.colorize( "#000000", title) .. "]" ..
		    "label[9.5,-0.1;" .. minetest.colorize( "#000000", star) .. "]" ..
			"container[0,1]" ..
			generate_formspec_substring(pos, meta, form_def) ..
			"container_end[]" ..
			"button[0.5,8.4;3,1;refresh;" .. S("Refresh") .. "]" ..
			"button_exit[3.5,8.4;3,1;cancel;" .. S("Cancel") .. "]" ..
			"button[6.5,8.4;3,1;save;" .. S("Save") .. "]"
	end
	return ""
end

function menu.eval_input(pos, ndef, form_def, fields)	
	--print(dump(fields))
	if fields.save then
		local meta = minetest.get_meta(pos)
		evaluate_data(pos, meta, form_def, fields)
	end
	return fields.refresh or fields.save
end

return menu