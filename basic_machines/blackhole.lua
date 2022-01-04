--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	All items and liquids disappear.

]]--

local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

local function take_liquid(pos, indir, name, amount)
	return 0, name
end

local function put_liquid(pos, indir, name, amount)
	return 0
end

local function peek_liquid(pos, indir)
	return nil
end

minetest.register_node("techage:blackhole", {
	description = S("TechAge Black Hole"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_blackhole.png^techage_appl_hole_pipe.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_blackhole.png^techage_appl_inp.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_blackhole.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_blackhole.png",
	},

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local node = minetest.get_node(pos)
		meta:set_int("push_dir", techage.side_to_indir("L", node.param2))
		meta:set_string("infotext", S("TechAge Black Hole (let items and liquids disappear)"))
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Pipe:after_dig_node(pos)
	end,

	on_rotate = screwdriver.disallow,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:blackhole",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"techage:tubeS", "default:coal_lump", "techage:ta3_pipeS"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
	},
})

techage.register_node({"techage:blackhole"}, {
	on_pull_item = nil,  		-- not needed
	on_unpull_item = nil,		-- not needed

	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("push_dir") == in_dir then
			return true
		end
	end,
})

liquid.register_nodes({"techage:blackhole"},
	Pipe, "tank", {"R"}, {
		capa = 9999999,
		peek = peek_liquid,
		put = put_liquid,
		take = take_liquid,
	}
)
