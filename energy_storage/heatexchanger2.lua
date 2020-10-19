--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	TA4 Heat Exchanger2 (middle part)

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local power = techage.power

local CYCLE_TIME = 2

local function he1_cmnd(pos, topic, payload)
	return techage.transfer({x = pos.x, y = pos.y - 1, z = pos.z}, 
		nil, topic, payload, nil,
		{"techage:heatexchanger1"})
end

local function formspec(self, pos, nvm)
	local capa_max, capa, needed_max, needed = he1_cmnd(pos, "state")
	capa_max = capa_max or 0
	capa = capa or 0
	needed_max = needed_max or 0
	needed = needed or 0
	local arrow = "image[2.5,1.5;1,1;techage_form_arrow_bg.png^[transformR270]"
	if needed > 0 then
		arrow = "image[2.5,1.5;1,1;techage_form_arrow_fg.png^[transformR270]"
	end
	return "size[6,4]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"box[0,-0.1;5.8,0.5;#c6e8ff]"..
		"label[2,-0.1;"..minetest.colorize( "#000000", S("Heat Exchanger")).."]"..
		power.formspec_label_bar(0,   0.8, S("Electricity"), needed_max, needed)..
		power.formspec_label_bar(3.5, 0.8, S("Thermal"), capa_max, capa, "")..
		arrow..
		"image_button[2.5,3;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2.5,3;1,1;"..self:get_state_tooltip(nvm).."]"
end

local function can_start(pos, nvm, state)
	--print("can_start", he1_cmnd(pos, "can_start"))
	return he1_cmnd(pos, "can_start") or S("did you check the plan?")
end

local function start_node(pos, nvm, state)
	he1_cmnd(pos, "start")
end

local function stop_node(pos, nvm, state)
	he1_cmnd(pos, "stop")
end

local function check_TES_integrity(pos, nvm)
	nvm.ticks = (nvm.ticks or 0) + 1
	if (nvm.ticks % 100) == 0 then -- not to often
		return he1_cmnd(pos, "integrity", "singleplayer")
	end
	return true
end	

local State = techage.NodeStates:new({
	node_name_passive = "techage:heatexchanger2",
	cycle_time = CYCLE_TIME,
	infotext_name = S("TA4 Heat Exchanger"),
	standby_ticks = 0,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
	formspec_func = formspec,
})

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local res = check_TES_integrity(pos, nvm)
	if res ~= true then
		State:fault(pos, nvm, res)
		he1_cmnd(pos, "stop")
	end
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", formspec(State, pos, nvm))
		return true
	end
	return false
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local nvm = techage.get_nvm(pos)
	return not nvm.running
end

local function on_rightclick(pos, node, clicker)
	techage.set_activeformspec(pos, clicker)
	local nvm = techage.get_nvm(pos)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
	minetest.get_node_timer(pos):start(CYCLE_TIME)
end

local function after_place_node(pos, placer)
	if techage.orientate_node(pos, "techage:heatexchanger1") then
		return true
	end
	local nvm = techage.get_nvm(pos)
	State:node_init(pos, nvm, "")
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end
	
local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	
	local nvm = techage.get_nvm(pos)
	State:state_button_event(pos, nvm, fields)
	M(pos):set_string("formspec", formspec(State, pos, nvm))
end

-- Middle node with the formspec from the bottom node
minetest.register_node("techage:heatexchanger2", {
	description = S("TA4 Heat Exchanger 2"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_hole_ta4.png",
		"techage_hole_ta4.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_tes_turb.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_tes_core.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_ribsB.png",
		"techage_filling_ta4.png^techage_frameM_ta4.png^techage_appl_ribsB.png",
	},
	
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1.5/2, -1/2, 1/2, 1/2, 1/2},
	},
	
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,
	on_timer = node_timer,
	after_place_node = after_place_node,
	can_dig = can_dig,

	paramtype2 = "facedir",
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techage:heatexchanger2",
	recipe = {
		{"default:tin_ingot", "", "default:steel_ingot"},
		{"", "techage:ta4_wlanchip", ""},
		{"", "techage:baborium_ingot", ""},
	},
})
