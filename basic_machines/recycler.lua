--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Recycler, recycling techage machines

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 8

local Recipes = {}

local SpecialItems = {
	["techage:sieved_gravel"] = "default:sand",
	["basic_materials:heating_element"] = "default:copper_ingot",
	["techage:ta4_wlanchip"] = "",
	["techage:basalt_cobble"] = "default:sand",
	["default:stone"] = "techage:sieved_gravel",
	["default:wood"] = "default:stick 5",
	["basic_materials:concrete_block"] = "techage:sieved_gravel",
	["dye:green"] = "",
	["dye:red"] = "",
	["dye:white"] = "",
	["dye:blue"] = "",
	["dye:brown"] = "",
	["dye:cyan"] = "",
	["dye:yellow"] = "",
	["dye:grey"] = "",
	["dye:orange"] = "",
	["dye:black"] = "",
	["techage:basalt_glass_thin"] = "",
	["group:stone"] = "techage:sieved_gravel",
	--["basic_materials:plastic_sheet"] = "",
	["group:wood"] = "default:stick 5",
	["techage:basalt_glass"] = "",
	["default:junglewood"] = "default:stick 5",
	["techage:ta4_silicon_wafer"] = "",
	["default:cobble"] = "techage:sieved_gravel",
	["default:pick_diamond"] = "default:stick",
	["techage:hammer_steel"] = "default:stick",
	["default:paper"] = "",
	["stairs:slab_basalt_glass2"] = "",
	["techage:basalt_stone"] = "techage:sieved_gravel",
	["techage:ta4_ramchip"] = "",
	["protector:chest"] = "default:chest",
	["techage:ta4_rotor_blade"] = "",
	["techage:ta4_carbon_fiber"] = "",
	["techage:ta4_round_ceramic"] = "",
	["techage:ta4_furnace_ceramic"] = "",
	["techage:ta5_aichip"] = "",
	["techage:ta4_leds"] = "",
}

local function formspec(self, pos, nvm)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;3,3;]"..
	--"item_image[0,0;1,1;default:cobble]"..
	"image[0,0;1,1;techage_form_mask.png]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;"..self:get_state_button_image(nvm)..";state_button;]"..
	"tooltip[3.5,2;1,1;"..self:get_state_tooltip(nvm).."]"..
	"list[context;dst;5,0;3,3;]"..
	--"item_image[5,0;1,1;default:gravel]"..
	"image[5,0;1,1;techage_form_mask.png]"..
	"list[current_player;main;0,4;8,4;]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "src" then
		CRD(pos).State:start_if_standby(pos)
	end
	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = M(pos):get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function cook_reverse(stack, inv, idx, recipe)
	-- check space
	for _,item in ipairs(recipe.items) do
		if not inv:room_for_item("dst", stack) then
			return false
		end
	end
	-- take item
	inv:remove_item("src", ItemStack(recipe.output))
	-- add items
	for _,item in ipairs(recipe.items) do
		inv:add_item("dst", item)
	end
	return true
end

local function get_recipe(stack)
	local name = stack:get_name()
	local recipe = Recipes[name]
	if recipe then
		if stack:get_count() >= ItemStack(recipe.output):get_count() then
			return recipe
		end
	end
end

local function recycling(pos, crd, nvm, inv)
	for idx,stack in ipairs(inv:get_list("src")) do
		local recipe = not stack:is_empty() and get_recipe(stack)
		if recipe then
			if cook_reverse(stack, inv, idx, recipe) then
				crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
			else
				crd.State:blocked(pos, nvm)
			end
			return
		end
	end
	crd.State:idle(pos, nvm)
end

local function keep_running(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	recycling(pos, crd, nvm, inv)
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local nvm = techage.get_nvm(pos)
	CRD(pos).State:state_button_event(pos, nvm, fields)
end

local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local inv = M(pos):get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end


local tiles = {}
-- '#' will be replaced by the stage number
-- '{power}' will be replaced by the power PNG
tiles.pas = {
	-- up, down, right, left, back, front
	"techage_appl_grinder.png^[colorize:@@000000:100^techage_frame_ta#_top.png",
	--"techage_appl_grinder.png^techage_frame_ta#_top.png^[multiply:#FF0000",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_recycler.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_recycler.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	{
		image = "techage_appl_grinder4.png^[colorize:@@000000:100^techage_frame4_ta#_top.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 1.0,
		},
	},
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_recycler.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_recycler.png^techage_frame_ta#.png",
}

local tubing = {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(pos, inv, "dst", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("push_dir") == in_dir or in_dir == 5 then
			local inv = M(pos):get_inventory()
			--CRD(pos).State:start_if_standby(pos) -- would need power!
			return techage.put_items(inv, "src", stack)
		end
	end,
	on_unpull_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "dst", stack)
		end
	end,
	on_recv_message = function(pos, src, topic, payload)
		return CRD(pos).State:on_receive_message(pos, topic, payload)
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_receive_cmnd(pos, topic, payload)
	end,
	on_beduino_request_data = function(pos, src, topic, payload)
		return CRD(pos).State:on_beduino_request_data(pos, topic, payload)
	end,
	on_node_load = function(pos)
		CRD(pos).State:on_node_load(pos)
	end,
}

local _, _, node_name_ta4 =
	techage.register_consumer("recycler", S("Recycler"), tiles, {
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-8/16, -8/16, -8/16,  8/16, 8/16, -6/16},
				{-8/16, -8/16,  6/16,  8/16, 8/16,  8/16},
				{-8/16, -8/16, -8/16, -6/16, 8/16,  8/16},
				{ 6/16, -8/16, -8/16,  8/16, 8/16,  8/16},
				{-6/16, -8/16, -6/16,  6/16, 6/16,  6/16},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-8/16, -8/16, -8/16,   8/16, 8/16, 8/16},
		},
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		after_place_node = function(pos, placer)
			local inv = M(pos):get_inventory()
			inv:set_size('src', 9)
			inv:set_size('dst', 9)
		end,
		can_dig = can_dig,
		node_timer = keep_running,
		on_receive_fields = on_receive_fields,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,0,0,1},
		power_consumption = {0,0,0,16},
	},
	{false, false, false, true})  -- TA4 only

minetest.register_craft({
	output = node_name_ta4,
	recipe = {
		{"", "default:mese_crystal", ""},
		{"", "techage:ta4_grinder_pas", ""},
		{"", "techage:ta4_wlanchip", ""},
	},
})

-------------------------------------------------------------------------------
-- Prepare recipes
-------------------------------------------------------------------------------
-- Nodes from mods that can be recycled
local ModNames = {
	techage = true,
	hyperloop = true,
}

local function get_item_list(inputs)
	local lst = {}
	for _,input in pairs(inputs or {}) do
		if SpecialItems[input] then
			input = SpecialItems[input]
		end
		if input and input ~= "" then
			if minetest.registered_nodes[input] or minetest.registered_items[input] then
				table.insert(lst, input)
			end
		end
	end
	return lst
end

local function get_special_recipe(name)
	if SpecialItems[name] then
		return {
			output = name,
			items = {SpecialItems[name]}
		}
	end
end

local function collect_recipes()
	local add = function(name, ndef)
		local _, _, mod, _ = string.find(name, "([%w_]+):([%w_]+)")
		local recipe = get_special_recipe(name) or
		               techage.recipes.get_recipe(name) or
		               minetest.get_craft_recipe(name)
		local items = get_item_list(recipe.items)

		if ModNames[mod]
		and ndef.groups.not_in_creative_inventory ~= 1
		and not ndef.tool_capabilities
		and recipe.output
		and next(items) then
			local s = table.concat(items, ", ")
			--print(string.format("%-36s {%s}", recipe.output, s))
			Recipes[name] = {output = recipe.output, items = items}
		end
	end

	for name, ndef in pairs(minetest.registered_nodes) do
		add(name, ndef)
	end
	for name, ndef in pairs(minetest.registered_items) do
		add(name, ndef)
	end
end

minetest.after(2, collect_recipes)
