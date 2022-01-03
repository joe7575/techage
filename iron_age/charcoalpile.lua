--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Charcoalpile to produce charcoal

]]--

local S = techage.S

local PILE_BURN_TIME = 1200
local COAL_BURN_TIME = 300

-- determine the number of wood nodes
local function num_wood(pos)
	local pos1 = {x=pos.x-1, y=pos.y, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y+2, z=pos.z+1}
	local nodes = minetest.find_nodes_in_area(pos1, pos2, "group:wood")
	return #nodes
end

-- determine the number of dirt nodes (around wood)
local function num_dirt(pos)
	local pos1 = {x=pos.x-2, y=pos.y-1, z=pos.z-2}
	local pos2 = {x=pos.x+2, y=pos.y+3, z=pos.z+2}
	local nodes = minetest.find_nodes_in_area(pos1, pos2, techage.aAnyKindOfDirtBlocks)
	return #nodes
end

-- determine the number of ignore nodes
local function num_ignore(pos)
	local pos1 = {x=pos.x-2, y=pos.y-1, z=pos.z-2}
	local pos2 = {x=pos.x+2, y=pos.y+3, z=pos.z+2}
	local nodes = minetest.find_nodes_in_area(pos1, pos2, "ignore")
	return #nodes
end

-- replace pile top nodes
local function make_dirt_with_dry_grass(pos)
	local pos1 = {x=pos.x-2, y=pos.y+3, z=pos.z-2}
	local pos2 = {x=pos.x+2, y=pos.y+3, z=pos.z+2}
	for _,p in ipairs(minetest.find_nodes_in_area(pos1, pos2, {
				"default:dirt_with_grass",
				"default:dirt_with_coniferous_litter",
				"default:dirt_with_rainforest_litter",
			})) do
		minetest.swap_node(p, {name = "default:dirt_with_dry_grass"})
	end
	if minetest.global_exists("ethereal") then
		for _,p in ipairs(minetest.find_nodes_in_area(pos1, pos2, techage.aEtherealDirts)) do
			minetest.swap_node(p, {name = "default:dirt_with_dry_grass"})
		end
	end
end

-- replace pile bottom nodes
local function make_dirt_with_ash(pos)
	local pos1 = {x=pos.x-1, y=pos.y-1, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y-1, z=pos.z+1}
	for _,p in ipairs(minetest.find_nodes_in_area(pos1, pos2, "default:dirt")) do
		minetest.swap_node(p, {name = "techage:dirt_with_ash"})
	end
end

local function start_smoke(pos)
	local meta = minetest.get_meta(pos)
	pos = {x=pos.x, y=pos.y+3.6, z=pos.z}
	local id = meta:get_int("smoke")
	local above = minetest.get_node(pos).name

	if id ~= 0 then
		minetest.delete_particlespawner(id)
		meta:set_int("smoke", 0)
	end

	if above == "air" then
		id = minetest.add_particlespawner({
			amount = 4, time = 0, collisiondetection = true,
			minpos = {x=pos.x-0.25, y=pos.y+0.1, z=pos.z-0.25},
			maxpos = {x=pos.x+0.25, y=pos.y+5, z=pos.z+0.25},
			minvel = {x=-0.2, y=0.3, z=-0.2}, maxvel = {x=0.2, y=1, z=0.2},
			minacc = {x=0,y=0,z=0}, maxacc = {x=0,y=0.5,z=0},
			minexptime = 2, maxexptime = 4,
			minsize = 6, maxsize = 12,
			texture = "techage_smoke.png",
		})
		meta:set_int("smoke", id)
	end
end

local function stop_smoke(pos)
	local meta = minetest.get_meta(pos)
	local id = meta:get_int("smoke")
	if id ~= 0 then
		minetest.delete_particlespawner(id)
	end
	meta:set_int("smoke", 0)
end

-- replace wood by burning coal
local function collapse_pile(pos)
	local pos1 = {x=pos.x-1, y=pos.y, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y+2, z=pos.z+1}
	techage.ironage_swap_nodes(pos1, pos2, "group:wood", "techage:charcoal_burn")
	stop_smoke(pos)
	make_dirt_with_ash(pos)
end

-- replace wood by coal
local function convert_to_coal(pos)
	local pos1 = {x=pos.x-1, y=pos.y+1, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y+2, z=pos.z+1}
	techage.ironage_swap_nodes(pos1, pos2, "group:wood", "air")
	pos1 = {x=pos.x-1, y=pos.y+0, z=pos.z-1}
	pos2 = {x=pos.x+1, y=pos.y+1, z=pos.z+1}
	techage.ironage_swap_nodes(pos1, pos2, "group:wood", "techage:charcoal")
	stop_smoke(pos)
	minetest.swap_node(pos, {name = "techage:charcoal"})
	make_dirt_with_ash(pos)
	make_dirt_with_dry_grass(pos)
end

function techage.start_pile(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int("ignite", minetest.get_gametime())
	minetest.get_node_timer(pos):start(20)
end

-- node timer function
function techage.keep_running_pile(pos)
	local meta = minetest.get_meta(pos)
	if meta:get_int("running") == 0 then
		if num_wood(pos) == 26 and num_dirt(pos) == 98 then
			meta:set_int("running", 1)
			start_smoke(pos)
		elseif minetest.get_gametime() > (meta:get_int("ignite") + 10) then
			collapse_pile(pos)
			minetest.remove_node(pos)
			return false
		end
	else
		if num_ignore(pos) == 0 and (num_wood(pos) ~= 26 or num_dirt(pos) ~= 98) then
			collapse_pile(pos)
			minetest.remove_node(pos)
			return false
		elseif minetest.get_gametime() > (meta:get_int("ignite") + PILE_BURN_TIME) then
			convert_to_coal(pos)
			return false
		end
	end
	return true
end

function techage.stop_pile(pos)
	collapse_pile(pos)
end


minetest.register_node("techage:dirt_with_ash", {
	description = S("Dirt with Ash"),
	tiles = {
		"techage_ash.png",
		"default_dirt.png",
		{name = "default_dirt.png^techage_ash_side.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1, not_in_creative_inventory=1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.4},
	}),
})


minetest.register_node("techage:charcoal_burn", {
	tiles = {"techage_charcoal_burn.png"},
	after_place_node = function(pos)
		minetest.get_node_timer(pos):start(math.random(COAL_BURN_TIME, COAL_BURN_TIME*1.2))
	end,
	on_timer = function(pos)
		minetest.remove_node(pos)
		return false
	end,
	drop = "",
	paramtype = "light",
	light_source = 10,
	is_ground_content = false,
	groups = {crumbly = 2, falling_node = 1, not_in_creative_inventory=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("techage:charcoal", {
	description = S("TA1 Charcoal"),
	tiles = {"techage_charcoal.png"},
	on_ignite = function(pos, igniter)
		minetest.after(2, minetest.swap_node, pos, {name = "techage:charcoal_burn"})
		minetest.after(COAL_BURN_TIME/2, minetest.remove_node, pos)
	end,
	is_ground_content = false,
	groups = {crumbly = 2, falling_node = 1},
	sounds = default.node_sound_dirt_defaults(),
})


minetest.register_craft({
	type = "fuel",
	recipe = "techage:charcoal",
	burntime = 120,
})

minetest.register_lbm({
	label = "[techage] Lighter update",
	name = "techage:lighter_update",
	nodenames = {"techage:lighter_burn"},
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		if meta:get_int("running") == 1 then
			start_smoke(pos)
		end
	end
})
