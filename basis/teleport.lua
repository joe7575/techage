--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	For tupe/pipe blocks with teleport support

]]--

-- for lazy programmers
local S2P = minetest.string_to_pos
local P2S = minetest.pos_to_string
local NDEF = function(pos) return minetest.registered_nodes[techage.get_node_lvm(pos).name] or {} end
local M = minetest.get_meta
local S = techage.S
local menu = techage.menu

techage.teleport = {}

local PairingList = {}  -- {owner = {node_type = {channel = pos}}}

local function get_pairing_table1(meta)
    local owner = meta:get_string("owner")
    local node_type = meta:get_string("tele_node_type")
	PairingList[owner] = PairingList[owner] or {}
	PairingList[owner][node_type] = PairingList[owner][node_type] or {}
	return PairingList[owner][node_type]
end

local function get_pairing_table2(oldmetadata)
    local owner = oldmetadata.fields.owner
    local node_type = oldmetadata.fields.tele_node_type
	PairingList[owner] = PairingList[owner] or {}
	PairingList[owner][node_type] = PairingList[owner][node_type] or {}
	return PairingList[owner][node_type]
end

local function get_free_server_list(pos)
	local tbl = {""}
	for name, pos in pairs(get_pairing_table1(M(pos))) do
		table.insert(tbl, name)
	end
	return table.concat(tbl, ",")
end

local TELE_MENU = {
	{
		type = "label",
		label = S("Enter a block name or select an existing one"),
		tooltip = "",
		name = "l1",
	},
	{
		type = "ascii",
		name = "conn_name",
		label = S("Block name"),
		tooltip = S("Connection name for this block"),
		default = "",
	},
	{
		type = "dropdown",
		choices = "",
		on_dropdown = get_free_server_list,
		name = "remote_name",
		label = S("Remote name"),
		tooltip = S("Connection name of the remote block"),
	},
	{
		type = "output",
		label = S("Status"),
		tooltip = S("Connection status"),
		name = "status",
		default = "",
	},
}

function techage.teleport.formspec(pos)
	local ndef = NDEF(pos)
	return menu.generate_formspec(pos, ndef, TELE_MENU)
end

local function store_connection(pos, peer_pos)
	local meta = M(pos)
	local status = S("connected to") .. " " .. P2S(peer_pos)
	meta:set_string("tele_status", status)
	meta:set_string("tele_peer_pos", P2S(peer_pos))
	meta:set_string("formspec", "")
end

function techage.teleport.prepare_pairing(pos, node_type, status)
	local meta = M(pos)
	if node_type then
		meta:set_string("tele_node_type", node_type)
	end
	status = status or S("not connected")
	meta:set_string("tele_status", status)
	meta:set_string("tele_peer_pos", "")
	meta:set_string("formspec", techage.teleport.formspec(pos))
end

function techage.teleport.stop_pairing(pos, oldmetadata)
	-- disconnect peer node
	if oldmetadata and oldmetadata.fields then
		if oldmetadata.fields.tele_peer_pos then
			local peer_pos = S2P(oldmetadata.fields.tele_peer_pos)
			local meta = M(peer_pos)
			if meta:get_string("conn_name") ~= "" then -- Server
				local tbl = get_pairing_table1(meta)
				tbl[meta:get_string("conn_name")] = peer_pos
				techage.teleport.prepare_pairing(peer_pos, nil, S("server not connected"))
			else
				techage.teleport.prepare_pairing(peer_pos)
			end
		elseif oldmetadata.fields.conn_name then
			local tbl = get_pairing_table2(oldmetadata)
			tbl[oldmetadata.fields.conn_name] = nil
		end
	end
end

function techage.teleport.is_connected(pos)
	return M(pos):get_string("tele_peer_pos") ~= ""
end

function techage.teleport.get_remote_pos(pos)
	local s = M(pos):get_string("tele_peer_pos")
	if s ~= "" then
		return S2P(s)
	end
end

function techage.teleport.after_formspec(pos, player, fields, max_dist, ex_points)
	if techage.get_expoints(player) >= ex_points then
		if techage.menu.eval_input(pos, TELE_MENU, fields) then
			if not techage.teleport.is_connected(pos) then
				local meta = M(pos)
				if fields.remote_name ~= "" then -- Client
					local tbl = get_pairing_table1(meta)
					local peer_pos = tbl[fields.remote_name]
					if peer_pos then
						if vector.distance(pos, peer_pos) <= max_dist then
							tbl[fields.remote_name] = nil
							store_connection(pos, peer_pos)
							store_connection(peer_pos, pos)
							M(pos):set_string("status", S("Connected"))
						else
							M(pos):set_string("status", S("Distance > @1 blocks", max_dist))
							meta:set_string("formspec", techage.teleport.formspec(pos))
						end
					end
				elseif fields.conn_name ~= "" then -- Server
					local tbl = get_pairing_table1(meta)
					tbl[fields.conn_name] = pos
					techage.teleport.prepare_pairing(pos, nil, S("server not connected"))
				end
			end
		end
	else
		M(pos):set_string("status", S("Ex-points missing (@1 < @2)", techage.get_expoints(player), ex_points))
		M(pos):set_string("formspec", techage.teleport.formspec(pos))
	end
end
