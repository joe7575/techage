--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Coal Power Station Boiler Top

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local CYCLE_TIME = 4
local WATER_CONSUMPTION = 0.1

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
	if node.name == "techage:coalboiler_base" then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", boiler.formspec(pos, nvm))
		Pipe:after_place_node(pos)
	end
end

local function after_dig_node(pos, oldnode)
	Pipe:after_dig_node(pos)
	techage.del_mem(pos)
end

minetest.register_node("techage:coalboiler_top", {
	description = S("TA3 Boiler Top"),
	tiles = {"techage_coal_boiler_mesh_top.png"},
	drawtype = "mesh",
	mesh = "techage_cylinder_12.obj",
	selection_box = {
		type = "fixed",
		fixed = {-13/32, -48/32, -13/32, 13/32, 16/32, 13/32},
	},

	can_dig = boiler.can_dig,
	on_timer = node_timer,
	on_rightclick = boiler.on_rightclick,
	after_place_node = after_place_node,
	after_dig_node = after_dig_node,
	on_punch = boiler.on_punch,

	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=1},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:coalboiler_top"})


techage.register_node({"techage:coalboiler_top"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "trigger" then
			local nvm = techage.get_nvm(pos)
			nvm.fire_trigger = true
			if not minetest.get_node_timer(pos):is_started() then
				minetest.get_node_timer(pos):start(CYCLE_TIME)
			end
			if (nvm.temperature or 20) > 80 then
				nvm.power_ratio = techage.transfer(pos, "F", "trigger", nil, Pipe, {
						"techage:turbine", "techage:turbine_on"}) or 0
				return nvm.power_ratio
			else
				return 0
			end
		end
	end,
})

minetest.register_craft({
	output = "techage:coalboiler_top",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"techage:iron_ingot", "", "techage:iron_ingot"},
		{"default:stone", "", "default:stone"},
	},
})
