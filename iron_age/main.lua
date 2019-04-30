--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
]]--

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local S, NS = dofile(MP.."/intllib.lua")

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

techage.register_chap_page("Iron Age (TA1)", S([[Iron Age is the first level of the available technic stages.
The goal of TA1 is to collect and craft enough XYZ Ingots
to be able to build machines for stage 2 (TA2).
1. You have to collect dirt and wood to build a Coal Pile.
    (The Coal Pile is needed to produce charcoal)
2. Build a Coal Burner to melt iron to steel ingots.
3. Craft a Gravel Sieve and collect gravel.
    (A Hammer can be used to smash cobble to gravel)
4. Sieve the gravel to get the necessary ores
]]))

