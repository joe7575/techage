--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 LED Grow Light

]]--

local S = techage.S

local CYCLE_TIME = 2
local RANDOM_VAL = 20
local PWR_NEEDED = 1

local Cable = techage.ElectricCable
local power = networks.power
local Flowers = {}
local Plants = {}
local Ignore = { ["flowers:waterlily_waving"] = true }
-- 9 plant positions below the light
local Positions = {
	{x = 0, y =-1, z = 0},
	{x =-1, y =-1, z = 0},
	{x = 0, y =-1, z =-1},
	{x = 1, y =-1, z = 0},
	{x = 0, y =-1, z = 1},
	{x =-1, y =-1, z =-1},
	{x = 1, y =-1, z = 1},
	{x =-1, y =-1, z = 1},
	{x = 1, y =-1, z =-1},
}

local function swap_node(pos, postfix)
	local node = techage.get_node_lvm(pos)
	local parts = string.split(node.name, "_")
	if postfix == parts[2] then
		return
	end
	node.name = parts[1].."_"..postfix
	minetest.swap_node(pos, node)
	techage.light_ring(pos, postfix == "on")
end

local function on_nopower(pos)
	swap_node(pos, "off")
	local nvm = techage.get_nvm(pos)
	nvm.turned_on = false
end

local function on_power(pos)
	swap_node(pos, "on")
	local nvm = techage.get_nvm(pos)
	nvm.turned_on = true
end

local function grow_flowers(pos)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.grow_pos = mem.grow_pos or {} -- keep the pos blank for some time
	nvm.tick = nvm.tick or math.random(RANDOM_VAL, RANDOM_VAL*2)
	nvm.tick = nvm.tick - 1
	if nvm.tick == 0 then
		nvm.tick = math.random(RANDOM_VAL, RANDOM_VAL*2)
		local plant_idx = math.random(1, 9)
		local plant_pos = vector.add(pos, Positions[plant_idx])
		local soil_pos = {x = plant_pos.x, y = plant_pos.y - 1, z = plant_pos.z}
		local plant_node = minetest.get_node(plant_pos)
		local soil_node = minetest.get_node(soil_pos)
		if soil_node and soil_node.name == "compost:garden_soil" then
			if plant_node and plant_node.name == "air" then
				if mem.grow_pos[plant_idx] then
					local idx = math.floor(math.random(1, #Flowers))
					if Flowers[idx] then
						minetest.set_node(plant_pos, {name = Flowers[idx]})
						mem.grow_pos[plant_idx] = false
					end
				else
					mem.grow_pos[plant_idx] = true
				end
			elseif plant_node and Plants[plant_node.name] then
				local ndef = minetest.registered_nodes[plant_node.name]
				ndef.on_timer(plant_pos, 200)
			else
				mem.grow_pos[plant_idx] = false
			end
		end
	end
end

local function node_timer_on(pos, elapsed)
	grow_flowers(pos)
	local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
	if consumed < PWR_NEEDED then
		on_nopower(pos)
	end
	return true
end

local function node_timer_off(pos, elapsed)
	local consumed = power.consume_power(pos, Cable, nil, PWR_NEEDED)
	if consumed == PWR_NEEDED then
		on_power(pos)
	end
	return true
end

local function on_switch_lamp(pos, on)
	techage.light_ring(pos, on)
end

techage.register_lamp("techage:growlight", {
	description = S("TA4 LED Grow Light"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_growlight_off.png',
		'techage_growlight_back.png',
		'techage_growlight_off.png',
		'techage_growlight_side.png',
		'techage_growlight_side.png',
		'techage_growlight_side.png',
		'techage_growlight_side.png',
		'techage_growlight_side.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  -8/16, -8/16, 8/16,  -13/32,  8/16},
		},
	},
	on_timer = node_timer_off,
	on_switch_lamp = on_switch_lamp,
	high_power = true,
},{
	description = S("TA4 LED Grow Light"),
	tiles = {
		-- up, down, right, left, back, front
		'techage_growlight_on.png',
		'techage_growlight_back.png',
		'techage_growlight_side.png',
		'techage_growlight_side.png',
		'techage_growlight_side.png',
		'techage_growlight_side.png',
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  -8/16, -8/16, 8/16,  -13/32,  8/16},
		},
	},
	on_timer = node_timer_on,
	on_switch_lamp = on_switch_lamp,
	high_power = true,
})

minetest.register_craft({
	output = "techage:growlight_off",
	recipe = {
		{"techage:ta4_leds", "techage:basalt_glass_thin", "techage:ta4_leds"},
		{"techage:ta4_leds", "techage:ta4_leds", "techage:ta4_leds"},
		{"techage:ta4_leds", "techage:aluminum", "techage:ta4_leds"},
	},
})

function techage.register_flower(name)
	Flowers[#Flowers+1] = name
end

function techage.register_plant(name)
	Plants[name] = true
end

minetest.after(1, function()
	for _,def in pairs(minetest.registered_decorations) do
		local name = def.decoration
		if name and type(name) == "string" then
			local mod = string.split(name, ":")[1]
			if mod == "flowers" or mod == "bakedclay" then -- Bakedclay also registers flowers as decoration.
				if not Ignore[name] then
					techage.register_flower(name)
				end
			end
		end
	end
	for name,ndef in pairs(minetest.registered_nodes) do
		if type(name) == "string" then
			local mod = string.split(name, ":")[1]
			if mod == "farming" and ndef.on_timer then -- probably a plant that still needs to grow
				if not Ignore[name] then
					techage.register_plant(name)
				end
			end
		end
	end
end)
