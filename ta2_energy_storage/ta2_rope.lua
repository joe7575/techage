--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Rope for TA2 gravity-based energy storage

]]--

local Entities = {}

-- Return first pos after start pos and the destination pos
local function get_positions(pos, length, force)
	local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}  -- start pos
	local pos2 = {x = pos.x, y = pos.y - 1 - length, z = pos.z}  -- end pos
	if force then
		return pos1, pos2  -- force given length
	end
	local _, pos3 = minetest.line_of_sight(pos1, pos2)
	return pos1, pos3 or pos2  -- new values
end

local function del_rope(pos)
	local key = minetest.hash_node_position(pos)
	local rope = Entities[key]
	if rope then
		rope:remove()
		Entities[key] = nil
	end
	return key
end

local function add_rope(pos, pos1, pos2)
	local key = del_rope(pos)

	pos1.y = pos1.y + 0.5  -- from
	pos2.y = pos2.y - 0.5  -- to
	local pos3 = {x = pos1.x, y = (pos1.y + pos2.y) / 2, z = pos1.z}  -- mid-pos
	local length = math.abs(pos1.y - pos2.y)

	local rope = minetest.add_entity(pos3, "techage:ta2_rope")
	if rope then
		rope:set_properties({visual_size = {x = 0.06, y = length}, collisionbox = {x = 0.06, y = length}})
	end
	Entities[key] = rope
end

minetest.register_entity("techage:ta2_rope", {
	initial_properties = {
		visual = "cube",
		textures = {
			"techage_rope.png",
			"techage_rope.png",
			"techage_rope.png",
			"techage_rope.png",
			"techage_rope.png",
			"techage_rope.png",
		},
		use_texture_alpha = false,
		physical = true,
		collide_with_objects = true,
		pointable = true,
		static_save = false,
		visual_size = {x = 0.06, y = 10, z = 0.06},
		shaded = true,
	},
})

-------------------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------------------
function techage.renew_rope(pos, length, force)
	local pos1, pos2 = get_positions(pos, length, force)
	if pos1 then
		add_rope(pos, pos1, pos2)
		return pos1, pos2
	end
end

techage.del_rope = del_rope
