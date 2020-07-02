--[[

	TechAge
	=======

	Copyright (C) 2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 LED Grow Light

]]--

local S = techage.S

local CYCLE_TIME = 2
local RANDOM_VAL = 20
local Cable = techage.ElectricCable
local power = techage.power
local Flowers = {}
local Plants = {}
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

local function node_timer(pos, elapsed)
	power.consumer_alive(pos, Cable, CYCLE_TIME)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.grow_pos = mem.grow_pos or {} -- keep the pos blank for same time
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
	on_timer = node_timer,
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
	for name,_ in pairs(minetest.registered_decorations) do
		if type(name) == "string" then
			local mod = string.split(name, ":")[1]
			if mod == "flowers" then
				techage.register_flower(name)
			end
		end
	end
	for name,ndef in pairs(minetest.registered_nodes) do
		if type(name) == "string" then
			local mod = string.split(name, ":")[1]
			if mod == "farming" then
				if ndef.on_timer then -- probably a plant that still needs to grow
					techage.register_plant(name)
				end
			end
		end
	end
end)
