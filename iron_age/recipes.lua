--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Meltingpot recipes
	Bucket redefinitions

]]--

local S = techage.S

--
-- New burner recipes
--
techage.ironage_register_recipe({
	output = "default:obsidian",
	recipe = {"default:cobble"},
	heat = 10,
	time = 8,
})

techage.ironage_register_recipe({
	output = "techage:iron_ingot",
	recipe = {"default:iron_lump"},
	heat = 5,
	time = 3,
})

minetest.register_craftitem("techage:iron_ingot", {
	description = S("TA1 Iron Ingot"),
	inventory_image = "techage_iron_ingot.png",
	use_texture_alpha = techage.CLIP,
})

local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

-- derived from bucket/init.lua
local function register_liquid(source, flowing, itemname, inventory_image, name,
		groups, force_renew)
	bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = itemname,
		force_renew = force_renew,
	}
	bucket.liquids[flowing] = bucket.liquids[source]

	if itemname ~= nil then
		minetest.unregister_item(itemname)

		minetest.register_craftitem(":"..itemname, {
			description = name,
			inventory_image = inventory_image,
			stack_max = 1,
			liquids_pointable = true,
			groups = groups,

			on_place = function(itemstack, user, pointed_thing)
				-- Must be pointing to node
				if pointed_thing.type ~= "node" then
					return
				end

				local node = minetest.get_node_or_nil(pointed_thing.under)
				local ndef = node and minetest.registered_nodes[node.name]

				-- Call on_rightclick if the pointed node defines it
				if ndef and ndef.on_rightclick and
						not (user and user:is_player() and
						user:get_player_control().sneak) then
					return ndef.on_rightclick(
						pointed_thing.under,
						node, user,
						itemstack)
				end

				local lpos

				-- Check if pointing to a buildable node
				if ndef and ndef.buildable_to then
					-- buildable; replace the node
					lpos = pointed_thing.under
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced

					lpos = pointed_thing.above
					node = minetest.get_node_or_nil(lpos)
					local above_ndef = node and minetest.registered_nodes[node.name]

					if not above_ndef or not above_ndef.buildable_to then
						-- do not remove the bucket with the liquid
						return itemstack
					end
				end

				if check_protection(lpos, user
						and user:get_player_name()
						or "", "place "..source) then
					return
				end

				-------------------------------- Start Modification
--				minetest.set_node(lpos, {name = source})
				if source == "default:lava_source" and lpos.y > 0 and not minetest.is_singleplayer() then
				   minetest.chat_send_player(user:get_player_name(), S("[Bucket] Lava can only be placed below sea level!"))
				   return
				else
					-- see "basis/lib.lua" techage.is_ocean(pos)
				    minetest.set_node(lpos, {name = source, param2 = 1})
				end
				-------------------------------- End Modification
				return ItemStack("bucket:bucket_empty")
			end
		})
	end
end


--
-- Changed default recipes
--
if techage.modified_recipes_enabled then
	minetest.clear_craft({output = "default:bronze_ingot"})
	minetest.clear_craft({output = "default:steel_ingot"})
	minetest.clear_craft({output = "fire:flint_and_steel"})
	minetest.clear_craft({output = "bucket:bucket_empty"})
	if minetest.global_exists("moreores") then
		minetest.clear_craft({output = "moreores:silver_ingot"})
	end

	-- add again
	minetest.register_craft({
		output = 'default:steel_ingot 9',
		recipe = {
			{'default:steelblock'},
		}
	})
	minetest.register_craft({
		output = 'default:bronze_ingot 9',
		recipe = {
			{'default:bronzeblock'},
		}
	})

	techage.ironage_register_recipe({
		output = "default:bronze_ingot 4",
		recipe = {"default:copper_ingot", "default:copper_ingot", "default:copper_ingot", "default:tin_ingot"},
		heat = 4,
		time = 8,
	})

	techage.ironage_register_recipe({
		output = "default:steel_ingot 4",
		recipe = {"default:coal_lump", "default:iron_lump", "default:iron_lump", "default:iron_lump"},
		heat = 7,
		time = 8,
	})

	techage.ironage_register_recipe({
		output = "default:tin_ingot 1",
		recipe = {"default:tin_lump"},
		heat = 4,
		time = 2,
	})

	if minetest.global_exists("moreores") then
		techage.ironage_register_recipe({
			output = "moreores:silver_ingot 1",
			recipe = {"moreores:silver_lump"},
			heat = 5,
			time = 2,
		})

	end

	minetest.register_craft({
	   output = "fire:flint_and_steel",
	   recipe = {
		  {"default:flint", "default:iron_lump"}
	   }
	})

	minetest.register_craft({
		output = 'bucket:bucket_empty 2',
		recipe = {
			{'techage:iron_ingot', '', 'techage:iron_ingot'},
			{'', 'techage:iron_ingot', ''},
		}
	})

	minetest.override_item("fire:flint_and_steel", {
			description = S("Flint and Iron"),
			inventory_image = "fire_flint_steel.png^[colorize:#c7643d:60",
	})

	minetest.override_item("bucket:bucket_empty", {
			inventory_image = "bucket.png^[colorize:#c7643d:40"
	})
	minetest.override_item("bucket:bucket_river_water", {
			inventory_image = "bucket_river_water.png^[colorize:#c7643d:30"
	})

	register_liquid(
		"default:water_source",
		"default:water_flowing",
		"bucket:bucket_water",
		"bucket_water.png^[colorize:#c7643d:30",
		"Water Bucket",
		{water_bucket = 1}
	)

	register_liquid(
		"default:lava_source",
		"default:lava_flowing",
		"bucket:bucket_lava",
		"bucket_lava.png^[colorize:#c7643d:30",
		"Lava Bucket"
	)
end
