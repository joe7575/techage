--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Laser basis functions

]]--

local Entities = {}
local SIZES = {1, 2, 3, 6, 12, 24, 48}  -- for laser entities
local GAP_MIN = 1                       -- between 2 blocks
local GAP_MAX = 2 * 48                  -- between 2 blocks

-- Return the area (pos1,pos2) for a destination node
local function get_pos_range(pos, dir)
	local pos1 = vector.add(pos, vector.multiply(dir, GAP_MIN + 1))  -- min
	local pos2 = vector.add(pos, vector.multiply(dir, GAP_MAX + 1))  -- max
	return pos1, pos2
end

-- Return first pos after start pos and the destination pos
local function get_positions(pos, mem, dir)
	local pos1 = vector.add(pos, dir)  -- start pos
	local _, pos2 = get_pos_range(pos, dir)  -- last pos
	local _, pos3 = minetest.line_of_sight(pos1, pos2)
	pos3 = pos3 or pos2  -- destination node pos
	if not mem.peer_node_pos or not vector.equals(pos3, mem.peer_node_pos) then
		mem.peer_node_pos = pos3
		local dist = vector.distance(pos1, pos3)
		if dist > GAP_MIN and dist <= GAP_MAX then
			return true, pos1, pos3  -- new values
		else
			return false -- invalid values
		end
	end
	return true  -- no new values
end

-- return for both laser entities the pos and length
local function get_laser_length_and_pos(pos1, pos2, dir)
	local dist = vector.distance(pos1, pos2)

	for _, size in ipairs(SIZES) do
		if dist <= (size * 2) then
			pos1 = vector.add     (pos1, vector.multiply(dir, (size / 2) - 0.5))
			pos2 = vector.subtract(pos2, vector.multiply(dir, (size / 2) + 0.5))
			return size, pos1, pos2
		end
	end
end

local function del_laser(pos)
	local key = minetest.hash_node_position(pos)
	local items = Entities[key]
	if items then
		local laser1, laser2 = items[1], items[2]
		laser1:remove()
		laser2:remove()
		Entities[key] = nil
	end
	return key
end

local function add_laser(pos, pos1, pos2, size, param2)
	local key = del_laser(pos)

	local laser1 = minetest.add_entity(pos1, "techage:laser" .. size)
	if laser1 then
		local yaw = math.pi / 2 * (param2 + 1)
		laser1:set_rotation({x = 0, y = yaw, z = 0})
	end

	local laser2 = minetest.add_entity(pos2, "techage:laser" .. size)
	if laser2 then
		param2 = (param2 + 2) % 4  -- flip dir
		local yaw = math.pi / 2 * (param2 + 1)
		laser2:set_rotation({x = 0, y = yaw, z = 0})
	end

	Entities[key] = {laser1, laser2}
end

for _, size in ipairs(SIZES) do
	minetest.register_entity("techage:laser" .. size, {
		initial_properties = {
			visual = "cube",
			textures = {
				"techage_laser.png",
				"techage_laser.png",
				"techage_laser.png",
				"techage_laser.png",
				"techage_laser.png",
				"techage_laser.png",
			},
			use_texture_alpha = true,
			physical = false,
			collide_with_objects = false,
			pointable = false,
			static_save = false,
			visual_size = {x = size, y = 0.05, z = 0.05},
			glow = 14,
			shaded = true,
		},
	})
end

-------------------------------------------------------------------------------
-- API functions
-------------------------------------------------------------------------------
-- if force is not true, do not redraw the laser if nothing has changed
function techage.renew_laser(pos, force)
	local mem = techage.get_mem(pos)
	if force then
		mem.peer_node_pos = nil
		mem.param2 = nil
	end
	mem.param2 = mem.param2 or minetest.get_node(pos).param2
	local dir = minetest.facedir_to_dir(mem.param2)
	local res, pos1, pos2 = get_positions(pos, mem, dir)
	if pos1 then
		local size, pos3, pos4 = get_laser_length_and_pos(pos1, pos2, dir)
		if size then
			add_laser(pos, pos3, pos4, size, mem.param2)
			return res, pos1, pos2
		end
	end
	return res
end

function techage.add_laser(pos, pos1, pos2)
	local dir = vector.direction(pos1, pos2)
	local param2 = minetest.dir_to_facedir(dir)
	local size, pos3, pos4 = get_laser_length_and_pos(pos1, pos2, dir)
	if size then
		add_laser(pos, pos3, pos4, size, param2)
	end
end

-- techage.del_laser(pos)
techage.del_laser = del_laser
