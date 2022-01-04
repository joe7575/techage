--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Oil Explorer

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S = techage.S

local PROBABILITY = 100
local OIL_MIN = 4096
local OIL_MAX = 20000
local DEPTH_MIN = 16
local DEPTH_MAX = 25*16
local DEPTH_STEP = 16
local YPOS_MAX = -6*16  -- oil can't found below this level
local OIL_BUBBLE_SIZE = 4096

local seed = tonumber(minetest.settings:get("techage_oil_exploration_seed")) or 1234  -- confidental!

local InvalidGroundNodes = {
	["air"] = true,
}

local ValidGroundNodes = {
	["default:cobble"] = true,
	["default:mossycobble"] = true,
	["default:desert_cobble"] = true,
}

local function oil_amount(pos)
	if pos.y > YPOS_MAX then return 0 end
	local block_key = seed +
		math.floor((pos.z + 32768) / 16) * 4096 * 4096 +
		math.floor((pos.y + 32768) / 16) * 4096 +
		math.floor((pos.x + 32768) / 16)
	math.randomseed(block_key)
	math.random(); math.random(); math.random()
	local has_oil = math.random(1,PROBABILITY) == 1
	if has_oil then
		local amount = math.random(OIL_MIN, OIL_MAX)
		return amount
	end
	return 0
end

local function center(coord)
	return (math.floor(coord/16) * 16) + 8
end

local function basis(coord)
	return (math.floor(coord/16) * 16)
end

-- determine the mapblock coordinates
local function mapblock_coordinates(pos)
	local pos1 = {x = basis(pos.x), y = basis(pos.y), z = basis(pos.z)}
	local pos2 = {x = pos1.x + 15,  y = pos1.y + 15,  z = pos1.z + 15}
	return pos1, pos2
end

local function calc_depth(pos, explore_pos)
	return pos.y - explore_pos.y + 1
end

-- posC is the center position of the oil bubble
-- idx is the vmdata index
-- function returns the real position {x,y,z}
local function calc_vmdata_pos(posC, idx)
	local rest, xoffs, yoffs, zoffs

	rest = idx - 1
	xoffs = rest % 16
	rest  = math.floor(rest / 16)
	zoffs = rest % 16
	rest  = math.floor(rest / 16)
	yoffs = rest % 16
	return {x = basis(posC.x) + xoffs, y = basis(posC.y) + yoffs, z = basis(posC.z) + zoffs}
end

local function calc_vmdata_index(xoffs, yoffs, zoffs)
	return (xoffs + (yoffs * 16) + (zoffs * 16 * 16)) + 1
end

-- from/to are x/z-offsets (0..15) for one layer of oil within one mapblock
local function gen_oil_slice(yoffs, from, to, vmdata, id)
	for xoffs = from, to do
		for zoffs = from, to do
			vmdata[calc_vmdata_index(xoffs, yoffs, zoffs)] = id
		end
	end
end

local function gen_oil_bubble(vmdata)
	local id = minetest.get_content_id("techage:oil_source")

	gen_oil_slice(1, 3, 12, vmdata, id)
	gen_oil_slice(2, 2, 13, vmdata, id)
	for offs = 3, 12 do
		gen_oil_slice(offs, 1, 14, vmdata, id)
	end
	gen_oil_slice(13, 2, 13, vmdata, id)
	gen_oil_slice(14, 3, 12, vmdata, id)
end

local function useable_stone_block(data)
	local valid = {}
	for _,id in ipairs(data) do
		if not valid[id] then
			local itemname = minetest.get_name_from_content_id(id)
			if not ValidGroundNodes[itemname] then
				local ndef = minetest.registered_nodes[itemname]
				if InvalidGroundNodes[itemname] or not ndef or ndef.is_ground_content == false then
					return false
				end
			end
			valid[id] = true
		end
	end
	return true
end

local function get_next_explore_pos(pos)
	local meta = M(pos)
	local ypos = meta:get_int("exploration_ypos")
	if ypos == 0 then
		ypos = math.min(YPOS_MAX, center(pos.y))
	end
	local d = calc_depth(pos, {y = ypos})
	if d + DEPTH_STEP < DEPTH_MAX then
		ypos = ypos - DEPTH_STEP
		local posC = {x = center(pos.x), y = center(ypos), z = center(pos.z)}
		local node = techage.get_node_lvm(posC)
		if node.name ~= "ignore" then
			meta:set_int("exploration_ypos", ypos)
		else
			-- load world and pause for one step
			minetest.emerge_area(posC, posC)
		end

	end
	return {x = center(pos.x), y = center(ypos), z = center(pos.z)}
end

local function get_oil_amount(pos)
	return M(pos):get_int("oil_amount")
end

local function set_oil_amount(pos, amount)
	minetest.set_node(pos, {name = "techage:oilstorage"})
	M(pos):set_int("oil_amount", amount)
	M(pos):set_int("initial_oil_amount", amount)
end

local function status(pos, player_name, explore_pos, amount)
	local depth = calc_depth(pos, explore_pos)
	minetest.chat_send_player(player_name,
		"[TA Oil] "..P2S(explore_pos).." "..S("depth")..": "..depth..",  "..S("Oil")..": "..amount.."    ")
end

local function marker(player_name, pos)
	local posC = {x = center(pos.x), y = pos.y, z = center(pos.z)}
	local pos1 = {x = posC.x - 2, y = posC.y - 2, z = posC.z - 2}
	local pos2 = {x = posC.x + 2, y = posC.y + 7, z = posC.z + 2}
	techage.switch_region(player_name, pos1, pos2)
end

-- check if oil can be placed and if so, do it and return true
local function generate_oil_bubble(posC, amount)
	local pos1, pos2 = mapblock_coordinates(posC)
	local vm = minetest.get_voxel_manip(pos1, pos2)
	local data = vm:get_data()

	if useable_stone_block(data) then
		gen_oil_bubble(data)
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
		set_oil_amount(posC, amount)
		return true
	end
	return false
end

local function explore_area(pos, node, player_name)
	if M(pos):get_int("oil_amount") == 0 then -- nothing found so far?
		local posC, amount

		node.name = "techage:oilexplorer_on"
		minetest.swap_node(pos, node)
		minetest.get_node_timer(pos):start(2.2)
		minetest.sound_play("techage_explore", {
			pos = pos,
			max_hear_distance = 8})

		for i = 1,4 do
			posC = get_next_explore_pos(pos)
			amount = oil_amount(posC)
			if amount > 0 then
				break
			end
		end

		if amount > 0 then
			if get_oil_amount(posC) == 0 then -- not explored so far?
				if generate_oil_bubble(posC, amount) then
					marker(player_name, pos)
				else
					amount = 0
				end
			end
			M(pos):set_int("oil_amount", amount)
		end

		minetest.after(2, status, pos, player_name, posC, amount)
	else
		local explore_pos = {x = center(pos.x), y = M(pos):get_int("exploration_ypos"), z = center(pos.z)}
		status(pos, player_name, explore_pos, M(pos):get_int("oil_amount"))
		marker(player_name, pos)
	end
end

-- Used as storage for already explored blocks
minetest.register_node("techage:oilstorage", {
	description = S("TA3 Oil Storage"),
	tiles = {"default_stone.png"},
	groups = {not_in_creative_inventory=1},
	diggable = false,
	drop = "",
	is_ground_content = false,
})

minetest.register_node("techage:oilexplorer", {
	description = S("TA3 Oil Explorer"),
	tiles = {
		"techage_filling_ta3.png^techage_appl_oilexplorer_top.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_oilexplorer.png",
	},

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		explore_area(pos, node, clicker:get_player_name())
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.unmark_region(digger:get_player_name())
		local xpos = (math.floor(pos.x / 16) * 16)
		local ypos = (math.floor(pos.y / 16) * 16)
		local zpos = (math.floor(pos.z / 16) * 16)
		local pos1 = {x=xpos, y=ypos, z=zpos}
		local pos2 = {x=xpos+15, y=ypos+15, z=zpos+15}
		techage.mark_region(digger:get_player_name(), pos1, pos2)
	end,
	is_ground_content = false,
	groups = {snappy=2,cracky=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:oilexplorer_on", {
	description = S("TA3 Oil Explorer"),
	tiles = {
		{
			image = "techage_filling4_ta3.png^techage_appl_oilexplorer_top4.png^techage_frame4_ta3_top.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",

				aspect_w = 32,
				aspect_h = 32,
				length = 1.2,
			},
		},
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_oilexplorer.png",
	},

	on_timer = function(pos,elapsed)
		local node = minetest.get_node(pos)
		node.name = "techage:oilexplorer"
		minetest.swap_node(pos, node)
	end,

	diggable = false,
	is_ground_content = false,
	paramtype = "light",
	light_source = 8,
	groups = {not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "techage:oilexplorer",
	recipe = {
		{"group:wood", "default:diamond", "group:wood"},
		{"techage:baborium_ingot", "basic_materials:gear_steel", "techage:usmium_nuggets"},
		{"group:wood", "techage:vacuum_tube", "group:wood"},
	},
})


techage.explore = {}

function techage.explore.get_oil_info(pos)
	local amount = 0
	local depth = DEPTH_MIN
	local posC = {x = center(pos.x), y = center(pos.y) - DEPTH_MIN, z = center(pos.z)}
	while amount == 0 and depth < DEPTH_MAX do
		amount = get_oil_amount(posC)
		depth = calc_depth(pos, posC)
		posC.y = posC.y - DEPTH_STEP
	end
	posC.y = posC.y + DEPTH_STEP
	return {depth = depth, amount = amount, storage_pos = posC}
end

function techage.explore.get_oil_amount(posC)
	local meta = M(posC)
	if meta:get_int("initial_oil_amount") == 0 then
		meta:set_int("initial_oil_amount", meta:get_int("oil_amount"))
	end
	return meta:get_int("oil_amount"), meta:get_int("initial_oil_amount")
end

function techage.explore.dec_oil_amount(posC)
	local oil_amount, oil_initial = techage.explore.get_oil_amount(posC)
	oil_amount = oil_amount - 1
	M(posC):set_int("oil_amount", oil_amount)

	local idx = math.floor(oil_amount * OIL_BUBBLE_SIZE / oil_initial)
	idx = idx + 256 -- last level is stone, so add one level
	if idx <= (OIL_BUBBLE_SIZE - 256) then -- first level is stone, too
		local pos = calc_vmdata_pos(posC, idx)
		local node = techage.get_node_lvm(pos)
		if node.name == "techage:oil_source" then
			minetest.remove_node(pos)
		end
	end
	return oil_amount
end
