--[[

	Tube Library
	============

	Copyright (C) 2017-2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	forceload.lua:
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

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
	minetest.chat_send_player(player:get_player_name(), "[Tubelib] "..text)
end

local function get_node_lvm(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:index(pos.x, pos.y, pos.z)
	node = {
		name = minetest.get_name_from_content_id(data[idx]),
		param2 = param2_data[idx]
	}
	return node
end

local function add_pos(pos, player)
	local lPos = minetest.deserialize(player:get_attribute("tubelib_forceload_blocks")) or {}
	if not in_list(lPos, pos) and #lPos < tubelib.max_num_forceload_blocks then
		lPos[#lPos+1] = pos
		player:set_attribute("tubelib_forceload_blocks", minetest.serialize(lPos))
		return true
	end
	return false
end
	
local function del_pos(pos, player)
	local lPos = minetest.deserialize(player:get_attribute("tubelib_forceload_blocks")) or {}
	lPos = remove_list_elem(lPos, pos)
	player:set_attribute("tubelib_forceload_blocks", minetest.serialize(lPos))
end

local function get_pos_list(player)
	return minetest.deserialize(player:get_attribute("tubelib_forceload_blocks")) or {}
end

local function set_pos_list(player, lPos)
	player:set_attribute("tubelib_forceload_blocks", minetest.serialize(lPos))
end

local function get_data(pos, player)
	local pos1, pos2 = calc_area(pos)
	local num = #minetest.deserialize(player:get_attribute("tubelib_forceload_blocks")) or 0
	local max = tubelib.max_num_forceload_blocks
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
		tRes[#tRes+1] = "label[0.8,"..ypos..";"..S(pos1).."]"
		tRes[#tRes+1] = "label[3.2,"..ypos..";to]"
		tRes[#tRes+1] = "label[4,"..ypos..";"..S(pos2).."]"
	end
	return table.concat(tRes)
end


minetest.register_node("tubelib:forceload", {
	description = "Tubelib Forceload Block",
	tiles = {
		-- up, down, right, left, back, front
		'tubelib_front.png',
		'tubelib_front.png',
		{
			image = "tubelib_forceload.png",
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
			M(pos):set_string("infotext", "Area "..S(pos1).." to "..S(pos2).." loaded!\n"..
				"Punch the block to make the area visible.")
			chat(placer, "Area ("..num.."/"..max..") "..S(pos1).." to "..S(pos2).." loaded!")
			tubelib.mark_region(placer:get_player_name(), pos1, pos2)
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
		tubelib.unmark_region(oldmetadata.fields.owner)
	end,
	
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if M(pos):get_string("owner") == clicker:get_player_name() or
				minetest.check_player_privs(clicker:get_player_name(), "server") then
			local s = formspec(clicker)
			minetest.show_formspec(clicker:get_player_name(), "tubelib:forceload", s)
		end
	end,
	
	on_punch = function(pos, node, puncher, pointed_thing)
		local pos1, pos2 = calc_area(pos)
		tubelib.switch_region(puncher:get_player_name(), pos1, pos2)
	end,

	paramtype = "light",
	sunlight_propagates = true,
	groups = {choppy=2, cracky=2, crumbly=2, 
		not_in_creative_inventory = tubelib.max_num_forceload_blocks == 0 and 1 or 0},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})


if tubelib.max_num_forceload_blocks > 0 then
	minetest.register_craft({
		output = "tubelib:forceload",
		recipe = {
			{"group:wood", "", "group:wood"},
			{"", "basic_materials:energy_crystal_simple", ""},
			{"group:wood", "tubelib:wlanchip", "group:wood"},
		},
	})
end

minetest.register_on_joinplayer(function(player)
	local lPos = {}
	for _,pos in ipairs(get_pos_list(player)) do
		local node = get_node_lvm(pos)
		if node.name == "tubelib:forceload" then
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
