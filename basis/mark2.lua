--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
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
		--use_texture_alpha = true,
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

