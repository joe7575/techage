--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Consumer node basis functionality.
	It handles:
	- up to 3 stages of nodes (TA2/TA3/TA4)
	- power consumption
	- node state handling
	- registration of passive and active nodes
	- Tube connections are on left and right side (from left to right)
	- Power connection are on front and back side (front or back)
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end
local CRDN = function(node) return (minetest.registered_nodes[node.name] or {}).consumer end

local power = techage.power
local networks = techage.networks
local Pipe = techage.LiquidPipe
local liquid = techage.liquid

local function has_power(pos, nvm, state)
	local crd = CRD(pos)
	return power.power_available(pos, crd.power_netw)
end

local function start_node(pos, nvm, state)
	local crd = CRD(pos)
	power.consumer_start(pos, crd.power_netw, crd.cycle_time)
end

local function stop_node(pos, nvm, state)
	local crd = CRD(pos)
	power.consumer_stop(pos, crd.power_netw)
end

local function on_power(pos)
	local crd = CRD(pos)
	local nvm = techage.get_nvm(pos)
	crd.State:start(pos, nvm)
end

local function on_nopower(pos)
	local crd = CRD(pos)
	local nvm = techage.get_nvm(pos)
	crd.State:nopower(pos, nvm)
end


local function node_timer(pos, elapsed)
	local crd = CRD(pos)
	local nvm = techage.get_nvm(pos)
	if crd.power_netw and techage.needs_power(nvm) then
		power.consumer_alive(pos, crd.power_netw, crd.cycle_time)
	end
	-- call the node timer routine
	if techage.is_operational(nvm) then
		crd.node_timer(pos, crd.cycle_time)
	end
	return crd.State:is_active(nvm)
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
		local name_inv = "TA"..stage.." "..inv_name
		names[#names+1] = name_pas

		if validStates[stage] then
			local on_recv_message = tNode.tubing.on_recv_message
			if stage > 2 then
				on_recv_message = function(pos, src, topic, payload)
					return "unsupported"
				end
			end

			local power_network
			local power_png = 'techage_axle_clutch.png'
			local power_used = tNode.power_consumption ~= nil
			local tNetworks
			-- power needed?
			if power_used then
				if stage > 2 then
					power_network = techage.ElectricCable
					power_png = 'techage_appl_hole_electric.png'
					tNetworks = {
						ele1 = {
							sides = tNode.power_sides or {F=1, B=1, U=1, D=1},
							ntype = "con1",
							nominal = tNode.power_consumption[stage],
							on_power = on_power,
							on_nopower = on_nopower,
							is_running = function(pos, nvm) return techage.is_running(nvm) end,
						},
					}
					if tNode.networks and tNode.networks.pipe2 then
						tNetworks.pipe2 = tNode.networks.pipe2
					end
				else
					power_network = techage.Axle
					power_png = 'techage_axle_clutch.png'
					tNetworks = {
						axle = {
							sides = tNode.power_sides or {F=1, B=1, U=1, D=1},
							ntype = "con1",
							nominal = tNode.power_consumption[stage],
							on_power = on_power,
							on_nopower = on_nopower,
						}
					}
				end
			end

			local tState = techage.NodeStates:new({
				node_name_passive = name_pas,
				node_name_active = name_act,
				infotext_name = name_inv,
				cycle_time = tNode.cycle_time,
				standby_ticks = tNode.standby_ticks,
				formspec_func = tNode.formspec,
				on_state_change = tNode.on_state_change,
				can_start = tNode.can_start,
				has_power = tNode.has_power or power_used and has_power or nil,
				start_node = power_used and start_node or nil,
				stop_node = power_used and stop_node or nil,
			})

			local tConsumer = {
				stage = stage,
				State = tState,
				-- number of items to be processed per cycle
				num_items = tNode.num_items and tNode.num_items[stage],
				power_consumption = power_used and 
				tNode.power_consumption[stage] or 0,
				node_timer = tNode.node_timer,
				cycle_time = tNode.cycle_time,
				power_netw = power_network,
			}

			local after_place_node = function(pos, placer, itemstack, pointed_thing)
				local crd = CRD(pos)
				local meta = M(pos)
				local nvm = techage.get_nvm(pos)
				local node = minetest.get_node(pos)
				meta:set_int("push_dir", techage.side_to_indir("L", node.param2))
				meta:set_int("pull_dir", techage.side_to_indir("R", node.param2))
				-- Delete existing node number. Needed for Digtron compatibility.
				if (meta:contains("node_number")) then
					meta:set_string("node_number", "")
				end
				local number = "-"
				if stage > 2 then
					number = techage.add_node(pos, name_pas)
				end
				if crd.power_netw then
					crd.power_netw:after_place_node(pos)
				end
				if tNode.after_place_node then
					tNode.after_place_node(pos, placer, itemstack, pointed_thing)
				end
				crd.State:node_init(pos, nvm, number)
			end

			local after_dig_node = function(pos, oldnode, oldmetadata, digger)
				if tNode.after_dig_node then
					tNode.after_dig_node(pos, oldnode, oldmetadata, digger)
				end
				local crd = CRDN(oldnode)
				if crd.power_netw then
					crd.power_netw:after_dig_node(pos)
				end
				techage.remove_node(pos, oldnode, oldmetadata)
				techage.del_mem(pos)
			end
			
			local tubelib2_on_update2 = function(pos, outdir, tlib2, node) 
				if tNode.tubelib2_on_update2 then
					tNode.tubelib2_on_update2(pos, outdir, tlib2, node)
				end
				if tlib2.tube_type == "pipe2" then
					liquid.update_network(pos, outdir, tlib2)
				else
					power.update_network(pos, outdir, tlib2)
				end
			end
			
			tNode.groups.not_in_creative_inventory = 0

			minetest.register_node(name_pas, {
				description = name_inv,
				tiles = prepare_tiles(tiles.pas, stage, power_png),
				consumer = tConsumer,
				drawtype = tNode.drawtype,
				node_box = tNode.node_box,
				selection_box = tNode.selection_box,

				can_dig = tNode.can_dig,
				on_rotate = tNode.on_rotate or screwdriver.disallow,
				on_timer = node_timer,
				on_receive_fields = tNode.on_receive_fields,
				on_rightclick = tNode.on_rightclick,
				after_place_node = after_place_node,
				after_dig_node = after_dig_node,
				preserve_metadata = tNode.preserve_metadata,
				tubelib2_on_update2 = tubelib2_on_update2,
				allow_metadata_inventory_put = tNode.allow_metadata_inventory_put,
				allow_metadata_inventory_move = tNode.allow_metadata_inventory_move,
				allow_metadata_inventory_take = tNode.allow_metadata_inventory_take,
				on_metadata_inventory_move = tNode.on_metadata_inventory_move,
				on_metadata_inventory_put = tNode.on_metadata_inventory_put,
				on_metadata_inventory_take = tNode.on_metadata_inventory_take,
				networks = tNetworks and table.copy(tNetworks),

				paramtype = tNode.paramtype,
				paramtype2 = "facedir",
				drop = tNode.drop,
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
				
				on_rotate = tNode.on_rotate or screwdriver.disallow,
				on_timer = node_timer,
				on_receive_fields = tNode.on_receive_fields,
				on_rightclick = tNode.on_rightclick,
				after_place_node = after_place_node,
				after_dig_node = after_dig_node,
				tubelib2_on_update2 = tubelib2_on_update2,
				allow_metadata_inventory_put = tNode.allow_metadata_inventory_put,
				allow_metadata_inventory_move = tNode.allow_metadata_inventory_move,
				allow_metadata_inventory_take = tNode.allow_metadata_inventory_take,
				on_metadata_inventory_move = tNode.on_metadata_inventory_move,
				on_metadata_inventory_put = tNode.on_metadata_inventory_put,
				on_metadata_inventory_take = tNode.on_metadata_inventory_take,
				networks = tNetworks and table.copy(tNetworks),

				paramtype = tNode.paramtype,
				paramtype2 = "facedir",
				drop = "",
				diggable = false,
				groups = table.copy(tNode.groups),
				is_ground_content = false,
				sounds = tNode.sounds,
			})

			if power_used then
				power_network:add_secondary_node_names({name_pas, name_act})
			end
			techage.register_node({name_pas, name_act}, tNode.tubing)
		end
	end
	return names[1], names[2], names[3]
end
