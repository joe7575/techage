--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	ICTA Controller - Signal Tower

]]--


local function switch_on(pos, node, color)
	local meta = minetest.get_meta(pos)
	meta:set_string("state", color)
	node.name = "techage:ta4_signaltower_"..color
	minetest.swap_node(pos, node)
end

local function switch_off(pos, node)
	local meta = minetest.get_meta(pos)
	meta:set_string("state", "off")
	node.name = "techage:ta4_signaltower"
	minetest.swap_node(pos, node)
end

minetest.register_node("techage:ta4_signaltower", {
	description = "TA4 Signal Tower",
	tiles = {
		'techage_signaltower_top.png',
		'techage_signaltower_top.png',
		'techage_signaltower.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -5/32, -16/32, -5/32,  5/32,  16/32, 5/32},
		},
	},

	after_place_node = function(pos, placer)
		local number = techage.add_node(pos, "techage:ta4_signaltower")
		local meta = minetest.get_meta(pos)
		meta:set_string("state", "off")
		meta:set_string("infotext", "TA4 Signal Tower "..number)
	end,

	on_rightclick = function(pos, node, clicker)
		if not minetest.is_protected(pos, clicker:get_player_name()) then
			switch_on(pos, node, "green")
		end
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

for _,color in ipairs({"green", "amber", "red"}) do
	minetest.register_node("techage:ta4_signaltower_"..color, {
		description = "TA4 Signal Tower",
		tiles = {
			'techage_signaltower_top.png',
			'techage_signaltower_top.png',
			'techage_signaltower_'..color..'.png',
		},

		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -5/32, -16/32, -5/32,  5/32,  16/32, 5/32},
			},
		},
		on_rightclick = function(pos, node, clicker)
			if not minetest.is_protected(pos, clicker:get_player_name()) then
				switch_off(pos, node)
			end
		end,

		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		light_source = 10,
		sunlight_propagates = true,
		paramtype2 = "facedir",
		groups = {crumbly=0, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
		drop = "techage:ta4_signaltower",
	})
end

minetest.register_craft({
	output = "techage:ta4_signaltower",
	recipe = {
		{"dye:red",    "default:copper_ingot", ""},
		{"dye:orange", "default:glass", ""},
		{"dye:green",  "techage:ta4_wlanchip", ""},
	},
})

techage.register_node({"techage:ta4_signaltower",
	"techage:ta4_signaltower_green",
	"techage:ta4_signaltower_amber",
	"techage:ta4_signaltower_red"}, {
	on_recv_message = function(pos, src, topic, payload)
		local node = minetest.get_node(pos)
		if topic == "green" then
			switch_on(pos, node, "green")
		elseif topic == "amber" then
			switch_on(pos, node, "amber")
		elseif topic == "red" then
			switch_on(pos, node, "red")
		elseif topic == "off" then
			switch_off(pos, node)
		elseif topic == "state" then
			local meta = minetest.get_meta(pos)
			return meta:get_string("state")
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 2 then
			local color = ({"green", "amber", "red"})[payload[1]]
			local node = minetest.get_node(pos)
			if color then
				switch_on(pos, node, color)
			else
				switch_off(pos, node)
			end
			return 0
		else
			return 2  -- unknown or invalid topic
		end
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		if topic == 130 then
			local meta = minetest.get_meta(pos)
			local color = ({off = 0, green = 1, amber = 2, red = 3})[meta:get_string("state")] or 1
			return 0, {color}
		else
			return 2, ""  -- unknown or invalid topic
		end
	end,
})
