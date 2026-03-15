--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Pipe Inlet

]]--

-- for lazy programmers
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local M = minetest.get_meta
local M = minetest.get_meta
local S = techage.S

local Pipe = techage.LiquidPipe

local function after_place_node(pos, placer, itemstack)
	Pipe:after_place_node(pos)
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	Pipe:after_dig_node(pos)
end

minetest.register_node("techage:ta4_pipe_inlet", {
	description = S("TA4 Pipe Inlet"),
	tiles = {
		-- up, down, right, left, back, front
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png",
		"basic_materials_concrete_block.png^techage_tes_inlet.png",
		"basic_materials_concrete_block.png^techage_tes_inlet.png",
	},

	after_place_node = after_place_node,
	after_dig_node = after_dig_node,

	networks = {
		pipe2 = {},
	},
	paramtype2 = "facedir", -- important!
	on_rotate = screwdriver.disallow, -- important!
	groups = {crumbly = 2, cracky = 2, snappy = 2},
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
})

Pipe:add_secondary_node_names({"techage:ta4_pipe_inlet"})
Pipe:set_valid_sides("techage:ta4_pipe_inlet", {"F", "B"})

local Numbers = {
	shell = {
		[2] = 96,  -- 5x5x2 + 3x5x2 + 3x3x2 - 2
		[3] = 216, -- 7x7x2 + 5x7x2 + 5x5x2 - 2
		[4] = 384, -- 9x9x2 + 7x9x2 + 7x7x2 - 2
		[5] = 600, -- 11x11x2 + 9x11x2 + 9x9x2 - 2
		[6] = 864, -- 13x13x2 + 11x13x2 + 11x11x2 - 2
	},
	filling = {
		[2] = 27,  -- 3x3x3
		[3] = 125, -- 5x5x5
		[4] = 343, -- 7x7x7
		[5] = 729, -- 9x9x9
		[6] = 1331, -- 11x11x11
	}
}

local function get_diameter(pos, in_dir)
	local dir = tubelib2.Dir6dToVector[in_dir]
	local pos2, node

	pos2 = vector.add(pos, vector.multiply(dir, 4))
	node = minetest.get_node(pos2)
	if node.name == "techage:ta3_pipe_wall_entry" then
		return
	end
	if node.name == "techage:ta4_pipe_inlet" then
		return 5
	end

	pos2 = vector.add(pos, vector.multiply(dir, 6))
	node = minetest.get_node(pos2)
	if node.name == "techage:ta3_pipe_wall_entry" then
		return
	end
	if node.name == "techage:ta4_pipe_inlet" then
		return 7
	end

	pos2 = vector.add(pos, vector.multiply(dir, 8))
	node = minetest.get_node(pos2)
	if node.name == "techage:ta3_pipe_wall_entry" then
		return
	end
	if node.name == "techage:ta4_pipe_inlet" then
		return 9
	end

	pos2 = vector.add(pos, vector.multiply(dir, 10))
	node = minetest.get_node(pos2)
	if node.name == "techage:ta3_pipe_wall_entry" then
		return
	end
	if node.name == "techage:ta4_pipe_inlet" then
		return 11
	end

	pos2 = vector.add(pos, vector.multiply(dir, 12))
	node = minetest.get_node(pos2)
	if node.name == "techage:ta3_pipe_wall_entry" then
		return
	end
	if node.name == "techage:ta4_pipe_inlet" then
		return 13
	end

	pos2 = vector.add(pos, vector.multiply(dir, 14))
	local poses = minetest.find_nodes_in_area(pos, pos2, {"techage:ta4_pipe_inlet"})
	if #poses > 1 then
		return vector.distance(pos, poses[2]) + 1
	end
end

local function check_volume(pos, in_dir, owner)
	local diameter = get_diameter(pos, in_dir)
	if diameter then
		local radius = (diameter - 1) / 2
		local dir = tubelib2.Dir6dToVector[in_dir]
		local cpos = vector.add(pos, vector.multiply(dir, radius))
		-- calculate size
		local pos1 = {x = cpos.x - radius, y = cpos.y - radius, z = cpos.z - radius}
		local pos2 = {x = cpos.x + radius, y = cpos.y + radius, z = cpos.z + radius}
		local _, node_tbl = minetest.find_nodes_in_area(pos1, pos2,
				{"default:gravel", "techage:ta4_pipe_inlet",
				"basic_materials:concrete_block", "default:obsidian_glass",
				"techage:glow_gravel"})
		local shell_found = node_tbl["default:obsidian_glass"] + node_tbl["basic_materials:concrete_block"]
		local fill_found  = node_tbl["default:gravel"] + node_tbl["techage:glow_gravel"]
		if node_tbl["default:obsidian_glass"] > 1 then
			return S("one window maximum")
		end
		local errors = {}
		if shell_found ~= Numbers.shell[radius] then
			local diff = Numbers.shell[radius] - shell_found
			local hint = diff > 0
				and string.format(" (%d missing)", diff)
				or  string.format(" (%d too many)", -diff)
			if owner and owner ~= "" then
				minetest.chat_send_player(owner,
					string.format("[Thermal Storage] wrong number of shell nodes%s:\n"..
						"  need %d, found %d (concrete_block=%d, obsidian_glass=%d)\n"..
						"  cube size %dx%dx%d at %s",
						hint,
						Numbers.shell[radius], shell_found,
						node_tbl["basic_materials:concrete_block"],
						node_tbl["default:obsidian_glass"],
						diameter, diameter, diameter,
						P2S(pos)))
				-- if too many concrete: find misplaced blocks inside the inner region
				if diff < 0 then
					local r = radius - 1
					local inner1 = {x = cpos.x - r, y = cpos.y - r, z = cpos.z - r}
					local inner2 = {x = cpos.x + r, y = cpos.y + r, z = cpos.z + r}
					local bad = minetest.find_nodes_in_area(inner1, inner2,
						{"basic_materials:concrete_block"})
					if #bad > 0 then
						local pstrs = {}
						for _, p in ipairs(bad) do pstrs[#pstrs+1] = P2S(p) end
						minetest.chat_send_player(owner,
							"[Thermal Storage] misplaced concrete block(s) inside:\n  " ..
							table.concat(pstrs, "\n  "))
					end
				end
			end
			errors[#errors+1] = S("wrong number of shell nodes") .. hint ..
				(owner and owner ~= "" and " (see chat)" or "")
		end
		if fill_found ~= Numbers.filling[radius] then
			local diff = Numbers.filling[radius] - fill_found
			local hint = diff > 0
				and string.format(" (%d missing)", diff)
				or  string.format(" (%d too many)", -diff)
			if owner and owner ~= "" then
				minetest.chat_send_player(owner,
					string.format("[Thermal Storage] wrong number of gravel nodes%s:\n"..
						"  need %d, found %d (gravel=%d, glow_gravel=%d)\n"..
						"  cube size %dx%dx%d at %s",
						hint,
						Numbers.filling[radius], fill_found,
						node_tbl["default:gravel"],
						node_tbl["techage:glow_gravel"],
						diameter-2, diameter-2, diameter-2,
						P2S(pos)))
			end
			errors[#errors+1] = S("wrong number of gravel nodes") .. hint ..
				(owner and owner ~= "" and " (see chat)" or "")
		end
		if #errors > 0 then
			return table.concat(errors, ", ")
		end
	else
		return S("wrong diameter (should be 5, 7, or 9)")
	end
	return true
end

-- provide position behind the obsidian_glass
local function check_window(pos, in_dir)
	local diameter = get_diameter(pos, in_dir)
	if diameter then
		local radius = (diameter - 1) / 2
		local dir = tubelib2.Dir6dToVector[in_dir]
		local cpos = vector.add(pos, vector.multiply(dir, radius))
		-- calculate size
		local pos1 = {x = cpos.x - radius, y = cpos.y - radius, z = cpos.z - radius}
		local pos2 = {x = cpos.x + radius, y = cpos.y + radius, z = cpos.z + radius}
		local poses,_ = minetest.find_nodes_in_area(pos1, pos2, {"default:obsidian_glass"})
		if #poses == 1 then
			local ndir = vector.direction(poses[1], cpos)
			ndir = vector.normalize(ndir)
			local npos = vector.add(poses[1], ndir)
			return npos
		end
	end
end

-- for logical communication
techage.register_node({"techage:ta4_pipe_inlet"}, {
	on_transfer = function(pos, in_dir, topic, payload)
		if topic == "diameter" then
			return get_diameter(pos, in_dir)
		elseif topic == "volume" then
			return check_volume(pos, in_dir, payload)
		elseif topic == "window" then
			return check_window(pos, in_dir)
		end
		return false
	end
})

minetest.register_craft({
	type = 'shapeless',
	output = "techage:ta4_pipe_inlet",
	recipe = {"basic_materials:concrete_block", "techage:ta4_pipeS"},
})
