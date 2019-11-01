--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information

	TA3 Oil Explorer
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S = techage.S

local PROBABILITY = 80
local OIL_MIN = 2000
local OIL_MAX = 20000
local DEPTH_MIN = 8
local DEPTH_MAX = (16 * 25) + 8
local DEPTH_STEP = 96

local seed = 1234  -- confidental!

local InvalidGroundNodes = {
	"air",
}

local function oil_amount(pos)
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

local function gen_oil_slice(pos1, posc, y, radius, data, id)
	local y_offs = (y - pos1.y) * 16
	for x = posc.x - radius + 2, posc.x + radius + 2 do
		for z = posc.z - radius + 1, posc.z + radius + 1 do
			local idx = x - pos1.x + y_offs + (z - pos1.z) * 16 * 16
			data[idx] = id
		end
	end
	return (radius * 2 + 1) * (radius * 2 + 1)
end

local function gen_oil_bubble(pos1, posC, amount, data)
	local id = minetest.get_content_id("techage:oil_source")
	--local id = minetest.get_content_id("air")
	local radius = math.floor(math.pow(amount, 1.0/3) / 2)
	local sum = 0
	for y = posC.y - radius, posC.y + radius do
		sum = sum + gen_oil_slice(pos1, posC, y, radius + 1, data, id)
		if sum >= amount then break end
	end
end	
	
local function useable_stone_block(data)
	local valid = {}
	for _,id in ipairs(data) do
		if not valid[id] then
			local itemname = minetest.get_name_from_content_id(id)
			local ndef = minetest.registered_nodes[itemname]
			if not ndef or not ndef.is_ground_content or InvalidGroundNodes[itemname] then
				return false
			end
			valid[id] = true
		end
	end
	return true
end
	
local function get_next_depth(pos)
	local meta = M(pos)
	local depth = meta:get_int("exploration_depth")
	if depth == 0 then
		depth = DEPTH_MIN
	end
	if depth + DEPTH_STEP < DEPTH_MAX then
		depth = depth + DEPTH_STEP
		meta:set_int("exploration_depth", depth)
	end
	return depth
end

local function get_oil_amount(pos)
	return M(pos):get_int("oil_amount")
end

local function set_oil_amount(pos, amount)
	minetest.set_node(pos, {name = "techage:oilstorage"})
	return M(pos):set_int("oil_amount", amount)
end

local function status(pos, player_name, depth, amount)
	depth = depth + pos.y
	local posC = {x = center(pos.x), y = pos.y, z = center(pos.z)}
	minetest.chat_send_player(player_name, 
		"[TA Oil] "..P2S(posC).." depth: "..depth..",  Oil: "..amount.."    ")
end

local function marker(player_name, pos)
	local posC = {x = center(pos.x), y = pos.y, z = center(pos.z)}
	local pos1 = {x = posC.x - 1, y = posC.y - 1, z = posC.z - 1}
	local pos2 = {x = posC.x + 1, y = posC.y + 3, z = posC.z + 1}
	techage.switch_region(player_name, pos1, pos2)
end

local function explore_area(pos, pos1, pos2, posC, depth, amount, player_name)
	local vm = minetest.get_voxel_manip(pos1, pos2)
	local data = vm:get_data()
	
	if useable_stone_block(data) then
		gen_oil_bubble(pos1, posC, amount/10, data)
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
		M(pos):set_int("oil_amount", amount)
		M(pos):set_int("depth", depth)
		set_oil_amount(posC, amount)
		marker(player_name, pos)
	else
		amount = 0
	end
	status(pos, player_name, depth, amount)
end

local function emerge_area(pos, node, player_name)
	if get_oil_amount(pos) == 0 then -- nothing found so far?
		local depth = get_next_depth(pos)
		local posC = {x = center(pos.x), y = center(-depth), z = center(pos.z)}
		local radius = 7
		local pos1 = {x = posC.x - radius, y = posC.y - radius, z = posC.z - radius}
		local pos2 = {x = posC.x + radius, y = posC.y + radius, z = posC.z + radius}
		local amount = oil_amount(posC)
		if creative and creative.is_enabled_for	and 
				creative.is_enabled_for(player_name) then
			amount = 10000
		end
		
		minetest.sound_play("techage_explore", {
			pos = pos, 
			max_hear_distance = 8})
	
		node.name = "techage:oilexplorer_on"
		minetest.swap_node(pos, node)
		minetest.get_node_timer(pos):start(2.2)
		
		if amount > 0 then
			if get_oil_amount(posC) == 0 then -- not explored so far?
				minetest.emerge_area(pos1, pos2)
				minetest.after(2, explore_area, pos, pos1, pos2, posC, depth, amount, player_name)
			else
				M(pos):set_int("oil_amount", amount)
				M(pos):set_int("depth", depth)
				minetest.after(2, status, pos, player_name, depth, amount)
				minetest.after(2, marker, player_name, pos)
			end
		else
			minetest.after(2, status, pos, player_name, depth, 0)
		end	
	else
		status(pos, player_name, M(pos):get_int("depth"), M(pos):get_int("oil_amount"))
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
		emerge_area(pos, node, clicker:get_player_name())
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.unmark_region(digger:get_player_name())
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
	local posC
	while amount == 0 and depth < DEPTH_MAX do
		depth = depth + DEPTH_STEP
		posC = {x = center(pos.x), y = center(-depth), z = center(pos.z)}
		amount = get_oil_amount(posC)
	end
	return {depth = center(depth) - 1 + pos.y, amount = amount, storage_pos = posC}
end

function techage.explore.get_oil_amount(posC)
	return M(posC):get_int("oil_amount")
end

function techage.explore.dec_oil_amount(posC)
	local meta = M(posC)
	local amount = meta:get_int("oil_amount")
	meta:set_int("oil_amount", amount-1)
	return amount-1
end
