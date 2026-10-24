--[[

	TechAge
	=======

	Copyright (C) 2024-2026 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Recipe Adapter

	A flat plate like the forceload tile. It can be mounted on top of, below,
	or on any side of a furnace or an electronic fab; the machine it is
	attached to is detected via the same "back side" logic as the Beduino IOT
	sensor (no formspec).
	It provides the machine's recipes via Beduino:

	  156          number of recipes
	  158 [idx]    output count
	  160          target node number
	  193 "idx"    output item name
	  194 "idx,slot" input item name
	  195 "name"   find recipe index by output name
	  196 [idx]    recipe time (furnace, otherwise 0)
	  197 [idx,slot] input count
	  198 [idx]    number of inputs
	  64  "idx"    select recipe on the target machine (electronic fab)

]]--

local S = techage.S
local M = minetest.get_meta
local P2S = minetest.pos_to_string

-- Same orientation mapping as the Beduino IOT sensor (rotate_and_place
-- produces a param2 that has to be translated to a facedir first).
local Wall2Facedir = {
	[0] = 4, [1] = 13, [2] = 10, [3] = 19,
	[7] = 2, [9] = 0, [12] = 3, [18] = 1,
	[20] = 8, [21] = 15, [22] = 6, [23] = 17,
}

local function machine_type(name)
	if name:find("furnace", 1, true) and
			not name:find("heater", 1, true) and
			not name:find("firebox", 1, true) then
		return "furnace"
	elseif name:find("electronic_fab", 1, true) then
		return "ta4_electronic_fab"
	end
end

-- The attached machine is on the back side of the adapter (like IOT sensor
-- port 0); the direction follows the placement (top, bottom or side).
local function detect(pos)
	local node = minetest.get_node(pos)
	local param2 = Wall2Facedir[node.param2] or node.param2
	local npos = networks.get_relpos(pos, "B", param2)
	local rtype = machine_type(minetest.get_node(npos).name)
	if rtype then
		local number = tonumber(M(npos):get_string("node_number"))
		if number then
			return rtype, number
		end
	end
end

local function update_infotext(pos)
	local meta = M(pos)
	local rtype = meta:get_string("rtype")
	local target = meta:get_string("target")
	local typ = "not docked"
	if rtype == "furnace" then
		typ = "Furnace"
	elseif rtype == "ta4_electronic_fab" then
		typ = "Electronic Fab"
	end
	meta:set_string("infotext", "TA4 Recipe Adapter " ..
		meta:get_string("node_number") .. " (" .. typ ..
		(target ~= "" and " -> " .. target or "") .. ")")
end

local function redetect(pos)
	local meta = M(pos)
	local rtype, target = detect(pos)
	if rtype then
		meta:set_string("rtype", rtype)
		meta:set_string("target", tostring(target))
	else
		meta:set_string("rtype", "")
		meta:set_string("target", "")
	end
	update_infotext(pos)
end

-- Return the normalized recipe list, the configured type and target number.
local function recipe_list(pos)
	local meta = M(pos)
	local rtype = meta:get_string("rtype")
	local target = tonumber(meta:get_string("target"))
	local owner
	if target then
		local ninfo = techage.get_node_info(target)
		if ninfo and ninfo.pos then
			owner = M(ninfo.pos):get_string("owner")
		end
	end

	local list = {}
	if rtype == "furnace" then
		if techage.furnace and techage.furnace.get_all then
			for _, r in ipairs(techage.furnace.get_all()) do
				local inputs = {}
				for _, name in ipairs(r.input or {}) do
					inputs[#inputs + 1] = {name = name, num = 1}
				end
				list[#list + 1] = {
					output = r.output,
					out_num = r.number or 1,
					inputs = inputs,
					time = r.time or 0,
				}
			end
		end
	elseif rtype == "ta4_electronic_fab" and techage.recipes then
		for _, r in ipairs(techage.recipes.get_all(rtype, owner)) do
			list[#list + 1] = {
				output = r.output.name,
				out_num = r.output.num,
				inputs = r.input,
				time = 0,
			}
		end
	end
	return list, rtype, target, owner
end

local function find_index(pos, name)
	local list = recipe_list(pos)
	for idx, r in ipairs(list) do
		if r.output == name then
			return idx
		end
	end
	for idx, r in ipairs(list) do
		if r.output:find(name, 1, true) then
			return idx
		end
	end
	return 0
end

local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	return minetest.rotate_and_place(itemstack, placer, pointed_thing)
end

minetest.register_node("techage:ta4_recipe_adapter", {
	description = S("TA4 Recipe Adapter"),
	tiles = {
		-- Placeholder texture; replace with dedicated adapter art later.
		"techage_filling_ta4.png^techage_frame_ta4_top.png^techage_appl_recipeblock.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-4/16, -8/16, -4/16, 4/16, -15/32, 4/16},
		},
	},
	on_place = on_place,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, cracky = 2, crumbly = 2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local number = techage.add_node(pos, "techage:ta4_recipe_adapter")
		meta:set_string("node_number", tostring(number or ""))
		meta:set_string("owner", placer and placer:get_player_name() or "")
		redetect(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	-- Re-detect the machine on rightclick (no formspec).
	on_rightclick = function(pos, node, clicker)
		redetect(pos)
		if M(pos):get_string("rtype") == "" then
			minetest.chat_send_player(clicker:get_player_name(),
				"[Techage] Recipe adapter: no furnace/electronic fab found below.")
		end
	end,
})

techage.register_node({"techage:ta4_recipe_adapter"}, {
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 64 and type(payload) == "string" then
			-- Select the recipe on the target machine (electronic fab).
			local list, rtype, target = recipe_list(pos)
			local idx = tonumber(payload) or 0
			if rtype == "ta4_electronic_fab" and target and list[idx] then
				local ninfo = techage.get_node_info(target)
				if ninfo and ninfo.pos then
					techage.recipes.set_recipe(ninfo.pos, rtype, idx)
					return 0
				end
				return 1
			end
			return 0
		end
		return 2
	end,

	on_beduino_request_data = function(pos, src, topic, payload)
		local list, rtype, target = recipe_list(pos)

		if topic == 156 then
			return 0, {#list}
		elseif topic == 160 then
			return 0, {target or 0}
		elseif topic == 158 then
			local idx = tonumber(payload and payload[1]) or 0
			local recipe = list[idx]
			return 0, {recipe and recipe.out_num or 0}
		elseif topic == 193 and type(payload) == "string" then
			local idx = tonumber(payload) or 0
			return 0, list[idx] and list[idx].output or ""
		elseif topic == 194 and type(payload) == "string" then
			local idx, slot = payload:match("^(%d+),(%d+)$")
			idx = tonumber(idx) or 0
			slot = tonumber(slot) or 0
			local recipe = list[idx]
			local input = recipe and recipe.inputs[slot]
			return 0, input and input.name or ""
		elseif topic == 195 and type(payload) == "string" then
			return 0, {find_index(pos, payload)}
		elseif topic == 196 then
			local idx = tonumber(payload and payload[1]) or 0
			local recipe = list[idx]
			return 0, {recipe and math.floor(recipe.time) or 0}
		elseif topic == 197 then
			local idx = tonumber(payload and payload[1]) or 0
			local slot = tonumber(payload and payload[2]) or 0
			local recipe = list[idx]
			local input = recipe and recipe.inputs[slot]
			return 0, {input and input.num or 0}
		elseif topic == 198 then
			local idx = tonumber(payload and payload[1]) or 0
			local recipe = list[idx]
			return 0, {recipe and #recipe.inputs or 0}
		end
		return 2, ""
	end,
})

minetest.register_craft({
	output = "techage:ta4_recipe_adapter",
	recipe = {
		{"techage:ta4_carbon_fiber", "dye:blue", "techage:aluminum"},
		{"", "basic_materials:ic", ""},
		{"default:steel_ingot", "techage:ta4_wlanchip", "default:steel_ingot"},
	},
})
