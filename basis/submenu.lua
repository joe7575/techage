--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

    A formspec control to generate formspec strings for machine settings and monitoring
]]--

local S = techage.S

techage.menu = {}

local function index(list, x)
	for idx, v in ipairs(list) do
		if v == x then return idx end
	end
	return nil
end

local function allow_put(inv, listname, index, stack, player)
	local list = inv:get_list(listname)
	stack:set_count(1)
	inv:set_stack(listname, index, stack)
	return 0
end

local function allow_take(inv, listname, index, stack, player)
	local list = inv:get_list(listname)
	stack:set_count(0)
	inv:set_stack(listname, index, stack)
	return 0
end


-- generate the formspec string to be placed into a container frame
local function generate_formspec_substring(pos, meta, form_def, player_name)
	local tbl = {}
	local player_inv_needed = false
	if meta and form_def then
		local nvm = techage.get_nvm(pos)

		for i,elem in ipairs(form_def) do
			local offs = (i - 1) * 0.9 - 0.2
			tbl[#tbl+1] = "label[0," .. offs .. ";" .. minetest.formspec_escape(elem.label) .. ":]"
			tbl[#tbl+1] = "tooltip[0," .. offs .. ";4,1;" .. elem.tooltip .. "]"
			if elem.type == "label" then
				-- none
			elseif elem.type == "number" then
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
				local val = nvm[elem.name] or meta:get_string(elem.name) or ""
				if tonumber(val) then
					val = techage.round(val)
				end
				tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. val .. "]"
			elseif elem.type == "dropdown" then
				local l = elem.choices:split(",")
				if nvm.running or techage.is_running(nvm) then
					local val = elem.default or ""
					if meta:contains(elem.name) then
						val = meta:get_string(elem.name) or ""
					end
					tbl[#tbl+1] = "label[4.75," .. offs .. ";" .. val .. "]"
				elseif elem.on_dropdown then -- block provides a specific list of choice elements
					local val = elem.default
					if meta:contains(elem.name) then
						val = meta:get_string(elem.name) or ""
					end
					local choices = elem.on_dropdown(pos)
					local l = choices:split(",")
					local idx = index(l, val) or 1
					tbl[#tbl+1] = "dropdown[4.72," .. (offs) .. ";5.5,1.4;" .. elem.name .. ";" .. choices .. ";" .. idx .. "]"
				else
					local val = elem.default
					if meta:contains(elem.name) then
						val = meta:get_string(elem.name) or ""
					end
					local idx = index(l, val) or 1
					tbl[#tbl+1] = "dropdown[4.72," .. (offs) .. ";5.5,1.4;" .. elem.name .. ";" .. elem.choices .. ";" .. idx .. "]"
				end
			elseif elem.type == "items" then  -- inventory
				tbl[#tbl+1] = "list[detached:" .. minetest.formspec_escape(player_name) .. "_techage_wrench_menu;cfg;4.75," .. offs .. ";" .. elem.size .. ",1;]"
				player_inv_needed = true
			end
		end
		if nvm.running or techage.is_running(nvm) then
			local offs = #form_def * 0.9 - 0.2
			tbl[#tbl+1] = "label[0," .. offs .. ";" .. S("Note: You can't change any values while the block is running!") .. "]"
		end
	end

	return player_inv_needed, table.concat(tbl, "")
end

local function value_check(elem, value)
	if elem.check then
		return elem.check(value)
	end
	return value ~= nil
end

local function evaluate_data(pos, meta, form_def, fields, player_name)
	local res = true

	if meta and form_def then
		local nvm = techage.get_nvm(pos)
		if nvm.running or techage.is_running(nvm) then
			return res
		end
		for idx,elem in ipairs(form_def) do
			if elem.type == "number" then
				if fields[elem.name] then
					if fields[elem.name] == "" then
						meta:set_string(elem.name, "")
					elseif fields[elem.name]:find("^[%d ]+$") then
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
					if fields[elem.name] == "" then
						meta:set_string(elem.name, "")
					elseif fields[elem.name]:find("^[%d ]+$") and value_check(elem, fields[elem.name]) then
						meta:set_string(elem.name, fields[elem.name])
					else
						res = false
					end
				end
			elseif elem.type == "float" then
				if fields[elem.name] == ""then
					meta:set_string(elem.name, "")
				elseif fields[elem.name] then
					local val = tonumber(fields[elem.name])
					if val and value_check(elem, val) then
						meta:set_string(elem.name, val)
					else
						res = false
					end
				end
			elseif elem.type == "ascii" then
				if fields[elem.name] == ""then
					meta:set_string(elem.name, "")
				elseif fields[elem.name] then
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
			elseif elem.type == "items" and player_name then
				local inv_name = minetest.formspec_escape(player_name) .. "_techage_wrench_menu"
				local dinv = minetest.get_inventory({type = "detached", name = inv_name})
				local ninv = minetest.get_inventory({type = "node", pos = pos})
				if dinv and ninv then
					for i = 1, ninv:get_size("cfg") do
						ninv:set_stack("cfg", i, dinv:get_stack("cfg", i))
					end
				end
			end
		end
	end
	return res
end

function techage.menu.generate_formspec(pos, ndef, form_def, player_name)
	local meta = minetest.get_meta(pos)
	local number = techage.get_node_number(pos) or "-"
	local mem = techage.get_mem(pos)
	mem.star = ((mem.star or 0) + 1) % 2
	local star = mem.star == 1 and "*" or ""
	if player_name then
		local inv_name = minetest.formspec_escape(player_name) .. "_techage_wrench_menu"
		minetest.create_detached_inventory(inv_name, {
			allow_put = allow_put,
			allow_take = allow_take})
		local dinv = minetest.get_inventory({type = "detached", name = inv_name})
		local ninv = minetest.get_inventory({type = "node", pos = pos})
		if dinv and ninv then
			dinv:set_size('cfg', ninv:get_size("cfg"))
			for i = 1, ninv:get_size("cfg") do
				dinv:set_stack("cfg", i, ninv:get_stack("cfg", i))
			end
		end
	end
	if meta and number and ndef and form_def then
		local title = ndef.description .. " (" .. number .. ")"
		local player_inv_needed, text = generate_formspec_substring(pos, meta, form_def, player_name)
		local buttons

		if player_inv_needed then
			buttons = "button[0.5,6.2;3,1;refresh;" .. S("Refresh") .. "]" ..
				"button_exit[3.5,6.2;3,1;cancel;" .. S("Cancel") .. "]" ..
				"button[6.5,6.2;3,1;save;" .. S("Save") .. "]" ..
				"list[current_player;main;1,7.2;8,2;]"
		else
			buttons = "button[0.5,8.4;3,1;refresh;" .. S("Refresh") .. "]" ..
				"button_exit[3.5,8.4;3,1;cancel;" .. S("Cancel") .. "]" ..
				"button[6.5,8.4;3,1;save;" .. S("Save") .. "]"
		end

		if #form_def > 8 then
			local size = (#form_def * 10) - 60
			return "size[10,9]" ..
				default.gui_bg ..
				default.gui_bg_img ..
				default.gui_slots ..
				"box[0,-0.1;9.8,0.5;#c6e8ff]" ..
				"label[0.2,-0.1;" .. minetest.colorize( "#000000", title) .. "]" ..
				"label[9.5,-0.1;" .. minetest.colorize( "#000000", star) .. "]" ..
				"scrollbaroptions[max=" .. size .. "]" ..
				"scrollbar[9.4,0.6;0.4,7.7;vertical;wrenchmenu;]" ..
				"scroll_container[0,1;12,9;wrenchmenu;vertical;]" ..
				text ..
				"scroll_container_end[]" ..
				buttons
		else
			return "size[10,9]" ..
				default.gui_bg ..
				default.gui_bg_img ..
				default.gui_slots ..
				"box[0,-0.1;9.8,0.5;#c6e8ff]" ..
				"label[0.2,-0.1;" .. minetest.colorize( "#000000", title) .. "]" ..
				"label[9.5,-0.1;" .. minetest.colorize( "#000000", star) .. "]" ..
				"container[0,1]" ..
				text ..
				"container_end[]" ..
				buttons
		end
	end
	return ""
end

function techage.menu.eval_input(pos, form_def, fields, player_name)
	if fields.save or fields.key_enter_field then
		local meta = minetest.get_meta(pos)
		evaluate_data(pos, meta, form_def, fields, player_name)
	end
	return fields.refresh or fields.save or fields.key_enter_field
end
