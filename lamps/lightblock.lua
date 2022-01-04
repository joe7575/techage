--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Invisible Light Block

]]--

local S = techage.S

-- 9 light positions in a 3x3 field
local Positions = {
	{x =-1, y = 0, z = 0},
	{x = 0, y = 0, z =-1},
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x =-1, y = 0, z =-1},
	{x = 1, y = 0, z = 1},
	{x =-1, y = 0, z = 1},
	{x = 1, y = 0, z =-1},
}

minetest.register_node("techage:lightblock", {
	description = "Techage Light Block",
	drawtype = "airlike",
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = true,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
	drop = "",
})

function techage.light_ring(center_pos, on, large)
	if on then
		for _,dir in ipairs(Positions) do
			if large then
				dir = vector.multiply(dir, 2)
			end
			local pos1 = vector.add(center_pos, dir)
			local node = techage.get_node_lvm(pos1)
			if node.name == "air" then
				minetest.set_node(pos1, {name = "techage:lightblock"})
			end
		end
	else
		local pos1 = {x=center_pos.x-2, y=center_pos.y-2, z=center_pos.z-2}
		local pos2 = {x=center_pos.x+2, y=center_pos.y+2, z=center_pos.z+2}
		for _,pos in ipairs(minetest.find_nodes_in_area(pos1, pos2, "techage:lightblock")) do
			minetest.remove_node(pos)
		end
		minetest.fix_light(pos1, pos2)
	end
end
