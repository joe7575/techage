--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	GPL v3
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
})

function techage.light_ring(center_pos, on)
	for _,dir in ipairs(Positions) do
		local pos1 = vector.add(center_pos, dir)
		local node = techage.get_node_lvm(pos1)
		print("light_ring", node.name, minetest.pos_to_string(pos1))
		if on then
			if node.name == "air" then
				minetest.set_node(pos1, {name = "techage:lightblock"})
			end
		else
			if node.name == "techage:lightblock" then
				minetest.remove_node(pos1)
			end
		end
	end
	local pos1 = {x=center_pos.x-2, y=center_pos.y-2, z=center_pos.z-2}
	local pos2 = {x=center_pos.x+2, y=center_pos.y+2, z=center_pos.z+2}
	minetest.fix_light(pos1, pos2)
end
				