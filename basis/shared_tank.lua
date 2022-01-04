--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Library for shared inventories

]]--

-- for lazy programmers
local M = minetest.get_meta
local NDEF = function(pos) return minetest.registered_nodes[techage.get_node_lvm(pos).name] or {} end

techage.shared_tank = {}

local liquid = networks.liquid
local hyperloop = techage.hyperloop
local remote_pos = techage.hyperloop.remote_pos
local is_paired = techage.hyperloop.is_paired
local menu = techage.menu

local function formspec(pos)
	local ndef = NDEF(pos)
	local status = M(pos):get_string("conn_status")
	if hyperloop.is_client(pos) or hyperloop.is_server(pos) then
		local title = ndef.description .. " " .. status
		local nvm = techage.get_nvm(remote_pos(pos))
		return techage.liquid.formspec(pos, nvm, title)
	else
		return menu.generate_formspec(pos, ndef, hyperloop.SUBMENU)
	end
end

function techage.shared_tank.node_timer(pos)
	if techage.is_activeformspec(pos) and is_paired(pos) then
		M(pos):set_string("formspec", formspec(pos))
		return true
	end
	return false
end

function techage.shared_tank.on_rightclick(pos, node, clicker)
	--if hyperloop.is_client(pos) then
		techage.set_activeformspec(pos, clicker)
		minetest.get_node_timer(pos):start(2)
	--end
	M(pos):set_string("formspec", formspec(pos))
end

function techage.shared_tank.can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	pos = remote_pos(pos)
	return techage.liquid.is_empty(pos)
end

function techage.shared_tank.peek_liquid(pos, indir)
	if is_paired(pos) then
		pos = remote_pos(pos)
		local nvm = techage.get_nvm(pos)
		return liquid.srv_peek(nvm)
	end
end

function techage.shared_tank.take_liquid(pos, indir, name, amount)
	if is_paired(pos) then
		pos = remote_pos(pos)
		local nvm = techage.get_nvm(pos)
		amount, name = liquid.srv_take(nvm, name, amount)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return amount, name
	end
	return 0, name
end

function techage.shared_tank.put_liquid(pos, indir, name, amount)
	if is_paired(pos) then
		pos = remote_pos(pos)
		-- check if it is not powder
		local ndef = minetest.registered_craftitems[name] or {}
		if not ndef.groups or ndef.groups.powder ~= 1 then
			local nvm = techage.get_nvm(pos)
			local ndef = NDEF(pos)
			local leftover = liquid.srv_put(nvm, name, amount, ndef.liquid.capa)
			if techage.is_activeformspec(pos) then
				M(pos):set_string("formspec", formspec(pos))
			end
			return leftover
		end
	end
	return amount
end

function techage.shared_tank.untake_liquid(pos, indir, name, amount)
	if is_paired(pos) then
		pos = remote_pos(pos)
		local nvm = techage.get_nvm(pos)
		local ndef = NDEF(pos)
		local leftover = liquid.srv_put(nvm, name, amount, ndef.liquid.capa)
		if techage.is_activeformspec(pos) then
			M(pos):set_string("formspec", formspec(pos))
		end
		return leftover
	end
	return amount
end

techage.shared_tank.formspec = formspec
