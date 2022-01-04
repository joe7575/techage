--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Power Terminal

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
local S = techage.S

local CYCLE_TIME = 2

local Cable = techage.ElectricCable
local power = networks.power
local control = networks.control

local HELP = S([[Commands
help . . . print this text
cls . . . . . clear screen
gen . . . . print all generators
sto . . . . . print all storage systems
con . . . . . print main consumers
]])

local function row(num, label, data)
	local y = 4.0 + num * 0.5
	return
		"box[0," .. y .. ";9.8,0.4;#395c74]"..
		"label[0.2,"..y..";" .. label .. "]" ..
		"label[8.5,"..y..";" .. data .. "]"
end


local function formspec1(pos, data)
	local mem = techage.get_mem(pos)
	local outdir = M(pos):get_int("outdir")
	local netw = networks.get_network_table(pos, Cable, outdir, true) or {}
	data = data or power.get_network_data(pos, Cable, outdir)

	mem.star = ((mem.star or 0) + 1) % 2
	local star = mem.star == 1 and "*" or ""
	local storage_provided = math.max(data.consumed - data.available, 0)
	local available = math.max(data.consumed, data.available)

	return "size[10,8]"..
		"tabheader[0,0;tab;status,console;1;;true]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;9.8,0.5;#c6e8ff]"..
		"label[0.2,-0.1;"..minetest.colorize( "#000000", S("Network Data")).."]"..
		"label[9.5,-0.1;"..minetest.colorize( "#000000", star).."]"..
		techage.formspec_power_bar(pos, 0.0, 0.7, S("Generator"), data.provided, data.available)..
		techage.formspec_power_bar(pos, 2.5, 0.7,  S("Consumer"), data.consumed, available)..
		techage.formspec_charging_bar(pos, 5.0, 0.7, S("Charging"), data)..
		techage.formspec_storage_bar(pos, 7.5, 0.7, S("Storage"),  data.curr_load, data.max_capa)..

		row(1, S("Number of network nodes:"), netw.num_nodes or 0) ..
		row(2, S("Number of generators:"), #(netw.gen or {})) ..
		row(3, S("Number of consumers:"), #(netw.con or {})) ..
		row(4, S("Number of storage systems:"), #(netw.sto or {}))
end

local function formspec2(pos)
	local mem = techage.get_mem(pos)
	local meta = M(pos)
	local output = meta:get_string("output")
	local command = mem.cmnd or "help"
	output = minetest.formspec_escape(output)
	output = output:gsub("\n", ",")

	return "size[10,8]"..
		"tabheader[0,0;tab;status,console;2;;true]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;9.8,0.5;#c6e8ff]"..
		"label[0.2,-0.1;"..minetest.colorize( "#000000", S("Network Data")).."]"..
		--"style_type[table,field;font=mono]"..
		"table[0,0.5;9.8,6.8;output;"..output..";200]"..
		"field[0.4,7.7;7.6,1;cmnd;;"..command.."]" ..
		"field_close_on_enter[cmnd;false]"..
		"button[7.9,7.4;2,1;enter;"..S("Enter").."]"
end

local function generators(pos)
	local tbl = {}
	local outdir = M(pos):get_int("outdir")
	local resp = control.request(pos, Cable, outdir, "gen", "info")
	for _, item in ipairs(resp) do
		local name = item.type .. " (" .. item.number .. ")"
		if item.running then
			local s = string.format("%s (%s): %s/%u ku (%s)",
					item.type, item.number, techage.round(item.provided), item.available, item.termpoint)
			tbl[#tbl + 1] = s
		else
			local s = string.format("%s (%s): off",
					item.type, item.number)
			tbl[#tbl + 1] = s
		end
	end
	table.sort(tbl)
	return table.concat(tbl, "\n")
end

local function storages(pos)
	local tbl = {}
	local outdir = M(pos):get_int("outdir")
	local resp = control.request(pos, Cable, outdir, "sto", "info")
	for _, item in ipairs(resp) do
		local name = item.type .. " (" .. item.number .. ")"
		if item.running then
			local s = string.format("%s (%s): %s/%s kud",
					item.type, item.number,
					techage.round(item.load / techage.CYCLES_PER_DAY),
					techage.round(item.capa / techage.CYCLES_PER_DAY))
			tbl[#tbl + 1] = s
		else
			local s = string.format("%s (%s): %s/%s kud (off)",
					item.type, item.number,
					techage.round(item.load / techage.CYCLES_PER_DAY),
					techage.round(item.capa / techage.CYCLES_PER_DAY))
			tbl[#tbl + 1] = s
		end
	end
	table.sort(tbl)
	return table.concat(tbl, "\n")
end

local function consumers(pos)
	local tbl = {}
	local outdir = M(pos):get_int("outdir")
	local netw = networks.get_network_table(pos, Cable, outdir) or {}
	for _,item in ipairs(netw.con or {}) do
		local number = techage.get_node_number(item.pos)
		if number then
			local name = techage.get_node_lvm(item.pos).name
			name = (minetest.registered_nodes[name] or {}).description or "unknown"
			tbl[#tbl + 1] = name .. " (" .. number .. ")"
		end
	end
	table.sort(tbl)
	return table.concat(tbl, "\n")
end

local function output(pos, command, text)
	local meta = M(pos)
	text = meta:get_string("output") .. "\n$ " .. command .. "\n" .. (text or "")
	text = text:sub(-2000,-1)
	meta:set_string("output", text)
end

local function command(pos, nvm, command)
	local meta = M(pos)

	if command then
		command = command:sub(1,80)
		command = string.trim(command)
		local cmd, data = unpack(string.split(command, " ", false, 1))

		if cmd == "cls" then
			meta:set_string("output", "")
		elseif cmd == "help" then
			output(pos, command, HELP)
		elseif cmd == "gen" then
			output(pos, command, generators(pos))
		elseif cmd == "sto" then
			output(pos, command, storages(pos))
		elseif cmd == "con" then
			output(pos, command, consumers(pos))
		elseif command ~= "" then
			output(pos, command, "")
		end
	end
end

minetest.register_node("techage:ta3_power_terminal", {
	description = S("TA3 Power Terminal"),
	inventory_image = "techage_power_terminal_front.png",
	tiles = {
		"techage_power_terminal_top.png",
		"techage_power_terminal_top.png",
		"techage_power_terminal_side.png",
		"techage_power_terminal_side.png",
		"techage_power_terminal_back.png",
		"techage_power_terminal_front.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, 0/16,  8/16, 8/16, 8/16},
		},
	},

	after_place_node = function(pos)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "B"))
		Cable:after_place_node(pos)
		M(pos):set_string("formspec", formspec1(pos))
	end,
	after_dig_node = function(pos)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
	on_rightclick = function(pos, node, clicker)
		local mem = techage.get_mem(pos)
		if mem.active_formspec == 2 then
			M(pos):set_string("formspec", formspec2(pos))
		else
			M(pos):set_string("formspec", formspec1(pos))
			minetest.get_node_timer(pos):start(CYCLE_TIME)
			techage.set_activeformspec(pos, clicker)
			mem.active_formspec = 1
		end
	end,
	on_timer = function(pos, elapsed)
		if techage.is_activeformspec(pos) then
			local outdir = M(pos):get_int("outdir")
			local data = power.get_network_data(pos, Cable, outdir)
			M(pos):set_string("formspec", formspec1(pos, data))
			return true
		end
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local nvm = techage.get_nvm(pos)
		local mem = techage.get_mem(pos)

		if fields.key_enter_field or fields.enter then
			command(pos, nvm, fields.cmnd)
			mem.cmnd = ""
			M(pos):set_string("formspec", formspec2(pos, mem))
			mem.cmnd = fields.cmnd
		elseif fields.tab == "1" then
			M(pos):set_string("formspec", formspec1(pos))
			techage.set_activeformspec(pos, player)
			minetest.get_node_timer(pos):start(CYCLE_TIME)
			mem.active_formspec = 1
		elseif fields.tab == "2" then
			M(pos):set_string("formspec", formspec2(pos))
			techage.reset_activeformspec(pos, player)
			mem.active_formspec = 2
		elseif fields.key_up and mem.cmnd then
			M(pos):set_string("formspec", formspec2(pos))
		end
	end,

	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	on_rotate = screwdriver.disallow,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, level = 2},
	sounds = default.node_sound_metal_defaults(),
})

power.register_nodes({"techage:ta3_power_terminal"}, Cable, "con", {"B"})

minetest.register_craft({
	output = "techage:ta3_power_terminal",
	recipe = {
		{"", "techage:usmium_nuggets", "default:steel_ingot"},
		{"", "techage:basalt_glass_thin", "default:copper_ingot"},
		{"", "techage:vacuum_tube", "default:steel_ingot"},
	},
})
