--[[

	TechAge
	=======

	Copyright (C) 2020-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	techage node registrations

]]--

local function register_alias(name)
	--minetest.register_alias("stairs:slab_" ..name, "techage:slab_" ..name)
	minetest.register_alias("stairs:slab_" ..name.. "_inverted", "techage:slab_" ..name.. "_inverted")
	minetest.register_alias("stairs:slab_" ..name.. "_wall", "techage:slab_" ..name.. "_wall")
	minetest.register_alias("stairs:slab_" ..name.. "_quarter", "techage:slab_" ..name.. "_quarter")
	minetest.register_alias("stairs:slab_" ..name.. "_quarter_inverted", "techage:slab_" ..name.. "_quarter_inverted")
	minetest.register_alias("stairs:slab_" ..name.. "_quarter_wall", "techage:slab_" ..name.. "_quarter_wall")
	minetest.register_alias("stairs:slab_" ..name.. "_three_quarter", "techage:slab_" ..name.. "_three_quarter")
	minetest.register_alias("stairs:slab_" ..name.. "_three_quarter_inverted", "techage:slab_" ..name.. "_three_quarter_inverted")
	minetest.register_alias("stairs:slab_" ..name.. "_three_quarter_wall", "techage:slab_" ..name.. "_three_quarter_wall")
	--minetest.register_alias("stairs:stair_" ..name, "techage:stair_" ..name)
	minetest.register_alias("stairs:stair_" ..name.. "_inverted", "techage:stair_" ..name.. "_inverted")
	minetest.register_alias("stairs:stair_" ..name.. "_wall", "techage:stair_" ..name.. "_wall")
	minetest.register_alias("stairs:stair_" ..name.. "_wall_half", "techage:stair_" ..name.. "_wall_half")
	minetest.register_alias("stairs:stair_" ..name.. "_wall_half_inverted", "techage:stair_" ..name.. "_wall_half_inverted")
	minetest.register_alias("stairs:stair_" ..name.. "_half", "techage:stair_" ..name.. "_half")
	minetest.register_alias("stairs:stair_" ..name.. "_half_inverted", "techage:stair_" ..name.. "_half_inverted")
	minetest.register_alias("stairs:stair_" ..name.. "_right_half", "techage:stair_" ..name.. "_right_half")
	minetest.register_alias("stairs:stair_" ..name.. "_right_half_inverted", "techage:stair_" ..name.. "_right_half_inverted")
	minetest.register_alias("stairs:stair_" ..name.. "_wall_half", "techage:stair_" ..name.. "_wall_half")
	minetest.register_alias("stairs:stair_" ..name.. "_wall_half_inverted", "techage:stair_" ..name.. "_wall_half_inverted")
	minetest.register_alias("stairs:stair_" ..name.. "_inner", "techage:stair_" ..name.. "_inner")
	minetest.register_alias("stairs:stair_" ..name.. "_inner_inverted", "techage:stair_" ..name.. "_inner_inverted")
	minetest.register_alias("stairs:stair_" ..name.. "_outer", "techage:stair_" ..name.. "_outer")
	minetest.register_alias("stairs:stair_" ..name.. "_outer_inverted", "techage:stair_" ..name.. "_outer_inverted")
end

local NodeNames = {
	"techage:compressed_gravel",
	"techage:red_stone",
	"techage:red_stone_block",
	"techage:red_stone_brick",

	"techage:basalt_cobble",
	"techage:basalt_stone",
	"techage:basalt_stone_block",
	"techage:basalt_stone_brick",
	"techage:sieved_basalt_gravel",

	"techage:basalt_glass",
	"techage:basalt_glass2",
	"techage:bauxite_stone",
	"techage:bauxite_cobble",
}

if(minetest.get_modpath("moreblocks")) then
    for _,name in ipairs(NodeNames) do
		local ndef = minetest.registered_nodes[name]
		if ndef then
			ndef = table.copy(ndef)
			local subname = string.split(name, ":")[2]
			ndef.sunlight_propagates = true
			ndef.groups.not_in_creative_inventory = 1
			stairsplus:register_all("techage", subname, name, ndef)
			register_alias(subname)
		end
    end
else
    for _,name in ipairs(NodeNames) do
		local ndef = minetest.registered_nodes[name]
		if ndef then
			local subname = string.split(name, ":")[2]
			stairs.register_stair_and_slab(
				subname,
				name,
				ndef.groups,
				ndef.tiles,
				ndef.description.." Stair",
				ndef.description.." Slab",
				ndef.sound,
				false
			)
			register_alias(subname)
		end
	end
end
