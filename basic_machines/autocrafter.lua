--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	The autocrafter is derived from pipeworks: 
	Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>  WTFPL
	
	TA2/TA3/TA4 Autocrafter
	
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).consumer end

local S = techage.S

local STANDBY_TICKS = 6
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4

local function formspec(self, pos, mem)
	return "size[8,9.2]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[context;recipe;0,0;3,3;]"..
		"image[2.9,1;1,1;techage_form_arrow.png]"..
		"image[3.8,0;1,1;"..techage.get_power_image(pos, mem).."]"..
		"list[context;output;3.8,1;1,1;]"..
		"image_button[3.8,2;1,1;".. self:get_state_button_image(mem) ..";state_button;]"..
		"list[context;src;0,3.2;8,2;]"..
		"list[context;dst;5,0;3,3;]"..
		"list[current_player;main;0,5.4;8,4;]" ..
		"listring[current_player;main]"..
		"listring[context;src]" ..
		"listring[current_player;main]"..
		"listring[context;dst]" ..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4)
end

local function count_index(invlist)
	local index = {}
	for _, stack in pairs(invlist) do
		if not stack:is_empty() then
			local stack_name = stack:get_name()
			index[stack_name] = (index[stack_name] or 0) + stack:get_count()
		end
	end
	return index
end

-- caches some recipe data
local autocrafterCache = {}  

local function get_craft(pos, inventory, hash)
	hash = hash or minetest.hash_node_position(pos)
	local craft = autocrafterCache[hash]
	if not craft then
		local recipe = inventory:get_list("recipe")
		local output, decremented_input = minetest.get_craft_result(
				{method = "normal", width = 3, items = recipe})
		craft = {recipe = recipe, consumption = count_index(recipe), 
				output = output, decremented_input = decremented_input}
		autocrafterCache[hash] = craft
	end
	return craft
end

local function autocraft(pos, crd, mem, inv)
	local craft = get_craft(pos, inv)
	if not craft then 
		crd.State:idle(pos, mem)
		return
	end
	local output_item = craft.output.item
	if output_item:get_name() == "" then
		crd.State:idle(pos, mem)
		return 
	end
		
	-- check if we have enough room in dst
	if not inv:room_for_item("dst", output_item) then	
		crd.State:blocked(pos, mem)
		return
	end
	local consumption = craft.consumption
	local inv_index = count_index(inv:get_list("src"))
	-- check if we have enough material available
	for itemname, number in pairs(consumption) do
		if (not inv_index[itemname]) or inv_index[itemname] < number then 
			crd.State:idle(pos, mem)
			return 
		end
	end
	-- consume material
	for itemname, number in pairs(consumption) do
		for i = 1, number do -- We have to do that since remove_item does not work if count > stack_max
			inv:remove_item("src", ItemStack(itemname))
		end
	end

	-- craft the result into the dst inventory and add any "replacements" as well
	inv:add_item("dst", output_item)
	for i = 1, 9 do
		inv:add_item("dst", craft.decremented_input.items[i])
	end
	
	crd.State:keep_running(pos, mem, COUNTDOWN_TICKS)
end


local function keep_running(pos, elapsed)
	local mem = tubelib2.get_mem(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	autocraft(pos, crd, mem, inv)
end

-- note, that this function assumes allready being updated to virtual items
-- and doesn't handle recipes with stacksizes > 1
local function after_recipe_change(pos, inventory)
	local mem = tubelib2.get_mem(pos)
	local crd = CRD(pos)
	-- if we emptied the grid, there's no point in keeping it running or cached
	if inventory:is_empty("recipe") then
		autocrafterCache[minetest.hash_node_position(pos)] = nil
		inventory:set_stack("output", 1, "")
		crd.State:stop(pos, mem)
		return
	end
	local recipe = inventory:get_list("recipe")

	local hash = minetest.hash_node_position(pos)
	local craft = autocrafterCache[hash]

	if craft then
		-- check if it changed
		local cached_recipe = craft.recipe
		for i = 1, 9 do
			if recipe[i]:get_name() ~= cached_recipe[i]:get_name() then
				autocrafterCache[hash] = nil -- invalidate recipe
				craft = nil
				break
			end
		end
	end

	craft = craft or get_craft(pos, inventory, hash)
	local output_item = craft.output.item
	inventory:set_stack("output", 1, output_item)
	crd.State:stop(pos, mem)
end

-- clean out unknown items and groups, which would be handled like unknown items in the crafting grid
-- if minetest supports query by group one day, this might replace them
-- with a canonical version instead
local function normalize(item_list)
	for i = 1, #item_list do
		local name = item_list[i]
		if not minetest.registered_items[name] then
			item_list[i] = ""
		end
	end
	return item_list
end

local function on_output_change(pos, inventory, stack)
	if not stack then
		inventory:set_list("output", {})
		inventory:set_list("recipe", {})
	else
		local input = minetest.get_craft_recipe(stack:get_name())
		if not input.items or input.type ~= "normal" then return end
		local items, width = normalize(input.items), input.width
		local item_idx, width_idx = 1, 1
		for i = 1, 9 do
			if width_idx <= width then
				inventory:set_stack("recipe", i, items[item_idx])
				item_idx = item_idx + 1
			else
				inventory:set_stack("recipe", i, ItemStack(""))
			end
			width_idx = (width_idx < 3) and (width_idx + 1) or 1
		end
		-- we'll set the output slot in after_recipe_change to the actual result of the new recipe
	end
	after_recipe_change(pos, inventory)
end


local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local inv = M(pos):get_inventory()
	if listname == "recipe" then
		stack:set_count(1)
		inv:set_stack(listname, index, stack)
		after_recipe_change(pos, inv)
		return 0
	elseif listname == "output" then
		on_output_change(pos, inv, stack)
		return 0
	elseif listname == "src" then
		CRD(pos).State:start_if_standby(pos)
	end
	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
--		upgrade_autocrafter(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "recipe" then
		inv:set_stack(listname, index, ItemStack(""))
		after_recipe_change(pos, inv)
		return 0
	elseif listname == "output" then
		on_output_change(pos, inv, nil)
		return 0
	end
	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local inv = minetest.get_meta(pos):get_inventory()
	local stack = inv:get_stack(from_list, from_index)

	if to_list == "output" then
		on_output_change(pos, inv, stack)
		return 0
	elseif from_list == "output" then
		on_output_change(pos, inv, nil)
		if to_list ~= "recipe" then
			return 0
		end -- else fall through to recipe list handling
	end

	if from_list == "recipe" or to_list == "recipe" then
		if from_list == "recipe" then
			inv:set_stack(from_list, from_index, ItemStack(""))
		end
		if to_list == "recipe" then
			stack:set_count(1)
			inv:set_stack(to_list, to_index, stack)
		end
		after_recipe_change(pos, inv)
		return 0
	end

	return count
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	local mem = tubelib2.get_mem(pos)
	CRD(pos).State:state_button_event(pos, mem, fields)
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
	"techage_filling_ta#.png^techage_appl_autocrafter.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_autocrafter.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_autocrafter.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	{
		image = "techage_filling4_ta#.png^techage_appl_autocrafter4.png^techage_frame4_ta#_top.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 0.5,
		},
	},
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	{
		image = "techage_filling4_ta#.png^techage_appl_autocrafter4.png^techage_frame4_ta#.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 0.5,
		},
	},
	{
		image = "techage_filling4_ta#.png^techage_appl_autocrafter4.png^techage_frame4_ta#.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 0.5,
		},
	},
}

local tubing = {
	on_pull_item = function(pos, in_dir, num)
		local meta = minetest.get_meta(pos)
		if meta:get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(inv, "dst", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		if meta:get_int("push_dir") == in_dir  or in_dir == 5 then
			local inv = M(pos):get_inventory()
			CRD(pos).State:start_if_standby(pos)
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
	on_recv_message = function(pos, topic, payload)
		return CRD(pos).State:on_receive_message(pos, topic, payload)
	end,
	on_node_load = function(pos)
		CRD(pos).State:on_node_load(pos)
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 = 
	techage.register_consumer("autocrafter", S("Autocrafter"), tiles, {
		drawtype = "normal",
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing = tubing,
		after_place_node = function(pos, placer)
			local inv = M(pos):get_inventory()
			inv:set_size("src", 2*8)
			inv:set_size("recipe", 3*3)
			inv:set_size("dst", 3*3)
			inv:set_size("output", 1)
		end,
		can_dig = can_dig,
		node_timer = keep_running,
		on_receive_fields = on_receive_fields,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,1,2,4},
		power_consumption = {0,4,6,9},
	})

minetest.register_craft({
	output = node_name_ta2,
	recipe = {
		{"group:wood", "default:diamond", "group:wood"},
		{"techage:tubeS", "basic_materials:gear_steel", "techage:tubeS"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
	},
})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "default:diamond", ""},
		{"", node_name_ta2, ""},
		{"", "techage:vacuum_tube", ""},
	},
})

techage.register_entry_page("ta2", "autocrafter",
	S("TA2 Autocrafter"), 
	S("The Autocrafter allows the automated crafting of items based on configured recipes.@n"..
		"It can craft one item every two seconds.@n"..
		"Needs axle power: 4"),
	"techage:ta2_autocrafter_pas")

techage.register_entry_page("ta3m", "autocrafter",
	S("TA3 Autocrafter"), 
	S("The Autocrafter allows the automated crafting of items based on configured recipes.@n"..
		"It can craft two items every two seconds.@n"..
		"Needs electrical power: 6"),
	"techage:ta3_autocrafter_pas")
