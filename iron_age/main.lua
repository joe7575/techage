--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

function techage.ironage_swap_node(pos, name)
	minetest.swap_node(pos, {name = name})
	local node = minetest.registered_nodes[name]
	if node.on_construct then
		node.on_construct(pos)
	end
	if node.after_place_node then
		node.after_place_node(pos)
	end
end

function techage.ironage_swap_nodes(pos1, pos2, name1, name2)
	for _,p in ipairs(minetest.find_nodes_in_area(pos1, pos2, name1)) do
		techage.ironage_swap_node(p, name2)
	end
end
