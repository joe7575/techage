--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA5 Fusion Reactor Controller

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local Cable = techage.ElectricCable
local sched = techage.scheduler
local power = networks.power
local control = networks.control

local CYCLE_TIME = 2
local STANDBY_TICKS = 0
local COUNTDOWN_TICKS = 1
local PWR_NEEDED = 400
local EXPECTED_PLASMA_NUM = 56
local EXPECTED_SHELL_NUM = 56
local EXPECTED_MAGNET_NUM = 56
local CALL_RATE1 = 16  -- 2s * 16 = 32s
local CALL_RATE2 = 8  -- 2s * 8 = 16s
local DESCRIPTION = S("TA5 Fusion Reactor Controller")
local EX_POINTS = 60

local function count_trues(t)
	local cnt = 0
	for _,v in ipairs(t) do
		if v then
			cnt = cnt + 1
		end
	end
	return cnt
end

local function nucleus(t)
	t = techage.tbl_filter(t, function(v, k, t) return type(v) == "table" end)
	if #t == 4 then
		if vector.equals(t[1], t[2]) and vector.equals(t[3], t[4]) then
			return true
		end
	end
	return S("Nucleus detection error")
end

local tSched = {}

sched.register(tSched, CALL_RATE1, 0, function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "connect")
		local cnt = count_trues(resp)
		if cnt ~= EXPECTED_MAGNET_NUM then
			return S("Magnet detection error\n(@1% found / 100% expected)", math.floor(cnt* 100 / EXPECTED_MAGNET_NUM))
		end
		return true
	end)

sched.register(tSched, CALL_RATE1, 1, function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "test_plasma")
		local cnt = count_trues(resp)
		if cnt ~= EXPECTED_PLASMA_NUM then
			return S("Plasma ring shape error")
		end
		return true
	end)

sched.register(tSched, CALL_RATE1, 2, function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "test_shell")
		local cnt = count_trues(resp)
		if cnt ~= EXPECTED_SHELL_NUM then
			return S("Shell shape error\n(@1% found / 100% expected)", math.floor(cnt* 100 / EXPECTED_SHELL_NUM))
		end
		return true
	end)

sched.register(tSched, CALL_RATE1, 3, function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "test_nucleus")
		return nucleus(resp)
	end)

sched.register(tSched, CALL_RATE2, 4, function(pos, outdir)
		local resp = control.request(pos, Cable, outdir, "con", "inc_power")
		local cnt = count_trues(resp)
		--print("inc_power", cnt)
		if cnt < 52 then
			return S("Cooling failed")
		end
		return true
	end)

local function can_start(pos, nvm)
	local outdir = networks.side_to_outdir(pos, "L")
	if not power.power_available(pos, Cable, outdir) then
		return S("No power")
	end
	outdir = networks.side_to_outdir(pos, "R")
	control.request(pos, Cable, outdir, "con", "rst_power")
	for i = 0,4 do
		local res = tSched[i](pos, outdir)
		if res ~= true then return res end
	end
	return true
end

local function start_node(pos, nvm)
	sched.init(pos)
	local outdir = networks.side_to_outdir(pos, "R")
	control.send(pos, Cable, outdir, "con", "on")
	sched.init(pos)
end

local function stop_node(pos, nvm)
	local outdir = networks.side_to_outdir(pos, "R")
	control.send(pos, Cable, outdir, "con", "off")
end

local function formspec(self, pos, nvm)
	return "size[5,3]"..
		"box[0,-0.1;4.8,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", DESCRIPTION) .. "]" ..
		"image_button[2,1.5;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
		"tooltip[2,1.5;1,1;"..self:get_state_tooltip(nvm).."]"
end

local State = techage.NodeStates:new({
	node_name_passive = "techage:ta5_fr_controller_pas",
	node_name_active = "techage:ta5_fr_controller_act",
	cycle_time = CYCLE_TIME,
	infotext_name = DESCRIPTION,
	standby_ticks = STANDBY_TICKS,
	can_start = can_start,
	start_node = start_node,
	stop_node = stop_node,
	formspec_func = formspec,
})

local function after_place_node(pos, placer, itemstack)
	local nvm = techage.get_nvm(pos)
	local meta = M(pos)
	local own_num = techage.add_node(pos, "techage:ta5_fr_controller_pas")
	State:node_init(pos, nvm, own_num)
	meta:set_string("owner", placer:get_player_name())
	Cable:after_place_node(pos)
end

local function consume_power(pos, nvm, outdir)
	if techage.needs_power(nvm) then
		local taken = power.consume_power(pos, Cable, outdir, PWR_NEEDED)
		if techage.is_running(nvm) then
			if taken < PWR_NEEDED then
				State:nopower(pos, nvm, "No power")
				stop_node(pos, nvm)
			else
				return true  -- keep running
			end
		end
	end
end

local function node_timer(pos)
	local nvm = techage.get_nvm(pos)
	local outdir = networks.side_to_outdir(pos, "L")
	if consume_power(pos, nvm, outdir) then
		local resp = sched.get(pos, tSched, function()
				return true end)(pos, networks.Flip[outdir])
		if resp ~= true then
			State:fault(pos, nvm, resp)
			stop_node(pos, nvm)
		else
			State:keep_running(pos, nvm, COUNTDOWN_TICKS)
		end
	end
	return State:is_active(nvm)
end

local function after_dig_node(pos, oldnode, oldmetadata)
	Cable:after_dig_node(pos)
	techage.remove_node(pos, oldnode, oldmetadata)
	techage.del_mem(pos)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	if techage.get_expoints(player) >= EX_POINTS then
		local nvm = techage.get_nvm(pos)
		State:state_button_event(pos, nvm, fields)
		--M(pos):set_string("formspec", formspec(State, pos, nvm))
	end
end

minetest.register_node("techage:ta5_fr_controller_pas", {
	description = S("TA5 Fusion Reactor Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_appl_plasma.png^techage_frame_ta5.png",
		"techage_filling_ta4.png^techage_appl_plasma.png^techage_frame_ta5.png",
	},
	after_place_node = after_place_node,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	on_receive_fields = on_receive_fields,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta5_fr_controller_act", {
	description = S("TA5 Fusion Reactor Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta5_top.png^techage_appl_arrow.png",
		"techage_filling_ta4.png^techage_frame_ta4_bottom.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		"techage_filling_ta4.png^techage_frame_ta5.png^techage_appl_hole_electric.png",
		{
			image = "techage_filling4_ta4.png^techage_appl_plasma4.png^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.5,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_appl_plasma4.png^techage_frame4_ta5.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.5,
			},
		},
	},
	after_place_node = after_place_node,
	on_timer = node_timer,
	after_dig_node = after_dig_node,
	on_receive_fields = on_receive_fields,
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	drop = "",
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

techage.register_node({"techage:ta5_fr_controller_pas", "techage:ta5_fr_controller_act"}, {
	on_recv_message = function(pos, src, topic, payload)
		return State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return State:on_beduino_request_data(pos, topic, payload)
	end,
})

power.register_nodes({"techage:ta5_fr_controller_pas", "techage:ta5_fr_controller_act"}, Cable, "con", {"L", "R"})

minetest.register_craft({
	output = "techage:ta5_fr_controller_pas",
	recipe = {
		{'techage:aluminum', 'basic_materials:gold_wire', 'default:steel_ingot'},
		{'techage:electric_cableS', 'techage:ta5_aichip2', 'techage:electric_cableS'},
		{'default:steel_ingot', 'default:diamond', 'techage:aluminum'},
	},
})

