--[[

	TechAge
	=======

	Copyright (C) 2024-2026 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Recipe Adapter

	Read-only recipe source for machines whose recipes are not in a recipe
	block (furnace, electronic fab). Place it next to the machine, set the
	recipe type and the machine's node number in the formspec. Beduino topics:

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

local function formspec(pos)
	local meta = M(pos)
	local rtype = meta:get_string("rtype")
	if rtype == "" then
		rtype = "furnace"
	end
	local select = (rtype == "ta4_electronic_fab") and 2 or 1
	return "size[6,3.4]" ..
		"label[0.2,0.1;" .. S("TA4 Recipe Adapter") .. "]" ..
		"dropdown[0.2,0.6;3.2,0.8;rtype;Furnace,Electronic Fab;" .. select .. "]" ..
		"field[0.2,1.6;4,0.8;target;" .. S("Target node number") .. ";" ..
			minetest.formspec_escape(meta:get_string("target")) .. "]" ..
		"button[0.2,2.5;2,0.8;save;" .. S("Save") .. "]"
end

local function update_infotext(pos)
	local meta = M(pos)
	local rtype = meta:get_string("rtype")
	local typ = (rtype == "ta4_electronic_fab") and "Electronic Fab" or "Furnace"
	meta:set_string("infotext", "TA4 Recipe Adapter " ..
		meta:get_string("node_number") .. " (" .. typ .. " -> " ..
		meta:get_string("target") .. ")")
end

-- Return the normalized recipe list, the configured type and target number.
local function recipe_list(pos)
	local meta = M(pos)
	local rtype = meta:get_string("rtype")
	if rtype == "" then
		rtype = "furnace"
	end
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
	elseif techage.recipes then
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

minetest.register_node("techage:ta4_recipe_adapter", {
	description = S("TA4 Recipe Adapter"),
	tiles = {
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_recipeblock.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_recipeblock.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_recipeblock.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_recipeblock.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_recipeblock.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_recipeblock.png",
	},
	groups = {choppy = 2, cracky = 2, crumbly = 2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local number = techage.add_node(pos, "techage:ta4_recipe_adapter")
		meta:set_string("node_number", tostring(number or ""))
		meta:set_string("owner", placer and placer:get_player_name() or "")
		if meta:get_string("rtype") == "" then
			meta:set_string("rtype", "furnace")
		end
		meta:set_string("formspec", formspec(pos))
		update_infotext(pos)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	on_rightclick = function(pos, node, clicker)
		if techage.set_activeformspec then
			techage.set_activeformspec(pos, clicker)
		end
		M(pos):set_string("formspec", formspec(pos))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		local meta = M(pos)
		if fields.rtype then
			meta:set_string("rtype",
				fields.rtype == "Electronic Fab" and "ta4_electronic_fab" or "furnace")
		end
		if fields.target then
			meta:set_string("target", tostring(tonumber(fields.target) or ""))
		end
		if fields.save or fields.rtype or fields.target then
			meta:set_string("formspec", formspec(pos))
			update_infotext(pos)
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
