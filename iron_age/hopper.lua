--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Simple TA1 Hopper

]]--

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

-- use the minecart hopper
minetest.register_alias("techage:hopper_ta1", "minecart:hopper")


minecart.register_inventory(
	{
		"techage:chest_ta2", "techage:chest_ta3", "techage:chest_ta4",
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
		"techage:ta2_distributor_pas", "techage:ta2_distributor_act",
		"techage:ta3_distributor_pas", "techage:ta3_distributor_act",
		"techage:ta4_distributor_pas", "techage:ta4_distributor_act",
		"techage:ta4_high_performance_distributor_pas", "techage:ta4_high_performance_distributor_act",
	},
	{
		put = {
			allow_inventory_put = function(pos, stack, player_name)
				CRD(pos).State:start_if_standby(pos)
				return true
			end,
			listname = "src",
		},
		take = {
			listname = "src",
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
	}
)

minecart.register_inventory(
	{
		"techage:ta1_mill_base",
	},
	{
		put = {
			listname = "src",
		},
		take = {
			listname = "dst",
		},
	}
)
