--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Gravel Rinser, washing sieved gravel to find more ores

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4

local Probability = {}

local function formspec(self, pos, nvm)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;3,3;]"..
	"item_image[0,0;1,1;default:gravel]"..
	"image[0,0;1,1;techage_form_mask.png]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;".. self:get_state_button_image(nvm) ..";state_button;]"..
	"tooltip[3.5,2;1,1;"..self:get_state_tooltip(nvm).."]"..
	"list[context;dst;5,0;3,3;]"..
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
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end


local function get_water_level(pos)
	local node  = techage.get_node_lvm(pos)
	if minetest.get_item_group(node.name, "water") > 0 then
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.liquidtype == "flowing" then
			return node.param2
		end
	end
	return 99
end

local function determine_water_dir(pos)
	local lvl = get_water_level(pos)
	if lvl > get_water_level({x=pos.x+1, y=pos.y, z=pos.z}) then
		return 2
	end
	if lvl > get_water_level({x=pos.x-1, y=pos.y, z=pos.z}) then
		return 4
	end
	if lvl > get_water_level({x=pos.x, y=pos.y, z=pos.z+1}) then
		return 1
	end
	if lvl > get_water_level({x=pos.x, y=pos.y, z=pos.z-1}) then
		return 3
	end
	return 0
end

local function set_velocity(obj, pos, vel)
	if obj then
		obj:set_acceleration({x = 0, y = 0, z = 0})
		local p = obj:get_pos()
		if p then
			obj:set_pos({x=p.x, y=p.y-0.3, z=p.z})
			obj:set_velocity(vel)
		end
	end
end

local function add_object(pos, name)
	local dir = determine_water_dir(pos)
	if dir > 0 then
		local obj = minetest.add_item(pos, ItemStack(name))
		local vel = vector.multiply(tubelib2.Dir6dToVector[dir], 0.3)
		minetest.after(0.3, set_velocity, obj, pos, vel)
	end
end

local function get_random_gravel_ore()
	for ore, probability in pairs(Probability) do
		if math.random(probability) == 1 then
			return ore
		end
	end
end

local function remove_objects(pos)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local lua_entity = object:get_luaentity()
		if not object:is_player() and lua_entity and lua_entity.name == "__builtin:item" then
			object:remove()
		end
	end
end

local function washing(pos, crd, nvm, inv)
	-- for testing purposes
	if inv:contains_item("src", ItemStack("default:stick")) then
		add_object({x=pos.x, y=pos.y+1, z=pos.z}, "default:stick")
		inv:remove_item("src", ItemStack("default:stick"))
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
		return
	end

	local src = ItemStack("techage:sieved_gravel")
	local dst = ItemStack("default:sand")
	if inv:contains_item("src", src) then
		if not inv:room_for_item("dst", dst) then
			crd.State:blocked(pos, nvm)
			return
		end
		local ore = get_random_gravel_ore()
		if ore then
			add_object({x=pos.x, y=pos.y+1, z=pos.z}, ore)
		end
		inv:add_item("dst", dst)
		inv:remove_item("src", src)
		crd.State:keep_running(pos, nvm, COUNTDOWN_TICKS)
		return
	else
		crd.State:idle(pos, nvm)
		return
	end
end

local function keep_running(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local crd = CRD(pos)
	local inv = M(pos):get_inventory()
	washing(pos, crd, nvm, inv)
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
	"techage_appl_rinser_top.png^techage_frame_ta#_top.png",
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
}
tiles.act = {
	-- up, down, right, left, back, front
	{
		image = "techage_appl_rinser4_top.png^techage_frame4_ta#_top.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 2.0,
		},
	},
	"techage_filling_ta#.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
	"techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
	"techage_filling_ta#.png^techage_appl_rinser.png^techage_frame_ta#.png",
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
		if meta:get_int("push_dir") == in_dir  or in_dir == 5 then
			local inv = M(pos):get_inventory()
			-- CRD(pos).State:start_if_standby(pos) -- would need power!
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
		remove_objects({x=pos.x, y=pos.y+1, z=pos.z})
		CRD(pos).State:on_node_load(pos)
	end,
}

local node_name_ta2, node_name_ta3, node_name_ta4 =
	techage.register_consumer("rinser", S("Gravel Rinser"), tiles, {
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
				{-6/16,  6/16, -1/16,  6/16, 8/16,  1/16},
				{-1/16,  6/16, -6/16,  1/16, 8/16,  6/16},
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
		num_items = {0,1,1,1},
		power_consumption = {0,3,3,3},
		tube_sides = {L=1, R=1, U=1},
	},
	{false, true, true, false})  -- TA2/TA3

minetest.register_craft({
	output = node_name_ta2,
	recipe = {
		{"group:wood", "default:mese_crystal", "group:wood"},
		{"techage:tubeS", "techage:sieve", "techage:tubeS"},
		{"group:wood", "default:tin_ingot", "group:wood"},
	},
})

minetest.register_craft({
	output = node_name_ta3,
	recipe = {
		{"", "default:mese_crystal", ""},
		{"", node_name_ta2, ""},
		{"", "techage:vacuum_tube", ""},
	},
})


techage.recipes.register_craft_type("rinsing", {
	description = S("Rinsing"),
	icon = "techage_appl_rinser_top.png^techage_frame_ta2_top.png",
	width = 2,
	height = 2,
})

function techage.add_rinser_recipe(recipe)
	Probability[recipe.output] = recipe.probability
	recipe.items = {recipe.input}
	recipe.type = "rinsing"
	techage.recipes.register_craft(recipe)
end

techage.add_rinser_recipe({input="techage:sieved_gravel", output="techage:usmium_nuggets", probability=30})
techage.add_rinser_recipe({input="techage:sieved_gravel", output="default:copper_lump", probability=15})
