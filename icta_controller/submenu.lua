--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller - Formspec

    A sub-menu control to generate a formspec sting for conditions and actions
]]--

local function index(list, x)
	for idx, v in ipairs(list) do
		if v == x then return idx end
	end
	return nil
end

-- generate the choice dependent part of the form
local function add_controls_to_table(tbl, kvDefinition, kvSelect)
	local offs = 1.4
	if kvDefinition[kvSelect.choice] then
		local lControls = kvDefinition[kvSelect.choice].formspec
		for _,elem in ipairs(lControls) do
			if elem.type == "label" then
				tbl[#tbl+1] = "label[0,"..offs..";Description:\n"..elem.label.."]"
				offs = offs + 0.4
			elseif elem.label and elem.label ~= "" then
				tbl[#tbl+1] = "label[0,"..offs..";"..elem.label..":]"
				offs = offs + 0.4
			end
			if elem.type == "numbers" or elem.type == "number" or elem.type == "digits" or elem.type == "letters"
					or elem.type == "ascii" then
				local val = kvSelect[elem.name] or elem.default
				tbl[#tbl+1] = "field[0.3,"..(offs+0.2)..";8,1;"..elem.name..";;"..val.."]"
				offs = offs + 0.9
			elseif elem.type == "textlist" then
				local l = elem.choices:split(",")
				local val = index(l, kvSelect[elem.name]) or elem.default
				tbl[#tbl+1] = "dropdown[0.0,"..(offs)..";8.5,1.4;"..elem.name..";"..elem.choices..";"..val.."]"
				offs = offs + 0.9
			end
		end
	end
	return tbl
end

local function default_data(kvDefinition, kvSelect)
	local lControls = kvDefinition[kvSelect.choice].formspec
	for _,elem in ipairs(lControls) do
		kvSelect[elem.name] = elem.default
	end
	kvSelect.button = kvDefinition[kvSelect.choice].button(kvSelect)
	return kvSelect
end

-- Copy field/formspec data to the table kvSelect
-- kvDefinition: submenu formspec definition
-- kvSelect: form data
-- fields: formspec input
local function field_to_kvSelect(kvDefinition, kvSelect, fields)
	local error = false
	local lControls = kvDefinition[kvSelect.choice].formspec
	for _,elem in ipairs(lControls) do
		if elem.type == "numbers" then
			if fields[elem.name] then
				if fields[elem.name]:find("^[%d ]+$") then
					kvSelect[elem.name] = fields[elem.name]
				else
					kvSelect[elem.name] = elem.default
					error = true
				end
			end
		elseif elem.type == "number" then
			if fields[elem.name] then
				if fields[elem.name]:find("^[%d ]+$") then
					kvSelect[elem.name] = fields[elem.name]
				else
					kvSelect[elem.name] = elem.default
					error = true
				end
			end
		elseif elem.type == "digits" then  -- including positions
			if fields[elem.name] then
				if fields[elem.name]:find("^[+%%-,%d]+$") then
					kvSelect[elem.name] = fields[elem.name]
				else
					kvSelect[elem.name] = elem.default
					error = true
				end
			end
		elseif elem.type == "letters" then
			if fields[elem.name] then
				if fields[elem.name]:find("^[+-]?%a+$") then
					kvSelect[elem.name] = fields[elem.name]
				else
					kvSelect[elem.name] = elem.default
					error = true
				end
			end
		elseif elem.type == "ascii" then
			if fields[elem.name] then
				kvSelect[elem.name] = fields[elem.name]
			end
		elseif elem.type == "textlist" then
			if fields[elem.name] ~= nil then
				kvSelect[elem.name] = fields[elem.name]
			end
		end
	end
	-- store user input of button text
	if fields._button_ then
		kvSelect._button_ = fields._button_
	end
	-- select button text
	if error then
		kvSelect.button = "invalid"
	elseif kvSelect._button_ and kvSelect._button_ ~= "" then
		kvSelect.button = kvSelect._button_
	else
		kvSelect.button = kvDefinition[kvSelect.choice].button(kvSelect)
	end
	return kvSelect
end

function techage.submenu_verify(owner, kvDefinition, kvSelect)
	local error = false
	local lControls = kvDefinition[kvSelect.choice].formspec
	for _,elem in ipairs(lControls) do
		if elem.type == "numbers" then
			if not kvSelect[elem.name]:find("^[%d ]+$") then
				error = true
			end
			if not techage.check_numbers(kvSelect[elem.name], owner) then
				error = true
			end
		elseif elem.type == "number" then
			if not kvSelect[elem.name]:find("^[%d]+$") then
				error = true
			end
			if not techage.check_numbers(kvSelect[elem.name], owner) then
				error = true
			end
		elseif elem.type == "digits" then  -- including positions
			if not kvSelect[elem.name]:find("^[+%%-,%d]+$") then
				error = true
			end
		elseif elem.type == "letters" then
			if not kvSelect[elem.name]:find("^[+-]?%a+$") then
				error = true
			end
		elseif elem.type == "ascii" then
			if kvSelect[elem.name] == "" or kvSelect[elem.name] == nil then
				error = true
			end
		elseif elem.type == "textlist" then
			if kvSelect[elem.name] == "" or kvSelect[elem.name] == nil then
				error = true
			end
		end
	end
	return (error == false)
end

-- generate a formspec string from the given control definition
-- row, col: numbers to identify the control
-- title: Title text for the control
-- lKeys: list of keywords of selected choices according to fields
-- lChoice: list of possible choices for the control
-- kvDefinition: definitions of the choice dependent controls
-- kvSelect: data of the last selected item {choice, number, value, ...}
function techage.submenu_generate_formspec(row, col, title, lKeys, lChoice, kvDefinition, kvSelect)
	if kvSelect == nil or next(kvSelect) == nil then
		kvSelect = {choice = "default"}
	end
	local tbl = {"size[8.2,9]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"field[0,0;0,0;_row_;;"..row.."]"..
		"field[0,0;0,0;_col_;;"..col.."]"}

	local sChoice = table.concat(lChoice, ",")
	local idx = index(lKeys, kvSelect.choice) or 1
	tbl[#tbl+1] = "label[0,0;"..title..":]"
	tbl[#tbl+1] = "dropdown[0,0.5;8.5,1;choice;"..sChoice..";"..idx.."]"
	tbl = add_controls_to_table(tbl, kvDefinition, kvSelect)
	tbl[#tbl+1] = "field[0.2,8.7;4,1;_button_;Alternative button text;"..(kvSelect._button_ or "").."]"
	tbl[#tbl+1] = "button[4,8.4;2,1;_cancel_;cancel]"
	tbl[#tbl+1] = "button[6,8.4;2,1;_exit_;ok]"
	return table.concat(tbl)
end


-- return the selected and configured menu item	based on user inputs (fields)
function techage.submenu_eval_input(kvDefinition, lKeys, lChoice, kvSelect, fields)
	-- determine selected choice
	if fields.choice then
		-- load with default values
		local idx = index(lChoice, fields.choice) or 1
		kvSelect = {choice = lKeys[idx]}
		kvSelect = default_data(kvDefinition, kvSelect)
		kvSelect = field_to_kvSelect(kvDefinition, kvSelect, fields)
	else
		-- add real data
		kvSelect = field_to_kvSelect(kvDefinition, kvSelect, fields)
	end
	return kvSelect
end
