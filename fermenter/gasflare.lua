--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Biogas flare

]]--


local HEIGHT = 7

local function remove_flame(pos)
	local idx
	for idx=HEIGHT,1,-1 do
		pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local node = minetest.get_node(pos)
		if string.find(node.name, "techage:flame") then
			minetest.remove_node(pos)
		end
	end
end

local function flame(pos)
	local idx
	for idx=HEIGHT,1,-1 do
		pos = {x=pos.x, y=pos.y+1, z=pos.z}
		idx = math.min(idx, 12)
		local node = minetest.get_node(pos)
		if node.name ~= "air" then
			return
		end
		minetest.add_node(pos, {name = "techage:flame"..math.min(idx,7)})
		local meta = minetest.get_meta(pos)
	end
end


local lRatio = {120, 110, 95, 75, 55, 28, 0}
local lColor = {"000080", "400040", "800000", "800000", "800000", "800000", "800000"}
for idx,ratio in ipairs(lRatio) do
	local color = "techage_flame_animated.png^[colorize:#"..lColor[idx].."B0:"..ratio
	minetest.register_node("techage:flame"..idx, {
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-3/8, -4/8, -2/8,  3/8, 4/8, 2/8},
				{-2/8, -4/8, -3/8,  2/8, 4/8, 3/8},
			},
		},
		tiles = {
			{
				name = color,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1
				},
			},
		},

		after_destruct = function(pos, oldnode)
			pos.y = pos.y + 1
			local node = minetest.get_node(pos)
			if minetest.get_item_group(node.name, "techage_flame") > 0 then
				minetest.remove_node(pos)
			end
		end,

		use_texture_alpha = techage.BLEND,
		inventory_image = "techage_flame.png",
		paramtype = "light",
		light_source = 13,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = "",
		drowning = 1,
		damage_per_second = 4 + idx,
		groups = {igniter = 2, dig_immediate = 3, techage_flame=1, not_in_creative_inventory=1},
		drop = "",
	})
end

local function start_flarestack(pos, playername)
	if minetest.is_protected(
			{x=pos.x, y=pos.y+1, z=pos.z},
			playername) then
		return
	end
	local meta = minetest.get_meta(pos)
	flame({x=pos.x, y=pos.y+1, z=pos.z})
	local handle = minetest.sound_play("gasflare", {
			pos = pos,
			max_hear_distance = 20,
			gain = 1,
			loop = true})
	--print("handle", handle)
	meta:set_int("handle", handle)
end

local function stop_flarestack(pos, handle)
	remove_flame({x=pos.x, y=pos.y+1, z=pos.z})
	minetest.sound_stop(handle)
end

minetest.register_node("techage:gasflare", {
	description = "gas flare",
	tiles = {
		"techage_gasflare.png",
		"techage_gasflare.png",
		"techage_gasflare.png",
		"techage_gasflare.png",
		"techage_gasflare.png",
		"techage_gasflare.png^techage_appl_hole2.png",
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		if node.name ~= "air" then
			return
		end
		minetest.add_node({x=pos.x, y=pos.y+1, z=pos.z}, {name = "techage:gasflare2"})
	end,

	on_punch = function(pos, node, puncher)
		local meta = minetest.get_meta(pos)
		local handle = meta:get_int("handle")
		minetest.sound_stop(handle)
		start_flarestack(pos, puncher:get_player_name())
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		--print(dump(oldmetadata))
		stop_flarestack(pos, oldmetadata.fields.handle)
		local node = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		if node.name == "techage:gasflare2" then
			minetest.remove_node({x=pos.x, y=pos.y+1, z=pos.z})
		end
	end,

	paramtype = "light",
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:gasflare2", {
	description = "",
	tiles = {
		"techage_gasflare.png^techage_appl_hole2.png",
		"techage_gasflare.png"
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, -4/8, -1/8,  1/8, 4/8, 1/8},
			{-4/8,  3/8, -4/8,  4/8, 4/8, 4/8},
		},
	},
	paramtype = "light",
	light_source = 0,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	diggable = false,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
