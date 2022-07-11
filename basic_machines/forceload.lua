--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Forceload block

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

local function postload_area(pos)
	minetest.log("warning", "[FLB] area "..P2S(pos).." not loaded!")
	if not minetest.forceload_block(pos, true) then
		minetest.after(60, postload_area, pos)
	end
end

local function add_pos(pos, player)
	local meta = player:get_meta()
	local lPos = minetest.deserialize(meta:get_string("techage_forceload_blocks")) or {}
	if not in_list(lPos, pos) and (#lPos < techage.max_num_forceload_blocks or
				minetest.global_exists("creative") and creative.is_enabled_for and
				creative.is_enabled_for(player:get_player_name())) then
		lPos[#lPos+1] = pos
		local meta = player:get_meta()
		meta:set_string("techage_forceload_blocks", minetest.serialize(lPos))
		return true
	end
	return false
end

local function del_pos(pos, player)
	local meta = player:get_meta()
	local lPos = minetest.deserialize(meta:get_string("techage_forceload_blocks")) or {}
	lPos = remove_list_elem(lPos, pos)
	meta:set_string("techage_forceload_blocks", minetest.serialize(lPos))
end

local function get_pos_list(player)
	local meta = player:get_meta()
	return minetest.deserialize(meta:get_string("techage_forceload_blocks")) or {}
end

local function set_pos_list(player, lPos)
	local meta = player:get_meta()
	meta:set_string("techage_forceload_blocks", minetest.serialize(lPos))
end

local function show_flbs(pos, name, range)
	local pos1 = {x=pos.x-range, y=pos.y-range, z=pos.z-range}
	local pos2 = {x=pos.x+range, y=pos.y+range, z=pos.z+range}
	for _,npos in ipairs(minetest.find_nodes_in_area(pos1, pos2, {"techage:forceload", "techage:forceloadtile"})) do
		local _pos1, _pos2 = calc_area(npos)
		local owner = M(npos):get_string("owner")
                techage.mark_region(name, _pos1, _pos2, owner .. " " .. P2S(npos))
	end
end

local function get_data(pos, player)
	local pos1, pos2 = calc_area(pos)
	local meta = player:get_meta()
	local num = #minetest.deserialize(meta:get_string("techage_forceload_blocks")) or 0
	local max = techage.max_num_forceload_blocks
	return pos1, pos2, num, max
end

local function formspec(name)
	local player = minetest.get_player_by_name(name)
	if player then
		local lPos = get_pos_list(player)
		local tRes = {}
		for idx,pos in ipairs(lPos) do
			local pos1, pos2 = calc_area(pos)
			tRes[#tRes+1] = idx
			tRes[#tRes+1] = minetest.formspec_escape(P2S(pos1))
			tRes[#tRes+1] = "to"
			tRes[#tRes+1] = minetest.formspec_escape(P2S(pos2))
		end
		return "size[7,9]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			"label[0,0;"..S("List of your Forceload Blocks:").."]"..
			"tablecolumns[text,width=1.2;text,width=12;text,width=1.6;text,width=12]"..
			"table[0,0.6;6.8,8.4;output;"..table.concat(tRes, ",")..";1]"
	end
end

local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	return minetest.rotate_and_place(itemstack, placer, pointed_thing)
end

local function after_place_node(pos, placer, itemstack)
	if add_pos(pos, placer) then
		minetest.forceload_block(pos, true)
		local pos1, pos2, num, max = get_data(pos, placer)
		M(pos):set_string("infotext", "Area "..P2S(pos1).." to "..P2S(pos2).." "..S("loaded").."!\n"..
			S("Punch the block to make the area visible."))
		chat(placer, "Area ("..num.."/"..max..") "..P2S(pos1).." to "..P2S(pos2).." "..S("loaded").."!")
		techage.mark_region(placer:get_player_name(), pos1, pos2)
		M(pos):set_string("owner", placer:get_player_name())
	else
		chat(placer, S("Area already loaded or max. number of Forceload Blocks reached!"))
		minetest.remove_node(pos)
		return itemstack
	end
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	local player = minetest.get_player_by_name(oldmetadata.fields.owner)
	if player then
		del_pos(pos, player)
	end
	minetest.forceload_free_block(pos, true)
	techage.unmark_region(oldmetadata.fields.owner)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local owner = M(pos):get_string("owner")
	local name = clicker:get_player_name()
	if name == owner or	minetest.check_player_privs(name, "server") then
		local s = formspec(owner)
		if s then
			minetest.show_formspec(owner, "techage:forceload", s)
		end
	end
end

local function on_punch(pos, node, puncher, pointed_thing)
	local pos1, pos2 = calc_area(pos)
	techage.switch_region(puncher:get_player_name(), pos1, pos2)
end

minetest.register_node("techage:forceload", {
	description = S("Techage Forceload Block"),
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

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_rightclick = on_rightclick,
	on_punch = on_punch,

	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = techage.CLIP,
	groups = {choppy=2, cracky=2, crumbly=2,
		digtron_protected = 1,
		not_in_creative_inventory = techage.max_num_forceload_blocks == 0 and 1 or 0},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:forceloadtile", {
	description = S("Techage Forceload Tile"),
	tiles = {
		-- up, down, right, left, back, front
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

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			--{-5/16,  -7/16, -5/16, 5/16,  -5/16,  5/16},
			{-4/16,  -8/16, -4/16, 4/16,  -15/32,  4/16},
		},
	},

	on_place = on_place,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_rightclick = on_rightclick,
	on_punch = on_punch,

	paramtype = "light",
	paramtype2 = "facedir",
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
	minetest.register_craft({
		type = "shapeless",
		output = "techage:forceloadtile",
		recipe = {"techage:forceload"},
	})
end

minetest.register_on_joinplayer(function(player)
	local lPos = {}
	for _,pos in ipairs(get_pos_list(player)) do
		local node = techage.get_node_lvm(pos)
		if node.name == "techage:forceload" or node.name == "techage:forceloadtile" then
			if not minetest.forceload_block(pos, true) then
				minetest.after(60, postload_area, pos)
			end
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


minetest.register_chatcommand("forceload", {
	params = "",
	description = S("Show all forceload blocks in a 64x64x64 range"),
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local pos = player:get_pos()
			pos = vector.round(pos)
			show_flbs(pos, name, 64)
		end
	end,
})
