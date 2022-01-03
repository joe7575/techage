--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Gravel Sieve, sieving gravel to find ores

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local get_random_gravel_ore = techage.gravelsieve_get_random_gravel_ore
local get_random_basalt_ore = techage.gravelsieve_get_random_basalt_ore

-- handle the sieve animation
local function swap_node(pos)
	local node = techage.get_node_lvm(pos)
	local idx = string.byte(node.name, -1) - 48
	idx = (idx + 1) % 4
	minetest.swap_node(pos, {name = "techage:sieve"..idx, param2 = node.param2})
	return idx == 3  -- true if done
end

local function push_items(pos, items)
	local pos1 = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = techage.get_node_lvm(pos1)
	minetest.add_item({x=pos.x, y=pos.y-0.4, z=pos.z}, items)
end

local function minecart_hopper_takeitem(pos, num)
	for _, obj in pairs(minetest.get_objects_inside_radius({x=pos.x, y=pos.y-0.4, z=pos.z}, 0.2)) do
		local entity = obj:get_luaentity()
		if not obj:is_player() and entity and entity.name == "__builtin:item" then
			obj:remove()
			return ItemStack(entity.itemstring or "air")
		end
	end
end

local function minecart_hopper_untakeitem(pos, in_dir, stack)
	push_items(pos, stack)
end

local function keep_running(pos, elapsed)
	if swap_node(pos) then
		local inv = M(pos):get_inventory()
		local src, dst

		if inv:contains_item("src", ItemStack("techage:basalt_gravel")) then
			dst, src = get_random_basalt_ore(), ItemStack("techage:basalt_gravel")
		elseif inv:contains_item("src", ItemStack("default:gravel")) then
			dst, src = get_random_gravel_ore(), ItemStack("default:gravel")
		elseif not inv:is_empty("src") then
			src = inv:get_stack("src", 1):take_item(1)
			dst = src
		else
			return false
		end
		push_items(pos, dst)
		inv:remove_item("src", src)
	end
	local inv = M(pos):get_inventory()
	return not inv:is_empty("src")
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", S("TA1 Gravel Sieve"))
	local inv = meta:get_inventory()
	inv:set_size('src', 1)
end

local function on_punch(pos, node, puncher, pointed_thing)
	local wielded_item = puncher:get_wielded_item():get_name()
	if wielded_item == "default:gravel" or wielded_item == "techage:basalt_gravel" then
		local inv = M(pos):get_inventory()
		local stack = ItemStack(wielded_item)
		if inv:room_for_item("src", stack) then
			inv:add_item("src", stack)
			minetest.swap_node(pos, {name = "techage:sieve0"})
			minetest.get_node_timer(pos):start(1)
			local w = puncher:get_wielded_item()
			if not(minetest.setting_getbool("creative_mode")) then
				w:take_item(1)
				puncher:set_wielded_item(w)
			end
		end
	end
end

local tiles_data = {
	-- up, down, right, left, back, front
	"techage_sieve_gravel_ta1.png",
	"techage_sieve_gravel_ta1.png",
	"techage_sieve_sieve_ta1.png",
	"techage_sieve_sieve_ta1.png",
	"techage_sieve_sieve_ta1.png",
	"techage_sieve_sieve_ta1.png",
}

local nodebox_data = {
	{ -8/16, -3/16, -8/16,   8/16, 4/16, -6/16 },
	{ -8/16, -3/16,  6/16,   8/16, 4/16,  8/16 },
	{ -8/16, -3/16, -8/16,  -6/16, 4/16,  8/16 },
	{  6/16, -3/16, -8/16,   8/16, 4/16,  8/16 },

	{ -8/16, -8/16, -8/16,  -6/16, -3/16, -6/16 },
	{  6/16, -8/16, -8/16,   8/16, -3/16, -6/16 },
	{ -8/16, -8/16,  6/16,  -6/16, -3/16,  8/16 },
	{  6/16, -8/16,  6/16,   8/16, -3/16,  8/16 },

	{ -6/16, -2/16, -6/16,   6/16, 8/16,  6/16 },
}

for idx = 0,3 do
	nodebox_data[9][5] = (8 - 2*idx) / 16
	if idx == 3 then
		tiles_data[1] = "techage_sieve_top_ta1.png"
	end

	minetest.register_node("techage:sieve"..idx, {
		description =  S("TA1 Gravel Sieve"),
		tiles = table.copy(tiles_data),
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = table.copy(nodebox_data),
		},
		selection_box = {
			type = "fixed",
			fixed = { -8/16, -3/16, -8/16,   8/16, 4/16, 8/16 },
		},

		on_construct = idx == 3 and on_construct or nil,
		on_punch = idx == 3 and on_punch or nil,
		on_timer = keep_running,

		minecart_hopper_takeitem = minecart_hopper_takeitem,
		minecart_hopper_untakeitem = minecart_hopper_untakeitem,

		paramtype = "light",
		use_texture_alpha = techage.CLIP,
		sounds = default.node_sound_wood_defaults(),
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, not_in_creative_inventory = (idx == 3) and 0 or 1},
		drop = "techage:sieve3",
	})
end

techage.register_node({"techage:sieve0", "techage:sieve1", "techage:sieve2", "techage:sieve3"}, {
	on_push_item = function(pos, in_dir, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if inv:room_for_item("src", stack) then
			inv:add_item("src", stack)
			minetest.get_node_timer(pos):start(1)
			return true
		end
		return false
	end,
})

minetest.register_node("techage:sieved_gravel", {
	description = S("Sieved Gravel"),
	tiles = {"default_gravel.png"},
	groups = {crumbly=2, falling_node=1, not_in_creative_inventory=1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_node("techage:compressed_gravel", {
	description = S("Compressed Gravel"),
	tiles = {"techage_compressed_gravel.png"},
	groups = {cracky=2, crumbly = 2},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_craft({
	output = "techage:sieve",
	recipe = {
		{"group:wood", "",                   "group:wood"},
		{"group:wood", "techage:iron_ingot", "group:wood"},
		{"group:wood", "",                   "group:wood"},
	},
})

minetest.register_craft({
	output = "techage:compressed_gravel",
	recipe = {
		{"techage:sieved_gravel", "techage:sieved_gravel"},
		{"techage:sieved_gravel", "techage:sieved_gravel"},
	},
})

minetest.register_craft({
	type = "cooking",
	output = "default:cobble",
	recipe = "techage:compressed_gravel",
	cooktime = 10,
})

minetest.register_alias("techage:sieve", "techage:sieve3")
minetest.register_alias("techage:auto_sieve", "techage:auto_sieve3")
