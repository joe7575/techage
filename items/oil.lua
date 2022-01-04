--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Oil

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S = techage.S

minetest.register_node("techage:oil_source", {
    description = S("Oil Source"),
	drawtype = "liquid",
    paramtype = "light",

    inventory_image = "techage_liquid2_inv.png^[colorize:#000000^techage_liquid1_inv.png",
    tiles = {
        {
            name = "techage_oil_animated.png",
			backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length   = 10
            }
        },
        {
            name = "techage_oil_animated.png",
			backface_culling = false,
            animation = {
				type = "vertical_frames",
				aspect_w = 16,
                aspect_h = 16,
				length = 2.0
			}
        }
    },

    walkable     = false,
    pointable    = false,
    diggable     = false,
    buildable_to = true,
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "techage:oil_flowing",
    liquid_alternative_source = "techage:oil_source",
    liquid_viscosity = 20,
    liquid_range = 10,
	liquid_renewable = false,
	post_effect_color = {a = 200, r = 1, g = 1, b = 1},
	groups = {liquid = 5, ta_liquid = 1},
})

minetest.register_node("techage:oil_flowing", {
	description = S("Flowing Oil"),
	drawtype = "flowingliquid",
	tiles = {"techage_oil.png"},
	special_tiles = {
		{
			name = "techage_oil_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 10,
			},
		},
		{
			name = "techage_oil_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 10,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	liquid_renewable = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "techage:oil_flowing",
	liquid_alternative_source = "techage:oil_source",
	liquid_viscosity = 20,
	liquid_range = 10,
	post_effect_color = {a = 200, r = 1, g = 1, b = 1},
	groups = {liquid = 5, not_in_creative_inventory = 1},
})

minetest.register_craft({
	type = "fuel",
	recipe = "techage:oil_source",
	burntime = 30,
})

bucket.register_liquid(
	"techage:oil_source",
	"techage:oil_flowing",
	"techage:bucket_oil",
	"techage_bucket_oil.png",
	"Oil Bucket")

minetest.register_craftitem("techage:ta3_barrel_oil", {
	description = S("TA3 Oil Barrel"),
	inventory_image = "techage_barrel_inv.png^[colorize:#000000:120^techage_symbol_liquid.png",
	stack_max = 1,
})

minetest.register_craftitem("techage:ta3_canister_oil", {
	description = S("TA3 Oil Canister"),
	inventory_image = "techage_canister_filling.png^[colorize:#000000^techage_canister_frame.png^techage_symbol_liquid.png",
	stack_max = 1,
})

techage.register_liquid("techage:bucket_oil", "bucket:bucket_empty", 1, "techage:oil_source")
techage.register_liquid("techage:ta3_barrel_oil", "techage:ta3_barrel_empty", 10, "techage:oil_source")
techage.register_liquid("techage:ta3_canister_oil", "techage:ta3_canister_empty", 1, "techage:oil_source")
