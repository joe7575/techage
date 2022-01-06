--[[

	TechAge
	=======

	Copyright (C) 2020-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Screwdriver

]]--
if minetest.global_exists("screwdriver") then

local S = techage.S
local M = minetest.get_meta

local USES = 2000

local function base_checks(user, pointed_thing)
	if pointed_thing.type ~= "node" then
		return false
	end

	if not user then
		return false
	end

	local pos = pointed_thing.under
	local player_name = user:get_player_name()

	if minetest.is_protected(pos, player_name) then
		return false
	end

	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]

	if not ndef then
		return false
	end

	if ndef.on_rotate == screwdriver.disallow and not ndef.ta_rotate_node then
		return false
	end

	local yaw = user:get_look_horizontal()
	local dir = minetest.yaw_to_dir(yaw)
	local facedir = minetest.dir_to_facedir(dir)

	return true, pos, player_name, facedir, node, ndef
end


local function store_node_param2(user, node)
	user:get_meta():set_int("techage_screwdriver_param2", node.param2)
	minetest.chat_send_player(user:get_player_name(), S("Block alignment stored!"))
end

local function turn_node_param2(pos, node, ndef, user)
	local param2 = user:get_meta():get_int("techage_screwdriver_param2") or 0
	if ndef.ta_rotate_node then
		ndef.ta_rotate_node(pos, node, param2)
	else
		minetest.swap_node(pos, {name = node.name, param2 = param2})
		minetest.check_for_falling(pos)
	end
end

local function turn_left(pos, node, ndef)
	local param2 = techage.param2_turn_left(node.param2)
	if ndef.ta_rotate_node then
		ndef.ta_rotate_node(pos, node, param2)
	else
		minetest.swap_node(pos, {name = node.name, param2 = param2})
		minetest.check_for_falling(pos)
	end
end

local function turn_up(pos, node, ndef, facedir)
	local param2 = techage.param2_turn_up(facedir, node.param2)
	if ndef.ta_rotate_node then
		ndef.ta_rotate_node(pos, node, param2)
	else
		minetest.swap_node(pos, {name = node.name, param2 = param2})
		minetest.check_for_falling(pos)
	end
end

-- on_use == on_left_click == turn left
local function on_use(itemstack, user, pointed_thing)
	local res, pos, player_name, facedir, node, ndef = base_checks(user, pointed_thing)
	if res then
		if ndef.paramtype2 == "facedir" then
			if user:get_player_control().sneak then
				store_node_param2(user, node)
			else
				turn_left(pos, node, ndef)
			end
		else
			return screwdriver.handler(itemstack, user, pointed_thing, screwdriver.ROTATE_FACE, USES)
		end

		if not minetest.is_creative_enabled(player_name) then
			itemstack:add_wear(65535 / (USES - 1))
		end
	end
	return itemstack
end

-- on_place == on_right_click == turn up
local function on_place(itemstack, user, pointed_thing)
	local res, pos, player_name, facedir, node, ndef = base_checks(user, pointed_thing)
	if res then
		if ndef.paramtype2 == "facedir" then
			if ndef.on_rotate ~= screwdriver.rotate_simple then
				if user:get_player_control().sneak then
					turn_node_param2(pos, node, ndef, user)
				else
					turn_up(pos, node, ndef, facedir)
				end
			else
				return itemstack
			end
		else
			return screwdriver.handler(itemstack, user, pointed_thing, screwdriver.ROTATE_AXIS, USES)
		end

		if not minetest.is_creative_enabled(player_name) then
			itemstack:add_wear(65535 / (USES - 1))
		end
	end
	return itemstack
end

minetest.register_tool("techage:screwdriver", {
	description = S("Techage Screwdriver\n(See: TA3 > Tools)"),
	inventory_image = "techage_screwdriver.png",
	on_use = on_use,
	on_place = on_place,
	node_placement_prediction = "",
	stack_max = 1,
})

minetest.register_craft({
	output = "techage:screwdriver",
	recipe = {
		{"", "default:diamond", ""},
		{"", "basic_materials:steel_bar", ""},
		{"", "techage:baborium_ingot", ""},
	},
})

end
