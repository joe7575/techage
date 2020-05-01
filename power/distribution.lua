--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Power Distribution

]]--

local N = function(pos) return techage.get_node_lvm(pos).name end
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local net_def = techage.networks.net_def

local STOPPED = techage.power.STOPPED
local NOPOWER = techage.power.NOPOWER
local RUNNING = techage.power.RUNNING

local function start_consumer(tbl, tlib_type)
	for _,v in pairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		local def = nvm[tlib_type] -- power related network data
		if def and def["cstate"] == NOPOWER and (def["calive"] or 0) > 0 then
			local ndef = net_def(v.pos, tlib_type)
			def["cstate"] = RUNNING
			def["taken"] = v.nominal or 0
			if ndef.on_power then
				ndef.on_power(v.pos, tlib_type)
			end
		end
	end
end

local function stop_consumer(tbl, tlib_type)
	for _,v in pairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		local def = nvm[tlib_type] -- power related network data
		local ndef = net_def(v.pos, tlib_type)
		if (def and def["cstate"] == RUNNING) or (ndef.is_running and ndef.is_running(v.pos, nvm)) then
			def["cstate"] = NOPOWER
			def["taken"] = 0
			if ndef.on_nopower then
				ndef.on_nopower(v.pos, tlib_type)
			end
		end
	end
end

local function get_generator_sum(tbl, tlib_type, cycle_time)
	local sum = 0
	for _,v in ipairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		local def = nvm[tlib_type] -- power related network data
		if def and def["gstate"] ~= STOPPED then
			def["galive"] = (def["galive"] or 1) - cycle_time/2
			if def["galive"] >= 0 then
				sum = sum + (def.curr_power or v.nominal)
			end
		end
	end
	return sum
end

local function get_consumer_sum(tbl, tlib_type, cycle_time)
	local sum = 0
	for _,v in ipairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		local def = nvm[tlib_type] -- power related network data
		if def and def["cstate"] ~= STOPPED then
			def["calive"] = (def["calive"] or 1) - cycle_time/2
			if def["calive"] >= 0 then
				sum = sum + v.nominal
			end
		end
		--print(N(v.pos), P2S(v.pos), def["cstate"], def["calive"])
	end
	return sum
end

local function set_given(pos, given, tlib_type)
	local nvm = techage.get_nvm(pos)
	local def = nvm[tlib_type] -- power related network data
	if (def and def["galive"] or 0) > 0 then
		if def.curr_power and def.curr_power < given then
			def["given"] = def.curr_power
		else
			def["given"] = given
		end
		return def["given"]
	end
	return 0
end

local function set_taken(pos, taken, tlib_type)
	local nvm = techage.get_nvm(pos)
	local def = nvm[tlib_type] -- power related network data
	if (def and def["calive"] or 0) > 0 then
		def["taken"] = taken
		def["cstate"] = RUNNING
		return taken
	end
	return 0
end

local function set_given_values(tbl, needed, tlib_type)
	for _,v in ipairs(tbl or {}) do
		local real = math.max(math.min(needed, v.nominal), 0)
		real = set_given(v.pos, real, tlib_type)
		needed = needed - real
	end
	return needed
end

local function set_taken_values(tbl, taken, tlib_type)
	for _,v in pairs(tbl or {}) do
		local real = math.max(math.min(taken, v.nominal), 0)
		real = set_taken(v.pos, real, tlib_type)
		taken = taken - real
	end
	return taken
end

function techage.power.power_distribution(network, tlib_type, netID, cycle_time)
	-- calc maximum power values
	network.available1 = get_generator_sum(network.gen1, tlib_type, cycle_time)
	network.available2 = get_generator_sum(network.gen2, tlib_type, cycle_time)
	network.needed1 = get_consumer_sum(network.con1, tlib_type, cycle_time)
	network.needed2 = get_consumer_sum(network.con2, tlib_type, cycle_time)
	--print(string.format("%X", netID), network.available1, network.available2, network.needed1, network.needed2)
	
	-- store results
	network.on = network.available1 + network.available2 >= network.needed1
	if network.on then
		network.ticker = (network.ticker or 0) + 1
		set_given_values(network.gen1, network.needed1 + network.needed2, tlib_type)
		set_given_values(network.gen2, network.needed1 - network.available1, tlib_type)
		start_consumer(network.con1, tlib_type)
		set_taken_values(network.con2, network.available1 - network.needed1, tlib_type)
	else
		set_given_values(network.gen1, 0, tlib_type)
		set_given_values(network.gen2, 0, tlib_type)
		stop_consumer(network.con1, tlib_type)
		set_taken_values(network.con2, 0, tlib_type)
	end
end
