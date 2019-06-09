--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Consumer node basis functionality.
	It handles:
	- up to 3 stages of nodes (TA2/TA3/TA4)
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
-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).consumer end
local CRDN = function(node) return (minetest.registered_nodes[node.name] or {}).consumer end

local ValidPowerConsumingStates = {
	[techage.RUNNING] = true,
	[techage.BLOCKED] = true,
	[techage.FAULT] = true,
}

local function start_node(pos, mem, state)
	-- First finish the start process, than check power and
	-- if needed, switch to "nopower"
	minetest.after(0.5, techage.power.power_distribution, pos)
end

local function stop_node(pos, mem, state)
	techage.power.power_distribution(pos)
end

local function on_power_pass1(pos, mem)
	local crd = CRD(pos)
	if ValidPowerConsumingStates[crd.State:get_state(mem)] then
		return crd.power_consumption
	end
	return 0
end	
		
local function on_power_pass2(pos, mem, sum)
	local crd = CRD(pos)
	local state = crd.State:get_state(mem)
	if sum > 0 and state == techage.NOPOWER then
		crd.State:start(pos, mem)
		return 0
	elseif sum <= 0 and ValidPowerConsumingStates[state] or state == techage.STANDBY then
		crd.State:nopower(pos, mem)
		return -crd.power_consumption
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
			
-- 'validStates' is optional and can be used to e.g. enable 
-- only one TA2 node {false, true, false, false}
function techage.register_consumer(base_name, inv_name, tiles, tNode, validStates)
	local names = {}
	validStates = validStates or {true, true, true, true}
	for stage = 2,4 do
		local name_pas = "techage:ta"..stage.."_"..base_name.."_pas"
		local name_act = "techage:ta"..stage.."_"..base_name.."_act"
		local name_def = "techage:ta"..stage.."_"..base_name.."_def"
		local name_inv = "TA"..stage.." "..inv_name
		names[#names+1] = name_pas
		
		if validStates[stage] then
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
				aging_factor = tNode.aging_factor * (stage-1) * 2,
				formspec_func = tNode.formspec,
				on_state_change = tNode.on_state_change,
				start_node = power_used and start_node or nil,
				stop_node = power_used and stop_node or nil,
			})
			
			local tConsumer = {
				stage = stage,
				State = tState,
				-- number of items to be processed per cycle
				num_items = tNode.num_items[stage],  
				power_consumption = power_used and 
						tNode.power_consumption[stage] or {0,0,0,0},
			}
			
			tNode.groups.not_in_creative_inventory = 0

			minetest.register_node(name_pas, {
				description = name_inv,
				tiles = prepare_tiles(tiles.pas, stage, power_png),
				consumer = tConsumer,
				drawtype = tNode.drawtype,
				node_box = tNode.node_box,
				selection_box = tNode.selection_box,
				
				on_construct = tubelib2.init_mem,
				
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					local meta = M(pos)
					local mem = tubelib2.get_mem(pos)
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
					CRD(pos).State:node_init(pos, mem, number)
				end,

				after_dig_node = function(pos, oldnode, oldmetadata, digger)
					if tNode.after_dig_node then
						tNode.after_dig_node(pos, oldnode, oldmetadata, digger)
					end
					techage.remove_node(pos)
					CRDN(oldnode).State:after_dig_node(pos, oldnode, 
							oldmetadata, digger)
				end,
				
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
				consumer = tConsumer,
				drawtype = tNode.drawtype,
				node_box = tNode.node_box,
				selection_box = tNode.selection_box,
				
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
				consumer = tConsumer,
				drawtype = tNode.drawtype,
				node_box = tNode.node_box,
				selection_box = tNode.selection_box,
				
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					local meta = M(pos)
					local mem = tubelib2.get_mem(pos)
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
					CRD(pos).State:defect(pos, mem)
				end,
				
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
				end,
				
				paramtype2 = "facedir",
				groups = tNode.groups,
				is_ground_content = false,
				sounds = tNode.sounds,
			})

			if power_used then
				techage.power.register_node({name_pas, name_act}, {
					on_power_pass1 = on_power_pass1,
					on_power_pass2 = on_power_pass2,
					conn_sides = {"F", "B"},
					power_network  = power_network,
				})
			end
			techage.register_node({name_pas, name_act, name_def}, tNode.tubing)
		end
	end
	return names[1], names[2], names[3]
end
