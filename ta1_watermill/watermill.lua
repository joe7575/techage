--[[

	TechAge
	=======

	Copyright (C) 2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA1 Watermill

]]--

local M = minetest.get_meta
local S = techage.S

local function calc_dir(dir, facedir)
	if facedir == 1 then
		return {x = dir.z, y = dir.y, z = -dir.x}
	elseif facedir == 2 then
		return {x = -dir.x, y = dir.y, z = -dir.z}
	elseif facedir == 3 then
		return {x = -dir.z, y = dir.y, z = dir.x}
	end
	return {x = dir.x, y = dir.y, z = dir.z}
end

local function add_node(pos, dir, facedir, node_name)
	local pos2 = vector.add(pos, calc_dir(dir, facedir))
	local node = minetest.get_node(pos2)
	if techage.is_air_like(node.name) then
		minetest.swap_node(pos2, {name = node_name})
	end
end

local function remove_node(pos, dir, facedir, node_name)
	local pos2 = vector.add(pos, calc_dir(dir, facedir))
	local node = minetest.get_node(pos2)
	if node.name == node_name then
		minetest.swap_node(pos2, {name = "air"})
	end
end

local function water_flowing(pos, facedir, tRes)
	facedir = ((facedir or 0) + 1) % 4
	local dir =  minetest.facedir_to_dir(facedir)

	local pos2 = vector.add(pos, dir)
	pos2.y = pos2.y + 1
	local node = minetest.get_node(pos2)
	if node.name == "default:water_flowing" then
		tRes.backward = false
		return true
	end

	pos2 = vector.subtract(pos, dir)
	pos2.y = pos2.y + 1
	node = minetest.get_node(pos2)
	if node.name == "default:water_flowing" then
		tRes.backward = true
		return true
	end
end

local function enough_space(pos, facedir)
	local pos1 = vector.add(pos, calc_dir({x =-1, y =-1, z = 0}, facedir))
	local pos2 = vector.add(pos, calc_dir({x = 1, y = 1, z = 0}, facedir))
	local _, nodes = minetest.find_nodes_in_area(pos1, pos2, {"air"})
	return nodes["air"] and nodes["air"] == 8
end

local function remove_nodes(pos, facedir)
	remove_node(pos, {x = 0, y = 1, z = 0}, facedir, "techage:water_stop")
	remove_node(pos, {x =-1, y = 0, z = 0}, facedir, "techage:water_stop")
	remove_node(pos, {x = 1, y = 0, z = 0}, facedir, "techage:water_stop")
	remove_node(pos, {x =-1, y = 1, z =-1}, facedir, "techage:water_stop")
	remove_node(pos, {x = 1, y = 1, z =-1}, facedir, "techage:water_stop")
	remove_node(pos, {x =-1, y = 1, z = 1}, facedir, "techage:water_stop")
	remove_node(pos, {x = 1, y = 1, z = 1}, facedir, "techage:water_stop")
end

local function start_wheel(pos, facedir, backward)
	local obj = minetest.add_entity(pos, "techage:ta1_watermill_entity")
	local dir =  minetest.facedir_to_dir(facedir)
	local yaw = minetest.dir_to_yaw(dir)
	if backward then
		obj:set_rotation({x=-math.pi/2, y=yaw, z=0})
	else
		obj:set_rotation({x=math.pi/2, y=yaw, z=0})
	end
	local self = obj:get_luaentity()
	self.facedir = facedir

	add_node(pos, {x = 0, y = 1, z = 0}, facedir, "techage:water_stop")
	add_node(pos, {x =-1, y = 0, z = 0}, facedir, "techage:water_stop")
	add_node(pos, {x = 1, y = 0, z = 0}, facedir, "techage:water_stop")
	add_node(pos, {x =-1, y = 1, z =-1}, facedir, "techage:water_stop")
	add_node(pos, {x = 1, y = 1, z =-1}, facedir, "techage:water_stop")
	add_node(pos, {x =-1, y = 1, z = 1}, facedir, "techage:water_stop")
	add_node(pos, {x = 1, y = 1, z = 1}, facedir, "techage:water_stop")
	minetest.remove_node(pos)
end

local function stop_wheel(pos, self)
	self.facedir = self.facedir or 0
	if self.facedir == 0 or self.facedir == 2 then
		minetest.swap_node(pos, {name = "techage:ta1_watermill", param2 = 4})
		M(pos):set_int("facedir", self.facedir)
		minetest.get_node_timer(pos):start(2)
	elseif self.facedir == 1 or self.facedir == 3 then
		minetest.swap_node(pos, {name = "techage:ta1_watermill", param2 = 13})
		M(pos):set_int("facedir", self.facedir)
		minetest.get_node_timer(pos):start(2)
	end

	remove_nodes(pos, self.facedir)
	self.object:remove()
end

local function trigger_consumer(pos, facedir)
	local outdir = facedir + 1
	local resp = techage.transfer(
		pos,
		outdir,          -- outdir
		"trigger",       -- topic
		nil,             -- payload
		techage.TA1Axle, -- network
		nil)             -- valid nodes
	if not resp then
		outdir = tubelib2.Turn180Deg[outdir]
		resp = techage.transfer(
			pos,
			outdir,          -- outdir
			"trigger",       -- topic
			nil,             -- payload
			techage.TA1Axle, -- network
			nil)             -- valid nodes
	end
end

minetest.register_node("techage:ta1_watermill", {
	description = S("TA1 Watermill"),
	tiles = {
		-- up, down, right, left, back, front
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, -1/2, -1/2,   1/2, 1/2,  1/2},

			{-4.5/2, -1/2,  0.8/2,   4.5/2, 1/2,  1.0/2},
			{-4.5/2, -1/2, -1.0/2,   4.5/2, 1/2, -0.8/2},
			{-3.8/2, -1/2,  2.1/2,   3.8/2, 1/2,  2.3/2},
			{-3.8/2, -1/2, -2.3/2,   3.8/2, 1/2, -2.1/2},

			{ 0.8/2, -1/2, -4.5/2,   1.0/2, 1/2,  4.5/2},
			{-1.0/2, -1/2, -4.5/2,  -0.8/2, 1/2,  4.5/2},
			{ 2.1/2, -1/2, -3.8/2,   2.3/2, 1/2,  3.8/2},
			{-2.3/2, -1/2, -3.8/2,  -2.1/2, 1/2,  3.8/2},
		},
	},
	on_rightclick = function(pos, node, clicker)
		start_wheel(pos, M(pos):get_int("facedir"))
	end,

	on_timer = function(pos, elapsed)
		local tRes = {}
		if water_flowing(pos, M(pos):get_int("facedir"), tRes) then
			start_wheel(pos, M(pos):get_int("facedir"), tRes.backward)
		end
		return true
	end,

	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, crumbly = 2, choppy = 2, not_in_creative_inventory = 1},
	node_placement_prediction = "",
	drop = "techage:ta1_watermill_inv",
})

-- A smaller one for the inventory
minetest.register_node("techage:ta1_watermill_inv", {
	description = S("TA1 Watermill"),
	--inventory_image = "techage_waterwheel_inv.png",
	--wield_image = "techage_waterwheel_inv.png",
	tiles = {
		-- up, down, right, left, back, front
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
		},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/4, -1/4, -1/4,   1/4, 1/4,  1/4},

			{-4.5/4,  0.8/4, -1/4,   4.5/4,  1.0/4, 1/4},
			{-4.5/4, -1.0/4, -1/4,   4.5/4, -0.8/4, 1/4},
			{-3.8/4,  2.1/4, -1/4,   3.8/4,  2.3/4, 1/4},
			{-3.8/4, -2.3/4, -1/4,   3.8/4, -2.1/4, 1/4},

			{ 0.8/4, -4.5/4, -1/4,   1.0/4,  4.5/4, 1/4},
			{-1.0/4, -4.5/4, -1/4,  -0.8/4,  4.5/4, 1/4},
			{ 2.1/4, -3.8/4, -1/4,   2.3/4,  3.8/4, 1/4},
			{-2.3/4, -3.8/4, -1/4,  -2.1/4,  3.8/4, 1/4},
		},
	},

	after_place_node = function(pos, placer)
		local node = minetest.get_node(pos)
		M(pos):set_int("facedir", node.param2)
		remove_nodes(pos, node.param2)
		if (node.param2 == 0 or node.param2 == 2) and enough_space(pos, node.param2) then
			minetest.swap_node(pos, {name = "techage:ta1_watermill", param2 = 4})
			minetest.get_node_timer(pos):start(2)
		elseif (node.param2 == 1 or node.param2 == 3)  and enough_space(pos, node.param2) then
			minetest.swap_node(pos, {name = "techage:ta1_watermill", param2 = 13})
			minetest.get_node_timer(pos):start(2)
		else
			minetest.remove_node(pos)
			return true
		end
	end,

	paramtype2 = "facedir",
	node_placement_prediction = "",
	diggable = false,
})

techage.register_node({"techage:ta1_watermill"}, {
	on_node_load = function(pos, node)
		minetest.get_node_timer(pos):start(2)
	end,
})


minetest.register_entity("techage:ta1_watermill_entity", {
	initial_properties = {
		physical = true,
		collisionbox = {-0.5, -1.5, -1.5, 0.5, 1.5, 1.5},
		visual = "wielditem",
		wield_item = "techage:ta1_watermill",
		visual_size = {x=0.67, y=0.67, z=0.67},
		static_save = true,
		automatic_rotate = -math.pi * 0.2,
		pointable = false,
	},

	on_step = function(self, dtime)
		self.dtime = (self.dtime or 0) + dtime

		if self.dtime > 2 then
			self.dtime = 0
			local pos = vector.round(self.object:get_pos())
			if not water_flowing(pos, self.facedir, {}) then
				stop_wheel(pos, self)
			end
			trigger_consumer(pos, self.facedir)
			minetest.sound_play("techage_watermill", {gain = 0.5, pos = pos,
			max_hear_distance = 10}, true)
		end
	end,

	on_rightclick = function(self, clicker)
		local pos = vector.round(self.object:get_pos())
		stop_wheel(pos, self)
	end,

	on_activate = function(self, staticdata)
		self.facedir = tonumber(staticdata) or 0
	end,

	get_staticdata = function(self)
		return self.facedir
	end,
})

minetest.register_node("techage:water_stop", {
	description = "Water Stop",
	drawtype = "glasslike_framed_optional",
	tiles = {"techage_invisible.png"},
	inventory_image = 'techage_invisible_inv.png',

	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
	drop = "",
})

minetest.register_craft({
	output = "techage:ta1_watermill_inv",
	recipe = {
		{"techage:ta1_board1_apple", "techage:ta1_board1_apple", "techage:ta1_board1_apple"},
		{"techage:ta1_board1_apple", "default:wood", "techage:ta1_board1_apple"},
		{"techage:ta1_board1_apple", "techage:ta1_board1_apple", "techage:ta1_board1_apple"},
	},
})
