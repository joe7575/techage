--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Coalburner as heater for the Meltingpot

]]--

local S = techage.S

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

local function remove_coal(pos, height)
	local pos1 = {x=pos.x-1, y=pos.y+1, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y+height, z=pos.z+1}
	for _,p in ipairs(minetest.find_nodes_in_area(pos1, pos2, "techage:charcoal_burn")) do
		minetest.remove_node(p)
	end
end

local function remove_flame(pos, height)
	local idx
	pos = {x=pos.x, y=pos.y+height, z=pos.z}
	for idx=height,1,-1 do
		pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local node = techage.get_node_lvm(pos)
		if string.find(node.name, "techage:flame") then
			minetest.remove_node(pos)
		elseif node.name == "techage:meltingpot" then
			techage.update_heat(pos)
		end
	end
end

local function calc_num_coal(height, burn_time)
	local num = height
	if burn_time < 0 then
		local x = (COAL_BURN_TIME * 0.2) / height
		num = math.max(height + math.floor(burn_time/x), 0)
	end
	return num
end

local function flame(pos, height, heat, first_time)
	local idx
	local playername = minetest.get_meta(pos):get_string("playername")
	pos = {x=pos.x, y=pos.y+height, z=pos.z}
	for idx=heat,1,-1 do
		pos = {x=pos.x, y=pos.y+1, z=pos.z}
		idx = math.min(idx, 12)
		local node = techage.get_node_lvm(pos)
		if node.name == "techage:meltingpot_active" or node.name == "ignore" then
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
		if minetest.is_protected(pos, playername) then
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
			local node = techage.get_node_lvm(pos)
			if minetest.get_item_group(node.name, "techage_flame") > 0 then
				minetest.remove_node(pos)
			end
		end,

		drawtype = "glasslike",
		use_texture_alpha = techage.BLEND,
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
	paramtype = "light",
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
		--meta:set_int("ignite", minetest.get_gametime())
		meta:set_int("burn_time", COAL_BURN_TIME)
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
	local burn_time = meta:get_int("burn_time")
	-- burner hole is open
	if num_air(pos) == 1 then
		meta:set_int("burn_time", burn_time - CYCLE_TIME)
		-- tower intact
		if num_cobble(pos, height) == height * 8 then
			local num_coal = calc_num_coal(height, burn_time)
			if num_coal > 0 then
				if meta:get_int("paused") == 1 then
					flame(pos, height, num_coal, true)
					meta:set_int("paused", 0)
				else
					flame(pos, height, num_coal, false)
				end
				handle = minetest.sound_play("techage_gasflare", {
						pos = {x=pos.x, y=pos.y+height, z=pos.z},
						max_hear_distance = 32,
						gain = num_coal/12.0,
						loop = true})
				meta:set_int("handle", handle)
			else
				minetest.swap_node(pos, {name="techage:ash"})
				remove_coal(pos, height)
				local handle = meta:get_int("handle")
				minetest.sound_stop(handle)
				return false
			end
		else
			minetest.swap_node(pos, {name="techage:ash"})
			remove_coal(pos, height)
			local handle = meta:get_int("handle")
			minetest.sound_stop(handle)
			return false
		end
	else
		meta:set_int("paused", 1)
	end
	return true
end

function techage.stop_burner(pos)
	local meta = minetest.get_meta(pos)
	local height = meta:get_int("height")
	remove_flame(pos, height)
	remove_coal(pos, height)
	local handle = meta:get_int("handle")
	minetest.sound_stop(handle)
	meta:set_int("burn_time", 0)
end
