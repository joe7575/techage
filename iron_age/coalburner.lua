--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Coalburner as heater for the Meltingpot
	
]]--


-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local S, NS = dofile(MP.."/intllib.lua")

local COAL_BURN_TIME = 1200
local CYCLE_TIME = 5


local function num_coal(pos)
	local pos1 = {x=pos.x, y=pos.y+1, z=pos.z}
	local pos2 = {x=pos.x, y=pos.y+32, z=pos.z}
	local nodes = minetest.find_nodes_in_area(pos1, pos2, {"techage:charcoal", "techage:charcoal_burn"})
	return #nodes
end

local function num_cobble(pos, height)
	local pos1 = {x=pos.x-1, y=pos.y+1, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y+height, z=pos.z+1}
	local nodes = minetest.find_nodes_in_area(pos1, pos2, {"default:cobble", "default:desert_cobble"})
	return #nodes
end

local function num_air(pos)
	local pos1 = {x=pos.x-1, y=pos.y, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y, z=pos.z+1}
	local nodes = minetest.find_nodes_in_area(pos1, pos2, {"air"})
	return #nodes
end

local function start_burner(pos, height)
	local pos1 = {x=pos.x-1, y=pos.y+1, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y+height, z=pos.z+1}
	for _,p in ipairs(minetest.find_nodes_in_area(pos1, pos2, "techage:charcoal")) do
		minetest.swap_node(p, {name = "techage:charcoal_burn"})
	end
end

local function remove_flame(pos, height)
	local idx
	pos = {x=pos.x, y=pos.y+height, z=pos.z}
	for idx=height,1,-1 do
		pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local node = minetest.get_node(pos)
		if string.find(node.name, "techage:flame") then
			minetest.remove_node(pos)
		elseif node.name == "techage:meltingpot" then
			techage.update_heat(pos)
		end
	end
end

local function calc_num_coal(meta)
	local t = minetest.get_gametime() - meta:get_int("ignite")
	local num = meta:get_int("height")
	t = t - COAL_BURN_TIME
	if t > 0 then
		local x = (COAL_BURN_TIME * 0.2) / num
		num = math.max(num - math.floor(t/x), 0)
	end
	return num
end	

local function flame(pos, height, heat, first_time)
	local idx
	pos = {x=pos.x, y=pos.y+height, z=pos.z}
	for idx=heat,1,-1 do
		pos = {x=pos.x, y=pos.y+1, z=pos.z}
		idx = math.min(idx, 12)
		local node = minetest.get_node(pos)
		if node.name == "techage:meltingpot_active" then
			return
		end
		if node.name == "techage:meltingpot" then
			if first_time then
				techage.switch_to_active(pos)
			else
				techage.update_heat(pos)
			end
			return
		end
		minetest.add_node(pos, {name = "techage:flame"..math.min(idx,7)})
		local meta = minetest.get_meta(pos)
		meta:set_int("heat", idx)
	end
end


local lRatio = {120, 110, 95, 75, 55, 28, 0}
local lColor = {"000080", "400040", "800000", "800000", "800000", "800000", "800000"}

for idx,ratio in ipairs(lRatio) do
	local color = "techage_flame_animated.png^[colorize:#"..lColor[idx].."B0:"..ratio
	minetest.register_node("techage:flame"..idx, {
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
		
		use_texture_alpha = true,
		inventory_image = "techage_flame.png",
		paramtype = "light",
		light_source = 13,
		walkable = false,
		buildable_to = true,
		floodable = true,
		sunlight_propagates = true,
		damage_per_second = 4 + idx,
		groups = {igniter = 2, dig_immediate = 3, techage_flame=1, not_in_creative_inventory=1},
		drop = "",
	})
end

minetest.register_node("techage:ash", {
	description = S("Ash"),
	tiles = {"techage_ash.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-4/8, -4/8, -4/8,  4/8, -3/8, 4/8},
		},
	},
	is_ground_content = false,
	groups = {crumbly = 3, not_in_creative_inventory=1},
	drop = "",
	sounds = default.node_sound_defaults(),
})

function techage.start_burner(pos, playername)
	local height = num_coal(pos)
	if minetest.is_protected(
			{x=pos.x, y=pos.y+height, z=pos.z}, 
			playername) then
		return
	end
	if num_cobble(pos, height) == height * 8 then
		local meta = minetest.get_meta(pos)
		meta:set_int("ignite", minetest.get_gametime())
		meta:set_int("height", height)
		start_burner(pos, height)
		flame(pos, height, height, true)
		local handle = minetest.sound_play("techage_gasflare", {
				pos = {x=pos.x, y=pos.y+height, z=pos.z}, 
				max_hear_distance = 20, 
				gain = height/12.0, 
				loop = true})
		meta:set_int("handle", handle)
		minetest.get_node_timer(pos):start(CYCLE_TIME)
	end
end

function techage.keep_running_burner(pos)
	local meta = minetest.get_meta(pos)
	local height = meta:get_int("height")
	remove_flame(pos, height)
	local handle = meta:get_int("handle")
	if handle then
		minetest.sound_stop(handle)
		meta:set_int("handle", 0)
	end
	if num_cobble(pos, height) == height * 8 then
		local num = calc_num_coal(meta)
		if num > 0 then
			if num_air(pos) == 0 then
				-- pause the burner
				meta:set_int("ignite", meta:get_int("ignite") + CYCLE_TIME)
				return true
			end
			flame(pos, height, num, false)
			handle = minetest.sound_play("techage_gasflare", {
					pos = {x=pos.x, y=pos.y+height, z=pos.z}, 
					max_hear_distance = 32, 
					gain = num/12.0, 
					loop = true})
			meta:set_int("handle", handle)
		else
			minetest.swap_node(pos, {name="techage:ash"})
			return false
		end
		return true
	end
	return true
end

function techage.stop_burner(pos)
	local meta = minetest.get_meta(pos)
	local height = meta:get_int("height")
	remove_flame(pos, height)
	local handle = meta:get_int("handle")
	minetest.sound_stop(handle)
end


local BurnerHelp = S([[Coal Burner to heat the melting pot:
- build a 3x3xN cobble tower
- more height means more flame heat   
- keep a hole open on one side
- put a lighter in
- fill the tower from the top with charcoal
- ignite the lighter
- place the pot in the flame, (one block above the tower)
- to pause the burner, close the hole temporarily with e.g. dirt
(see plan)]])

local BurnerImages = {
	
	{false, false, false, "default_cobble.png^techage_meltingpot.png", false},
	{false, false, false, false, false},
	{false, false, "default_cobble.png", "techage_charcoal.png", "default_cobble.png"},
	{false, false, "default_cobble.png", "techage_charcoal.png", "default_cobble.png"},
	{false, false, "default_cobble.png", "techage_charcoal.png", "default_cobble.png"},
	{false, false, "default_cobble.png", "techage_charcoal.png", "default_cobble.png"},
	{false, false, false,                "techage_lighter.png",  "default_cobble.png"},
	{false, false, "default_cobble.png", "default_cobble.png",   "default_cobble.png"},
}

techage.register_help_page("Coal Burner", BurnerHelp, nil, BurnerImages)
