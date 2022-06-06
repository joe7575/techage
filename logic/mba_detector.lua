--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Mapblock Active Detector

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic

minetest.register_node("techage:ta4_mbadetector", {
	description = "TA4 Mapblock Active Detector",
	inventory_image = 'techage_smartline_mba_detector_inv.png',
	tiles = {
		-- up, down, right, left, back, front
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png",
		"techage_smartline.png^techage_smartline_mba_detector.png",
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
		logic.after_place_node(pos, placer, "techage:ta4_mbadetector", S("TA4 Mapblock Active Detector"))
		logic.infotext(meta, S("TA4 Mapblock Active Detector"))
		minetest.get_node_timer(pos):start(1)
	end,

	on_timer =  function(pos, elapsed)
		local mem = techage.get_mem(pos)
		mem.gametime = minetest.get_gametime()
		return true
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techage:ta4_mbadetector",
	recipe = {
		{"", "group:wood", "default:mese_crystal"},
		{"", "techage:vacuum_tube", "default:copper_ingot"},
		{"", "group:wood", ""},
	},
})

techage.register_node({"techage:ta4_mbadetector"}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "state" then
				if minetest.compare_block_status then
					if minetest.compare_block_status(pos, "active") then
						return "on"
					else
						return "off"
					end
				else
					local mem = techage.get_mem(pos)
					local res = mem.gametime and mem.gametime > (minetest.get_gametime() - 2)
					return res and "on" or "off"
				end
			else
				return "unsupported"
			end
		end,
		on_beduino_request_data = function(pos, src, topic, payload)
			if topic == 142 then  -- Binary State
				if minetest.compare_block_status then
					if minetest.compare_block_status(pos, "active") then
						return 0, {1}
					else
						return 0, {0}
					end
				else
					local mem = techage.get_mem(pos)
					local res = mem.gametime and mem.gametime > (minetest.get_gametime() - 2)
					return 0, {res and 1 or 0}
				end
			else
				return 2, ""
			end
		end,
		on_node_load = function(pos)
			minetest.get_node_timer(pos):start(1)
		end,
	}
)
