--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Simple TA1 Hopper
	
]]--

-- use the minecart hopper
minetest.register_alias("techage:hopper_ta1", "minecart:hopper")


minecart.register_inventory(
	{
		"techage:chest_ta3", "techage:chest_ta4",
		"techage:meltingpot", "techage:meltingpot_active",
	}, 
	{
		put = {
			listname = "main",
		},
		take = {
			listname = "main",
		},
	}
)

minecart.register_inventory(
	{
		"techage:sieve0", "techage:sieve1", "techage:sieve2", "techage:sieve3",
	}, 
	{
		put = {
			allow_inventory_put = function(pos, stack, player_name)
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				if inv:is_empty("src") then
					minetest.get_node_timer(pos):start(1)
					return true
				end
			end, 
			listname = "src",
		},
		take = {
			listname = "src",
		},
	}
)
