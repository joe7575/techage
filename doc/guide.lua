--[[

]]--

local S = techage.S

local tItems = techage.Items  -- k/v table with item definitions
local tPlans = techage.ConstructionPlans  -- k/v table with plan definitions


local function tooltip(item)
	if type(item) == "table" then
		local img, name = item[1], item[2]
		if img == "" then  -- larger image for the plan?
			return "", name
		elseif img == "10x10" then  -- huge image for the plan?
			return "10x10", name
		elseif img == "5x4" then  -- huge image for the plan?
			return "5x4", name
		end
		local ndef = minetest.registered_nodes[name]
		if ndef and ndef.description then
			return img, minetest.formspec_escape(ndef.description)
		end
		return img
	end
	return item
end


-- formspec images
local function plan(images)
	local tbl = {}
	if images == "none" then return "label[1,3;"..S("No plan available") .."]" end
	for y=1,#images do
		for x=1,#images[1] do
			local item = images[y][x] or false
			if item ~= false then
				local img, tooltip = tooltip(item)
				local x_offs, y_offs = (x-1) * 0.9, (y-1) * 0.9 + 0.8
				if img == "top_view" then
					tbl[#tbl+1] = "label["..x_offs..","..y_offs..";"..S("Top view").."]"
				elseif img == "side_view" then
					tbl[#tbl+1] = "label["..x_offs..","..y_offs..";"..S("Side view").."]"
				elseif img == "sectional_view" then
					tbl[#tbl+1] = "label["..x_offs..","..y_offs..";"..S("Sectional view").."]"
				elseif img == "" then
					img = tooltip -- use tooltip for bigger image
					tbl[#tbl+1] = "image["..x_offs..","..y_offs..";2.2,2.2;"..img.."]"
				elseif img == "10x10" then
					img = tooltip -- use tooltip for bigger image
					tbl[#tbl+1] = "image["..x_offs..","..y_offs..";10,10;"..img.."]"
				elseif img == "5x4" then
					img = tooltip -- use tooltip for bigger image
					tbl[#tbl+1] = "image["..x_offs..","..y_offs..";5,4;"..img.."]"
				elseif string.find(img, ":") then
					tbl[#tbl+1] = "item_image["..x_offs..","..y_offs..";1,1;"..img.."]"
				else
					tbl[#tbl+1] = "image["..x_offs..","..y_offs..";1,1;"..img.."]"
				end
				if tooltip then
					tbl[#tbl+1] = "tooltip["..x_offs..","..y_offs..";1,1;"..tooltip..";#0C3D32;#FFFFFF]"
				end
			end
		end
	end
	return table.concat(tbl)
end

local function formspec_help(meta, manual)
	local bttn
	local idx = meta:get_int("index")
	local box = "box[9.5,0.9;1,1.1;#BBBBBB]"
	local aTitel = manual.aTitel
	local aText = manual.aText
	local aItemName = manual.aItemName  -- item identifier as key
	local aPlanTable = manual.aPlanTable  -- plan identifier as key

	if aPlanTable[idx] ~= "" then
		bttn = "button[9.6,1;1,1;plan;"..S("Plan").."]"
	elseif aItemName[idx] ~= "" then
		local item = tItems[aItemName[idx]] or ""
		if string.find(item, ":") then
			bttn = box.."item_image[9.6,1;1,1;"..item.."]"
		else
			bttn = "image[9.3,1;2,2;"..item.."]"
		end
	else
		bttn = box
	end
	return "size[11,10]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"item_image[9.6,0;1,1;techage:construction_board]"..
	"tablecolumns[tree,width=1;text,width=10,align=inline]"..
	"tableoptions[opendepth=1]"..
	"table[0.1,0;9,5;page;"..table.concat(aTitel, ",")..";"..idx.."]"..
	bttn..
	"style_type[textarea;textcolor=#FFFFFF]"..
	"textarea[0.3,5.7;11,5.3;;"..(aText[idx] or "")..";]"..
	"box[0,5.75;10.775,4.45;#000000]"
end

local function formspec_plan(meta, manual)
	local idx = meta:get_int("index")
	local images = tPlans[manual.aPlanTable[idx]] or "none"
	local titel = string.sub(manual.aTitel[idx], 3) or "unknown"

	return "size[11,10]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"label[0,0;"..titel..":]"..
		"button[10,0;1,0.8;back;<<]"..
		plan(images)
end

local board_box = {
	type = "wallmounted",
	--wall_top = {-8/16, 15/32, -6/16, 8/16, 8/16, 6/16},
    --wall_bottom = {-8/16, 15/32, -6/16, 8/16, 8/16, 6/16},
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
		local meta = minetest.get_meta(pos)
		meta:set_int("index", 1)
		meta:set_string("formspec", formspec_help(meta, techage.manual_DE))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			return
		end
		local meta = minetest.get_meta(pos)
		if fields.plan then
			meta:set_string("formspec", formspec_plan(meta, techage.manual_DE))
		elseif fields.back then
			meta:set_string("formspec", formspec_help(meta, techage.manual_DE))
		elseif fields.page then
			local evt = minetest.explode_table_event(fields.page)
			if evt.type == "CHG" then
				local idx = tonumber(evt.row)
				meta:set_int("index", idx)
				meta:set_string("formspec", formspec_help(meta, techage.manual_DE))
			end
		end
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
		local meta = minetest.get_meta(pos)
		meta:set_int("index", 1)
		meta:set_string("formspec", formspec_help(meta, techage.manual_EN))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			return
		end
		local meta = minetest.get_meta(pos)
		if fields.plan then
			meta:set_string("formspec", formspec_plan(meta, techage.manual_EN))
		elseif fields.back then
			meta:set_string("formspec", formspec_help(meta, techage.manual_EN))
		elseif fields.page then
			local evt = minetest.explode_table_event(fields.page)
			if evt.type == "CHG" then
				local idx = tonumber(evt.row)
				meta:set_int("index", idx)
				meta:set_string("formspec", formspec_help(meta, techage.manual_EN))
			end
		end
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
