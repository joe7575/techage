--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	Power distribution and consumption calculation
	for any kind of power distribution network

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
-- Techage Related Data
local PWR = function(pos) return (minetest.registered_nodes[minetest.get_node(pos).name] or {}).power end
local PWRN = function(node) return (minetest.registered_nodes[node.name] or {}).power end

-- Used to determine the already passed nodes while power distribution
local Route = {}

local function pos_already_reached(pos)
	local key = minetest.hash_node_position(pos)
	if not Route[key] then
		Route[key] = true
		return false
	end
	return true
end
	
local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}

local function side_to_dir(param2, side)
	local dir = SideToDir[side]
	if dir < 5 then
		dir = (((dir - 1) + (param2 % 4)) % 4) + 1
	end
	return dir
end

function techage.get_pos(pos, side)
	local node = minetest.get_node(pos)
	local dir = nil
	if node.name ~= "air" and node.name ~= "ignore" then
		dir = side_to_dir(node.param2, side)
	end
	return tubelib2.get_pos(pos, dir)
end	

local function set_conn_dirs(pos, sides)
	local tbl = {}
	local node = minetest.get_node(pos)
	for _,side in ipairs(sides) do
		tbl[#tbl+1] = tubelib2.Turn180Deg[side_to_dir(node.param2, side)]
	end
	M(pos):set_string("power_dirs", minetest.serialize(tbl))
end
		
local function valid_indir(pos, in_dir)
	local s = M(pos):get_string("power_dirs")
	if s == "" then
		local pwr = PWR(pos)
		if pwr then
			set_conn_dirs(pos, pwr.conn_sides)
		end
	end
	if s ~= "" then
		local tbl
		for _,dir in ipairs(minetest.deserialize(s)) do
			if dir == in_dir then
				return true
			end
		end
	end
	return false
end

local function valid_outdir(pos, out_dir)
	return valid_indir(pos, tubelib2.Turn180Deg[out_dir])
end

-- Both nodes are from the same power network type?
local function matching_nodes(pos, peer_pos)
	local tube_type1 = pos and PWR(pos) and PWR(pos).power_network.tube_type
	local tube_type2 = peer_pos and PWR(peer_pos) and PWR(peer_pos).power_network.tube_type
	return not tube_type1 or not tube_type2 or tube_type1 == tube_type2
end

local function get_clbk(pos, clbk_name)
	local pwr = PWR(pos)
	return pwr and pwr[clbk_name]
end
			
local function connection_walk(pos, clbk_name, sum)
	local clbk = get_clbk(pos, clbk_name)
	--print("connection_walk", S(pos), sum, clbk)
	if clbk then
		local mem = tubelib2.get_mem(pos)
		sum = sum - (clbk(pos, mem, sum) or 0)
	end
	local mem = tubelib2.get_mem(pos)
	for _,item in pairs(mem.connections or {}) do
		if item.pos and not pos_already_reached(item.pos) then
			sum = connection_walk(item.pos, clbk_name, sum)
		end
	end
	return sum
end

-- Start the overall power consumption and depending on that 
-- turn nodes on/off
local function power_distribution(pos)
	local sum = 0
	Route = {}
	pos_already_reached(pos) 
	sum = connection_walk(pos, "on_power_pass1", sum)
	Route = {}
	pos_already_reached(pos) 
	sum = connection_walk(pos, "on_power_pass2", sum)
	Route = {}
	pos_already_reached(pos) 
	sum = connection_walk(pos, "on_power_pass3", sum)
	print("power sum = "..sum)
end

local function register_lbm(name)
	minetest.register_lbm({
		label = "[TechAge] Node update",
		nodenames = {name},
		name = name.."_update",
		run_at_every_load = true,
		action = function(pos, node)
			local pwr = PWRN(node)
			-- repair power_dirs
			if pwr and pwr.conn_sides and M(pos):get_string("power_dirs") == "" then
				set_conn_dirs(pos, pwr.conn_sides)
			end
		end
	})
end

--
-- Generic API functions
--
techage.power = {}

techage.power.power_distribution = power_distribution

function techage.power.register_node(names, pwr_def)
	for _,name in ipairs(names) do
		local ndef = minetest.registered_nodes[name]
		if ndef then
			minetest.override_item(name, {
				power = {
					on_power_pass1 = pwr_def.on_power_pass1,
					on_power_pass2 = pwr_def.on_power_pass2,
					on_power_pass3 = pwr_def.on_power_pass3,
					conn_sides = pwr_def.conn_sides or {"L", "R", "U", "D", "F", "B"},
					power_network = pwr_def.power_network,
					after_place_node = ndef.after_place_node,
					after_dig_node = ndef.after_dig_node,
					after_tube_update = ndef.after_tube_update,
				},
				-- after_place_node decorator
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					local pwr = PWR(pos)
					set_conn_dirs(pos, pwr.conn_sides)
					pwr.power_network:after_place_node(pos)
					if pwr.after_place_node then
						return pwr.after_place_node(pos, placer, itemstack, pointed_thing)
					end
				end,
				-- after_dig_node decorator
				after_dig_node = function(pos, oldnode, oldmetadata, digger)
					local pwr = PWRN(oldnode)
					pwr.power_network:after_dig_node(pos)
					minetest.after(0.1, tubelib2.del_mem, pos)  -- At latest...
					if pwr.after_dig_node then
						return pwr.after_dig_node(pos, oldnode, oldmetadata, digger)
					end
				end,
				-- tubelib2 callback, called after any connection change
				after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
					local pwr = PWR(pos)
					local mem = tubelib2.get_mem(pos)
					mem.connections = mem.connections or {}
					if not peer_pos or not valid_indir(peer_pos, peer_in_dir)
							or not valid_outdir(pos, out_dir)
							or not matching_nodes(pos, peer_pos) then
						mem.connections[out_dir] = nil -- del connection
					else
						mem.connections[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}
					end
					-- To be called delayed, so that all network connections have been established
					minetest.after(0.2, power_distribution, pos)
					if pwr.after_tube_update then
						return pwr.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
					end
				end,
			})
			pwr_def.power_network:add_secondary_node_names({name})
			register_lbm(name)
		end
	end
end		

function techage.power.percent(max_val, curr_val)
	return math.min(math.ceil(((curr_val or 0) * 100.0) / (max_val or 1.0)), 100)
end

function techage.power.formspec_power_bar(max_power, current_power)
	local percent = techage.power.percent(max_power, current_power)
	return "techage_form_level_bg.png^[lowpart:"..percent..":techage_form_level_fg.png"
end

-- charging is true, false, or nil if turned off
function techage.power.formspec_load_bar(charging)
	if charging ~= nil then
		if charging then
			return "techage_form_level_charge.png"
		else
			return "techage_form_level_unload.png"
		end
	end
	return "techage_form_level_off.png"
end
