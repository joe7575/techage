--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Helper functions

]]--

-- for lazy programmers
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Input data to generate the Param2ToDir table
local Input = {
	8,9,10,11,    -- 1
	16,17,18,19,  -- 2
	4,5,6,7,      -- 3
	12,13,14,15,  -- 4
	0,1,2,3,      -- 5
	20,21,22,23,  -- 6
}

-- allowed for digging
local RegisteredNodesToBeDug = {}

function techage.register_node_to_be_dug(name)
	RegisteredNodesToBeDug[name] = true
end

-- translation from param2 to dir (out of the node upwards)
local Param2Dir = {}
for idx,val in ipairs(Input) do
	Param2Dir[val] = math.floor((idx - 1) / 4) + 1
end

-- used by lamps and power switches
function techage.determine_node_bottom_as_dir(node)
	return tubelib2.Turn180Deg[Param2Dir[node.param2] or 1]
end

function techage.determine_node_top_as_dir(node)
	return Param2Dir[node.param2] or 1
end

-- rotation rules (screwdriver) for wallmounted "facedir" nodes
function techage.rotate_wallmounted(param2)
	local offs = math.floor(param2 / 4) * 4
	local rot = ((param2 % 4) + 1) % 4
	return offs + rot
end

function techage.in_range(val, min, max)
	val = tonumber(val)
	if val < min then return min end
	if val > max then return max end
	return val
end

function techage.one_of(val, selection)
	for _,v in ipairs(selection) do
		if val == v then return val end
	end
	return selection[1]
end

function techage.index(list, x)
	for idx, v in pairs(list) do
		if v == x then return idx end
	end
	return nil
end

function techage.in_list(list, x)
	for idx, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function techage.add_to_set(set, x)
	if not techage.index(set, x) then
		table.insert(set, x)
	end
end

function techage.get_node_lvm(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node
	end
	local vm = minetest.get_voxel_manip()
	local MinEdge, MaxEdge = vm:read_from_map(pos, pos)
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local area = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local idx = area:index(pos.x, pos.y, pos.z)
	node = {
		name = minetest.get_name_from_content_id(data[idx]),
		param2 = param2_data[idx]
	}
	return node
end

--
-- Functions used to hide electric cable and biogas pipes
--
-- Overridden method of tubelib2!
function techage.get_primary_node_param2(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local param2 = M(npos):get_int("tl2_param2")
	if param2 ~= 0 then
		return param2, npos
	end
end

-- Overridden method of tubelib2!
function techage.is_primary_node(pos, dir)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	local param2 = M(npos):get_int("tl2_param2")
	return param2 ~= 0
end

-- returns true, if node can be dug, otherwise false
function techage.can_node_dig(node, ndef)
	if RegisteredNodesToBeDug[node.name] then 
		return true 
	end
	if not ndef then return false end
	if node.name == "ignore" then return false end
	if node.name == "air" then return true end
	if ndef.buildable_to == true then return true end
	if ndef.diggable == false then return false end
	if ndef.after_dig_node then return false end
	-- add it to the white list
	RegisteredNodesToBeDug[node.name] = true
	return true
end	

local function handle_drop(drop)
	-- To keep it simple, return only the item with the lowest rarity
	if drop.items then
		local rarity = 9999
		local name
		for idx,item in ipairs(drop.items) do
			if item.rarity and item.rarity < rarity then
				rarity = item.rarity
				name = item.items[1] -- take always the first item
			else
				return item.items[1] -- take always the first item
			end
		end
		return name
	end
	return false
end

-- returns the node name, if node can be dropped, otherwise nil
function techage.dropped_node(node, ndef)
	if node.name == "air" then return end
	--if ndef.buildable_to == true then return end
	if ndef.drop == "" then return end
	if type(ndef.drop) == "table" then
		return handle_drop(ndef.drop)
	end
	return ndef.drop or node.name
end	

-- needed for windmill plants
local function determine_ocean_ids()
	techage.OceanIdTbl = {}
	for name, _ in pairs(minetest.registered_biomes) do
		if string.find(name, "ocean") then
			local id = minetest.get_biome_id(name)
			--print(id, name)
			techage.OceanIdTbl[id] = true
		end
	end
end

determine_ocean_ids()

-- check if natural water is on given position (water placed by player has param2 = 1)
function techage.is_ocean(pos)
	if pos.y ~= 1 then return false end
	local node = techage.get_node_lvm(pos)
	if node.name ~= "default:water_source" then return false end
	if node.param2 == 1 then return false end
	return true
end

function techage.item_image(x, y, itemname)
	local name, size = unpack(string.split(itemname, " "))
	local label = ""
	local tooltip = ""
	local ndef = minetest.registered_nodes[name] or minetest.registered_items[name] or minetest.registered_craftitems[name]
	
	if ndef and ndef.description then
		local text = minetest.formspec_escape(ndef.description)
		tooltip = "tooltip["..x..","..y..";1,1;"..text..";#0C3D32;#FFFFFF]"
	end
	
	if ndef and ndef.stack_max == 1 then
		size = tonumber(size)
		local offs = 0
		if size < 10 then
			offs = 0.65
		elseif size < 100 then
			offs = 0.5
		elseif size < 1000 then
			offs = 0.35
		else
			offs = 0.2
		end
		label = "label["..(x + offs)..","..(y + 0.45)..";"..tostring(size).."]"
	end
	
	return "box["..x..","..y..";0.85,0.9;#808080]"..
		"item_image["..x..","..y..";1,1;"..itemname.."]"..
		tooltip..
		label
end

function techage.item_image_small(x, y, itemname, tooltip_prefix)
	local name = unpack(string.split(itemname, " "))
	local tooltip = ""
	local ndef = minetest.registered_nodes[name] or minetest.registered_items[name] or minetest.registered_craftitems[name]
	
	if ndef and ndef.description then
		local text = minetest.formspec_escape(ndef.description)
		tooltip = "tooltip["..x..","..y..";0.8,0.8;"..tooltip_prefix..": "..text..";#0C3D32;#FFFFFF]"
	end
	
	return "box["..x..","..y..";0.65,0.7;#808080]"..
		"item_image["..x..","..y..";0.8,0.8;"..name.."]"..
		tooltip
end

function techage.mydump(o, indent, nested, level)
	local t = type(o)
	if not level and t == "userdata" then
		-- when userdata (e.g. player) is passed directly, print its metatable:
		return "userdata metatable: " .. techage.mydump(getmetatable(o))
	end
	if t ~= "table" then
		return basic_dump(o)
	end
	-- Contains table -> true/nil of currently nested tables
	nested = nested or {}
	if nested[o] then
		return "<circular reference>"
	end
	nested[o] = true
	indent = " "
	level = level or 1
	local t = {}
	local dumped_indexes = {}
	for i, v in ipairs(o) do
		t[#t + 1] = techage.mydump(v, indent, nested, level + 1)
		dumped_indexes[i] = true
	end
	for k, v in pairs(o) do
		if not dumped_indexes[k] then
			if type(k) ~= "string" or not is_valid_identifier(k) then
				k = "["..techage.mydump(k, indent, nested, level + 1).."]"
			end
			v = techage.mydump(v, indent, nested, level + 1)
			t[#t + 1] = k.." = "..v
		end
	end
	nested[o] = nil
	if indent ~= "" then
		local indent_str = string.rep(indent, level)
		local end_indent_str = string.rep(indent, level - 1)
		return string.format("{%s%s%s}",
				indent_str,
				table.concat(t, ","..indent_str),
				end_indent_str)
	end
	return "{"..table.concat(t, ", ").."}"
end

-- title bar help (width is the fornmspec width)
function techage.question_mark_help(width, tooltip)
	local x = width- 0.6
	return "label["..x..",-0.1;"..minetest.colorize("#000000", minetest.formspec_escape("[?]")).."]"..
		"tooltip["..x..",-0.1;0.5,0.5;"..tooltip..";#0C3D32;#FFFFFF]"
end

