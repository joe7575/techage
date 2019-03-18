--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Gravel Sieve, sieving gravel to find ores
	
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end

-- Load support for intllib.
local MP = minetest.get_modpath("techage")
local I,_ = dofile(MP.."/intllib.lua")

-- Increase the probability over the natural occurrence
local PROBABILITY_FACTOR = 3

-- Ore probability table  (1/n)
techage.ore_probability = {
}

-- collect all registered ores and calculate the probability
local function add_ores()
	for _,item in  pairs(minetest.registered_ores) do
		if minetest.registered_nodes[item.ore] then
			local drop = minetest.registered_nodes[item.ore].drop
			if type(drop) == "string"
			and drop ~= item.ore
			and drop ~= ""
			and item.ore_type == "scatter"
			and item.wherein == "default:stone"
			and item.clust_scarcity ~= nil and item.clust_scarcity > 0 
			and item.clust_num_ores ~= nil and item.clust_num_ores > 0 
			and item.y_max ~= nil and item.y_min ~= nil then
				local probability = (techage.ore_rarity / PROBABILITY_FACTOR) * item.clust_scarcity /
						(item.clust_num_ores * ((item.y_max - item.y_min) / 65535))
				if techage.ore_probability[drop] == nil then
					techage.ore_probability[drop] = probability
				else
					-- harmonic sum
					techage.ore_probability[drop] = 1.0 / ((1.0 / techage.ore_probability[drop]) +
							(1.0 / probability))
				end
			end
		end
	end
	local overall_probability = 0.0
	for name,probability in pairs(techage.ore_probability) do
		minetest.log("info", string.format("[techage] %-32s %u", name, probability))
		overall_probability = overall_probability + 1.0/probability
	end
	minetest.log("info", string.format("[techage] Overall probability %g", overall_probability))
end	

minetest.after(1, add_ores)

local sieve_formspec =
	"size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;1,1.5;1,1;]"..
	"image[3,1.5;1,1;techage_form_arrow.png]"..
	"list[context;dst;4,0;4,4;]"..
	"list[current_player;main;0,4.2;8,4;]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"


local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

-- handle the sieve animation
local function swap_node(pos, meta, start)
	local node = minetest.get_node(pos)
	local idx = meta:get_int("idx")
	if start then
		if idx == 3 then
			idx = 0
		end
	else
		idx = (idx + 1) % 4
	end
	meta:set_int("idx", idx)
	node.name = meta:get_string("node_name")..idx
	minetest.swap_node(pos, node)
	return idx == 3
end

-- place ores to dst according to the calculated probability
local function random_ore(inv, src)
	local num
	for ore, probability in pairs(techage.ore_probability) do
		if math.random(probability) == 1 then
			local item = ItemStack(ore)
			if inv:room_for_item("dst", item) then
				inv:add_item("dst", item)
				return true     -- ore placed
			end
		end
	end
	return false    -- gravel has to be moved
end


local function add_gravel_to_dst(meta, inv)
	-- maintain a counter for gravel kind selection
	local gravel_cnt = meta:get_int("gravel_cnt") + 1
	meta:set_int("gravel_cnt", gravel_cnt)

	if (gravel_cnt % 2) == 0 then  -- gravel or sieved gravel?
		inv:add_item("dst", ItemStack("default:gravel"))  -- add to dest
	else
		inv:add_item("dst", ItemStack("techage:sieved_gravel")) -- add to dest
	end
end


-- move gravel and ores to dst
local function move_src2dst(meta, pos, inv, src, dst)
	if inv:room_for_item("dst", dst) and inv:contains_item("src", src) then
		local res = swap_node(pos, meta, false)
		if res then                                     -- time to move one item?
			if src:get_name() == "default:gravel" then  -- will we find ore?
				if not random_ore(inv, src) then        -- no ore found?
					add_gravel_to_dst(meta, inv)
				end
			else
				inv:add_item("dst", ItemStack("techage:sieved_gravel")) -- add to dest
			end
			inv:remove_item("src", src)
		end
		return true  -- process finished
	end
	return false -- process still running
end

-- timer callback, alternatively called by on_punch
local function sieve_node_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local gravel = ItemStack("default:gravel")
	local gravel_sieved = ItemStack("techage:sieved_gravel")

	if move_src2dst(meta, pos, inv, gravel) then
		return true
	elseif move_src2dst(meta, pos, inv, gravel_sieved) then
		return true
	else
		minetest.get_node_timer(pos):stop()
		return false
	end
end


for idx = 0,4 do
	local nodebox_data = {
		{ -8/16, -8/16, -8/16,   8/16, 4/16, -6/16 },
		{ -8/16, -8/16,  6/16,   8/16, 4/16,  8/16 },
		{ -8/16, -8/16, -8/16,  -6/16, 4/16,  8/16 },
		{  6/16, -8/16, -8/16,   8/16, 4/16,  8/16 },
		{ -6/16, -2/16, -6/16,  6/16, 8/16, 6/16 },
	}
	nodebox_data[5][5] = (8 - 2*idx) / 16

	local node_name
	local description
	local tiles_data
	local tube_info
	local not_in_creative_inventory
	node_name = "techage:sieve"
	description = "Gravel Sieve"
	tiles_data = {
		-- up, down, right, left, back, front
		"techage_handsieve_gravel.png",
		"techage_handsieve_gravel.png",
		"techage_handsieve_sieve.png",
		"techage_handsieve_sieve.png",
		"techage_handsieve_sieve.png",
		"techage_handsieve_sieve.png",
	}

	if idx == 3 then
		tiles_data[1] = "techage_handsieve_top.png"
		not_in_creative_inventory = 0
	else
		not_in_creative_inventory = 1
	end


	minetest.register_node(node_name..idx, {
		description = description,
		tiles = tiles_data,
		drawtype = "nodebox",
        drop = node_name,
		
		tube = tube_info,     --  NEW
		
		node_box = {
			type = "fixed",
			fixed = nodebox_data,
		},
		selection_box = {
			type = "fixed",
			fixed = { -8/16, -8/16, -8/16,   8/16, 4/16, 8/16 },
		},

		on_timer = sieve_node_timer,

		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("idx", idx)        -- for the 4 sieve phases
			meta:set_int("gravel_cnt", 0)   -- counter to switch between gravel and sieved gravel
			meta:set_string("node_name", node_name)
			meta:set_string("formspec", sieve_formspec)
			local inv = meta:get_inventory()
			inv:set_size('src', 1)
			inv:set_size('dst', 16)
		end,
		
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", I("TA1 Gravel Sieve"))
		end,
			
		on_metadata_inventory_move = function(pos)
			local meta = minetest.get_meta(pos)
			swap_node(pos, meta, true)
		end,

		on_metadata_inventory_take = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:is_empty("src") then
				-- sieve should be empty
				meta:set_int("idx", 2)
				swap_node(pos, meta, false)
				meta:set_int("gravel_cnt", 0)
			end
		end,

		on_metadata_inventory_put = function(pos)
			local meta = minetest.get_meta(pos)
			swap_node(pos, meta, true)
		end,

		on_punch = function(pos, node, puncher, pointed_thing)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:is_empty("dst") and inv:is_empty("src") then
				minetest.node_punch(pos, node, puncher, pointed_thing)
			else
				sieve_node_timer(pos, 0)
			end
		end,

		on_dig = function(pos, node, puncher, pointed_thing)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:is_empty("dst") and inv:is_empty("src") then
				minetest.node_dig(pos, node, puncher, pointed_thing)
			end
		end,

		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,

		paramtype = "light",
		sounds = default.node_sound_wood_defaults(),
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy=2, cracky=1, not_in_creative_inventory=not_in_creative_inventory},
		drop = node_name.."3",
	})
end

minetest.register_node("techage:sieved_gravel", {
	description = I("Sieved Gravel"),
	tiles = {"default_gravel.png"},
	groups = {crumbly=2, falling_node=1, not_in_creative_inventory=1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_node("techage:compressed_gravel", {
	description = I("Compressed Gravel"),
	tiles = {"techage_compressed_gravel.png"},
	groups = {cracky=2, crumbly = 2, cracky = 2},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_craft({
	output = "techage:sieve",
	recipe = {
		{"group:wood", "",                      "group:wood"},
		{"group:wood", "default:steel_ingot",   "group:wood"},
		{"group:wood", "",                      "group:wood"},
	},
})

minetest.register_craft({
	output = "techage:auto_sieve",
	type = "shapeless",
	recipe = {
		"techage:sieve", "default:mese_crystal",  "default:mese_crystal",
	},
})

minetest.register_craft({
	output = "techage:compressed_gravel",
	recipe = {
		{"techage:sieved_gravel", "techage:sieved_gravel"},
		{"techage:sieved_gravel", "techage:sieved_gravel"},
	},
})

minetest.register_craft({
	type = "cooking",
	output = "default:cobble",
	recipe = "techage:compressed_gravel",
	cooktime = 10,
})

minetest.register_alias("techage:sieve", "techage:sieve3")
minetest.register_alias("techage:auto_sieve", "techage:auto_sieve3")

-- adaption to Circular Saw
--if minetest.get_modpath("moreblocks") then
	
--	stairsplus:register_all("techage", "compressed_gravel", "techage:compressed_gravel", {
--		description= I("Compressed Gravel"),
--		groups={cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
--		tiles = {"techage_compressed_gravel.png"},
--		sounds = default.node_sound_stone_defaults(),
--	})
--end


