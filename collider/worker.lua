--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Detector Worlker as part of the Collider

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local AssemblyPlan = {
	-- y-offs, path, facedir-offs, name
	-- 0 = forward, 1 = right, 2 = backward, 3 = left

	-- level 1
	-- left/right
	{ 1, {3,3,3,2}, 0, "techage:ta4_colliderblock"},
	{ 1, {3,3,3},   0, "techage:ta4_colliderblock"},
	{ 1, {3,3,3,0}, 0, "techage:ta4_colliderblock"},
	{ 1, {1,1,1,2}, 0, "techage:ta4_colliderblock"},
	{ 1, {1,1,1},   0, "techage:ta4_colliderblock"},
	{ 1, {1,1,1,0}, 0, "techage:ta4_colliderblock"},
	-- front
	{ 1, {3,3,2}, 0, "techage:ta4_colliderblock"},
	{ 1, {3,2},   0, "techage:ta4_colliderblock"},
	{ 1, {2},     0, "techage:ta4_colliderblock"},
	{ 1, {1,2},   0, "techage:ta4_colliderblock"},
	{ 1, {1,1,2}, 0, "techage:ta4_colliderblock"},
	-- back
	{ 1, {3,3,0}, 0, "techage:ta4_colliderblock"},
	{ 1, {3,0},   0, "techage:ta4_colliderblock"},
	{ 1, {0},     2, "techage:ta4_collider_pipe_inlet"},
	{ 1, {1,0},   0, "techage:ta4_colliderblock"},
	{ 1, {1,1,0}, 0, "techage:ta4_colliderblock"},
	-- middle
	{ 1, {3,3},   0, "techage:ta4_detector_magnet"},
	{ 1, {3},     0, "techage:ta4_detector_magnet"},
	{ 1, {1},     0, "techage:ta4_detector_magnet"},
	{ 1, {1,1},   0, "techage:ta4_detector_magnet"},

	-- level 2
	-- left/right
	{ 2, {3,3,3,2}, 1, "techage:ta4_collider_pipe_inlet"},
	{ 2, {3,3,3},   1, "techage:ta4_collider_tube_inlet"},
	{ 2, {3,3,3,0}, 0, "techage:ta4_colliderblock"},
	{ 2, {1,1,1,2}, 3, "techage:ta4_collider_pipe_inlet"},
	{ 2, {1,1,1},   3, "techage:ta4_collider_tube_inlet"},
	{ 2, {1,1,1,0}, 0, "techage:ta4_colliderblock"},
	-- front
	{ 2, {3,3,2}, 0, "techage:ta4_detector_magnet"},
	{ 2, {3,2},   0, "techage:ta4_detector_magnet"},
	{ 2, {2},     0, "default:obsidian_glass"},
	{ 2, {1,2},   0, "techage:ta4_detector_magnet"},
	{ 2, {1,1,2}, 0, "techage:ta4_detector_magnet"},
	-- back
	{ 2, {3,3,0}, 0, "techage:ta4_detector_magnet"},
	{ 2, {3,0},   0, "techage:ta4_detector_magnet"},
	{ 2, {0},     0, "techage:ta4_colliderblock"},
	{ 2, {1,0},   0, "techage:ta4_detector_magnet"},
	{ 2, {1,1,0}, 0, "techage:ta4_detector_magnet"},

	-- level 3
	-- left/right
	{ 3, {3,3,3,2}, 0, "techage:ta4_colliderblock"},
	{ 3, {3,3,3},   1, "techage:ta4_collider_cable_inlet"},
	{ 3, {3,3,3,0}, 0, "techage:ta4_colliderblock"},
	{ 3, {1,1,1,2}, 0, "techage:ta4_colliderblock"},
	{ 3, {1,1,1},   3, "techage:ta4_collider_cable_inlet"},
	{ 3, {1,1,1,0}, 0, "techage:ta4_colliderblock"},
	-- front
	{ 3, {3,3,2}, 0, "techage:ta4_colliderblock"},
	{ 3, {3,2},   0, "techage:ta4_colliderblock"},
	{ 3, {2},     0, "techage:ta4_colliderblock"},
	{ 3, {1,2},   0, "techage:ta4_colliderblock"},
	{ 3, {1,1,2}, 0, "techage:ta4_colliderblock"},
	-- back
	{ 3, {3,3,0}, 0, "techage:ta4_colliderblock"},
	{ 3, {3,0},   0, "techage:ta4_colliderblock"},
	{ 3, {0},     2, "techage:ta4_collider_pipe_inlet"},
	{ 3, {1,0},   0, "techage:ta4_colliderblock"},
	{ 3, {1,1,0}, 0, "techage:ta4_colliderblock"},
	-- middle
	{ 3, {3,3},   0, "techage:ta4_detector_magnet"},
	{ 3, {3},     0, "techage:ta4_detector_magnet"},
	{ 3, {},      0, "techage:ta4_collider_pipe_outlet"},
	{ 3, {1},     0, "techage:ta4_detector_magnet"},
	{ 3, {1,1},   0, "techage:ta4_detector_magnet"},

	-- Core block
	{ 1, {},      0, "techage:ta4_detector_core"},
}

local t = {}
for name, cnt in pairs(techage.assemble.count_items(AssemblyPlan)) do
	t[#t + 1] = " - " .. cnt .. " " .. name
end
local LABEL = table.concat(t, "\n")

local function build(pos, player_name)
	minetest.chat_send_player(player_name, S("[TA4] Detector is being built!"))
	local inv = M(pos):get_inventory()
	techage.assemble.build_inv(pos, inv, AssemblyPlan, player_name)
end

local function remove(pos, player_name)
	minetest.chat_send_player(player_name, S("[TA4] Detector is being removed!"))
	local inv = M(pos):get_inventory()
	techage.assemble.remove_inv(pos, inv, AssemblyPlan, player_name)
end


local function formspec()
	return "size[8,8.2]"..
	"list[context;src;5,0;3,3;]"..
	"label[0.2,-0.2;" .. S("Item list") .. ":\n" .. LABEL .. "]" ..
	"button_exit[0,3.5;4,1;build;" .. S("Build detector") .. "]" ..
	"button_exit[4,3.5;4,1;remove;" .. S("Remove detector") .. "]" ..
	"list[current_player;main;0,4.5;8,4;]"..
	"listring[context;src]"..
	"listring[current_player;main]"
end

minetest.register_node("techage:ta4_collider_detector_worker", {
	description = S("TA4 Collider Detector Worker"),
	tiles = {
		-- up, down, right, left, back, front
		"default_steel_block.png^techage_collider_detector_appl.png^techage_collider_detector_banner.png",
		"default_steel_block.png^techage_collider_detector_banner.png",
		"default_steel_block.png^techage_collider_detector_banner.png",
		"default_steel_block.png^techage_collider_detector_banner.png",
		"default_steel_block.png^techage_collider_detector_banner.png",
		"default_steel_block.png^techage_collider_detector_appl.png^techage_collider_detector_banner.png",
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	groups = {cracky = 1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	after_place_node = function(pos, placer, itemstack)
		if pos.y > (techage.collider_min_depth - 2) then
			minetest.remove_node(pos)
			minetest.add_item(pos, ItemStack("techage:ta4_collider_detector_worker"))
			return
		end
		local inv = M(pos):get_inventory()
		inv:set_size("src", 9)
		M(pos):set_string("formspec", formspec())
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local nvm = techage.get_nvm(pos)
		if fields.build then
			if not nvm.assemble_locked then
				build(pos, player:get_player_name())
			end
		elseif fields.remove then
			if not nvm.assemble_locked then
				local nvm = techage.get_nvm({x=pos.x, y=pos.y + 1, z=pos.z})
				if not nvm.locked then
					remove(pos, player:get_player_name())
				end
			end
		end
	end,

	after_dig_node = function(pos, oldnode)
		techage.del_mem(pos)
	end,

	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		local nvm = techage.get_nvm(pos)
		if nvm.assemble_locked or nvm.assemble_build then
			minetest.after(30, function(pos)
				local nvm = techage.get_nvm(pos)
				nvm.assemble_locked = false
			end, pos)
			return false
		end
		local inv = M(pos):get_inventory()
		return inv:is_empty("src")
	end,
})


minetest.register_craft({
	output = "techage:ta4_collider_detector_worker",
	recipe = {
		{'techage:aluminum', 'default:chest', 'default:steel_ingot'},
		{'', 'basic_materials:gear_steel', ''},
		{'default:steel_ingot', 'default:mese_crystal', 'techage:aluminum'},
	},
})
