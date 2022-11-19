--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Hammer to convert stone into gravel

]]--

local S = techage.S

local Stone2Gravel = {
	["default:stone"] = "default:gravel",
	["default:cobble"] = "default:gravel",
	["default:desert_stone"] = "default:gravel",
	["techage:basalt_stone"] = "techage:basalt_gravel",
	["techage:basalt_cobble"] = "techage:basalt_gravel",
	["techage:bauxite_stone"] = "techage:bauxite_gravel",
	["techage:bauxite_cobble"] = "techage:bauxite_gravel",
}

function techage.register_stone_gravel_pair(stone_name, gravel_name)
	Stone2Gravel[stone_name] = gravel_name
end

-- Pipeworks uses a fakeplayer based on the owner of the nodebraker.
local function is_real_player(player)
	return minetest.is_player(player) and not player.is_fake_player
end

local function handler(player_name, node, itemstack, digparams)
	local pos = techage.dug_node[player_name]
	if not pos then return end
	techage.dug_node[player_name] = nil

	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end

	if minetest.get_item_group(node.name, "stone") > 0 then
		-- Remove item from players inventory or from the world
		local ndef = minetest.registered_nodes[node.name]
		if ndef then
			local item = ItemStack(ndef.drop or node.name)
			local inv = minetest.get_inventory({type="player", name=player_name})
			if inv and inv:room_for_item("main", item) then
				-- item should have been added and can therefore be removed again
				local taken = inv:remove_item("main", item)
			else
				for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
					obj:remove()
					break
				end
			end
		end
		if Stone2Gravel[node.name] then
			node.name = Stone2Gravel[node.name]
		else
			node.name = "default:gravel"
		end
		minetest.swap_node(pos, node)
		minetest.check_single_for_falling(pos)
	end
end

minetest.register_tool("techage:hammer_stone", {
	description = S("TA1 Stone Hammer (smash stone to gravel)"),
	inventory_image = "techage_tool_hammer_stone.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=6.00, [2]=2.5, [3]=1.2}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		if is_real_player(user) then
			minetest.after(0.01, handler, user:get_player_name(), node)
		end
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_tool("techage:hammer_bronze", {
	description = S("TA1 Bronze Hammer (smash stone to gravel)"),
	inventory_image = "techage_tool_hammer_bronze.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=5.00, [2]=2.0, [3]=1.0}, uses=40, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		if is_real_player(user) then
			minetest.after(0.01, handler, user:get_player_name(), node)
		end
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_tool("techage:hammer_steel", {
	description = S("TA1 Steel Hammer (smash stone to gravel)"),
	inventory_image = "techage_tool_hammer_steel.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=50, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		if is_real_player(user) then
			minetest.after(0.01, handler, user:get_player_name(), node)
		end
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_tool("techage:hammer_mese", {
	description = S("TA1 Mese Hammer (smash stone to gravel)"),
	inventory_image = "techage_tool_hammer_mese.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.4, [2]=1.2, [3]=0.60}, uses=60, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		if is_real_player(user) then
			minetest.after(0.01, handler, user:get_player_name(), node)
		end
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

minetest.register_tool("techage:hammer_diamond", {
	description = S("TA1 Diamond Hammer (smash stone to gravel)"),
	inventory_image = "techage_tool_hammer_diamond.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=70, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	after_use = function(itemstack, user, node, digparams)
		if is_real_player(user) then
			minetest.after(0.01, handler, user:get_player_name(), node)
		end
		itemstack:add_wear(digparams.wear)
		return itemstack
	end,
})

if minetest.global_exists("wielded_light") then
	minetest.register_tool("techage:hammer_meridium", {
		description = S("TA1 Meridium Hammer (smash stone to gravel)"),
		inventory_image = "techage_tool_hammer_meridium.png",
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level=1,
			groupcaps={
				cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=60, maxlevel=2},
			},
			damage_groups = {fleshy=4},
		},
		sound = {breaks = "default_tool_breaks"},
		light_source = 12,
		after_use = function(itemstack, user, node, digparams)
			minetest.after(0.01, handler, user:get_player_name(), node)
			itemstack:add_wear(digparams.wear)
			return itemstack
		end,
	})
	minetest.register_craft({
		output = "techage:hammer_meridium 2",
		recipe = {
			{"techage:meridium_ingot", "group:stick", "techage:meridium_ingot"},
			{"techage:meridium_ingot", "group:stick", "techage:meridium_ingot"},
			{"", "group:stick", ""},
		}
	})
end

minetest.register_craft({
	output = "techage:hammer_stone 2",
	recipe = {
		{"default:cobble", "group:stick", "default:cobble"},
		{"default:cobble", "group:stick", "default:cobble"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "techage:hammer_bronze 2",
	recipe = {
		{"default:bronze_ingot", "group:stick", "default:bronze_ingot"},
		{"default:bronze_ingot", "group:stick", "default:bronze_ingot"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "techage:hammer_steel 2",
	recipe = {
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "techage:hammer_mese 2",
	recipe = {
		{"default:mese_crystal", "group:stick", "default:mese_crystal"},
		{"default:mese_crystal", "group:stick", "default:mese_crystal"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "techage:hammer_diamond 2",
	recipe = {
		{"default:diamond", "group:stick", "default:diamond"},
		{"default:diamond", "group:stick", "default:diamond"},
		{"", "group:stick", ""},
	}
})
