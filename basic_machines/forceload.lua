--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	Forceload  block
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S = techage.S

local function calc_area(pos)
	local xpos = (math.floor(pos.x / 16) * 16)
	local ypos = (math.floor(pos.y / 16) * 16)
	local zpos = (math.floor(pos.z / 16) * 16)
	local pos1 = {x=xpos, y=ypos, z=zpos}
	local pos2 = {x=xpos+15, y=ypos+15, z=zpos+15}
	return pos1, pos2
end

local function in_list(list, x)
	local pos1 = calc_area(x)
	for _,v in ipairs(list) do
		local pos2 = calc_area(v)
		if vector.equals(pos1, pos2) then return true end
	end
	return false
end

local function remove_list_elem(list, x)
	local n = nil
	for idx, v in ipairs(list) do
		if vector.equals(v, x) then 
			n = idx
			break
		end
	end
	if n then
		table.remove(list, n)
	end
	return list
end

local function chat(player, text)
	minetest.chat_send_player(player:get_player_name(), "[Techage] "..text)
end

local function add_pos(pos, player)
	local lPos = minetest.deserialize(player:get_attribute("techage_forceload_blocks")) or {}
	if not in_list(lPos, pos) and (#lPos < techage.max_num_forceload_blocks or
				creative and creative.is_enabled_for and 
				creative.is_enabled_for(player:get_player_name())) then
		lPos[#lPos+1] = pos
		player:set_attribute("techage_forceload_blocks", minetest.serialize(lPos))
		return true
	end
	return false
end
	
local function del_pos(pos, player)
	local lPos = minetest.deserialize(player:get_attribute("techage_forceload_blocks")) or {}
	lPos = remove_list_elem(lPos, pos)
	player:set_attribute("techage_forceload_blocks", minetest.serialize(lPos))
end

local function get_pos_list(player)
	return minetest.deserialize(player:get_attribute("techage_forceload_blocks")) or {}
end

local function set_pos_list(player, lPos)
	player:set_attribute("techage_forceload_blocks", minetest.serialize(lPos))
end

local function get_data(pos, player)
	local pos1, pos2 = calc_area(pos)
	local num = #minetest.deserialize(player:get_attribute("techage_forceload_blocks")) or 0
	local max = techage.max_num_forceload_blocks
	return pos1, pos2, num, max
end

local function formspec(player)
	local lPos = get_pos_list(player)
	local tRes = {}
	tRes[1] = "size[7,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"label[0,0;List of your Forceload Blocks:]"
	
	for idx,pos in ipairs(lPos) do
		local pos1, pos2 = calc_area(pos)
		local ypos = 0.2 + idx * 0.4
		tRes[#tRes+1] = "label[0,"..ypos..";"..idx.."]"
		tRes[#tRes+1] = "label[0.8,"..ypos..";"..P2S(pos1).."]"
		tRes[#tRes+1] = "label[3.2,"..ypos..";to]"
		tRes[#tRes+1] = "label[4,"..ypos..";"..P2S(pos2).."]"
	end
	return table.concat(tRes)
end


minetest.register_node("techage:forceload", {
	description = "Techage Forceload Block",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta2.png^techage_frame_ta2_top.png',
		'techage_filling_ta2.png^techage_frame_ta2_top.png',
		{
			image = "techage_filling_ta2.png^techage_frame_ta2_top.png^techage_appl_forceload.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.5,
			},
		},
	},

	after_place_node = function(pos, placer, itemstack)
		if add_pos(pos, placer) then
			minetest.forceload_block(pos, true)
			local pos1, pos2, num, max = get_data(pos, placer)
			M(pos):set_string("infotext", "Area "..P2S(pos1).." to "..P2S(pos2).." loaded!\n"..
				"Punch the block to make the area visible.")
			chat(placer, "Area ("..num.."/"..max..") "..P2S(pos1).." to "..P2S(pos2).." loaded!")
			techage.mark_region(placer:get_player_name(), pos1, pos2)
			M(pos):set_string("owner", placer:get_player_name())
		else
			chat(placer, "Area already loaded or max. number of Forceload Blocks reached!")
			minetest.remove_node(pos)
			return itemstack
		end
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local player = minetest.get_player_by_name(oldmetadata.fields.owner)
		if player then
			del_pos(pos, player)
		end
		minetest.forceload_free_block(pos, true)
		techage.unmark_region(oldmetadata.fields.owner)
	end,
	
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if M(pos):get_string("owner") == clicker:get_player_name() or
				minetest.check_player_privs(clicker:get_player_name(), "server") then
			local s = formspec(clicker)
			minetest.show_formspec(clicker:get_player_name(), "techage:forceload", s)
		end
	end,
	
	on_punch = function(pos, node, puncher, pointed_thing)
		local pos1, pos2 = calc_area(pos)
		techage.switch_region(puncher:get_player_name(), pos1, pos2)
	end,

	paramtype = "light",
	sunlight_propagates = true,
	groups = {choppy=2, cracky=2, crumbly=2, 
		not_in_creative_inventory = techage.max_num_forceload_blocks == 0 and 1 or 0},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


if techage.max_num_forceload_blocks > 0 then
	minetest.register_craft({
		output = "techage:forceload",
		recipe = {
			{"group:wood", "", "group:wood"},
			{"default:mese_crystal_fragment", "techage:usmium_nuggets", "default:mese_crystal_fragment"},
			{"group:wood", "techage:iron_ingot", "group:wood"},
		},
	})
end

minetest.register_on_joinplayer(function(player)
	local lPos = {}
	for _,pos in ipairs(get_pos_list(player)) do
		local node = techage.get_node_lvm(pos)
		if node.name == "techage:forceload" then
			minetest.forceload_block(pos, true)
			lPos[#lPos+1] = pos
		end
	end
	set_pos_list(player, lPos)
end)

minetest.register_on_leaveplayer(function(player)
	for _,pos in ipairs(get_pos_list(player)) do
		minetest.forceload_free_block(pos, true)
	end
end)

techage.register_entry_page("ta", "forceload",
	S("Techage Forceload Block"), 
	S("The Forceload Block keeps the corresponding area loaded and the machines operational "..
		"as far as the player is logged in. If the player leaves the game, all areas will be unloaded.@n"..
		"The maximum number of Forceload Blocks per player is configurable (default 16).@n"..
		"The loaded area per block is a cube with 16 m side length (according to a Minetest area block). "..
		"Punching the block makes the area visible and invisible again."),
	"techage:forceload")



