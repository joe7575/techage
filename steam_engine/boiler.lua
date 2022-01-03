--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA2 Steam Engine Boiler

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 4
local WATER_CONSUMPTION = 0.5

local Pipe = techage.SteamPipe
local boiler = techage.boiler

local function steaming(pos, nvm, temp)
	if temp >= 80 then
		local wc = WATER_CONSUMPTION * (nvm.power_ratio or 1)
		nvm.water_level = math.max((nvm.water_level or 0) - wc, 0)
	end
end

local function node_timer(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local temp = boiler.water_temperature(pos, nvm)
	steaming(pos, nvm, temp)
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", boiler.formspec(pos, nvm))
	end
	return temp > 20
end

local function after_place_node(pos)
	local node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
	if node.name == "techage:boiler1" then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", boiler.formspec(pos, nvm))
		Pipe:after_place_node(pos)
	end
end

local function after_dig_node(pos, oldnode)
	Pipe:after_dig_node(pos)
	techage.del_mem(pos)
end

-- boiler2: Main part, needed as generator
minetest.register_node("techage:boiler2", {
	description = S("TA2 Boiler Top"),
	tiles = {"techage_boiler2.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_09.obj",
	selection_box = {
		type = "fixed",
		fixed = {-10/32, -48/32, -10/32, 10/32, 16/32, 10/32},
	},

	can_dig = boiler.can_dig,
	on_timer = node_timer,
	on_rightclick = boiler.on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_punch = boiler.on_punch,

	paramtype = "light",
	groups = {cracky=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:boiler2"})

techage.register_node({"techage:boiler2"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "trigger" then
			local nvm = techage.get_nvm(pos)
			nvm.fire_trigger = true
			if not minetest.get_node_timer(pos):is_started() then
				minetest.get_node_timer(pos):start(CYCLE_TIME)
			end
			if (nvm.temperature or 20) > 80 then
				nvm.power_ratio = techage.transfer(pos, 6, "trigger", nil, Pipe, {
						"techage:cylinder", "techage:cylinder_on"}) or 0
				return nvm.power_ratio
			else
				return 0
			end
		end
	end,
})

minetest.register_node("techage:boiler1", {
	description = S("TA2 Boiler Base"),
	tiles = {"techage_boiler.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_09.obj",
	selection_box = {
		type = "fixed",
		fixed = {-8/32, -16/32, -8/32, 8/32, 16/32, 8/32},
	},

	paramtype = "light",
	groups = {cracky=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})



minetest.register_craft({
	output = "techage:boiler1",
	recipe = {
		{"techage:iron_ingot", "", "techage:iron_ingot"},
		{"default:bronze_ingot", "", "default:bronze_ingot"},
		{"techage:iron_ingot", "default:bronze_ingot", "techage:iron_ingot"},
	},
})

minetest.register_craft({
	output = "techage:boiler2",
	recipe = {
		{"techage:iron_ingot", "techage:steam_pipeS", "techage:iron_ingot"},
		{"default:bronze_ingot", "", "default:bronze_ingot"},
		{"techage:iron_ingot", "", "techage:iron_ingot"},
	},
})
