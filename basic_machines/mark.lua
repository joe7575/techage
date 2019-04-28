--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	mark.lua:
	
]]--

local marker_region = {}

function techage.unmark_region(name)
	if marker_region[name] ~= nil then --marker already exists
		--wip: make the area stay loaded somehow
		for _, entity in ipairs(marker_region[name]) do
			entity:remove()
		end
		marker_region[name] = nil
	end
end

function techage.mark_region(name, pos1, pos2)

	techage.unmark_region(name)
	
	local thickness = 0.2
	local sizex, sizey, sizez = (1 + pos2.x - pos1.x) / 2, (1 + pos2.y - pos1.y) / 2, (1 + pos2.z - pos1.z) / 2
	local markers = {}

	--XY plane markers
	for _, z in ipairs({pos1.z - 0.5, pos2.z + 0.5}) do
		local marker = minetest.add_entity({x=pos1.x + sizex - 0.5, y=pos1.y + sizey - 0.5, z=z}, "techage:region_cube")
		if marker ~= nil then
			marker:set_properties({
				visual_size={x=sizex * 2, y=sizey * 2},
				collisionbox = {-sizex, -sizey, -thickness, sizex, sizey, thickness},
			})
			marker:get_luaentity().player_name = name
			table.insert(markers, marker)
		end
	end

	--YZ plane markers
	for _, x in ipairs({pos1.x - 0.5, pos2.x + 0.5}) do
		local marker = minetest.add_entity({x=x, y=pos1.y + sizey - 0.5, z=pos1.z + sizez - 0.5}, "techage:region_cube")
		if marker ~= nil then
			marker:set_properties({
				visual_size={x=sizez * 2, y=sizey * 2},
				collisionbox = {-thickness, -sizey, -sizez, thickness, sizey, sizez},
			})
			marker:setyaw(math.pi / 2)
			marker:get_luaentity().player_name = name
			table.insert(markers, marker)
		end
	end

	marker_region[name] = markers
end

function techage.switch_region(name, pos1, pos2)
	if marker_region[name] ~= nil then --marker already exists
		techage.unmark_region(name)
	else
		techage.mark_region(name, pos1, pos2)
	end
end

minetest.register_entity(":techage:region_cube", {
	initial_properties = {
		visual = "upright_sprite",
		visual_size = {x=1.1, y=1.1},
		textures = {"techage_cube_mark.png"},
		use_texture_alpha = true,
		visual_size = {x=10, y=10},
		physical = false,
	},
	on_step = function(self, dtime)
		if marker_region[self.player_name] == nil then
			self.object:remove()
			return
		end
	end,
	on_punch = function(self, hitter)
		techage.unmark_region(self.player_name)
	end,
})

