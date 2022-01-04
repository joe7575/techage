--[[

	TechAge
	=======

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA1 Mill

]]--

local M = minetest.get_meta
local S = techage.S

local function start_mill(pos)
	local obj = minetest.add_entity(pos, "techage:ta1_mill_entity")
	minetest.remove_node(pos)
end

local function stop_mill(pos, self)
	minetest.swap_node(pos, {name = "techage:ta1_mill", param2 = 0})
	minetest.get_node_timer(pos):start(2)
	self.object:remove()
end

local function has_power(pos, y_offs)
	local pos1 = {x = pos.x, y = pos.y + y_offs, z = pos.z}
	local nvm = techage.get_nvm(pos1)
	nvm.watermill_trigger = (nvm.watermill_trigger or 1) - 1
	return nvm.watermill_trigger > 0
end

techage.ta1_mill_has_power = has_power

minetest.register_node("techage:ta1_mill_gear", {
	description = S("TA1 Mill Gear"),
	tiles = {
		"default_wood.png^techage_axle_bearing.png^[transformR90",
		"default_wood.png^techage_axle_bearing.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, -1/2,   1/2, -1/8,  1/2},
			{-1/8, -1/8, -1/2,   1/8,  1/8,  1/2},
		},
	},

	after_place_node = function(pos, placer)
		techage.TA1Axle:after_place_node(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.TA1Axle:after_dig_node(pos)
	end,

	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, crumbly = 2, choppy = 2},
})

techage.register_node({"techage:ta1_mill_gear"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == "trigger" then
			nvm.watermill_trigger = 4
			return true
		end
	end,
})

minetest.register_node("techage:ta1_mill", {
	description = S("TA1 Mill"),
	tiles = {
		-- up, down, right, left, back, front
			"techage_mill_side.png",
			"techage_mill_side.png",
			"techage_mill_side.png",
			"techage_mill_side.png",
			"techage_mill_front.png",
			"techage_mill_front.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -1/8, -1/8,   1/8,  4/8,  1/8},
			{-3/8, -3/8, -4/8,  -1/8,  3/8,  4/8},
			{-3/8, -4/8, -3/8,  -1/8,  4/8,  3/8},
			{ 1/8, -3/8, -4/8,   3/8,  3/8,  4/8},
			{ 1/8, -4/8, -3/8,   3/8,  4/8,  3/8},
		},
	},

	after_place_node = function(pos, placer)
		minetest.get_node_timer(pos):start(2)
	end,

	on_rightclick = function(pos, node, clicker)
		start_mill(pos)
	end,

	on_timer = function(pos, elapsed)
		if has_power(pos, 1) then
			start_mill(pos)
		end
		return true
	end,

	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, crumbly = 2, choppy = 2},
})

minetest.register_entity("techage:ta1_mill_entity", {
	initial_properties = {
		physical = true,
		visual = "wielditem",
		wield_item = "techage:ta1_mill",
		visual_size = {x=0.67, y=0.67, z=0.67},
		static_save = true,
		automatic_rotate = -math.pi * 0.2,
		pointable = false,
	},

	on_step = function(self, dtime)
		self.dtime = (self.dtime or 0) + dtime

		if self.dtime > 2 then
			local pos = vector.round(self.object:get_pos())
			if not has_power(pos, 1) then
				stop_mill(pos, self)
			end
			self.dtime = 0
			minetest.sound_play("techage_mill", {gain = 0.3, pos = pos,
			max_hear_distance = 10}, true)
		end
	end,

	on_rightclick = function(self, clicker)
		local pos = vector.round(self.object:get_pos())
		stop_mill(pos, self)
	end,
})

techage.register_node({"techage:ta1_mill"}, {
	on_node_load = function(pos, node)
		minetest.get_node_timer(pos):start(2)
	end,
})

minetest.register_craft({
	output = "techage:ta1_mill_gear",
	recipe = {
		{"default:wood", "", "default:wood"},
		{"techage:ta1_axle", "default:wood", "techage:ta1_axle"},
		{"default:wood", "techage:ta1_axle", "default:wood"},
	},
})

minetest.register_craft({
	output = "techage:ta1_mill",
	recipe = {
		{"", "techage:iron_ingot", ""},
		{"stairs:slab_stone", "techage:iron_ingot", "stairs:slab_stone"},
		{"", "", ""},
	},
})
