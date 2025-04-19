--[[

	TechAge
	=======

	Copyright (C) 2017-2025 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Observer

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local CYCLE_TIME = 2 -- seconds
local RADIUS = 8 -- radius for player detection

local function scan_for_player(pos)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, RADIUS)) do
		if object:is_player() then
			return true
		end
	end
	return false
end

local function animation(pos, in_dir, stack)
    local offs = vector.divide(tubelib2.Dir6dToVector[tubelib2.Turn180Deg[in_dir or 0]], 1.8)
	local obj = minetest.add_entity(vector.add(pos, offs), "techage:observer_item")
	if obj then
	    obj:set_properties({wield_item=stack:get_name()})
        local dir = tubelib2.Dir6dToVector[in_dir or 0]
        local acc = vector.multiply(dir, 4)
        obj:set_acceleration(acc)
    end
end

local function valid_surroundings(pos, in_dir)
    local node1 = minetest.get_node(tubelib2.get_pos(pos, in_dir))
    local node2 = minetest.get_node(tubelib2.get_pos(pos, tubelib2.Turn180Deg[in_dir or 0]))
    return node1.name ~= "techage:ta3_observer" and node2.name ~= "techage:ta3_observer" 
end

minetest.register_entity("techage:observer_item", {
	initial_properties = {
		pointable = false,
		makes_footstep_sound = false,
		static_save = false,
		collide_with_objects = false,
		physical = false,
        automatic_rotate = 5,
		visual = "wielditem",
		wield_item = "default:dirt",
		visual_size = {x=0.25, y=0.25, z=0.25},
	},

	on_step = function(self, dtime, moveresult)
		self.ttl = self.ttl or 1.0
        self.ttl = self.ttl - dtime
        if self.ttl <= 0 then
            self.object:remove()
        end
	end,
})

minetest.register_node("techage:ta3_observer", {
	description = S("TA3 Observation Window"),
    inventory_image = 'techage_observer_inv.png',
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 7/16, -8/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16,  7/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16,  7/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16, -7/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16, -7/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16,  8/16, -7/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16,  8/16,  8/16},
		},
    },
	tiles = {
		"techage_basalt_glass2.png^default_obsidian_glass.png",
	},

	after_place_node = function(pos, placer)
        minetest.get_node_timer(pos):start(CYCLE_TIME)
        M(pos):set_string("infotext", "TA3 Observation Window")
    end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
        techage.remove_node(pos, oldnode, oldmetadata)
        techage.del_mem(pos)
    end,
	on_timer = function (pos, elapsed)
        local nvm = techage.get_nvm(pos)
		nvm.active = scan_for_player(pos)
		return true
	end,

	on_rotate = screwdriver.disallow,
    use_texture_alpha = techage.BLEND,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = "techage:ta3_observer",
	recipe = {
		{"techage:basalt_glass_thin2", "default:steel_ingot", "techage:basalt_glass_thin2"},
		{"techage:tubeS", "", "techage:tubeS"},
		{"techage:basalt_glass_thin2", "default:steel_ingot", "techage:basalt_glass_thin2"},
	},
})

techage.register_node({"techage:ta3_observer"}, {
	on_push_item = function(pos, in_dir, stack)
        local leftover = techage.safe_push_items(pos, in_dir, stack)
        local nvm = techage.get_nvm(pos)
        if nvm.active and valid_surroundings(pos, in_dir) and leftover then
            if leftover == true or leftover:get_count() ~= stack:get_count() then
                animation(pos, in_dir, stack)
            end
        end
        return leftover
	end,
	is_pusher = true,  -- is a pulling/pushing node
})
