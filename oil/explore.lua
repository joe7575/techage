-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,IS = dofile(MP.."/intllib.lua")


local PROBABILITY = 2
local OIL_MIN = 1000
local OIL_MAX = 20000
local DEPTH_MIN = (16 * 7) - 8
local DEPTH_MAX = (16 * 60) - 8

local seed = 1234

local function get_node_name(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node.name
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:index(pos.x, pos.y, pos.z)
	return minetest.get_name_from_content_id(data[idx])
end


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

local Invalid = {
	"air",
}

local function gen_oil_slice(pos1, posc, y, radius, data, id)
	local y_offs = (y - pos1.y) * 16
	for x = posc.x - radius, posc.x + radius do
		for z = posc.z - radius, posc.z + radius do
			local idx = x - pos1.x + y_offs + (z - pos1.z) * 16 * 16
			data[idx] = id
		end
	end
	return (radius * 2 + 1) * (radius * 2 + 1)
end

local function gen_oil_bubble(pos1, posC, amount, data)
	local id = minetest.get_content_id("techage:oil_source")
	local radius = math.floor(math.pow(amount, 1.0/3) / 2)
	local sum = 0
	for y = posC.y - radius, posC.y + radius do
		sum = sum + gen_oil_slice(pos1, posC, y, radius + 1, data, id)
		print(y, sum, amount)
		if sum >= amount then break end
	end
end	
	
local function useable_stone_block(data)
	local valid = {}
	for _,id in ipairs(data) do
		if not valid[id] then
			local itemname = minetest.get_name_from_content_id(id)
			local ndef = minetest.registered_nodes[itemname]
			if not ndef or not ndef.is_ground_content or Invalid[itemname] then
				return false
			end
			valid[id] = true
		end
	end
	return true
end
	
local function explore_area(posS, depth, amount, player_name, pos1, pos2, posC)
	if amount > 0 and M(posS):get_int("oil_amount") == 0 then
		local vm = minetest.get_voxel_manip(pos1, pos2)
		local data = vm:get_data()
		
		if useable_stone_block(data) then
			gen_oil_bubble(pos1, posC, amount/10, data)
			vm:set_data(data)
			vm:write_to_map()
			vm:update_map()
			print("explore_area", S(pos1), S(pos2))
		else
			amount = 0
		end
	end
	M(posS):set_int("oil_amount", amount)
	minetest.chat_send_player(player_name, "[TA Oil] depth: "..tostring(depth)..
		",  Oil: "..tostring(amount).."    ")
end

local function get_next_depth(pos)
	local meta = M(pos)
	local name = get_node_name(pos)	
	local depth = DEPTH_MIN
	if name == "techage:oilstorage" then
		if meta:get_int("oil_amount") == 0 then
			depth = M(pos):get_int("exploration_depth") + 32
		else
			depth = M(pos):get_int("exploration_depth")
		end
	else
		minetest.set_node(pos, {name = "techage:oilstorage"})
	end
	M(pos):set_int("exploration_depth", depth)
	return depth
end

local function emerge_area(pos, node, player_name)
	node.name = "techage:oilexplorer_on"
	minetest.swap_node(pos, node)
	minetest.get_node_timer(pos):start(2.2)
	
	-- used to store the depth/amount info
	local store_pos = {x = center(pos.x), y = -100, z = center(pos.z)}
	local depth = get_next_depth(store_pos)
	minetest.sound_play("techage_explore", {
		pos = pos, 
		max_hear_distance = 8})
	local posC = {x = center(pos.x), y = center(pos.y-depth), z = center(pos.z)}
	local amount = oil_amount(posC)
	if amount > 0 then
		local radius = 7
		local pos1 = {x = posC.x - radius, y = posC.y - radius, z = posC.z - radius}
		local pos2 = {x = posC.x + radius, y = posC.y + radius, z = posC.z + radius}
		print("emerge_area", S(pos1), S(pos2), S(posC))
		minetest.emerge_area(pos1, pos2)
		minetest.after(2, explore_area, store_pos, depth, amount, player_name, pos1, pos2, posC)
	else
		minetest.after(2, explore_area, store_pos, depth, 0, player_name)
	end	
end

--local function test(pos)
--	local posC = {x = center(pos.x), y = center(pos.y+20), z = center(pos.z)}
--	local pos1 = {x = posC.x - 8, y = posC.y - 8, z = posC.z - 8}
--	local pos2 = {x = posC.x + 7, y = posC.y + 7, z = posC.z + 7}
--	bubble(pos1, pos2, posC, math.random(10, 200))	
--end

-- Used as storage for already explored blocks
-- Will be places -100 in the middle if a block (8,8)
minetest.register_node("techage:oilstorage", {
	description = "TA Oil Storage",
	tiles = {"default_stone.png"},
	groups = {not_in_creative_inventory=1},
	diggable = false,
	is_ground_content = false,
})

minetest.register_node("techage:oilexplorer", {
	description = "Oil Explorer",
	tiles = {
		"techage_filling_ta3.png^techage_appl_oilexplorer_top.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_oilexplorer.png",
	},

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		emerge_area(pos, node, clicker:get_player_name())
	end,
	
	is_ground_content = false,
	groups = {snappy=2,cracky=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:oilexplorer_on", {
	description = "Oil Explorer",
	tiles = {
	{
		image = "techage_filling4_ta3.png^techage_appl_oilexplorer_top4.png^techage_frame4_ta3_top.png",
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 32,
			aspect_h = 32,
			length = 1.0,
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
	
	is_ground_content = false,
	groups = {snappy=2,cracky=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("techage:oil_source", {
    description = "Oil Source",
	drawtype = "liquid",
    paramtype = "light",

    inventory_image = "techage_oil_inv.png",
    tiles = {
        {
            name = "techage_oil_animated.png",
			backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length   = 10
            }
        },
        {
            name = "techage_oil_animated.png",
			backface_culling = false,
            animation = {
				type = "vertical_frames",
				aspect_w = 16,
                aspect_h = 16, 
				length = 2.0
			}   
        }
    },

    walkable     = false,
    pointable    = false,
    diggable     = false,
    buildable_to = true,
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "techage:oil_flowing",
    liquid_alternative_source = "techage:oil_source",
    liquid_viscosity = 20,
    liquid_range = 10,
	post_effect_color = {a = 200, r = 1, g = 1, b = 1},
	groups = {liquid = 5},
})



minetest.register_node("techage:oil_flowing", {
	description = "Flowing Oil",
	drawtype = "flowingliquid",
	tiles = {"techage_oil.png"},
	special_tiles = {
		{
			name = "techage_oil_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 10,
			},
		},
		{
			name = "techage_oil_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 10,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "techage:oil_flowing",
	liquid_alternative_source = "techage:oil_source",
	liquid_viscosity = 20,
	liquid_range = 10,
	post_effect_color = {a = 200, r = 1, g = 1, b = 1},
	groups = {liquid = 5, not_in_creative_inventory = 1},
})