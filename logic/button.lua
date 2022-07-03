--[[

	TechAge
	=======

	Copyright (C) 2017-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 & TA4 Logic button

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local NDEF = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}) end

local logic = techage.logic

local WRENCH_MENU = {
	{
		type = "ascii",
		name = "command",
		label = S("Command"),
		tooltip = S("Command to be sent"),
		default = "on",
	},
}

local function switch_on(pos)
	local cycle_time = M(pos):get_int("cycle_time")
	local name = techage.get_node_lvm(pos).name
	if name == "techage:ta3_button_off" then
		logic.swap_node(pos, "techage:ta3_button_on")
	elseif name == "techage:ta4_button_off" then
		logic.swap_node(pos, "techage:ta4_button_on")
	end
	local meta = M(pos)
	local s = meta:contains("command") and meta:get_string("command") or "on"
	local command, payload = unpack(string.split(s, " ", false, 1))
	logic.send_cmnd(pos, M(pos), command, payload, cycle_time)
	minetest.sound_play("techage_button", {
			pos = pos,
			gain = 0.5,
			max_hear_distance = 5,
		})
end

local function switch_off(pos, is_button)
	local name = techage.get_node_lvm(pos).name
	if name == "techage:ta3_button_on" then
		logic.swap_node(pos, "techage:ta3_button_off")
	elseif name == "techage:ta4_button_on" then
		logic.swap_node(pos, "techage:ta4_button_off")
	end
	local meta = M(pos)
	if not meta:contains("command") or meta:get_string("command") == "on" then
		logic.send_off(pos, M(pos))
	end
	if not is_button then
		minetest.sound_play("techage_button", {
				pos = pos,
				gain = 0.5,
				max_hear_distance = 5,
			})
	end
end

local function formspec(meta)
	local numbers = meta:get_string("numbers") or ""
	local idx = meta:get_int("cycle_idx") or 0
	if idx == 0 then idx = 1 end
	local access_idx = meta:get_string("public") == "true" and 3 or meta:get_string("protected") == "true" and 2 or 1
	return "size[7.5,6]"..
		"dropdown[0.2,0;3;type;switch,button 1s,button 2s,button 4s,button 8s,button 16s,button 32s;"..idx.."]"..
		"field[0.5,2;7,1;numbers;"..S("Insert destination node number(s)")..";"..numbers.."]" ..
		"label[0.2,3;"..S("Access:").."]"..
		"dropdown[3,3;4;access;private,protected,public;"..access_idx.."]"..
		"button_exit[2,4;3,1;exit;"..S("Save").."]"
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local meta = M(pos)
	if not techage.check_numbers(fields.numbers, player:get_player_name()) then
		return
	end
	meta:set_string("numbers", fields.numbers)
	if fields.access == "protected" then
		meta:set_string("protected", "true")
		meta:set_string("public", "")
	end
	if fields.access == "public" then
		meta:set_string("public", "true")
		meta:set_string("protected", "")
	end
	if fields.access == "private" then
		meta:set_string("public", "")
		meta:set_string("protected", "")
	end
	local cycle_time = nil
	if fields.type == "switch" then
		meta:set_int("cycle_idx", 1)
		cycle_time = 0
	elseif fields.type == "button 1s" then
		meta:set_int("cycle_idx", 2)
		cycle_time = 1
	elseif fields.type == "button 2s" then
		meta:set_int("cycle_idx", 3)
		cycle_time = 2
	elseif fields.type == "button 4s" then
		meta:set_int("cycle_idx", 4)
		cycle_time = 4
	elseif fields.type == "button 8s" then
		meta:set_int("cycle_idx", 5)
		cycle_time = 8
	elseif fields.type == "button 16s" then
		meta:set_int("cycle_idx", 6)
		cycle_time = 16
	elseif fields.type == "button 32s" then
		meta:set_int("cycle_idx", 7)
		cycle_time = 32
	end
	if cycle_time ~= nil then
		meta:set_int("cycle_time", cycle_time)
	end
	logic.infotext(meta, NDEF(pos).description)
	if fields.exit then
		meta:set_string("formspec", nil)
		meta:set_string("fixed" , "true")
	else
		meta:set_string("formspec", formspec(meta))
	end
end

local function can_access(pos, player)
	local meta = M(pos)
	local public = meta:get_string("public") == "true"
	local protected = meta:get_string("protected") == "true"
	local owner = meta:get_string("owner")
	local name = player:get_player_name()
	return public or protected and not minetest.is_protected(pos, name) or owner == name
end

local function on_rightclick_on(pos, node, clicker)
	local meta = M(pos)
	local fixed = meta:get_string("fixed")
	if fixed == "true" then
		if can_access(pos, clicker) then
			switch_on(pos)
			local mem = techage.get_mem(pos)
			mem.clicker = clicker and clicker:get_player_name()
			mem.time = math.floor(minetest.get_us_time() / 100000)
		end
	end
end

local function on_rightclick_off(pos, node, clicker)
	local meta = M(pos)
	local numbers = meta:get_string("numbers")
	local cycle_time = meta:get_int("cycle_time") or 0
	if numbers ~= "" and numbers ~= nil and cycle_time == 0 then
		if can_access(pos, clicker) then
			switch_off(pos)
		end
	end
end

local function techage_set_numbers(pos, numbers, player_name)
	local meta = M(pos)
	local res = logic.set_numbers(pos, numbers, player_name, NDEF(pos).description)
	meta:set_string("formspec", formspec(meta))
	return res
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	techage.remove_node(pos, oldnode, oldmetadata)
end

minetest.register_node("techage:ta3_button_off", {
	description = S("TA3 Button/Switch"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_button_off.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta3_button_off", S("TA3 Button/Switch"))
		logic.infotext(meta, S("TA3 Button/Switch"))
		meta:set_string("formspec", formspec(meta))
		meta:set_string("public", "false")
		meta:set_int("cycle_time", 0)
	end,

	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick_on,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,

	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:ta3_button_on", {
	description = ("TA3 Button/Switch"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_button.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_button_on.png",
	},

	on_rightclick = on_rightclick_off,
	on_timer = switch_off,
	on_rotate = screwdriver.disallow,
	techage_set_numbers = techage_set_numbers,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "techage:ta3_button_off",
})

minetest.register_node("techage:ta4_button_off", {
	description = S("TA4 Button/Switch"),
	inventory_image = "techage_smartline_button_inv.png",
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_smartline_button_off.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta4_button_off", S("TA4 Button/Switch"))
		logic.infotext(meta, S("TA4 Button/Switch"))
		meta:set_string("formspec", formspec(meta))
		meta:set_string("public", "false")
		meta:set_int("cycle_time", 0)
	end,

	ta4_formspec = WRENCH_MENU,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick_on,
	techage_set_numbers = techage_set_numbers,
	after_dig_node = after_dig_node,

	on_rotate = screwdriver.disallow,
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("techage:ta4_button_on", {
	description = ("TA4 Button/Switch"),
	inventory_image = "techage_smartline_button_inv.png",
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_smartline_button_on.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/32, -6/32, 14/32,  6/32,  6/32, 16/32},
		},
	},

	on_rightclick = on_rightclick_off,
	on_timer = switch_off,
	on_rotate = screwdriver.disallow,
	techage_set_numbers = techage_set_numbers,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	drop = "techage:ta4_button_off",
})

minetest.register_craft({
	output = "techage:ta3_button_off",
	recipe = {
		{"", "group:wood", ""},
		{"default:glass", "techage:vacuum_tube", ""},
		{"", "group:wood", ""},
	},
})

minetest.register_craft({
	output = "techage:ta4_button_off",
	recipe = {
		{"", "techage:aluminum", "dye:blue"},
		{"", "default:glass", "techage:ta4_wlanchip"},
		{"", "", ""},
	},
})

techage.register_node({
		"techage:ta4_button_off", "techage:ta4_button_on",
	}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "name" then
				local mem = techage.get_mem(pos)
				return mem.clicker or ""
			elseif topic == "time" then
				local mem = techage.get_mem(pos)
				return mem.time or 0
			else
				return "unsupported"
			end
		end,
		on_beduino_request_data = function(pos, src, topic, payload)
			if topic == 144 then  -- Player Name
				local mem = techage.get_mem(pos)
				return 0, mem.clicker
			elseif topic == 149 then  --time
				local mem = techage.get_mem(pos)
				return 0, {mem.time or 0}
			else
				return 2, ""
			end
		end,
	}
)
