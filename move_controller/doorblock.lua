--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Door block

]]--

local M = minetest.get_meta
local S = techage.S

-- See also gateblock!!!
local NUM_TEXTURES = 22

local sTextures = "Wood,Aspen Wood,Jungle Wood,Pine Wood,"..
                  "Cobblestone,Sandstone,Stone,Desert Sandstone,"..
				  "Desert Stone,Silver Sandstone,Mossy Cobble,Desert Cobble,"..
                  "Copper,Steel,Tin,Coral,"..
				  "Glas,Obsidian Glas,Basalt Glass,Basalt Glass 2,"..
				  "Ice,Gate Wood"

local tTextures = {
	["Wood"]=1, ["Aspen Wood"]=2, ["Jungle Wood"]=3, ["Pine Wood"]=4,
	["Cobblestone"]=5, ["Sandstone"]=6, ["Stone"]=7, ["Desert Sandstone"]=8,
	["Desert Stone"]=9, ["Silver Sandstone"]=10, ["Mossy Cobble"]=11, ["Desert Cobble"]=12,
	["Copper"]=13, ["Steel"]=14, ["Tin"]=15, ["Coral"]=16,
	["Glas"]=17, ["Obsidian Glas"]=18, ["Basalt Glass"]=19, ["Basalt Glass 2"]=20,
	["Ice"]=21, ["Gate Wood"]=22,
}

local tPgns = {"default_wood.png", "default_aspen_wood.png", "default_junglewood.png", "default_pine_wood.png",
	"default_cobble.png", "default_sandstone.png", "default_stone.png", "default_desert_sandstone.png",
	"default_desert_stone_block.png", "default_silver_sandstone.png", "default_mossycobble.png", "default_desert_cobble.png",
	"default_copper_block.png", "default_steel_block.png", "default_tin_block.png", "default_coral_skeleton.png",
	"default_glass.png", "default_obsidian_glass.png", "techage_basalt_glass.png", "techage_basalt_glass2.png",
	"default_ice.png", "techage_gate.png"}

for idx,pgn in ipairs(tPgns) do
	minetest.register_node("techage:doorblock"..idx, {
		description = S("TechAge Door Block"),
		tiles = {
			pgn.."^[transformR90",
			pgn,
			pgn.."^[transformR90",
			pgn.."^[transformR90",
			pgn,
			pgn.."^[transformFX",
		},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -8/16, -8/16, -1/16,  8/16,  8/16, 1/16},
			},
		},

		after_place_node = function(pos, placer)
			M(pos):set_string("formspec", "size[3,2]"..
			"label[0,0;Select texture]"..
			"dropdown[0,0.5;3;type;"..sTextures..";"..NUM_TEXTURES.."]"..
			"button_exit[0.5,1.5;2,1;exit;Save]")
		end,

		on_receive_fields = function(pos, formname, fields, player)
			local meta = minetest.get_meta(pos)
			local node = minetest.get_node(pos)
			if fields.type then
				node.name = "techage:doorblock"..tTextures[fields.type]
				minetest.swap_node(pos, node)
			end
			if fields.exit then
				meta:set_string("formspec", nil)
				local number = techage.add_node(pos, node.name)
				meta:set_string("infotext", S("TechAge Door Block").." "..number)
			end
		end,

		after_dig_node = function(pos, oldnode, oldmetadata)
			techage.remove_node(pos, oldnode, oldmetadata)
		end,

		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = techage.BLEND,
		sunlight_propagates = true,
		sounds = default.node_sound_stone_defaults(),
		groups = {cracky=2, choppy=2, crumbly=2, techage_door = 1,
				not_in_creative_inventory = idx==NUM_TEXTURES and 0 or 1},
		is_ground_content = false,
		drop = "techage:doorblock"..NUM_TEXTURES,
	},
	techage.register_node({"techage:doorblock"..idx}, {}))
end

minetest.register_craft({
	output = "techage:doorblock"..NUM_TEXTURES,
	recipe = {
		{"techage:basalt_glass_thin", "", ""},
		{"default:mese_crystal_fragment", "",""},
		{"group:wood",       "", ""},
	},
})
