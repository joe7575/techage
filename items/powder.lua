--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
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

minetest.register_craftitem("techage:iron_powder", {
	description = S("Iron Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#c7643d:160",
	groups = {powder = 1},
})

minetest.register_craftitem("techage:clay_powder", {
	description = S("Clay Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#F9DE80:160",
	groups = {powder = 1},
})

minetest.register_craftitem("techage:aluminum_powder", {
	description = S("Aluminum Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#A1BDC4:160",
	groups = {powder = 1},
})

minetest.register_craftitem("techage:silver_sandstone_powder", {
	description = S("Silver Sandstone Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#FFFFFF:160",
	groups = {powder = 1},
})

minetest.register_craftitem("techage:graphite_powder", {
	description = S("Graphite Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#000000:160",
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
techage.add_grinder_recipe({input="default:iron_lump", output="techage:iron_powder"})
techage.add_grinder_recipe({input="default:clay", output="techage:clay_powder"})
techage.add_grinder_recipe({input="techage:aluminum", output="techage:aluminum_powder"})
techage.add_grinder_recipe({input="default:silver_sandstone", output="techage:silver_sandstone_powder"})
techage.add_grinder_recipe({input="default:coal_lump", output="techage:graphite_powder"})

