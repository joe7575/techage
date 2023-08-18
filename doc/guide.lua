--[[

]]--

local S = techage.S
local M = minetest.get_meta
local MP = minetest.get_modpath("techage")

local settings = {
	symbol_item = "techage:construction_board",
}

doclib.create_manual("techage", "DE", settings)
doclib.create_manual("techage", "EN", settings)

local content
content = dofile(MP.."/doc/manual_DE.lua") 
doclib.add_to_manual("techage", "DE", content)
content = dofile(MP.."/doc/manual_ta1_DE.lua") 
doclib.add_to_manual("techage", "DE", content)
content = dofile(MP.."/doc/manual_ta2_DE.lua") 
doclib.add_to_manual("techage", "DE", content)
content = dofile(MP.."/doc/manual_ta3_DE.lua") 
doclib.add_to_manual("techage", "DE", content)
content = dofile(MP.."/doc/manual_ta4_DE.lua") 
doclib.add_to_manual("techage", "DE", content)
content = dofile(MP.."/doc/manual_ta5_DE.lua") 
doclib.add_to_manual("techage", "DE", content)

content = dofile(MP.."/doc/manual_EN.lua") 
doclib.add_to_manual("techage", "EN", content)
content = dofile(MP.."/doc/manual_ta1_EN.lua") 
doclib.add_to_manual("techage", "EN", content)
content = dofile(MP.."/doc/manual_ta2_EN.lua") 
doclib.add_to_manual("techage", "EN", content)
content = dofile(MP.."/doc/manual_ta3_EN.lua") 
doclib.add_to_manual("techage", "EN", content)
content = dofile(MP.."/doc/manual_ta4_EN.lua") 
doclib.add_to_manual("techage", "EN", content)
content = dofile(MP.."/doc/manual_ta5_EN.lua") 
doclib.add_to_manual("techage", "EN", content)


local board_box = {
	type = "wallmounted",
    wall_side = {-16/32, -11/32, -16/32,   -15/32, 6/16, 8/16},
}

minetest.register_node("techage:construction_board", {
	description = "TA Konstruktionsplan (DE)",
	inventory_image = 'techage_constr_plan_inv.png',
	tiles = {"techage_constr_plan.png"},
	drawtype = "nodebox",
	node_box = board_box,
	selection_box = board_box,

	after_place_node = function(pos, placer, itemstack)
		M(pos):set_string("infotext", "TA Konstruktionsplan (DE)")
		M(pos):set_string("formspec", doclib.formspec(pos, "techage", "DE"))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			return
		end
		M(pos):set_string("formspec", doclib.formspec(pos, "techage", "DE", fields))
	end,

	paramtype2 = "wallmounted",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:construction_board",
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"},
	},
})

minetest.register_node("techage:construction_board_EN", {
	description = "TA Construction Board (EN)",
	inventory_image = 'techage_constr_plan_inv.png',
	tiles = {"techage_constr_plan.png"},
	drawtype = "nodebox",
	node_box = board_box,
	selection_box = board_box,

	after_place_node = function(pos, placer, itemstack)
		M(pos):set_string("infotext", "TA Konstruktionsplan (EN)")
		M(pos):set_string("formspec", doclib.formspec(pos, "techage", "EN"))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			return
		end
		M(pos):set_string("formspec", doclib.formspec(pos, "techage", "EN", fields))
	end,

	paramtype2 = "wallmounted",
	paramtype = "light",
	use_texture_alpha = techage.CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:construction_board_EN",
	recipe = {
		{"default:stick", "default:paper", "default:stick"},
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"},
	},
})

minetest.register_craft({
  type = "shapeless",
	output = "techage:construction_board_EN",
	recipe = {"techage:construction_board"},
})

minetest.register_craft({
  type = "shapeless",
	output = "techage:construction_board",
	recipe = {"techage:construction_board_EN"},
})


--
-- Legacy API functions
--
function techage.add_to_manual(language, titles, texts, items, plans)
	local content = {titles = titles, texts = texts, images = items or {}, plans = plans or {}}
	doclib.add_to_manual("techage", language, content)
end

function techage.add_manual_items(table_with_items)
	for name, image in pairs(table_with_items) do
		doclib.add_manual_image("techage", "EN", name, image)
		doclib.add_manual_image("techage", "DE", name, image)
	end
end

function techage.add_manual_plans(table_with_plans)
	for name, plan in pairs(table_with_plans) do
		doclib.add_manual_plan("techage", "EN", name, plan)
		doclib.add_manual_plan("techage", "DE", name, plan)
	end
end
