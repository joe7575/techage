--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	TA4 Laser beam emitter and receiver 
	
]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local S = techage.S

local STORAGE_CAPA = 1000

local Axle = techage.Axle
local power = networks.power

minetest.register_node("techage:ta2_winch", {
	description = S("TA2 Winch"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_laser_hole.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_hole_electric.png",
	},

	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		local outdir = networks.side_to_outdir(pos, "R")
		M(pos):set_int("outdir", outdir)
		Axle:after_place_node(pos, {outdir})
		local pos1, pos2 = techage.renew_rope(pos, 10)
		local pos3 = {x = pos1.x, y = (pos1.y + pos2.y) / 2, z = pos1.z}  -- mid-pos
		minetest.add_entity(pos3, "techage:ta2_weight_chest")
		minetest.get_node_timer(pos):start(2)
		power.start_storage_calc(pos, Axle, outdir)
	end,

	on_timer = function(pos, elapsed)
		local nvm = techage.get_nvm(pos)
		local mem = techage.get_mem(pos)
		local outdir = M(pos):get_int("outdir")
		
		--power.start_storage_calc(pos, Axle, outdir)
		
		nvm.load = power.get_storage_load(pos, Axle, outdir, STORAGE_CAPA)
		if nvm.load then
			print("on_timer" , nvm.load)
			local len = 11 - (nvm.load / STORAGE_CAPA * 10)
			local y = pos.y - len
			techage.renew_rope(pos, len)
			if mem.obj then
				mem.obj:remove()
			end
			mem.obj = minetest.add_entity({x = pos.x, y = y, z = pos.z}, "techage:ta2_weight_chest")
		end
		--print("on_timer", nvm.load)
		return true
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata)
		local outdir = tonumber(oldmetadata.fields.outdir or 0)
		power.start_storage_calc(pos, Axle, outdir)
		Axle:after_dig_node(pos, {outdir})
		techage.del_mem(pos)
	end,
	
	get_storage_data = function(pos, tlib2)
		local nvm = techage.get_nvm(pos)
		return {level = (nvm.load or 0) / STORAGE_CAPA, capa = STORAGE_CAPA}
	end,
	
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_entity("techage:ta2_weight_chest", {
	initial_properties = {
		physical = true,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "wielditem",
		textures = {"techage:chest_ta2"},
		visual_size = {x=0.66, y=0.66, z=0.66},
		static_save = false,
	},
	driver_allowed = true,
})

power.register_nodes({"techage:ta2_winch"}, Axle, "sto", {"R"})

--minetest.register_craft({
--	output = "techage:ta4_laser_emitter",
--	recipe = {
--		{"techage:ta4_carbon_fiber", "dye:blue", "techage:ta4_carbon_fiber"},
--		{"techage:electric_cableS", "basic_materials:energy_crystal_simple", "techage:ta4_leds"},
--		{"default:steel_ingot", "techage:ta4_wlanchip", "default:steel_ingot"},
--	},
--})

