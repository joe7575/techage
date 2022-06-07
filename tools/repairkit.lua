--[[

	TechAge
	=======

	Copyright (C) 2017-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable1 = techage.ElectricCable
local Cable2 = techage.TA4_Cable
local Pipe2 = techage.LiquidPipe
local menu = techage.menu

local N = techage.get_node_lvm
local CTL = function(pos) return (minetest.registered_nodes[N(pos).name] or {}).control end

local function network_check(start_pos, Cable, player_name)
--	local ndef = techage.networks.net_def(start_pos, Cable.tube_type)
--	local outdir = nil
--	local num = 0
--	if ndef and ndef.ntype ~= "junc" then
--		outdir = M(start_pos):get_int("outdir")
--	end
--	networks.connection_walk(start_pos, outdir, Cable, function(pos, indir, node)
--		local distance = vector.distance(start_pos, pos)
--		num = num + 1
--		if distance < 50 and num < 100 then
--			local state = techage.power.power_available(pos, Cable) and "power" or "no power"
--			techage.mark_position(player_name, pos, state, "#ff0000", 6)
--		end
--	end)
end

local function read_state(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos and user then
		local time = math.floor(minetest.get_timeofday() * 24 * 6)
		local hours = math.floor(time / 6)
		local mins = (time % 6) * 10
		if mins < 10 then mins = "00" end

		local number = techage.get_node_number(pos)
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]

		if node.name == "default:water_source" then
			local player_name = user:get_player_name()
			techage.valid_place_for_windturbine(pos, player_name, 0)
			return itemstack
		end

		minetest.chat_send_player(user:get_player_name(), S("Time")..": "..hours..":"..mins.."    ")
		local data = minetest.get_biome_data(pos)
		if data then
			local name = minetest.get_biome_name(data.biome)
			minetest.chat_send_player(user:get_player_name(), S("Biome")..": "..name..", "..S("Position temperature")..": "..math.floor(data.heat).."    ")
		end

		if number then
			if ndef and ndef.description then
				local info = techage.send_single("0", number, "info", nil)
				if info and info ~= "" and info ~= "unsupported" then
					info = tostring(info)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..":\n"..info.."    ")
				end
				local state = techage.send_single("0", number, "state", nil)
				if state and state ~= "" and state ~= "unsupported" then
					state = dump(state)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": state = "..state.."    ")
				end
				local state = techage.send_single("0", number, "count", nil)
				if state and state ~= "" and state ~= "unsupported" then
					state = dump(state)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": count = "..state.."    ")
				end
				local fuel = techage.send_single("0", number, "fuel", nil)
				if fuel and fuel ~= "" and fuel ~= "unsupported" then
					fuel = dump(fuel)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": fuel = "..fuel.."    ")
				end
				local output = techage.send_single("0", number, "output", nil)
				if output and output ~= "" and output ~= "unsupported" then
					output = dump(output)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": output = "..output.."    ")
				end
				local load, abs = techage.send_single("0", number, "load", nil)
				if load and load ~= "" and load ~= "unsupported" then
					load, abs = dump(load), abs and dump(abs) or "--"
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": load = "..load.." % / "..abs.." units    ")
				end
				local delivered = techage.send_single("0", number, "delivered", nil)
				if delivered and delivered ~= "" and delivered ~= "unsupported" then
					delivered = dump(delivered)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": delivered = "..delivered.." ku    ")
				end
				local consumption = techage.send_single("0", number, "consumption", nil)
				if consumption and consumption ~= "" and consumption ~= "unsupported" then
					consumption = dump(consumption)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": consumption = "..consumption.." kud    ")
				end
				local flowrate = techage.send_single("0", number, "flowrate", nil)
				if flowrate and flowrate ~= "" and flowrate ~= "unsupported" then
					flowrate = dump(flowrate)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": flowrate = "..flowrate.."    ")
				end
				local owner = M(pos):get_string("owner") or ""
				if owner ~= "" then
					minetest.chat_send_player(user:get_player_name(), S("Node owner")..": "..owner.."    ")
				end
				minetest.chat_send_player(user:get_player_name(), S("Position")..": "..minetest.pos_to_string(pos).."    ")
				itemstack:add_wear(65636/200)
				return itemstack
			end
		elseif ndef and ndef.description then
			if ndef.techage_info then
				local info = ndef.techage_info(pos) or ""
				minetest.chat_send_player(user:get_player_name(), ndef.description..":\n"..info)
			end
			local owner = M(pos):get_string("owner") or ""
			if owner ~= "" then
				minetest.chat_send_player(user:get_player_name(), S("Node owner")..": "..owner.."    ")
			end
			minetest.chat_send_player(user:get_player_name(), S("Position")..": "..minetest.pos_to_string(pos).."    ")
			itemstack:add_wear(65636/200)
			return itemstack
		end
	end
end

local context = {}

local function settings_menu(pos, playername)
	if minetest.is_protected(pos, playername) then
		return
	end
	-- Check node settings in addition
	local access = M(pos):get_string("access")
	local owner = M(pos):get_string("owner")
	if access == "private" and playername ~= owner then
		return
	end

	local number = techage.get_node_number(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local form_def

	if ndef then
		if ndef.ta3_formspec or ndef.ta4_formspec then
			form_def = ndef.ta3_formspec or ndef.ta4_formspec
		elseif ndef.ta5_formspec then
			local player = minetest.get_player_by_name(playername)
			if techage.get_expoints(player) >= ndef.ta5_formspec.ex_points then
				form_def = ndef.ta5_formspec.menu
			end
		end
	end

	context[playername] = pos
	if form_def then
		minetest.show_formspec(playername, "techage:ta_formspec",
			menu.generate_formspec(pos, ndef, form_def, playername))
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "techage:ta_formspec" then
		return false
	end

	local playername = player:get_player_name()
	local pos = context[playername]
	if pos then
		--context[playername] = nil
		local number = techage.get_node_number(pos)
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		local form_def = ndef and (ndef.ta3_formspec or ndef.ta4_formspec or ndef.ta5_formspec.menu)

		if form_def then
			if menu.eval_input(pos, form_def, fields, playername) then
				--context[playername] = pos
				minetest.after(0.2, function()
					minetest.show_formspec(playername, "techage:ta_formspec",
						menu.generate_formspec(pos, ndef, form_def, playername))
				end)
				if ndef.ta_after_formspec then
					ndef.ta_after_formspec(pos, fields, playername)
				end
			end
		end
	end
	return true
end)


local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local playername = placer:get_player_name()
		if placer:get_player_control().sneak then
			settings_menu(pos, playername)
		end
	end
end

minetest.register_tool("techage:repairkit", {
	description = S("TechAge Repair Kit"),
	inventory_image = "techage_repairkit.png",
	wield_image = "techage_repairkit.png^[transformR270",
	groups = {cracky=1, book=1},
	--on_use = repair,
	--on_place = repair,
	node_placement_prediction = "",
	stack_max = 1,
})


minetest.register_tool("techage:end_wrench", {
	description = S("TechAge Info Tool (use = read status info)"),
	inventory_image = "techage_end_wrench.png",
	wield_image = "techage_end_wrench.png",
	groups = {cracky=1, book=1},
	on_use = read_state,
	on_place = on_place,
	node_placement_prediction = "",
	liquids_pointable = true,
	stack_max = 1,
})

minetest.register_craft({
	output = "techage:end_wrench",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"", "techage:iron_ingot", ""},
		{"default:steel_ingot", "", ""},
	},
})
