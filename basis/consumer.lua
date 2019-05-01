--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Consumer node basis functionality.
	It handles:
	- 3 stages of nodes (TA2/TA3/TA4)
	- power consumption
	- node state handling
	- registration of passive, active and defect nodes
	- Tube connections are on left and right side (from left to right)
	- Power connection are on front and back side (front or back)
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local TRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).techage end
local TRDN = function(node) return (minetest.registered_nodes[node.name] or {}).techage end

local consumer = techage.consumer

local function valid_power_dir(pos, power_dir, in_dir)
	return true
end

local function start_node(pos, mem, state)
	consumer.turn_power_on(pos, TRD(pos).power_consumption)
end

local function stop_node(pos, mem, state)
	consumer.turn_power_on(pos, 0)
end

local function turn_on_clbk(pos, in_dir, sum)
	local mem = tubelib2.get_mem(pos)
	local trd = TRD(pos)
	local state = trd.State:get_state(mem)
	if sum <= 0 and state == techage.RUNNING then
		trd.State:fault(pos, mem)
	end
end

local function prepare_tiles(tiles, stage, power_png)
	local tbl = {}
	for _,item in ipairs(tiles) do
		if type(item) == "string" then
			tbl[#tbl+1] = item:gsub("#", stage):gsub("{power}", power_png)
		else
			local temp = table.copy(item)
			temp.image = temp.image:gsub("#", stage):gsub("{power}", power_png)
			tbl[#tbl+1] = temp
		end
	end
	return tbl
end
			
function techage.register_consumer(base_name, inv_name, tiles, tNode)
	local names = {}
	for stage = 2,4 do
		local name_pas = "techage:ta"..stage.."_"..base_name.."_pas"
		local name_act = "techage:ta"..stage.."_"..base_name.."_act"
		local name_def = "techage:ta"..stage.."_"..base_name.."_def"
		local name_inv = "TA"..stage.." "..inv_name
		names[#names+1] = name_pas
		
		local on_recv_message = tNode.tubing.on_recv_message
		if stage > 2 then
			on_recv_message = function(pos, topic, payload)
				return "unsupported"
			end
		end
		
		local power_network
		local power_png = 'techage_axle_clutch.png'
		local power_used = tNode.power_consumption ~= nil
		-- power needed?
		if power_used then
			if stage > 2 then
				power_network = techage.ElectricCable
				power_png = 'techage_appl_hole_electric.png'
			else
				power_network = techage.Axle
				power_png = 'techage_axle_clutch.png'
			end
			power_network:add_secondary_node_names({name_pas, name_act})
		end
	
		local tState = techage.NodeStates:new({
			node_name_passive = name_pas,
			node_name_active = name_act,
			node_name_defect = name_def,
			infotext_name = name_inv,
			cycle_time = tNode.cycle_time,
			standby_ticks = tNode.standby_ticks,
			has_item_meter = tNode.has_item_meter,
			aging_factor = tNode.aging_factor,
			formspec_func = tNode.formspec,
			start_node = power_used and start_node or nil,
			stop_node = power_used and stop_node or nil,
		})
		local tTechage = {
			stage = stage,
			State = tState,
			num_items = tNode.num_items[stage],
			turn_on = power_used and turn_on_clbk or nil,
			read_power_consumption = consumer.read_power_consumption,
			power_network = power_used and power_network or nil,
			power_side = "F",
			valid_power_dir = power_used and valid_power_dir or nil,
			power_consumption = power_used and tNode.power_consumption[stage] or {0,0,0,0},
			-- animated_power_network = true,  TODO
		}
		
		tNode.groups.not_in_creative_inventory = 0

		minetest.register_node(name_pas, {
			description = name_inv,
			tiles = prepare_tiles(tiles.pas, stage, power_png),
			techage = tTechage,
			drawtype = tNode.drawtype,
			node_box = tNode.node_box,
			selection_box = tNode.selection_box,
			
			after_place_node = function(pos, placer, itemstack, pointed_thing)
				local mem
				if power_network then
					mem = consumer.after_place_node(pos, placer)
				else
					mem = tubelib2.init_mem(pos)
				end
				local meta = M(pos)
				local node = minetest.get_node(pos)
				meta:set_int("push_dir", techage.side_to_indir("L", node.param2))
				meta:set_int("pull_dir", techage.side_to_indir("R", node.param2))
				local number = "-"
				if stage > 2 then
					number = techage.add_node(pos, name_pas)
				end
				if tNode.after_place_node then
					tNode.after_place_node(pos, placer, itemstack, pointed_thing)
				end
				TRD(pos).State:node_init(pos, mem, number)
			end,

			after_dig_node = function(pos, oldnode, oldmetadata, digger)
				if tNode.after_dig_node then
					tNode.after_dig_node(pos, oldnode, oldmetadata, digger)
				end
				techage.remove_node(pos)
				TRDN(oldnode).State:after_dig_node(pos, oldnode, oldmetadata, digger)
				if power_network then
					consumer.after_dig_node(pos, oldnode)
				end
			end,
			
			after_tube_update = consumer.after_tube_update,
			can_dig = tNode.can_dig,
			on_rotate = screwdriver.disallow,
			on_timer = tNode.node_timer,
			on_receive_fields = tNode.on_receive_fields,
			on_rightclick = tNode.on_rightclick,
			allow_metadata_inventory_put = tNode.allow_metadata_inventory_put,
			allow_metadata_inventory_move = tNode.allow_metadata_inventory_move,
			allow_metadata_inventory_take = tNode.allow_metadata_inventory_take,
			on_metadata_inventory_move = tNode.on_metadata_inventory_move,
			on_metadata_inventory_put = tNode.on_metadata_inventory_put,
			on_metadata_inventory_take = tNode.on_metadata_inventory_take,

			drop = "",
			paramtype2 = "facedir",
			groups = table.copy(tNode.groups),
			is_ground_content = false,
			sounds = tNode.sounds,
		})

		tNode.groups.not_in_creative_inventory = 1
		
		minetest.register_node(name_act, {
			description = name_inv,
			tiles = prepare_tiles(tiles.act, stage, power_png),
			techage = tTechage,
			drawtype = tNode.drawtype,
			node_box = tNode.node_box,
			selection_box = tNode.selection_box,
			
			after_tube_update = consumer.after_tube_update,
			on_rotate = screwdriver.disallow,
			on_timer = tNode.node_timer,
			on_receive_fields = tNode.on_receive_fields,
			on_rightclick = tNode.on_rightclick,
			allow_metadata_inventory_put = tNode.allow_metadata_inventory_put,
			allow_metadata_inventory_move = tNode.allow_metadata_inventory_move,
			allow_metadata_inventory_take = tNode.allow_metadata_inventory_take,
			on_metadata_inventory_move = tNode.on_metadata_inventory_move,
			on_metadata_inventory_put = tNode.on_metadata_inventory_put,
			on_metadata_inventory_take = tNode.on_metadata_inventory_take,

			paramtype2 = "facedir",
			diggable = false,
			groups = tNode.groups,
			is_ground_content = false,
			sounds = tNode.sounds,
		})

		minetest.register_node(name_def, {
			description = name_inv,
			tiles = prepare_tiles(tiles.def, stage, power_png),
			techage = tTechage,
			drawtype = tNode.drawtype,
			node_box = tNode.node_box,
			selection_box = tNode.selection_box,
			
			after_place_node = function(pos, placer, itemstack, pointed_thing)
				local mem = consumer.after_place_node(pos, placer)
				local meta = M(pos)
				local node = minetest.get_node(pos)
				meta:set_int("push_dir", techage.side_to_indir("L", node.param2))
				meta:set_int("pull_dir", techage.side_to_indir("R", node.param2))
				local number = "-"
				if stage > 2 then
					number = techage.add_node(pos, name_pas)
				end
				if tNode.after_place_node then
					tNode.after_place_node(pos, placer, itemstack, pointed_thing)
				end
				TRD(pos).State:defect(pos, mem)
			end,
			
			after_tube_update = consumer.after_tube_update,
			on_rotate = screwdriver.disallow,
			on_receive_fields = tNode.on_receive_fields,
			on_rightclick = tNode.on_rightclick,
			allow_metadata_inventory_put = tNode.allow_metadata_inventory_put,
			allow_metadata_inventory_move = tNode.allow_metadata_inventory_move,
			allow_metadata_inventory_take = tNode.allow_metadata_inventory_take,
			on_metadata_inventory_move = tNode.on_metadata_inventory_move,
			on_metadata_inventory_put = tNode.on_metadata_inventory_put,
			on_metadata_inventory_take = tNode.on_metadata_inventory_take,

			after_dig_node = function(pos, oldnode, oldmetadata, digger)
				if tNode.after_dig_node then
					tNode.after_dig_node(pos, oldnode, oldmetadata, digger)
				end
				techage.remove_node(pos)
				consumer.after_dig_node(pos, oldnode)
			end,
			
			paramtype2 = "facedir",
			groups = tNode.groups,
			is_ground_content = false,
			sounds = tNode.sounds,
		})

		techage.register_node(name_pas, {name_act, name_def}, tNode.tubing)
	end
	return names[1], names[2], names[3]
end
