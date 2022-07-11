--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	mark.lua:

]]--

local marker_region = {}

function techage.unmark_position(name)
	if marker_region[name] ~= nil then --marker already exists
		--wip: make the area stay loaded somehow
		for _, entity in ipairs(marker_region[name]) do
			entity:remove()
		end
		marker_region[name] = nil
	end
end

function techage.mark_position(name, pos, nametag, color, time)
	local marker = minetest.add_entity(pos, "techage:position_cube")
	if marker ~= nil then
		marker:set_nametag_attributes({color = color, text = nametag})
		marker:get_luaentity().player_name = name
		if not marker_region[name] then
			marker_region[name] = {}
		end
		marker_region[name][#marker_region[name] + 1] = marker
	end
	minetest.after(time or 30, techage.unmark_position, name)
end

function techage.mark_cube(name, pos1, pos2, nametag, color, time)
	local new_x = pos1.x + ((pos2.x - pos1.x) / 2)
	local new_y = pos1.y + ((pos2.y - pos1.y) / 2)
	local new_z = pos1.z + ((pos2.z - pos1.z) / 2)
	local size_x = math.abs(pos1.x - pos2.x)  + 1
	local size_y = math.abs(pos1.y - pos2.y)  + 1
	local size_z = math.abs(pos1.z - pos2.z)  + 1

	local marker = minetest.add_entity(
		{x = new_x, y = new_y, z = new_z}, "techage:position_cube")
	if marker ~= nil then
		marker:set_nametag_attributes({color = color, text = nametag, visual_size = {x = size_x, y = size_y, z = size_z}})
		marker:get_luaentity().player_name = name
		marker:set_properties({visual_size = {x = size_x, y = size_y, z = size_z}})
		if not marker_region[name] then
			marker_region[name] = {}
		end
		marker_region[name][#marker_region[name] + 1] = marker
	end
	minetest.after(time or 30, techage.unmark_position, name)
end

minetest.register_entity(":techage:position_cube", {
	initial_properties = {
		visual = "cube",
		textures = {
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
		},
		use_texture_alpha = techage.BLEND,
		physical = false,
		visual_size = {x = 1.1, y = 1.1},
		collisionbox = {-0.55,-0.55,-0.55, 0.55,0.55,0.55},
		glow = 8,
	},
	on_step = function(self, dtime)
		if marker_region[self.player_name] == nil then
			self.object:remove()
			return
		end
	end,
	on_punch = function(self, hitter)
		techage.unmark_position(self.player_name)
	end,
})

function techage.mark_side(name, pos, dir, nametag, color, time)
	local v = vector.multiply(tubelib2.Dir6dToVector[dir or 0], 0.7)
	local pos2 = vector.add(pos, v)

	local marker = minetest.add_entity(pos2, "techage:position_side")
	if marker ~= nil then
		marker:set_nametag_attributes({color = color, text = nametag})
		marker:get_luaentity().player_name = name
		if dir == 2 or dir == 4 then
			marker:setyaw(math.pi / 2)
		end

		if not marker_region[name] then
			marker_region[name] = {}
		end
		marker_region[name][#marker_region[name] + 1] = marker
	end
	minetest.after(time or 30, techage.unmark_position, name)
end

minetest.register_entity(":techage:position_side", {
	initial_properties = {
		visual = "upright_sprite",
		textures = {"techage_side_mark.png"},
		physical = false,
		visual_size = {x = 1.1, y = 1.1, z = 1.1},
		collisionbox = {-0.55,-0.55,-0.55, 0.55,0.55,0.55},
		glow = 12,
	},
	on_step = function(self, dtime)
		if marker_region[self.player_name] == nil then
			self.object:remove()
			return
		end
	end,
	on_punch = function(self, hitter)
		techage.unmark_position(self.player_name)
	end,
})
