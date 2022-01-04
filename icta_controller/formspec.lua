--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller - Formspec

]]--

techage.NUM_RULES = 8

local SIZE = "size[13,8]"

local sHELP = [[ICTA Controller Help

Control other nodes by means of rules like:
    IF <condition> THEN <action>

These rules allow to execute actions based on conditions.
Examples for conditions are:
 - the Player Detector detects a player
 - a button is pressed
 - a machine is fault, blocked, standby,...

Actions are:
 - switch on/off lamps and machines
 - send chat messages to the owner
 - output a text message to the display

The controller executes all rules cyclically.
The cycle time for each rule is configurable
(1..1000 sec).
0 means, the rule will only be called, if
the controller received a command from
another blocks, such as buttons.

Actions can be delayed. Therefore, the
'after' value can be set (0..1000 sec).

Edit command examples:
 - 'x 1 8'  exchange rows 1 with row 8
 - 'c 1 2'  copy row 1 to 2
 - 'd 3'    delete row 3

The 'outp' tab is for debugging outputs via 'print'
The 'notes' tab for your notes.

The controller needs battery power to work.
The battery pack has to be placed near the
controller (1 node distance).
The needed battery power is directly dependent
on the CPU time the controller consumes.

 The Manual in German:
 https://github.com/joe7575/techage/blob/master/manuals/ta4_icta_controller_DE.md

 Or the same as PDF:
 https://github.com/joe7575/techage/blob/master/manuals/ta4_icta_controller_DE.pdf

]]

-- to simplify the search for a pressed main form button (condition/action)
local lButtonKeys = {}

for idx = 1,techage.NUM_RULES do
	lButtonKeys[#lButtonKeys+1] = "cond"..idx
	lButtonKeys[#lButtonKeys+1] = "actn"..idx
end

local function buttons(s)
	return "button_exit[7.4,7.5;1.8,1;cancel;Cancel]"..
	"button[9.3,7.5;1.8,1;save;Save]"..
	"button[11.2,7.5;1.8,1;"..s.."]"
end

function techage.formspecError(meta)
	local running = meta:get_int("state") == techage.RUNNING
	local cmnd = running and "stop;Stop" or "start;Start"
	local init = meta:get_string("init")
	init = minetest.formspec_escape(init)
	return "size[4,3]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0,0;No Battery?]"..
	"button[1,2;1.8,1;start;Start]"
end

local function button(data)
	if data then
		return data.button
	else
		return "..."
	end
end

function techage.listing(fs_data)
	local tbl = {}

	for idx = 1,techage.NUM_RULES do
		tbl[#tbl+1] = idx.." ("..fs_data[idx].cycle.."s): IF "..button(fs_data[idx].cond)
		tbl[#tbl+1] = " THEN "..button(fs_data[idx].actn).." after "..fs_data[idx].after.."s\n"
	end
	return table.concat(tbl)
end

local function formspec_rules(fs_data)
	local tbl = {"field[0,0;0,0;_type_;;main]"..
		"label[0.4,0;Cycle/s:]label[2.5,0;IF  cond:]label[7,0;THEN  action:]label[11.5,0;after/s:]"}

	for idx = 1,techage.NUM_RULES do
		local ypos = idx * 0.75 - 0.4
		tbl[#tbl+1] = "label[0,"..(0.2+ypos)..";"..idx.."]"
		tbl[#tbl+1] = "field[0.7,"..(0.3+ypos)..";1.4,1;cycle"..idx..";;"..(fs_data[idx].cycle or "").."]"
		tbl[#tbl+1] = "button[1.9,"..ypos..";4.9,1;cond"..idx..";"..minetest.formspec_escape(button(fs_data[idx].cond)).."]"
		tbl[#tbl+1] = "button[6.8,"..ypos..";4.9,1;actn"..idx..";"..minetest.formspec_escape(button(fs_data[idx].actn)).."]"
		tbl[#tbl+1] = "field[12,"..(0.3+ypos)..";1.4,1;after"..idx..";;"..(fs_data[idx].after or "").."]"
	end
	return table.concat(tbl)
end

function techage.store_main_form_data(meta, fields)
	local fs_data = minetest.deserialize(meta:get_string("fs_data"))
	for idx = 1,techage.NUM_RULES do
		fs_data[idx].cycle = fields["cycle"..idx] or ""
		fs_data[idx].after = fields["after"..idx] or "0"
	end
	meta:set_string("fs_data", minetest.serialize(fs_data))
end

function techage.main_form_button_pressed(fields)
	for _,key in ipairs(lButtonKeys) do
		if fields[key] then
			return key
		end
	end
	return nil
end

function techage.formspecSubMenu(meta, key)
	local fs_data = minetest.deserialize(meta:get_string("fs_data"))
	if key:sub(1,4) == "cond" then
		local row = tonumber(key:sub(5,5))
		return techage.cond_formspec(row, fs_data[row].cond)
	else
		local row = tonumber(key:sub(5,5))
		return techage.actn_formspec(row, fs_data[row].actn)
	end
end

function techage.formspec_button_update(meta, fields)
	local fs_data = minetest.deserialize(meta:get_string("fs_data"))
	local row = tonumber(fields._row_ or 1)
	if fields._col_ == "cond" then
		fs_data[row].cond = techage.cond_eval_input(fs_data[row].cond, fields)
	elseif fields._col_ == "actn" then
		fs_data[row].actn = techage.actn_eval_input(fs_data[row].actn, fields)
	end
	meta:set_string("fs_data", minetest.serialize(fs_data))
end

function techage.cond_formspec_update(meta, fields)
	local fs_data = minetest.deserialize(meta:get_string("fs_data"))
	local row = tonumber(fields._row_ or 1)
	fs_data[row].cond = techage.cond_eval_input(fs_data[row].cond, fields)
	meta:set_string("formspec", techage.cond_formspec(row, fs_data[row].cond))
	meta:set_string("fs_data", minetest.serialize(fs_data))
end

function techage.actn_formspec_update(meta, fields)
	local fs_data = minetest.deserialize(meta:get_string("fs_data"))
	local row = tonumber(fields._row_ or 1)
	fs_data[row].actn = techage.actn_eval_input(fs_data[row].actn, fields)
	meta:set_string("formspec", techage.actn_formspec(row, fs_data[row].actn))
	meta:set_string("fs_data", minetest.serialize(fs_data))
end


function techage.formspecRules(meta, fs_data, output)
	local running = meta:get_int("state") == techage.RUNNING
	local cmnd = running and "stop;Stop" or "start;Start"
	local init = meta:get_string("init")
	init = minetest.formspec_escape(init)
	return SIZE..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"tabheader[0,0;tab;rules,outp,notes,help;1;;true]"..
	formspec_rules(fs_data)..
	"label[0.2,7.0;"..output.."]"..
	"field[0.3,7.8;4,1;cmnd;;<cmnd>]"..
	"button[4.0,7.5;1.5,1;go;GO]"..
	buttons(cmnd)
end

function techage.formspecOutput(meta)
	local running = meta:get_int("state") == techage.RUNNING
	local cmnd = running and "stop;Stop" or "start;Start"
	local output = meta:get_string("output")
	output = minetest.formspec_escape(output)
	return SIZE..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"tabheader[0,0;tab;rules,outp,notes,help;2;;true]"..
	"textarea[0.3,0.2;13,8.3;output;Output:;"..output.."]"..
	"button[5.5,7.5;1.8,1;list;List]"..
	"button[7.4,7.5;1.8,1;clear;Clear]"..
	"button[9.3,7.5;1.8,1;update;Update]"..
	"button[11.2,7.5;1.8,1;"..cmnd.."]"
end

function techage.formspecNotes(meta)
	local running = meta:get_int("state") == techage.RUNNING
	local cmnd = running and "stop;Stop" or "start;Start"
	local notes = meta:get_string("notes") or ""
	if notes == "" then notes = "<space for your notes>" end
	notes = minetest.formspec_escape(notes)
	return SIZE..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"tabheader[0,0;tab;rules,outp,notes,help;3;;true]"..
	"textarea[0.3,0.2;13,8.3;notes;Notepad:;"..notes.."]"..
	buttons(cmnd)
end

function techage.formspecHelp(offs)
	return SIZE..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"tabheader[0,0;tab;rules,outp,notes,help;4;;true]"..
	"field[0,0;0,0;_type_;;help]"..
	"label[0,"..(-offs/50)..";"..sHELP.."]"..
	--"label[0.2,0;test]"..
	"scrollbar[12,1;0.5,7;vertical;sb_help;"..offs.."]"
end
