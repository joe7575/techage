
--[[
stairsplus:register_all("moreblocks", "wood", "default:wood", {
		description = "Wooden",
		tiles = {"default_wood.png"},
		groups = {oddly_breakabe_by_hand=1},
		sounds = default.node_sound_wood_defaults(),
	})
]]--
local S = techage.S

local nodes = {
                {
                    subname = "red_stone",
                    item = "techage:red_stone",
                    desc = S("Red Stone"),
                    tile = {"default_stone.png^[colorize:#ff4538:110"},
                    group = {cracky = 3, stone = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "red_stone_brick",
                    item = "techage:red_stone_brick",
                    desc = S("Red Stone Brick"),
                    tile = {"default_stone_brick.png^[colorize:#ff4538:110"},
                    group = {cracky = 3, stone = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "red_stone_block",
                    item = "techage:red_stone_block",
                    desc = S("Red Stone Block"),
                    tile = {"default_stone_block.png^[colorize:#ff4538:110"},
                    group = {cracky = 3, stone = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "basalt_stone",
                    item = "techage:basalt_stone",
                    desc = S("Basalt Stone"),
                    tile = {"default_stone.png^[brighten"},
                    group = {cracky = 3, stone = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "basalt_cobble",
                    item = "techage:basalt_cobble",
                    desc = S("Basalt Cobble"),
                    tile = {"default_cobble.png^[brighten"},
                    group = {cracky = 3, stone = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "basalt_stone_brick",
                    item = "techage:basalt_stone_brick",
                    desc = S("Basalt Stone Brick"),
                    tile = {"default_stone.png^[brighten"},
                    group = {cracky = 3, stone = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "basalt_gravel",
                    item = "techage:basalt_gravel",
                    desc = S("Basalt Gravel"),
                    tile = {"default_gravel.png^[brighten"},
                    group = {crumbly = 2, falling_node = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "sieved_basalt_gravel",
                    item = "techage:sieved_basalt_gravel",
                    desc = S("Sieved Basalt Gravel"),
                    tile = {"default_gravel.png^[brighten"},
                    group = {crumbly = 2, falling_node = 1, not_in_creative_inventory=1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "basalt_glass",
                    item = "techage:basalt_glass",
                    desc = S("Basalt Glass"),
                    tile = {"techage_basalt_glass.png"},
                    group = {cracky = 3, oddly_breakable_by_hand = 3},
                    sound = default.node_sound_glass_defaults(),
                },
                {
                    subname = "basalt_glass2",
                    item = "techage:basalt_glass2",
                    desc = S("Basalt Glass 2"),
                    tile = {"techage_basalt_glass2.png"},
                    group = {cracky = 3, oddly_breakable_by_hand = 3},
                    sound = default.node_sound_glass_defaults(),
                },
                {
                    subname = "basalt_glass_thin",
                    item = "techage:basalt_glass_thin",
                    desc = S("Basalt Glass Thin"),
                    tile = {"techage_basalt_glass.png"},
                    group = {cracky = 3, oddly_breakable_by_hand = 3},
                    sound = default.node_sound_glass_defaults(),
                },
                {
                    subname = "basalt_glass_thin2",
                    item = "techage:basalt_glass_thin2",
                    desc = S("Basalt Glass Thin 2"),
                    tile = {"techage_basalt_glass2.png"},
                    group = {cracky = 3, oddly_breakable_by_hand = 3},
                    sound = default.node_sound_glass_defaults(),
                },
                {
                    subname = "basalt_glass_thin_xl",
                    item = "techage:basalt_glass_thin_xl",
                    desc = S("Basalt Glass Thin XL"),
                    tile = {"techage_basalt_glass2.png"},
                    group = {cracky = 3, oddly_breakable_by_hand = 3},
                    sound = default.node_sound_glass_defaults(),
                },
                {
                    subname = "basalt_glass_thin_xl",
                    item = "techage:basalt_glass_thin_xl",
                    desc = S("Basalt Glass Thin XL"),
                    tile = {"techage_basalt_glass2.png"},
                    group = {cracky = 3, oddly_breakable_by_hand = 3},
                    sound = default.node_sound_glass_defaults(),
                },
                {
                    subname = "bauxite_stone",
                    item = "techage:bauxite_stone",
                    desc = S("Bauxite Stone"),
                    tile = {"default_desert_stone.png^techage_bauxit_overlay.png^[colorize:#FB2A00:120"},
                    group = {cracky = 3, stone = 1},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "bauxite_cobble",
                    item = "techage:bauxite_cobble",
                    desc = S("Bauxite Cobblestone"),
                    tile = {"default_desert_cobble.png^[colorize:#FB2A00:80"},
                    group = {cracky = 3, stone = 2},
                    sound = default.node_sound_stone_defaults(),
                },
                {
                    subname = "bauxite_gravel",
                    item = "techage:bauxite_gravel",
                    desc = S("Bauxite Gravel"),
                    tile = {"default_gravel.png^[colorize:#FB2A00:180"},
                    group = {crumbly = 2, falling_node = 1},
                    sound = default.node_sound_gravel_defaults(),
                },

            }

if(minetest.get_modpath("moreblocks")) then

    for _,value in pairs(nodes) do

                stairsplus:register_all("techage", value.subname, value.item,
                                        {
                                            description = value.desc,
                                            tiles = value.tile,
                                            groups = value.group,
                                            sound = value.sound,
                                        })
        --end
    
    end
  
end

    
if(minetest.get_modpath("barchairs")) then
    
    for _,value in pairs(nodes) do
                print("Register Barchair techage:" .. value.subname)
                barchair.register_barchair("techage:", value.subname, 0)
    
    end
    
end
