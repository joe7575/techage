--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Power helper functions
]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local P = minetest.string_to_pos
local M = minetest.get_meta
local N = function(pos) return minetest.get_node(pos).name end
-- Techage Related Data
local PWR = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).power end
local PWRN = function(node) return (minetest.registered_nodes[node.name] or {}).power end
		
local network_changed = techage.power.network_changed		
		
local SideToDir = {B=1, R=2, F=3, L=4, D=5, U=6}

local function side_to_dir(param2, side)
	local dir = SideToDir[side]
	if dir < 5 then
		dir = (((dir - 1) + (param2 % 4)) % 4) + 1
	end
	return dir
end

local function set_conn_dirs(pos, sides)
	local tbl = {}
	local node = minetest.get_node(pos)
	if type(sides) == "function" then
		tbl = sides(pos, node)
	else
		for _,side in ipairs(sides) do
			tbl[#tbl+1] = tubelib2.Turn180Deg[side_to_dir(node.param2, side)]
		end
	end
	M(pos):set_string("power_dirs", minetest.serialize(tbl))
end

techage.power.side_to_dir = side_to_dir
techage.power.set_conn_dirs = set_conn_dirs

local function valid_indir(pos, in_dir)
	local s = M(pos):get_string("power_dirs")
	if s == "" then
		local pwr = PWR(pos)
		if pwr then
			set_conn_dirs(pos, pwr.conn_sides)
		end
	end
	if s ~= "" then
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

function techage.get_pos(pos, side)
	local node = techage.get_node_lvm(pos)
	local dir = nil
	if node.name ~= "air" and node.name ~= "ignore" then
		dir = side_to_dir(node.param2, side)
	end
	return tubelib2.get_pos(pos, dir)
end	

-- only for nodes with own 'conn_sides' and rotate function
function techage.power.after_rotate_node(pos, cable)
	cable:after_dig_node(pos)
	set_conn_dirs(pos, PWR(pos).conn_sides)
	cable:after_place_node(pos)
end

local function add_connection(mem, pos, out_dir, peer_pos, peer_in_dir, power)
	mem.connections = mem.connections or {}
    if not peer_pos or not valid_indir(peer_pos, peer_in_dir)
			or not valid_outdir(pos, out_dir)
			or not matching_nodes(pos, peer_pos) then
		mem.connections[out_dir] = nil -- del connection
	else
		mem.connections[out_dir] = {pos = peer_pos, in_dir = peer_in_dir}
	end
end

function techage.power.register_node(names, pwr_def)
	for _,name in ipairs(names) do
		local ndef = minetest.registered_nodes[name]
		if ndef then
			minetest.override_item(name, {
				power = {
					conn_sides = pwr_def.conn_sides or {"L", "R", "U", "D", "F", "B"},
					on_power = pwr_def.on_power,
					on_nopower = pwr_def.on_nopower,
					on_getpower = pwr_def.on_getpower,
					power_network = pwr_def.power_network,
					after_place_node = pwr_def.after_place_node,
					after_dig_node = pwr_def.after_dig_node,
					after_tube_update = pwr_def.after_tube_update,
				},
				-- after_place_node decorator
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					local res
					local pwr = PWR(pos)
					set_conn_dirs(pos, pwr.conn_sides)
					if pwr.after_place_node then
						res = pwr.after_place_node(pos, placer, itemstack, pointed_thing)
					end
					pwr.power_network:after_place_node(pos)
					return res
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
				-- tubelib2->Cable:register_on_tube_update callback, called after any connection change
				after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
					local pwr = PWR(pos)
					local mem = tubelib2.get_mem(pos)
					add_connection(mem, pos, out_dir, peer_pos, peer_in_dir, pwr)
					if pwr.after_tube_update then
						return pwr.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
					end
				end,
			})
			pwr_def.power_network:add_secondary_node_names({name})
		end
	end
end		


--
-- API function set for nodes, which don't (what to) call techage.power.register_node()
--
function techage.power.enrich_node(names, pwr_def)
	for _,name in ipairs(names) do
		minetest.override_item(name, {
			power = {
				conn_sides = pwr_def.conn_sides or {"L", "R", "U", "D", "F", "B"},
				on_power = pwr_def.on_power,
				on_nopower = pwr_def.on_nopower,
				on_getpower = pwr_def.on_getpower,
				power_network = pwr_def.power_network,
			}
		})
		pwr_def.power_network:add_secondary_node_names({name})
	end
end
			
function techage.power.after_place_node(pos)
	local pwr = PWR(pos)
	set_conn_dirs(pos, pwr.conn_sides)
	pwr.power_network:after_place_node(pos)
end

function techage.power.after_dig_node(pos, oldnode)
	local pwr = PWRN(oldnode)
	pwr.power_network:after_dig_node(pos)
end

function techage.power.after_tube_update2(node, pos, out_dir, peer_pos, peer_in_dir)
	local pwr = PWR(pos)
	local mem = tubelib2.get_mem(pos)
	add_connection(mem, pos, out_dir, peer_pos, peer_in_dir, pwr)
end

--
-- Further helper functions
-- 

-- Called from tubelib2 via Cable:register_on_tube_update()
-- For all kind of nodes, used as cable filler/grout
function techage.power.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir, power)
	local mem = tubelib2.get_mem(pos)
	add_connection(mem, pos, out_dir, peer_pos, peer_in_dir, power)
	if power.after_tube_update then
		return power.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
	end
end

function techage.power.percent(max_val, curr_val)
	return math.min(math.ceil(((curr_val or 0) * 100.0) / (max_val or 1.0)), 100)
end

function techage.power.formspec_load_bar(charging, max_val)
	local percent
	charging = charging or 0
	max_val = max_val or 1
	if charging ~= 0 then
		percent = 50 + math.ceil((charging * 50.0) / max_val)
	end

	if charging > 0 then
		return "techage_form_level_off.png^[lowpart:"..percent..":techage_form_level_charge.png"
	elseif charging < 0 then
		return "techage_form_level_unload.png^[lowpart:"..percent..":techage_form_level_off.png"
	else
		return "techage_form_level_off.png"
	end
end

function techage.power.formspec_power_bar(max_power, current_power)
	if (current_power or 0) == 0 then
		return "techage_form_level_bg.png"
	end
	local percent = techage.power.percent(max_power, current_power)
	percent = (percent + 5) / 1.22  -- texture correction
	return "techage_form_level_bg.png^[lowpart:"..percent..":techage_form_level_fg.png"
end


function techage.power.side_to_outdir(pos, side)
	local node = techage.get_node_lvm(pos)
	return side_to_dir(node.param2, side)
end	

-- Used to turn on/off the power by means of a power switch
function techage.power.power_cut(pos, dir, cable, cut)
	local npos = vector.add(pos, tubelib2.Dir6dToVector[dir or 0])
	
	local node = techage.get_node_lvm(npos)
	if node.name ~= "techage:powerswitch_box" and
			M(npos):get_string("techage_hidden_nodename") ~= "techage:powerswitch_box" then
		return
	end
	
	local mem = tubelib2.get_mem(npos)
	mem.interrupted_dirs = mem.interrupted_dirs or {}
	
	if cut then
		mem.interrupted_dirs = {true, true, true, true, true, true}
		for dir,_ in pairs(mem.connections) do
			mem.interrupted_dirs[dir] = false -- open the port
			techage.power.network_changed(npos, mem)
			mem.interrupted_dirs[dir] = true
		end
	else
		mem.interrupted_dirs = {}
		techage.power.network_changed(npos, mem)
	end
end

