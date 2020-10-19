--[[

	TechAge
	=======

	Copyright (C) 2017-2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	repairkit.lua:
]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local Cable1 = techage.ElectricCable
local Cable2 = techage.TA4_Cable
local Pipe2 = techage.LiquidPipe
local networks = techage.networks

local ListOfNodes = {
	["techage:generator"] = true, 
	["techage:generator_on"] = true,
	["techage:ta4_generator"] = true,
	["techage:ta4_generator_on"] = true,
	["techage:ta4_fuelcell"] = true,
	["techage:ta4_fuelcell_on"] = true,
	["techage:t3_pump"] = true,
	["techage:t3_pump_on"] = true,
	["techage:t4_pump"] = true,
	["techage:t4_pump_on"] = true,
	["techage:ta4_solar_inverter"] = true,
	["techage:flywheel"] = true,
	["techage:flywheel_on"] = true,
	["techage:tiny_generator"] = true,
	["techage:tiny_generator_on"] = true,
	["techage:ta4_electrolyzer"] = true,
	["techage:ta4_electrolyzer_on"] = true,
	["techage:oilfirebox"] = true,
}


local function delete_data(pos)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local number = meta:get_string("number")
	local node_number = meta:get_string("node_number")
	tubelib2.del_mem(pos)
	meta:from_table(nil)
	meta:set_string("owner", owner)
	meta:set_string("number", number)
	meta:set_string("node_number", node_number)
end

local function inv_get_count(inv, listname, size)
	local cnt = 0
	for i = 1,size do
		cnt = cnt + inv:get_stack(listname, i):get_count() 
	end
	return cnt
end

local function inv_get_name(inv, listname, size)
	for i = 1,size do
		local name = inv:get_stack(listname, i):get_name() 
		if name ~= "" then 
			return name
		end
	end
	return ""
end

local function inv_clear(inv, listname, size)
	for i = 1,size do
		inv:set_stack(listname, i, nil)
	end
end

local function restore_inv_content(pos, listname, size)
	local inv = M(pos):get_inventory()
	local count = inv_get_count(inv, listname, size)
	if count > 0 then
		local nvm = techage.get_nvm(pos)
		nvm.liquid = nvm.liquid or {}
		nvm.liquid.amount = count
		nvm.liquid.name = inv_get_name(inv, listname, size)
		inv:set_stack(listname, 1, nil)
		inv_clear(inv, listname, size)
		return true
	end
	return false
end

local function init_data(pos, netw)
	local sides = netw.ele1 and netw.ele1.sides
	if sides and sides["R"] then
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		M(pos):set_string("infotext", "repaired")
	end
	
	sides = netw.pipe2 and netw.pipe2.sides
	if sides and sides["R"] then
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		M(pos):set_string("infotext", "repaired")
	end
		
	sides = netw.ele2 and netw.ele2.sides
	if sides and sides["L"] then
		M(pos):set_int("leftdir", networks.side_to_outdir(pos, "L"))
	end
	
	sides = netw.axle and netw.axle.sides
	if sides and sides["R"] then
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
	end
	
	Cable1:after_place_node(pos)
	Cable2:after_place_node(pos)
	Pipe2:after_place_node(pos)
end


local function repair(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos and user then
		if minetest.is_protected(pos, user:get_player_name()) then
			return itemstack
		end
		
		local number = techage.get_node_number(pos)
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef then
			local netw = ndef.networks
			if netw and ListOfNodes[node.name] then
				if node.name == "techage:tiny_generator" or node.name == "techage:tiny_generator_on" then
					restore_inv_content(pos, "fuel", 1)
				elseif node.name == "techage:oilfirebox" then
					restore_inv_content(pos, "fuel", 1)
				elseif node.name == "techage:ta4_fuelcell" or node.name == "techage:ta4_fuelcell_on" then
					restore_inv_content(pos, "src", 4)
				elseif node.name == "techage:ta4_electrolyzer" or node.name == "techage:ta4_electrolyzer_on" then
					restore_inv_content(pos, "dst", 1)
				end
				delete_data(pos)
				init_data(pos, netw)
				minetest.chat_send_player(user:get_player_name(), ndef.description.." "..S("repaired"))
				itemstack:add_wear(65636/200)
				return itemstack
			end
			
			if netw and netw.ele1 and netw.ele1.ntype == "junc" then
				if ndef.after_place_node and ndef.tubelib2_on_update2 then
					ndef.after_place_node(pos)
					ndef.tubelib2_on_update2(pos, 0, Cable1)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..S("repaired"))
					itemstack:add_wear(65636/200)
					return itemstack
				end
			end
		
			if netw and netw.ele2 and netw.ele2.ntype == "junc" then
				if ndef.after_place_node and ndef.tubelib2_on_update2 then
					ndef.after_place_node(pos)
					ndef.tubelib2_on_update2(pos, 0, Cable2)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..S("repaired"))
					itemstack:add_wear(65636/200)
					return itemstack
				end
			end
		end
	end
	return itemstack
end	
	
local function network_check(start_pos, Cable, player_name)
	local ndef = techage.networks.net_def(start_pos, Cable.tube_type)
	local outdir = nil
	local num = 0
	if ndef and ndef.ntype ~= "junc" then
		outdir = M(start_pos):get_int("outdir")
	end
	networks.connection_walk(start_pos, outdir, Cable, function(pos, indir, node)
		local distance = vector.distance(start_pos, pos)
		num = num + 1
		if distance < 50 and num < 100 then
			local state = techage.power.power_available(pos, Cable) and "power" or "no power"
			techage.mark_position(player_name, pos, state, "#ff0000", 6)
		end
	end)
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
		
		if ndef and ndef.networks then
			local player_name = user:get_player_name()
			if ndef.networks.ele1 then
				network_check(pos, Cable1, player_name)
			elseif ndef.networks.ele2 then
				network_check(pos, Cable2, player_name)
			elseif ndef.networks.pipe2 then
				network_check(pos, Pipe2, player_name)
			end
		end
		
		if number then
			if ndef and ndef.description then
				local info = techage.send_single("0", number, "info", nil)
				if info and info ~= "" and info ~= "unsupported" then
					info = dump(info)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": Supported Commands:\n"..info.."    ")
				end
				local state = techage.send_single("0", number, "state", nil)
				if state and state ~= "" and state ~= "unsupported" then
					state = dump(state)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": state = "..state.."    ")
				end
				local fuel = techage.send_single("0", number, "fuel", nil)
				if fuel and fuel ~= "" and fuel ~= "unsupported" then
					fuel = dump(fuel)
					minetest.chat_send_player(user:get_player_name(), ndef.description.." "..number..": fuel = "..fuel.."    ")
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

minetest.register_tool("techage:repairkit", {
	description = S("TechAge Repair Kit"),
	inventory_image = "techage_repairkit.png",
	wield_image = "techage_repairkit.png^[transformR270",
	groups = {cracky=1, book=1},
	on_use = repair,
	on_place = repair,
	node_placement_prediction = "",
	stack_max = 1,
})


minetest.register_tool("techage:end_wrench", {
	description = S("TechAge Info Tool (use = read status info)"),
	inventory_image = "techage_end_wrench.png",
	wield_image = "techage_end_wrench.png",
	groups = {cracky=1, book=1},
	on_use = read_state,
	on_place = read_state,
	node_placement_prediction = "",
	liquids_pointable = true,
	stack_max = 1,
})

--minetest.register_craft({
--	output = "techage:repairkit",
--	recipe = {
--		{"", "basic_materials:gear_steel", ""},
--		{"", "techage:end_wrench", ""},
--		{"", "basic_materials:oil_extract", ""},
--	},
--})

minetest.register_craft({
	output = "techage:end_wrench",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"", "techage:iron_ingot", ""},
		{"default:steel_ingot", "", ""},
	},
})

