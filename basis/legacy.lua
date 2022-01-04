--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	For the transition from v0.26 to v1.0

]]--

function techage.register_node_for_v1_transition(nodenames, on_node_load)
	minetest.register_lbm({
		label = "[TechAge] V1 transition",
		name = nodenames[1].."transition",
		nodenames = nodenames,
		run_at_every_load = false,
		action = function(pos, node)
			on_node_load(pos, node)
		end
	})
end
