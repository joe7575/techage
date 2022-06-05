--[[

	TechAge
	=======

	Copyright (C) 2021-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Sound Block

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local t = {}
for idx, ogg in ipairs(techage.OggFileList) do
	t[idx] = idx .. "," .. ogg
end
local OGG_FILES = table.concat(t, ",")

local logic = techage.logic

local GAIN = {0.05 ,0.1, 0.2, 0.5, 1.0}


local function play_sound(pos, ogg, gain)
	minetest.sound_play(ogg, {
		pos = pos,
		gain = GAIN[gain or 1] or 1,
		max_hear_distance = 15})
end

local function formspec(meta)
	local idx = meta:contains("idx") and meta:get_int("idx") or 1
	local gain = meta:contains("gain") and meta:get_int("gain") or 1
	return "size[8,8]"..
		"tablecolumns[text,width=5;text]"..
		"table[0,0;8,6;oggfiles;" .. OGG_FILES .. ";" .. idx .. "]" ..
		"dropdown[0,6.5;5.5,1.4;gain;1,2,3,4,5;" .. gain .. "]" ..
		"button[2.5,7.2;3,1;play;" .. S("Play") .. "]"
end

local function play_predefined_sound(pos)
	local mem = techage.get_mem(pos)
	if not mem.blocking_time or (mem.blocking_time < minetest.get_gametime()) then
		local idx = M(pos):get_int("idx")
		local ogg = techage.OggFileList[idx or 1] or techage.OggFileList[1]
		local gain = M(pos):get_int("gain")
		play_sound(pos, ogg, gain)
		mem.blocking_time = minetest.get_gametime() + 2
		return true
	end
end

minetest.register_node("techage:ta3_soundblock", {
	description = S("TA3 Sound Block"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_sound.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		logic.after_place_node(pos, placer, "techage:ta3_soundblock", S("TA3 Sound Block"))
		logic.infotext(meta, S("TA3 Sound Block"))
		meta:set_string("formspec", formspec(meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		if fields.oggfiles then
			local mem = techage.get_mem(pos)
			local t = minetest.explode_table_event(fields.oggfiles)
			mem.idx = t.row
		end
		if fields.gain then
			M(pos):set_int("gain", tonumber(fields.gain) or 1)
		end
		if fields.play then
			local mem = techage.get_mem(pos)
			M(pos):set_int("idx", mem.idx or 1)
			local ogg = techage.OggFileList[mem.idx or 1] or techage.OggFileList[1]
			play_sound(pos, ogg, M(pos):get_int("gain"))
		end
	end,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local INFO = [[Commands: 'on', 'sound', 'gain']]

techage.register_node({"techage:ta3_soundblock"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "info" then
			return INFO
		elseif topic == "on" then
			play_predefined_sound(pos)
		elseif topic == "sound" then
			M(pos):set_int("idx", tonumber(payload or 1) or 1)
		elseif topic == "gain" then
			M(pos):set_int("gain", tonumber(payload or 1) or 1)
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 1 then
			if payload[1] == 0 then
				play_predefined_sound(pos)
				return 0
			end
		elseif topic == 14 then
			if payload[1] == 1 then
				M(pos):set_int("gain", payload[2])
				return 0
			elseif payload[1] == 2 then
				M(pos):set_int("idx", payload[2])
				return 0
			end
		end
		return 2  -- unknown or invalid topic
	end,
	on_node_load = function(pos)
		local meta = M(pos)
		meta:set_string("formspec", formspec(meta))
	end
})

minetest.register_craft({
	output = "techage:ta3_soundblock",
	recipe = {
		{"", "group:wood",""},
		{"techage:vacuum_tube", "basic_materials:gold_wire", "techage:usmium_nuggets"},
		{"", "group:wood", ""},
	},
})
