--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Powder 
	
]]--

local S = techage.S

minetest.register_craftitem("techage:leave_powder", {
	description = S("Leave Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#71a157:120",
	groups = {powder = 1},
})

minetest.register_craftitem("techage:needle_powder", {
	description = S("Needle Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#1c800f:120",
	groups = {powder = 1},
})

techage.add_grinder_recipe({input="default:acacia_bush_leaves", output="techage:leave_powder"})
techage.add_grinder_recipe({input="default:acacia_leaves", output="techage:leave_powder"})
techage.add_grinder_recipe({input="default:aspen_leaves", output="techage:leave_powder"})
techage.add_grinder_recipe({input="default:blueberry_bush_leaves", output="techage:leave_powder"})
techage.add_grinder_recipe({input="default:bush_leaves", output="techage:leave_powder"})
techage.add_grinder_recipe({input="default:jungleleaves", output="techage:leave_powder"})
techage.add_grinder_recipe({input="default:leaves", output="techage:leave_powder"})

techage.add_grinder_recipe({input="default:pine_needles", output="techage:needle_powder"})

