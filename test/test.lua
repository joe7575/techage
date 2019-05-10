-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

local function determine_water_dir(pos)
	local pos1 = {x=pos.x+1, y=pos.y+1, z=pos.z}
	local pos2 = {x=pos.x-1, y=pos.y+1, z=pos.z}
	local pos3 = {x=pos.x, y=pos.y+1, z=pos.z+1}
	local pos4 = {x=pos.x, y=pos.y+1, z=pos.z-1}
	local node1 =  minetest.get_node(pos1)
	local node2 =  minetest.get_node(pos2)
	local node3 =  minetest.get_node(pos3)
	local node4 =  minetest.get_node(pos4)
	if node1.name == "default:water_flowing" and node2.name == "default:water_flowing" then
		if node1.param2 > node2.param2 then
			return 4
		elseif node1.param2 < node2.param2 then
			return 2
		end
	elseif node3.name == "default:water_flowing" and node4.name == "default:water_flowing" then
		if node3.param2 > node4.param2 then
			return 3
		elseif node3.param2 < node4.param2 then
			return 1
		end
	end
	return 0
end

local function remove(obj)
	obj:remove()
end

local function velocity(obj, dir)
	obj:set_velocity(vector.multiply(tubelib2.Dir6dToVector[dir], 0.3))
	minetest.after(10, remove, obj)
end

local function node_timer(pos, elapsed)
	local node = minetest.get_node(techage.get_pos(pos, 'U'))
	local obj = minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, ItemStack("default:gold_lump"))
	minetest.after(0.8, velocity, obj, M(pos):get_int("water_dir"))
	return true
end

minetest.register_node("techage:rinser", {
	description = "TechAge Rinser",
	tiles = {
		-- up, down, right, left, back, front
		{
			image = "techage_appl_sieve4_top.png^techage_frame4_ta2_top.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		'techage_electric_button.png',
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,

	after_place_node = function(pos, placer)
		minetest.get_node_timer(pos):start(5)
		local dir = determine_water_dir(pos)
		M(pos):set_int("water_dir", dir)
	end,

	on_timer = node_timer,
})

local function remove_objects(pos)
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local lua_entity = object:get_luaentity()
		if not object:is_player() and lua_entity and lua_entity.name == "__builtin:item" then
			object:remove()
		end
	end
end

minetest.register_lbm({
	label = "[techage] Rinser update",
	name = "techage:update",
	nodenames = {"techage:rinser"},
	run_at_every_load = true,
	action = function(pos, node)
		remove_objects({x=pos.x, y=pos.y+1, z=pos.z})
	end
})

