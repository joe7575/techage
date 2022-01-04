--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Electric Cables (AC)

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local S = techage.S

local power = networks.power

local ELE1_MAX_CABLE_LENGHT = 1000

local Cable = tubelib2.Tube:new({
	dirs_to_check = {1,2,3,4,5,6},
	max_tube_length = ELE1_MAX_CABLE_LENGHT,
	show_infotext = false,
	tube_type = "ele1",
	primary_node_names = {"techage:electric_cableS", "techage:electric_cableA",
		"techage:power_line", "techage:power_lineS", "techage:power_lineA",
		"techage:power_pole2", "techage:powerswitch_box", "techage:powerswitch_box_on"},
	secondary_node_names = {},
	after_place_tube = function(pos, param2, tube_type, num_tubes)
		local node = minetest.get_node(pos)
		local name = node.name
		local color_param2 = math.floor(node.param2 / 32) * 32
		if name == "techage:powerswitch_box" or name == "techage:powerswitch_box_on" or name == "techage:powerswitch_box_off" then
			minetest.swap_node(pos, {name = name, param2 = param2 % 32})
		elseif name == "techage:power_line" or name == "techage:power_lineS" or name == "techage:power_lineA" then
			minetest.swap_node(pos, {name = "techage:power_line"..tube_type, param2 = param2 % 32})
		elseif name == "techage:power_pole2" then
			-- nothing
		elseif not networks.hidden_name(pos) then
			minetest.swap_node(pos, {name = "techage:electric_cable"..tube_type, param2 = param2 % 32 + color_param2})
		end
		M(pos):set_int("netw_param2", param2)
		M(pos):set_int("netw_color_param2", color_param2)
	end,
})

-- Enable hidden cables
networks.use_metadata(Cable)
networks.register_hidden_message("Use the trowel tool to remove the node.")

-- Use global callback instead of node related functions
Cable:register_on_tube_update2(function(pos, outdir, tlib2, node)
	power.update_network(pos, outdir, tlib2, node)
end)

local preserve_metadata = function(pos, oldnode, oldmeta, drops)
	for _,drop in ipairs(drops) do
		local meta = drop:get_meta()
		if meta:get_int("palette_index") == 0 then
			meta:set_string("palette_index", "")
		end
	end
end

minetest.register_node("techage:electric_cableS", {
	description = S("TA Electric Cable"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
	},
	overlay_tiles = {
		"",
		"",
		"",
		"",
		{ name = "techage_electric_cable_end.png", color = "white" },
		{ name = "techage_electric_cable_end.png", color = "white" },
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if not Cable:after_place_tube(pos, placer, pointed_thing) then
			minetest.remove_node(pos)
			return true
		end
		return false
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "colorfacedir", -- important!
	palette = "techage_cable_palette.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/32, -3/32, -4/8,  3/32, 3/32, 4/8},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, techage_trowel = 1},
	sounds = default.node_sound_defaults(),
	preserve_metadata = preserve_metadata,
})

minetest.register_node("techage:electric_cableA", {
	description = S("TA Electric Cable"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
		"techage_electric_cable.png",
	},
	overlay_tiles = {
		"",
		{ name = "techage_electric_cable_end.png", color = "white" },
		"",
		"",
		"",
		{ name = "techage_electric_cable_end.png", color = "white" },
	},

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Cable:after_dig_tube(pos, oldnode, oldmetadata)
	end,

	paramtype2 = "colorfacedir", -- important!
	palette = "techage_cable_palette.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/32, -4/8, -3/32,  3/32, 3/32,  3/32},
			{-3/32, -3/32, -4/8,  3/32, 3/32, -3/32},
		},
	},
	on_rotate = screwdriver.disallow, -- important!
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
			techage_trowel = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
	drop = {
		items = {
			{ items = { "techage:electric_cableS" }, inherit_color = true },
		}
	},
	preserve_metadata = preserve_metadata,
})

minetest.register_craft({
	output = "techage:electric_cableS 6",
	recipe = {
		{"basic_materials:plastic_sheet", "", ""},
		{"", "default:copper_ingot", ""},
		{"", "", "basic_materials:plastic_sheet"},
	},
})

techage.ElectricCable = Cable
techage.ELE1_MAX_CABLE_LENGTH = ELE1_MAX_CABLE_LENGHT


for idx, color in ipairs({ "white", "grey", "black", "brown", "yellow", "red", "dark_green", "blue" }) do
	minetest.register_craft({
		output = idx == 1 and "techage:electric_cableS 8" or minetest.itemstring_with_palette("techage:electric_cableS 8", (idx-1)*32),
		recipe = {
			{ "techage:electric_cableS", "techage:electric_cableS", "techage:electric_cableS", },
			{ "techage:electric_cableS", "dye:"..color, "techage:electric_cableS", },
			{ "techage:electric_cableS", "techage:electric_cableS", "techage:electric_cableS", },
		}
	})
end
