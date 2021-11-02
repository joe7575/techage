--[[

	TechAge
	=======

	Copyright (C) 2019-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	For chests and tanks with hyperloop support

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local M = minetest.get_meta
local N = techage.get_node_lvm
local S = techage.S

-- Will be initialized when mods are loaded
local Stations = nil
local Tube = nil
local HYPERLOOP = nil

techage.hyperloop = {}

--[[

	tStations["(x,y,z)"] = {
		conn = {dir = "(200,0,20)", ...},
		name = <node_type>,   -- chest/tank
		owner = "singleplayer",
		conn_name = <own name>,
		single = true/nil,
	}

]]--

minetest.register_on_mods_loaded(function()
	if minetest.global_exists("hyperloop") then
		Stations = hyperloop.Stations
		Tube = hyperloop.Tube
		HYPERLOOP = true
		Tube:add_secondary_node_names({"techage:ta4_tank", "techage:chest_ta4"})
	else
		techage.hyperloop.WRENCH_MENU[2] = nil
		techage.hyperloop.WRENCH_MENU[1] = nil
	end
end)

local function get_remote_pos(pos, rmt_name)
	local owner = M(pos):get_string("owner")
	for key,item in pairs(Stations:get_node_table(pos)) do
		if item.owner == owner and item.conn_name == rmt_name then
			return S2P(key)
		end
	end
end

local function get_free_server_list(pos, owner)
	local tbl = {M(pos):get_string("remote_name")}
	for key,item in pairs(Stations:get_node_table(pos)) do
		if item.single and item.owner == owner then
			if M(pos):get_string("node_type") == M(S2P(key)):get_string("node_type") then
				tbl[#tbl+1] = item.conn_name
			end
		end
	end
	tbl[#tbl+1] = ""
	return tbl
end

local function on_dropdown(pos)
    local owner = M(pos):get_string("owner")
	return table.concat(get_free_server_list(pos, owner), ",")
end

local function update_node_data(pos, state, conn_name, remote_name, rmt_pos)
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	
	if state == "server_connected" then
		Stations:update(pos, {conn_name=conn_name, single="nil"})
		meta:set_string("conn_name", conn_name)
		meta:set_string("remote_name", "")
		nvm.conn_status = P2S(rmt_pos)
		nvm.rmt_pos = rmt_pos
	elseif state == "client_connected" then
		Stations:update(pos, {conn_name="nil", single="nil"})
		meta:set_string("conn_name", "")
		meta:set_string("remote_name", remote_name)
		nvm.conn_status = P2S(rmt_pos)
		nvm.rmt_pos = rmt_pos
	elseif state == "server_not_connected" then
		Stations:update(pos, {conn_name=conn_name, single=true})
		meta:set_string("conn_name", conn_name)
		meta:set_string("remote_name", "")
		nvm.conn_status = S("not connected")
		nvm.rmt_pos = nil
	elseif state == "client_not_connected" then
		Stations:update(pos, {conn_name="nil", single=nil})
		meta:set_string("conn_name", "")
		meta:set_string("remote_name", "")
		nvm.conn_status = S("not connected")
		nvm.rmt_pos = nil
	end
end

techage.hyperloop.WRENCH_MENU = {
	{
		type = "label",
		label = S("Provide 'own name' or select a 'remote name' (not both)"),
		tooltip = "",
		name = "l1",
	},
	{
		type = "ascii",
		name = "conn_name",
		label = S("Own name"),
		tooltip = S("Connection name for this block"),
		default = "",
	},
	{
		type = "dropdown",
		choices = "",
		on_dropdown = on_dropdown,
		name = "remote_name",
		label = S("Remote name"),      
		tooltip = S("Connection name of the remote block"),
	},
	{
		type = "output",
		name = "conn_status",
		label = S("Connected to"),
		tooltip = S("Connection status"),
		default = S("not connected"),
	},
}

function techage.hyperloop.is_client(pos)
	if HYPERLOOP then
		local nvm = techage.get_nvm(pos)
		if Stations:get(nvm.rmt_pos) then
			if M(pos):contains("remote_name") then
				return true
			end
		end
	end
end
	
function techage.hyperloop.is_server(pos)
	if HYPERLOOP then
		local nvm = techage.get_nvm(pos)
		if Stations:get(nvm.rmt_pos) then
			if M(pos):contains("conn_name") then
				return true
			end
		end
	end
end

function techage.hyperloop.remote_pos(pos)
	if HYPERLOOP then
		local nvm = techage.get_nvm(pos)
		if Stations:get(nvm.rmt_pos) then
			if M(pos):contains("remote_name") then
				return nvm.rmt_pos
			end
		end
	end
	return pos
end
	
function techage.hyperloop.after_place_node(pos, placer, node_type)
	if HYPERLOOP then
		Stations:set(pos, node_type, {owner=placer:get_player_name()})
		M(pos):set_string("node_type", node_type)
		Tube:after_place_node(pos)
	end
end	

function techage.hyperloop.after_dig_node(pos, oldnode, oldmetadata, digger)
	if HYPERLOOP then
		local conn_name = oldmetadata.fields.conn_name
		local remote_name = oldmetadata.fields.remote_name
		local loc_pos, rmt_pos = pos, techage.get_nvm(pos).rmt_pos
		
		-- Close connections
		if remote_name ~= "" and rmt_pos then -- Connected client
			update_node_data(rmt_pos, "server_not_connected", remote_name, "")
		elseif conn_name ~= "" and rmt_pos then -- Connected server
			update_node_data(rmt_pos, "client_not_connected", "", conn_name)
		end
		
		Tube:after_dig_node(pos)
		Stations:delete(pos)
	end
end

function techage.hyperloop.after_formspec(pos, fields, playername)
	if HYPERLOOP and fields.save then
		local meta = M(pos)
		local conn_name = meta:get_string("conn_name")
		local remote_name = meta:get_string("remote_name")
		local loc_pos, rmt_pos = pos, techage.get_nvm(pos).rmt_pos
		
		-- Close connections
		if remote_name ~= "" then -- Connected client
			update_node_data(loc_pos, "client_not_connected", "", remote_name)
			if rmt_pos then
				update_node_data(rmt_pos, "server_not_connected", remote_name, "")
			end
		elseif conn_name ~= "" and conn_name ~= fields.conn_name  then -- Connected server
			update_node_data(loc_pos, "server_not_connected", conn_name, "")
			if rmt_pos then
				update_node_data(rmt_pos, "client_not_connected", "", conn_name)
			end
		end
		
		if fields.remote_name ~= "" then -- Client
			local rmt_pos = get_remote_pos(pos, fields.remote_name)
			if rmt_pos then
				update_node_data(loc_pos, "client_connected", "", fields.remote_name, rmt_pos)
				update_node_data(rmt_pos, "server_connected", fields.remote_name, "", loc_pos)
			end
		elseif fields.conn_name ~= "" then -- Server
			update_node_data(loc_pos, "server_not_connected", fields.conn_name, "")
		end
	end
end

