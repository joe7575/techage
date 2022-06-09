--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller

]]--

 -- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local logic = techage.logic

--
-- Helper functions
--
local function gen_table(size, val)
	local tbl = {}
	for idx = 1,size do
		if type(val) == "table" then
			tbl[idx] = table.copy(val)
		else
			tbl[idx] = val
		end
	end
	return tbl
end

local function integer(s, min, max)
	if s and s ~= "" and s:find("^%d+$") then
		local num = tonumber(s)
		if num < min then num = min end
		if num > max then num = max end
		return num
	end
	return min
end

local sOUTPUT = "Edit commands (see help)"
local Cache = {}
local FS_DATA = gen_table(techage.NUM_RULES, {})


local function output(pos, text, flush_buffer)
	local meta = minetest.get_meta(pos)
	if not flush_buffer then
		text = meta:get_string("output") .. "\n" .. (text or "")
		text = text:sub(-500,-1)
	end
	meta:set_string("output", text)
	meta:set_string("formspec", techage.formspecOutput(meta))
end

-- cyclic execution (cycle, cond, result, after, actn)
local function TemplCyc(cycle, cond, result, after, actn, idx)
	return function(env, output)
		if env.blocked[idx] == false and env.ticks % cycle == 0 then
			env.result[idx] = cond(env, idx)
			env.blocked[idx] = result(env.result[idx])
			if env.blocked[idx] then
				env.timer[idx] = env.ticks + after
			end
			env.condition[idx] = env.blocked[idx]
		else
			env.condition[idx] = false
		end
		if env.blocked[idx] and env.timer[idx] == env.ticks then
			actn(env, output, idx)
			env.blocked[idx] = false
		end
	end
end

-- event based execution
local function TemplEvt(cond, result, after, actn, idx)
	return function(env, output)
		if env.blocked[idx] == false and env.event then
			env.result[idx] = cond(env, idx)
			env.blocked[idx] = result(env.result[idx])
			if env.blocked[idx] then
				env.timer[idx] = env.ticks + after
			end
			env.condition[idx] = env.blocked[idx]
		else
			env.condition[idx] = false
		end
		if env.blocked[idx] and env.timer[idx] == env.ticks then
			actn(env, output, idx)
			env.blocked[idx] = false
		end
	end

end

-- generate the Lua code from the NUM_RULES rules
local function generate(pos, meta, environ)
	local fs_data = minetest.deserialize(meta:get_string("fs_data")) or FS_DATA
	local tbl = {}
	for idx = 1,techage.NUM_RULES do
		local cycle = integer(fs_data[idx].cycle, 0, 1000)
		local cond, result = techage.code_condition(fs_data[idx].cond, environ)
		local after = integer(fs_data[idx].after, 0, 1000)
		local actn = techage.code_action(fs_data[idx].actn, environ)
		-- valid rule?
		if cycle and cond and after and actn then
			-- add rule number
			local f
			if cycle == 0 then  -- event
				f = TemplEvt(cond, result, after, actn, idx)
			else  -- cyclic
				f = TemplCyc(cycle, cond, result, after, actn, idx)
			end
			-- add to list of rules
			tbl[#tbl+1] = f
		elseif cond ~= nil and actn == nil then
			output(pos, "Error in action in rule "..idx)
		elseif cond == nil and actn ~= nil then
			output(pos, "Error in condition in rule "..idx)
		end
	end
	return tbl
end

local function runtime_environ(pos)
	return {
		ticks = 0,
		pos = pos,
		timer = gen_table(8, 0),
		blocked = gen_table(8, false),
		result = gen_table(8, false),
		condition = gen_table(8, false),
		input = {},  -- node number is key
	}
end

local function compile(pos, meta, number)
	local gen_environ = {
		meta = meta,
		pos = pos,
		number = number,
		owner = meta:get_string("owner"),
	}
	local functions = generate(pos, meta, gen_environ)
	Cache[number] = {
		code = functions,
		env = runtime_environ(pos),
	}
	return true
end

local function execute(pos, number, event)
	local code = Cache[number].code
	local env = Cache[number].env
	if event then
		env.event = true
	else
		env.event = false
		env.ticks = env.ticks + 1
	end
	for _,func in ipairs(code) do
		local res, err = pcall(func, env, output)
		if not res then
			output(pos, err)
			return false
		end
	end
	return true
end


local function battery(pos)
	local battery_pos = minetest.find_node_near(pos, 1, {"techage:ta4_battery"})
	if battery_pos then
		local meta = minetest.get_meta(pos)
		meta:set_string("battery", minetest.pos_to_string(battery_pos))
		return true
	end
	return false
end

local function start_controller(pos, meta)
	local number = meta:get_string("number")
	if not battery(pos) then
		meta:set_string("formspec", techage.formspecError(meta))
		return false
	end

	meta:set_string("output", "<press update>")
	meta:set_int("cpu", 0)

	if compile(pos, meta, number) then
		meta:set_int("state", techage.RUNNING)
		minetest.get_node_timer(pos):start(1)
		local fs_data = minetest.deserialize(meta:get_string("fs_data")) or FS_DATA
		meta:set_string("formspec", techage.formspecRules(meta, fs_data, sOUTPUT))
		meta:set_string("infotext", "Controller "..number..": running")
		return true
	end
	return false
end

local function stop_controller(pos, meta)
	local number = meta:get_string("number")
	meta:set_int("state", techage.STOPPED)
	minetest.get_node_timer(pos):stop()
	meta:set_string("infotext", "Controller "..number..": stopped")
	local fs_data = minetest.deserialize(meta:get_string("fs_data")) or FS_DATA
	meta:set_string("formspec", techage.formspecRules(meta, fs_data, sOUTPUT))
end

local function no_battery(pos)
	local meta = minetest.get_meta(pos)
	local number = meta:get_string("number")
	meta:set_int("state", techage.STOPPED)
	minetest.get_node_timer(pos):stop()
	meta:set_string("infotext", "Controller "..number..": No battery")
	meta:set_string("formspec", techage.formspecError(meta))
end

local function update_battery(meta, cpu)
	local pos = minetest.string_to_pos(meta:get_string("battery"))
	if pos then
		meta = minetest.get_meta(pos)
		local content = meta:get_int("content") - cpu
		if content <= 0 then
			meta:set_int("content", 0)
			return false
		end
		meta:set_int("content", content)
		return true
	end
end

local function on_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local t = minetest.get_us_time()
	local number = meta:get_string("number")
	if Cache[number] or compile(pos, meta, number) then
		local res = execute(pos, number, elapsed == -1)
		if res then
			t = minetest.get_us_time() - t
			if not update_battery(meta, t) then
				no_battery(pos)
				return false
			end
		end
		--print("on_timer", t)
		return res
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if not player or not player:is_player() then
		return
	end
	if player:get_player_name() ~= owner then
		return
	end

	--print("fields", dump(fields))
	if fields.quit then  -- cancel button
		return
	end
	if fields.notes then -- notes tab?
		meta:set_string("notes", fields.notes)
	end
	if fields.go then
		local fs_data = minetest.deserialize(meta:get_string("fs_data")) or FS_DATA
		local output = techage.edit_command(fs_data, fields.cmnd)
		stop_controller(pos, meta)
		meta:set_string("formspec", techage.formspecRules(meta, fs_data, output))
		meta:set_string("fs_data", minetest.serialize(fs_data))
	end
	if fields._type_ == "main" then
		techage.store_main_form_data(meta, fields)
		local key = techage.main_form_button_pressed(fields)
		if key then
			-- store data before going into sub-menu
			meta:set_string("fs_old", meta:get_string("fs_data"))
			meta:set_string("formspec", techage.formspecSubMenu(meta, key))
		end
	elseif fields._col_ == "cond" then
		techage.cond_formspec_update(meta, fields)
	elseif fields._col_ == "actn" then
		techage.actn_formspec_update(meta, fields)
	end
	if fields._exit_ == "ok" then  -- exit from sub-menu?
		if fields._button_ then
			techage.formspec_button_update(meta, fields)
		end
		-- simulate tab selection
		fields.tab = "1"
	elseif fields._cancel_ == "cancel" then  -- abort from sub-menu?
		-- restore old data
		meta:set_string("fs_data", meta:get_string("fs_old"))
		-- simulate tab selection
		fields.tab = "1"
	elseif fields.save == "Save" then  -- abort from sub-menu?
		-- store as old data
		meta:set_string("fs_old", meta:get_string("fs_data"))
		-- simulate tab selection
		fields.tab = "1"
	elseif fields.sb_help then
		local evt = minetest.explode_scrollbar_event(fields.sb_help)
		meta:set_string("formspec", techage.formspecHelp(evt.value))
	end
	if fields.update then
		meta:set_string("formspec", techage.formspecOutput(meta))
	elseif fields.clear then
		meta:set_string("output", "<press update>")
		meta:set_string("formspec", techage.formspecOutput(meta))
	elseif fields.list then
		local fs_data = minetest.deserialize(meta:get_string("fs_data")) or FS_DATA
		local s = techage.listing(fs_data)
		output(pos, s, true)
	elseif fields.tab == "1" then
		local fs_data = minetest.deserialize(meta:get_string("fs_data")) or FS_DATA
		meta:set_string("formspec", techage.formspecRules(meta, fs_data, sOUTPUT))
	elseif fields.tab == "2" then
		meta:set_string("formspec", techage.formspecOutput(meta))
	elseif fields.tab == "3" then
		meta:set_string("formspec", techage.formspecNotes(meta))
	elseif fields.tab == "4" then
		meta:set_string("formspec", techage.formspecHelp(1))
	elseif fields.start == "Start" then
		local environ = {
			meta = meta,
			pos = pos,
			number = meta:get_string("number"),
			owner = meta:get_string("owner"),
		}
		--print("CODE:", generate(pos, meta, environ))
		start_controller(pos, meta)
		minetest.log("action", player:get_player_name() ..
			" starts the ta4_controller at ".. minetest.pos_to_string(pos))
	elseif fields.stop == "Stop" then
		stop_controller(pos, meta)
	end
end

minetest.register_node("techage:ta4_icta_controller", {
	description = "TA4 ICTA Controller",
	inventory_image = "techage_ta4_controller_inventory.png",
	wield_image = "techage_ta4_controller_inventory.png",
	stack_max = 1,
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_ta4_controller.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:ta4_icta_controller")
		local fs_data = FS_DATA
		meta:set_string("fs_data", minetest.serialize(fs_data))
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("number", number)
		meta:set_int("state", techage.STOPPED)
		meta:set_string("formspec", techage.formspecRules(meta, fs_data, sOUTPUT))
		--meta:set_string("formspec", techage.cond_formspec(1, 1, nil))
		meta:set_string("infotext", "TA4 ICTA Controller "..number..": stopped")
	end,

	on_receive_fields = on_receive_fields,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	on_timer = on_timer,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	use_texture_alpha = techage.CLIP,
	groups = {choppy=1, cracky=1, crumbly=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_craft({
	output = "techage:ta4_icta_controller",
	recipe = {
		{"basic_materials:plastic_sheet", "dye:blue", "basic_materials:plastic_sheet"},
		{"", "default:copper_ingot", ""},
		{"techage:ta4_wlanchip", "techage:ta4_ramchip", "techage:ta4_ramchip"},
	},
})

-- write inputs from remote nodes
local function set_input(pos, own_number, rmt_number, val)
	if rmt_number then
		if Cache[own_number] and Cache[own_number].env.input then
			local t = minetest.get_us_time()
			Cache[own_number].env.input[rmt_number] = val
			Cache[own_number].env.last_event = t
			-- only two events per second
			if not Cache[own_number].last_event or Cache[own_number].last_event < t then
				minetest.after(0.01, on_timer, pos, -1)
				Cache[own_number].last_event = t + 500000 -- add 500 ms
			end
		end
	end
end

techage.register_node({"techage:ta4_icta_controller"}, {
	on_recv_message = function(pos, src, topic, payload)
		local meta = minetest.get_meta(pos)
		local number = meta:get_string("number")
		local state = meta:get_int("state")

		if state == techage.RUNNING and topic == "on" then
			set_input(pos, number, src, topic)
		elseif state == techage.RUNNING and topic == "off" then
			set_input(pos, number, src, topic)
		elseif topic == "state" then
			local state = meta:get_int("state") or 0
			return techage.StateStrings[state] or "stopped"
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local meta = minetest.get_meta(pos)
		local number = meta:get_string("number")
		local state = meta:get_int("state")

		if state == techage.RUNNING and topic == 1 and payload[1] == 1 then
			set_input(pos, number, src, topic)
		elseif state == techage.RUNNING and topic == 1 and payload[1] == 0 then
			set_input(pos, number, src, topic)
		else
			return 2
		end
		return 0
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		local meta = minetest.get_meta(pos)
		local number = meta:get_string("number")
		local state = meta:get_int("state")

		if topic == 129 then
			local state = meta:get_int("state") or 0
			return 0, {state or techage.STOPPED}
		else
			return 2, ""
		end
	end,
})
