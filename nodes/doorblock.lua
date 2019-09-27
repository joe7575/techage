--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	Door block
	
]]--

local S = techage.S

-- See also gateblock!!!
local NUM_TEXTURES = 20

local sTextures = "Wood,Aspen Wood,Jungle Wood,Pine Wood,"..
                  "Cobblestone,Sandstone,Stone,Desert Sandstone,"..
				  "Desert Stone,Silver Sandstone,Mossy Cobble,Desert Cobble,"..  
                  "Copper,Steel,Tin,Coral,"..
				  "Glas,Obsidian Glas,Ice,Gate Wood"  

local tTextures = {
	["Wood"]=1, ["Aspen Wood"]=2, ["Jungle Wood"]=3, ["Pine Wood"]=4,
	["Cobblestone"]=5, ["Sandstone"]=6, ["Stone"]=7, ["Desert Sandstone"]=8,
	["Desert Stone"]=9, ["Silver Sandstone"]=10, ["Mossy Cobble"]=11, ["Desert Cobble"]=12,
	["Copper"]=13, ["Steel"]=14, ["Tin"]=15, ["Coral"]=16,
	["Glas"]=17, ["Obsidian Glas"]=18, ["Ice"]=19, ["Gate Wood"]=20,
}
	
local tPgns = {"default_wood.png", "default_aspen_wood.png", "default_junglewood.png", "default_pine_wood.png",
	"default_cobble.png", "default_sandstone.png", "default_stone.png", "default_desert_sandstone.png",
	"default_desert_stone_block.png", "default_silver_sandstone.png", "default_mossycobble.png", "default_desert_cobble.png",
	"default_copper_block.png", "default_steel_block.png", "default_tin_block.png", "default_coral_skeleton.png",
	"default_glass.png", "default_obsidian_glass.png", "default_ice.png", "techage_gate.png"}

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
				{ -8/16, -8/16, -2/16,  8/16,  8/16, 2/16},
			},
		},

		after_place_node = function(pos, placer)
			local mem = tubelib2.init_mem(pos)
			local meta = minetest.get_meta(pos)
			local node = minetest.get_node(pos)
			local number = techage.add_node(pos, "techage:doorblock"..idx)
			mem.facedir = node.param2
			meta:set_string("node_number", number)
			meta:set_string("infotext", S("TechAge Door Block").." "..number)
			meta:set_string("formspec", "size[3,2]"..
			"label[0,0;Select texture]"..
			"dropdown[0,0.5;3;type;"..sTextures..";"..NUM_TEXTURES.."]".. 
			"button_exit[0.5,1.5;2,1;exit;Save]")
		end,

		on_receive_fields = function(pos, formname, fields, player)
			local meta = minetest.get_meta(pos)
			local node = minetest.get_node(pos)
			local mem = tubelib2.get_mem(pos)
			if fields.type then
				node.name = "techage:doorblock"..tTextures[fields.type]
				minetest.swap_node(pos, node)
				mem.name = node.name
			end
			if fields.exit then
				meta:set_string("formspec", nil)
			end
		end,
		
		after_dig_node = function(pos, oldnode, oldmetadata)
			techage.remove_node(pos)
			tubelib2.del_mem(pos)
		end,

		--drawtype = "glasslike",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		sounds = default.node_sound_stone_defaults(),
		groups = {cracky=2, choppy=2, crumbly=2, not_in_creative_inventory = idx==NUM_TEXTURES and 0 or 1},
		is_ground_content = false,
		drop = "techage:doorblock"..NUM_TEXTURES,
	})

	techage.register_node({"techage:doorblock"..idx}, {
		on_recv_message = function(pos, src, topic, payload)
			if topic == "on" then
				minetest.remove_node(pos)
			elseif topic == "off" then
				local mem = tubelib2.get_mem(pos)
				mem.facedir = mem.facedir or 0
				mem.name = mem.name or "techage:doorblock"..NUM_TEXTURES
				minetest.add_node(pos, {name = mem.name, paramtype2 = "facedir", param2 = mem.facedir})
			end
		end,
	})		
end

minetest.register_craft({
	output = "techage:doorblock"..NUM_TEXTURES,
	recipe = {
		{"default:mese_crystal_fragment", "",""},
		{"techage:vacuum_tube", "", ""},
		{"group:wood",       "", ""},
	},
})

