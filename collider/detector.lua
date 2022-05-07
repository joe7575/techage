--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Detector as part of the Collider

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local getpos = techage.assemble.get_pos

local CYCLE_TIME = 2
local TNO_MAGNETS = 22
local IMPROBABILITY = 60  -- every 60 min
--  one point per 60 min: check every 20 s => factor = 60 * 3 = 180
IMPROBABILITY = (minetest.settings:get("techage_expoint_rate_in_min") or 60) * 3

local TIME_SLOTS = 10
local Schedule = {[0] =
	-- Route: 0 = forward, 1 = right, 2 = backward, 3 = left
	-- Gas left/right
	{name = "techage:ta4_collider_pipe_inlet",  yoffs = 1, route = {3,3,3,2}, check = techage.gas_inlet_check},
	{name = "techage:ta4_collider_pipe_inlet",  yoffs = 1, route = {1,1,1,2}, check = techage.gas_inlet_check},
	-- Power left/right
	{name = "techage:ta4_collider_cable_inlet", yoffs = 2, route = {3,3,3}, check = techage.power_inlet_check},
	{name = "techage:ta4_collider_cable_inlet", yoffs = 2, route = {1,1,1}, check = techage.power_inlet_check},
	-- Cooler
	{name = "techage:ta4_collider_pipe_inlet",  yoffs = 0, route = {0}, check = techage.cooler_check},
	{name = "techage:ta4_collider_pipe_inlet",  yoffs = 2, route = {0}, check = techage.cooler_check},
	-- Air outlet
	{name = "techage:ta4_collider_pipe_outlet", yoffs = 2, route = {}, check = techage.air_outlet_check},
	-- All nodes
	{name = "shell", yoffs = 0, route = {}, check = nil},
}

local function play_sound(pos)
	minetest.sound_play("techage_hum", {
		pos = pos,
		gain = 0.5,
		max_hear_distance = 10,
	})
end

local function terminal_message(pos, msg)
	local term_num = M(pos):contains("term_num") and M(pos):get_string("term_num")
	local own_num = M(pos):get_string("node_number")

	if term_num and own_num then
		techage.send_single(own_num, term_num, "text", msg)
	end
end

local function experience_points(pos)
	if math.random(IMPROBABILITY) == 1 then
		local owner = M(pos):get_string("owner")
		local own_num = M(pos):get_string("node_number")
		local player = minetest.get_player_by_name(owner)
		if player then
			if techage.add_expoint(player, own_num) then
				terminal_message(pos, "Experience point reached!")
			end
		end
	end
end

local function check_shell(pos, param2)
	local pos1 = getpos(pos, param2, {3,3,3,2}, 0)
	local pos2 = getpos(pos, param2, {1,1,1,0}, 2)
	local _, tbl = minetest.find_nodes_in_area(pos1, pos2, {"techage:ta4_detector_magnet", "techage:ta4_colliderblock", "default:obsidian_glass"})
	if tbl["techage:ta4_detector_magnet"] < 16 then
		return false, "Magnet missing"
	elseif tbl["techage:ta4_colliderblock"] < 31 then
		return false, "Steel block missing"
	elseif tbl["default:obsidian_glass"] < 1 then
		return false, "Obsidian glass missing"
	end
	return true
end

local function check_state(pos)
	-- Cyclically check all connections
	local param2 = minetest.get_node(pos).param2
	local nvm = techage.get_nvm(pos)
	nvm.ticks = (nvm.ticks or 0) + 1
	local idx = nvm.ticks % TIME_SLOTS
	local item = Schedule[idx]

	if idx == 1 then
		nvm.result = true
	end

	if item then
		if item.name == "shell" then
			local res, err = check_shell(pos, param2)
			if not res then
				nvm.result = false
				nvm.runnning = false
				terminal_message(pos, (err or "unknown") .. "!!!")
				return nvm.result
			end
		else
			local pos2 = getpos(pos, param2, item.route, item.yoffs)
			local nvm2 = techage.get_nvm(pos2)
			local meta2 = M(pos2)
			local node2 = minetest.get_node(pos2)
			if item.name == node2.name then
				local res, err = item.check(pos2, node2, meta2, nvm2)
				--print("check_state", idx, res, err)
				if not res then
					nvm.result = false
					nvm.runnning = false
					terminal_message(pos, (err or "unknown") .. "!!!")
					return nvm.result
				end
			else
				nvm.result = false
				nvm.runnning = false
				terminal_message(pos, "Detector defect!!!")
			end
		end
	elseif idx == #Schedule + 1 then
		return nvm.result
	end
end

local function add_laser(pos)
	local param2 = minetest.get_node(pos).param2
	local pos1 = getpos(pos, param2, {3,3}, 1)
	local pos2 = getpos(pos, param2, {1,1,1}, 1)
	techage.del_laser(pos)
	techage.add_laser(pos, pos1, pos2)
end

local function create_task(pos, task)
	local mem = techage.get_mem(pos)
	if not mem.co then
		mem.co = coroutine.create(task)
	end

	local _, err = coroutine.resume(mem.co, pos)
	if err then
		mem.co = nil
		--print(err)
		return
	end
	minetest.after(0.4, create_task, pos, task)
end

-- Call on_cyclic_check of all magents so that the magnets don't need a FLB.
local function magnet_on_cyclic_check(pos, nvm)
	local ndef = minetest.registered_nodes["techage:ta4_magnet"]
	for idx,pos2 in ipairs(nvm.magnet_positions or {}) do
		local res = ndef.on_cyclic_check(pos2)
		if res == -2 then
			terminal_message(pos, "Magnet #" .. idx .. " defect!!!")
			return false
		elseif res == -1 then
			terminal_message(pos, "Vacuum defect!!!")
			techage.air_outlet_reset({x=pos.x, y=pos.y + 2, z=pos.z})
			return false
		end
	end
	return true
end

minetest.register_node("techage:ta4_detector_core", {
	description = S("TA4 Collider Detector Core"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png^techage_collider_detector_core.png",
		"default_steel_block.png^techage_collider_detector_core.png",
		"default_steel_block.png^techage_collider_detector_core.png",
		"default_steel_block.png^techage_collider_detector_core.png",
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {cracky = 1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack)
		local nvm = techage.get_nvm(pos)
		local meta = M(pos)
		local own_num = techage.add_node(pos, "techage:ta4_detector_core")
		meta:set_string("node_number", own_num)
		meta:set_string("owner", placer:get_player_name())
		M({x=pos.x, y=pos.y - 1, z=pos.z}):set_string("infotext", S("TA4 Collider Detector") .. " " .. own_num)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,

	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		if not magnet_on_cyclic_check(pos, nvm) then
			techage.del_laser(pos)
			if nvm.running then
				terminal_message(pos, "Detector stopped.")
				nvm.running = false
			end
			nvm.magnet_positions = nil
		elseif nvm.running then
			local res = check_state(pos)
			if res == true then
				experience_points(pos)
				add_laser(pos)
				if nvm.ticks <= TIME_SLOTS then -- only once
					terminal_message(pos, "Detector running.")
				end
			elseif res == false then
				techage.del_laser(pos)
				nvm.running = false
				nvm.magnet_positions = nil
				terminal_message(pos, "Detector stopped.")
			end
			if nvm.running then
				play_sound(pos)
			end
		end
		return true
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.on_remove_collider(digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,
})

local function check_expr(own_num, term_num, text, expr)
	techage.send_single(own_num, term_num, "text", text .. "..." .. (expr and "ok" or "error!!!"))
	return expr
end

local function start_task(pos)
	local term_num = M(pos):contains("term_num") and M(pos):get_string("term_num")
	local param2 = minetest.get_node(pos).param2
	local pos2 = getpos(pos, param2, {3,3,3}, 1)
	local own_num = M(pos):get_string("node_number")
	local nvm = techage.get_nvm(pos)
	nvm.magnet_positions = {}

	if term_num and param2 and pos2 then
		techage.send_single(own_num, term_num, "text", "#### Start ####")

		coroutine.yield()
		local resp = techage.tube_inlet_command(pos2, "enumerate", 1)
		if not check_expr(own_num, term_num, "- Check number of magnets", resp == TNO_MAGNETS) then
			nvm.locked = false
			return
		end

		coroutine.yield()
		techage.send_single(own_num, term_num, "text", "- Check position of magnets...")
		resp = techage.tube_inlet_command(pos2, "distance")
		if resp ~= true then
			techage.send_single(own_num, term_num, "append", "#" .. resp .. " defect!!!")
			nvm.locked = false
			return
		end
		techage.send_single(own_num, term_num, "append", "ok")

		coroutine.yield()
		techage.send_single(own_num, term_num, "text", "- Start magnets...")
		local t = {}
		for num = 1, TNO_MAGNETS do
			local resp = techage.tube_inlet_command(pos2, "pos", num)
			if not resp or type(resp) ~= "table" then
				techage.send_single(own_num, term_num, "append", "#" .. num .. " defect!!!")
				nvm.magnet_positions = nil
				nvm.locked = false
				return
			else
				t[#t + 1] = resp
			end
			coroutine.yield()
		end
		nvm.magnet_positions = t
		techage.send_single(own_num, term_num, "append", "ok")

		coroutine.yield()
		techage.send_single(own_num, term_num, "text", "- Check magnets...")
		-- The check will be performed by the timer, so wait 5 sec.
		for i = 1,14 do
			coroutine.yield()
		end
		if nvm.magnet_positions then
			techage.send_single(own_num, term_num, "append", "ok")
		else
			nvm.locked = false
			return
		end

		coroutine.yield()
		techage.send_single(own_num, term_num, "text", "- Check detector...")
		for _,item  in ipairs(Schedule)do
			if item.name == "shell" then
				local res, err = check_shell(pos, param2)
				if not res then
					techage.send_single(own_num, term_num, "append", err .. "!!!")
					nvm.magnet_positions = nil
					nvm.locked = false
					return
				end
			else
				local pos2 = getpos(pos, param2, item.route, item.yoffs)
				local nvm2 = techage.get_nvm(pos2)
				local meta2 = M(pos2)
				local node2 = minetest.get_node(pos2)
				if item.name == node2.name then
					local res, err = item.check(pos2, node2, meta2, nvm2)
					if not res then
						techage.send_single(own_num, term_num, "append", err .. "!!!")
						nvm.magnet_positions = nil
						nvm.locked = false
						return
					end
				else
					techage.send_single(own_num, term_num, "append", "defect!!!")
					nvm.magnet_positions = nil
					nvm.locked = false
					return
				end
				coroutine.yield()
			end
		end
		techage.send_single(own_num, term_num, "append", "ok")

		coroutine.yield()
		techage.send_single(own_num, term_num, "text", "Collider started.")
		nvm.ticks = 0
		nvm.running = true
	end
end

local function test_magnet(pos, payload)
	local term_num = M(pos):contains("term_num") and M(pos):get_string("term_num")
	local param2 = minetest.get_node(pos).param2
	local pos2 = getpos(pos, param2, {3,3,3}, 1)
	local own_num = M(pos):get_string("node_number")
	local magnet_num = tonumber(payload)
	local res, err = techage.tube_inlet_command(pos2, "test", magnet_num)
	if res then
		techage.send_single(own_num, term_num, "text", "magnet #" .. magnet_num .. ": ok")
	else
		techage.send_single(own_num, term_num, "text", "magnet #" .. magnet_num .. ": " .. (err or "unknown error") .. "!!!")
	end
end

techage.register_node({"techage:ta4_detector_core"}, {
	on_recv_message = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "connect" then
			M(pos):set_string("term_num", src)
			return true
		elseif topic == "start" then
			-- Worker block
			nvm.locked = true
			create_task(pos, start_task)
			return true
		elseif topic == "stop" then
			nvm.running = false
			techage.del_laser(pos)
			nvm.locked = false
			return "Detector stopped."
		elseif topic == "status" then
			if nvm.running == true then
				return "running"
			elseif nvm.result == false then
				return "fault"
			else
				return "stopped"
			end
		elseif topic == "test"then
			if payload and tonumber(payload) then
				test_magnet(pos, payload)
				return true
			else
				return "Invalid magnet number"
			end
		elseif topic == "points" then
			local owner = M(pos):get_string("owner")
			local player = minetest.get_player_by_name(owner)
			if player then
				local points = techage.get_expoints(player)
				return "Ex. Points = " .. points
			end
		else
			return "unsupported"
		end
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end,
})


minetest.register_craft({
	output = "techage:ta4_detector_core",
	recipe = {
		{'techage:aluminum', 'basic_materials:heating_element', 'default:steel_ingot'},
		{'default:diamond', 'techage:ta4_wlanchip', 'techage:electric_cableS'},
		{'default:steel_ingot', '', 'techage:aluminum'},
	},
})
