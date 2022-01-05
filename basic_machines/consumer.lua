--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Consumer node basis functionality.
	It handles:
	- up to 4 stages of nodes (TA2/TA3/TA4/TA5)
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

local Tube = techage.Tube
local power = networks.power
local liquid = networks.liquid
local CYCLE_TIME = 2

local function get_keys(tbl)
	local keys = {}
	for k,v in pairs(tbl) do
		keys[#keys + 1] = k
	end
	return keys
end

local function has_power(pos, nvm, state)
	local crd = CRD(pos)
	return power.power_available(pos, crd.power_netw)
end

local function start_node(pos, nvm, state)
end

local function stop_node(pos, nvm, state)
end

local function node_timer_pas(pos, elapsed)
	local crd = CRD(pos)
	local nvm = techage.get_nvm(pos)

	-- handle power consumption
	if crd.power_netw and techage.needs_power(nvm) then
		local consumed = power.consume_power(pos, crd.power_netw, nil, crd.power_consumption)
		if consumed == crd.power_consumption then
			crd.State:start(pos, nvm)
		end
	end

		-- call the node timer routine
	if techage.is_operational(nvm) then
		nvm.node_timer_call_cyle = (nvm.node_timer_call_cyle or 0) + 1
		if nvm.node_timer_call_cyle >= crd.call_cycle then
			crd.node_timer(pos, crd.cycle_time)
			nvm.node_timer_call_cyle = 0
		end
	end
	return crd.State:is_active(nvm)
end

local function node_timer_act(pos, elapsed)
	local crd = CRD(pos)
	local nvm = techage.get_nvm(pos)

	-- handle power consumption
	if crd.power_netw and techage.needs_power(nvm) then
		local consumed = power.consume_power(pos, crd.power_netw, nil, crd.power_consumption)
		if consumed < crd.power_consumption then
			crd.State:nopower(pos, nvm)
		end
	end

	-- call the node timer routine
	if techage.is_operational(nvm) then
		nvm.node_timer_call_cyle = (nvm.node_timer_call_cyle or 0) + 1
		if nvm.node_timer_call_cyle >= crd.call_cycle then
			crd.node_timer(pos, crd.cycle_time)
			nvm.node_timer_call_cyle = 0
		end
	end
	return crd.State:is_active(nvm)
end

local function prepare_tiles(tiles, stage, power_png)
	local tbl = {}
	for _,item in ipairs(tiles) do
		if type(item) == "string" then
			tbl[#tbl+1] = item:gsub("#", stage):gsub("{power}", power_png):gsub("@@", '#')
		else
			local temp = table.copy(item)
			temp.image = temp.image:gsub("#", stage):gsub("{power}", power_png):gsub("@@", '#')
			tbl[#tbl+1] = temp
		end
	end
	return tbl
end

-- 'validStates' is optional and can be used to e.g. enable
-- only one TA2 node {false, true, false, false}
function techage.register_consumer(base_name, inv_name, tiles, tNode, validStates, node_name_prefix)
	local names = {}
	validStates = validStates or {true, true, true, true}
	if not node_name_prefix then
		node_name_prefix = "techage:ta"
	end
	for stage = 2,5 do
		local name_pas = node_name_prefix..stage.."_"..base_name.."_pas"
		local name_act = node_name_prefix..stage.."_"..base_name.."_act"
		local name_inv = "TA"..stage.." "..inv_name
		names[#names+1] = name_pas

		if validStates[stage] then
			local power_network
			local power_png = 'techage_axle_clutch.png'
			local power_used = tNode.power_consumption ~= nil
			local sides
			-- power needed?
			if power_used then
				if stage > 2 then
					power_network = techage.ElectricCable
					power_png = 'techage_appl_hole_electric.png'
					sides = get_keys(tNode.power_sides or {F=1, B=1, U=1, D=1})
				else
					power_network = techage.Axle
					power_png = 'techage_axle_clutch.png'
					sides = get_keys(tNode.power_sides or {F=1, B=1, U=1, D=1})
				end
			end

			local tState = techage.NodeStates:new({
				node_name_passive = name_pas,
				node_name_active = name_act,
				infotext_name = name_inv,
				cycle_time = CYCLE_TIME,
				standby_ticks = tNode.standby_ticks,
				formspec_func = tNode.formspec,
				on_state_change = tNode.on_state_change,
				can_start = tNode.can_start,
				quick_start = tNode.quick_start,
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
				call_cycle = tNode.cycle_time / 2,
				power_netw = power_network,
			}

			local after_place_node = function(pos, placer, itemstack, pointed_thing)
				local crd = CRD(pos)
				local meta = M(pos)
				local nvm = techage.get_nvm(pos)
				local node = minetest.get_node(pos)
				meta:set_int("push_dir", techage.side_to_indir("L", node.param2))
				meta:set_int("pull_dir", techage.side_to_indir("R", node.param2))
				meta:set_string("owner", placer:get_player_name())
				-- Delete existing node number. Needed for Digtron compatibility.
				if (meta:contains("node_number")) then
					meta:set_string("node_number", "")
				end
				local number = techage.add_node(pos, name_pas, stage == 2)
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

			tNode.groups.not_in_creative_inventory = 0

			local def_pas = {
				description = name_inv,
				tiles = prepare_tiles(tiles.pas, stage, power_png),
				consumer = tConsumer,
				drawtype = tNode.drawtype,
				node_box = tNode.node_box,
				selection_box = tNode.selection_box,

				can_dig = tNode.can_dig,
				on_rotate = tNode.on_rotate or screwdriver.disallow,
				on_timer = node_timer_pas,
				on_receive_fields = tNode.on_receive_fields,
				on_rightclick = tNode.on_rightclick,
				after_place_node = after_place_node,
				after_dig_node = after_dig_node,
				preserve_metadata = tNode.preserve_metadata,
				allow_metadata_inventory_put = tNode.allow_metadata_inventory_put,
				allow_metadata_inventory_move = tNode.allow_metadata_inventory_move,
				allow_metadata_inventory_take = tNode.allow_metadata_inventory_take,
				on_metadata_inventory_move = tNode.on_metadata_inventory_move,
				on_metadata_inventory_put = tNode.on_metadata_inventory_put,
				on_metadata_inventory_take = tNode.on_metadata_inventory_take,
				ta_rotate_node = tNode.ta_rotate_node,

				paramtype = tNode.paramtype,
				paramtype2 = "facedir",
				drop = tNode.drop,
				groups = table.copy(tNode.groups),
				is_ground_content = false,
				sounds = tNode.sounds,
			}

			-- Copy custom properties (starting with an underscore)
			for k,v in pairs(tNode) do
				if string.sub(k, 1, 1) == "_" then
					def_pas[k] = v
				end
			end

			minetest.register_node(name_pas, def_pas)

			tNode.groups.not_in_creative_inventory = 1

			local def_act = {
				description = name_inv,
				tiles = prepare_tiles(tiles.act, stage, power_png),
				consumer = tConsumer,
				drawtype = tNode.drawtype,
				node_box = tNode.node_box,
				selection_box = tNode.selection_box,

				on_rotate = tNode.on_rotate or screwdriver.disallow,
				on_timer = node_timer_act,
				on_receive_fields = tNode.on_receive_fields,
				on_rightclick = tNode.on_rightclick,
				after_place_node = after_place_node,
				after_dig_node = after_dig_node,
				allow_metadata_inventory_put = tNode.allow_metadata_inventory_put,
				allow_metadata_inventory_move = tNode.allow_metadata_inventory_move,
				allow_metadata_inventory_take = tNode.allow_metadata_inventory_take,
				on_metadata_inventory_move = tNode.on_metadata_inventory_move,
				on_metadata_inventory_put = tNode.on_metadata_inventory_put,
				on_metadata_inventory_take = tNode.on_metadata_inventory_take,
				ta_rotate_node = tNode.ta_rotate_node,

				paramtype = tNode.paramtype,
				paramtype2 = "facedir",
				drop = "",
				diggable = false,
				groups = table.copy(tNode.groups),
				is_ground_content = false,
				sounds = tNode.sounds,
			}

			-- Copy custom properties (starting with an underscore)
			for k,v in pairs(tNode) do
				if string.sub(k, 1, 1) == "_" then
					def_act[k] = v
				end
			end

			minetest.register_node(name_act, def_act)

			if power_used then
				power.register_nodes({name_pas, name_act}, power_network, "con", sides)
			end
			techage.register_node({name_pas, name_act}, tNode.tubing)

			if tNode.tube_sides then
				Tube:set_valid_sides(name_pas, get_keys(tNode.tube_sides))
				Tube:set_valid_sides(name_act, get_keys(tNode.tube_sides))
			end
		end
	end
	return names[1], names[2], names[3], names[4]
end
